#import <XCTest/XCTest.h>
#import "HAAuthManager.h"

/// Tests for HAAuthManager token refresh queueing.
///
/// Validates that concurrent callers of refreshAccessTokenWithCompletion:
/// all receive the result when the single refresh completes, rather than
/// the second caller being silently dropped with completion(NO, nil).
@interface HAAuthManagerTests : XCTestCase
@end

@implementation HAAuthManagerTests

/// When two callers request a refresh concurrently, both must receive
/// the same error (not a silent NO-with-nil-error for the second caller).
///
/// Before the fix, the second caller got completion(NO, nil) immediately,
/// which callers interpreted as a permanent auth failure.
- (void)testConcurrentRefreshCallersAllReceiveError {
    HAAuthManager *mgr = [HAAuthManager sharedManager];

    // Save dummy OAuth credentials pointing to an unreachable server.
    // The refresh will fail with a connection error — that's expected.
    [mgr saveOAuthCredentials:@"http://127.0.0.1:1"
                  accessToken:@"test-access"
                 refreshToken:@"test-refresh"
                    expiresIn:3600];

    XCTestExpectation *first = [self expectationWithDescription:@"first caller completes"];
    XCTestExpectation *second = [self expectationWithDescription:@"second caller completes"];

    __block NSError *firstError = nil;
    __block NSError *secondError = nil;

    [mgr refreshAccessTokenWithCompletion:^(BOOL success, NSError *error) {
        XCTAssertFalse(success, @"Expected failure (unreachable server)");
        firstError = error;
        [first fulfill];
    }];

    [mgr refreshAccessTokenWithCompletion:^(BOOL success, NSError *error) {
        XCTAssertFalse(success, @"Expected failure (unreachable server)");
        // KEY ASSERTION: second caller must get an actual error, not nil.
        // Before the fix, error was nil here (silent failure).
        XCTAssertNotNil(error, @"Second caller must receive the error, not nil");
        secondError = error;
        [second fulfill];
    }];

    [self waitForExpectationsWithTimeout:30.0 handler:nil];

    // Both callers should receive the same error
    XCTAssertEqualObjects(firstError.domain, secondError.domain);

    // Clean up
    [mgr clearCredentials];
}

@end
