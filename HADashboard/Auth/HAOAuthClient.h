#import <Foundation/Foundation.h>

@interface HAOAuthClient : NSObject

- (instancetype)initWithServerURL:(NSString *)serverURL;

/// Steps 1+2: Start login flow, then submit credentials.
/// Returns an authorization code on success.
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(void (^)(NSString *authCode, NSError *error))completion;

/// Step 3: Exchange authorization code for access + refresh tokens.
/// Returns dict with keys: access_token, refresh_token, expires_in, token_type.
- (void)exchangeAuthCode:(NSString *)authCode
               completion:(void (^)(NSDictionary *tokenResponse, NSError *error))completion;

/// Refresh an expired access token using a refresh token.
/// Returns dict with keys: access_token, expires_in, token_type.
- (void)refreshWithToken:(NSString *)refreshToken
              completion:(void (^)(NSDictionary *tokenResponse, NSError *error))completion;

/// Fetch available auth providers for this client IP.
/// Returns an array of provider dicts, each with "type", "name", "id" keys.
/// The trusted_networks provider only appears when the client IP is on a trusted network.
- (void)fetchAuthProviders:(void (^)(NSArray *providers, NSError *error))completion;

/// Login via trusted networks auth provider.
/// Starts a login_flow with the trusted_networks handler.
/// On success, calls completion with an auth code (exchange via exchangeAuthCode:).
/// If multiple users are available, calls completion with usersOrNil containing
/// a mapping of user IDs to display names, plus the flow_id to continue with.
/// Call again with a specific userId and flowId to complete the login.
- (void)loginWithTrustedNetworkUser:(NSString *)userId
                             flowId:(NSString *)flowId
                         completion:(void (^)(NSString *authCode,
                                              NSDictionary *usersOrNil,
                                              NSString *flowIdOrNil,
                                              NSError *error))completion;

@end
