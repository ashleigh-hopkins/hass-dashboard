#import <Foundation/Foundation.h>

typedef void (^HAHTTPCompletion)(NSData *data, NSURLResponse *response, NSError *error);

@class HAHTTPClient;

@protocol HAHTTPClientStreamDelegate <NSObject>
@optional
- (void)httpClient:(HAHTTPClient *)client didReceiveResponse:(NSURLResponse *)response forTask:(id)task;
- (void)httpClient:(HAHTTPClient *)client didReceiveData:(NSData *)data forTask:(id)task;
- (void)httpClient:(HAHTTPClient *)client didFinishTask:(id)task;
- (void)httpClient:(HAHTTPClient *)client task:(id)task didFailWithError:(NSError *)error;
@end

@interface HAHTTPClient : NSObject

+ (instancetype)sharedClient;

- (id)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(HAHTTPCompletion)completion;
- (id)streamingTaskWithRequest:(NSURLRequest *)request delegate:(id<HAHTTPClientStreamDelegate>)delegate;
- (void)cancelTask:(id)task;

@end
