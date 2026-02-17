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

@end
