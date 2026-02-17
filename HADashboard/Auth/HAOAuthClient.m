#import "HAOAuthClient.h"
#import "HAAuthManager.h"

static NSString *const kClientId = @"https://hadashboard.local/";
static NSString *const kRedirectURI = @"https://hadashboard.local/";

@interface HAOAuthClient ()
@property (nonatomic, copy) NSString *serverURL;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation HAOAuthClient

- (instancetype)initWithServerURL:(NSString *)serverURL {
    self = [super init];
    if (self) {
        _serverURL = [[HAAuthManager normalizedURL:serverURL] copy];

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 15.0;
        config.timeoutIntervalForResource = 30.0;
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

#pragma mark - Login Flow

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(void (^)(NSString *authCode, NSError *error))completion {
    // Step 1: Initiate login flow
    NSURL *flowURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/login_flow", self.serverURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:flowURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *body = @{
        @"client_id": kClientId,
        @"handler": @[@"homeassistant", [NSNull null]],
        @"redirect_uri": kRedirectURI,
    };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
                return;
            }

            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            NSDictionary *result = [self parseJSONData:data];

            if (httpResp.statusCode != 200 || !result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, [self errorWithMessage:@"Failed to start login flow" code:httpResp.statusCode]);
                });
                return;
            }

            NSString *flowId = result[@"flow_id"];
            if (!flowId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, [self errorWithMessage:@"No flow_id in response" code:0]);
                });
                return;
            }

            // Step 2: Submit credentials
            [weakSelf submitCredentials:username password:password flowId:flowId completion:completion];
        }];
    [task resume];
}

- (void)submitCredentials:(NSString *)username
                 password:(NSString *)password
                   flowId:(NSString *)flowId
               completion:(void (^)(NSString *authCode, NSError *error))completion {
    NSURL *submitURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/login_flow/%@", self.serverURL, flowId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:submitURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *body = @{
        @"username": username,
        @"password": password,
        @"client_id": kClientId,
    };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
                return;
            }

            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            NSDictionary *result = [self parseJSONData:data];

            if (httpResp.statusCode != 200 || !result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, [self errorWithMessage:@"Login failed — check username/password" code:httpResp.statusCode]);
                });
                return;
            }

            // Check for errors in the flow response
            NSString *stepType = result[@"type"];
            if ([stepType isEqualToString:@"form"]) {
                // Still on a form step — means credentials were wrong
                NSArray *errors = result[@"errors"];
                NSString *errMsg = @"Invalid username or password";
                if ([errors isKindOfClass:[NSDictionary class]]) {
                    NSString *baseErr = ((NSDictionary *)errors)[@"base"];
                    if (baseErr) errMsg = baseErr;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, [self errorWithMessage:errMsg code:401]);
                });
                return;
            }

            if ([stepType isEqualToString:@"create_entry"]) {
                // Success — extract the auth code from the result
                NSString *authCode = result[@"result"];
                if (authCode) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(authCode, nil);
                    });
                    return;
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, [self errorWithMessage:@"Unexpected login response" code:0]);
            });
        }];
    [task resume];
}

#pragma mark - Token Exchange

- (void)exchangeAuthCode:(NSString *)authCode
               completion:(void (^)(NSDictionary *tokenResponse, NSError *error))completion {
    [self postTokenEndpointWithBody:[NSString stringWithFormat:
        @"grant_type=authorization_code&code=%@&client_id=%@",
        [self urlEncode:authCode], [self urlEncode:kClientId]]
                        completion:completion];
}

- (void)refreshWithToken:(NSString *)refreshToken
              completion:(void (^)(NSDictionary *tokenResponse, NSError *error))completion {
    [self postTokenEndpointWithBody:[NSString stringWithFormat:
        @"grant_type=refresh_token&refresh_token=%@&client_id=%@",
        [self urlEncode:refreshToken], [self urlEncode:kClientId]]
                        completion:completion];
}

#pragma mark - Internal

- (void)postTokenEndpointWithBody:(NSString *)formBody
                       completion:(void (^)(NSDictionary *tokenResponse, NSError *error))completion {
    NSURL *tokenURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/token", self.serverURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tokenURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [formBody dataUsingEncoding:NSUTF8StringEncoding];

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
                return;
            }

            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            NSDictionary *result = [self parseJSONData:data];

            if (httpResp.statusCode != 200 || !result) {
                NSString *errMsg = result[@"error_description"] ?: @"Token exchange failed";
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, [self errorWithMessage:errMsg code:httpResp.statusCode]);
                });
                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result, nil);
            });
        }];
    [task resume];
}

- (NSDictionary *)parseJSONData:(NSData *)data {
    if (!data || data.length == 0) return nil;
    id parsed = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [parsed isKindOfClass:[NSDictionary class]] ? parsed : nil;
}

- (NSString *)urlEncode:(NSString *)string {
    return [string stringByAddingPercentEncodingWithAllowedCharacters:
        [NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code {
    return [NSError errorWithDomain:@"HAOAuthClient"
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
