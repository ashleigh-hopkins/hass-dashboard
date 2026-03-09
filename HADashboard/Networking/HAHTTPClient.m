#import "HAHTTPClient.h"

#pragma mark - NSURLConnection streaming wrapper

@interface _HAConnectionStreamTask : NSObject <NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, weak) id<HAHTTPClientStreamDelegate> delegate;
@property (nonatomic, weak) HAHTTPClient *client;
@end

@implementation _HAConnectionStreamTask

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([self.delegate respondsToSelector:@selector(httpClient:didReceiveResponse:forTask:)]) {
        [self.delegate httpClient:self.client didReceiveResponse:response forTask:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(httpClient:didReceiveData:forTask:)]) {
        [self.delegate httpClient:self.client didReceiveData:data forTask:self];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(httpClient:didFinishTask:)]) {
        [self.delegate httpClient:self.client didFinishTask:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(httpClient:task:didFailWithError:)]) {
        [self.delegate httpClient:self.client task:self didFailWithError:error];
    }
}

@end

#pragma mark - HAHTTPClient

@interface HAHTTPClient () <NSURLSessionDataDelegate>
@property (nonatomic, assign) BOOL useURLSession;
@property (nonatomic, strong) NSURLSession *delegateSession;
@property (nonatomic, strong) NSMutableDictionary *streamDelegates; // NSURLSessionTask -> delegate wrapper
@end

typedef struct {
    __unsafe_unretained id<HAHTTPClientStreamDelegate> delegate;
    __unsafe_unretained HAHTTPClient *client;
} _HAStreamEntry;

@implementation HAHTTPClient

+ (instancetype)sharedClient {
    static HAHTTPClient *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HAHTTPClient alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _useURLSession = [NSURLSession class] != nil;
        _streamDelegates = [NSMutableDictionary dictionary];
        if (_useURLSession) {
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.timeoutIntervalForRequest = 30;
            config.timeoutIntervalForResource = 0;
            _delegateSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        }
    }
    return self;
}

#pragma mark - Data Tasks

- (id)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(HAHTTPCompletion)completion {
    if (self.useURLSession) {
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (completion) completion(data, response, error);
            }];
        [task resume];
        return task;
    }

    // NSURLConnection fallback
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (completion) completion(data, response, error);
    }];
    return request; // Opaque token; non-cancellable for simple tasks
}

#pragma mark - Streaming Tasks

- (id)streamingTaskWithRequest:(NSURLRequest *)request delegate:(id<HAHTTPClientStreamDelegate>)delegate {
    if (self.useURLSession) {
        NSURLSessionDataTask *task = [self.delegateSession dataTaskWithRequest:request];
        @synchronized(self.streamDelegates) {
            self.streamDelegates[@(task.taskIdentifier)] = delegate;
        }
        [task resume];
        return task;
    }

    // NSURLConnection fallback
    _HAConnectionStreamTask *wrapper = [[_HAConnectionStreamTask alloc] init];
    wrapper.delegate = delegate;
    wrapper.client = self;
    wrapper.connection = [[NSURLConnection alloc] initWithRequest:request delegate:wrapper startImmediately:YES];
    return wrapper;
}

#pragma mark - Cancel

- (void)cancelTask:(id)task {
    if ([task isKindOfClass:[NSURLSessionTask class]]) {
        [(NSURLSessionTask *)task cancel];
        @synchronized(self.streamDelegates) {
            [self.streamDelegates removeObjectForKey:@([(NSURLSessionTask *)task taskIdentifier])];
        }
    } else if ([task isKindOfClass:[_HAConnectionStreamTask class]]) {
        ((_HAConnectionStreamTask *)task).delegate = nil;
        [[(_HAConnectionStreamTask *)task connection] cancel];
    }
}

#pragma mark - NSURLSessionDataDelegate (streaming)

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    id<HAHTTPClientStreamDelegate> delegate;
    @synchronized(self.streamDelegates) {
        delegate = self.streamDelegates[@(dataTask.taskIdentifier)];
    }
    if ([delegate respondsToSelector:@selector(httpClient:didReceiveResponse:forTask:)]) {
        [delegate httpClient:self didReceiveResponse:response forTask:dataTask];
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    id<HAHTTPClientStreamDelegate> delegate;
    @synchronized(self.streamDelegates) {
        delegate = self.streamDelegates[@(dataTask.taskIdentifier)];
    }
    if ([delegate respondsToSelector:@selector(httpClient:didReceiveData:forTask:)]) {
        [delegate httpClient:self didReceiveData:data forTask:dataTask];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    id<HAHTTPClientStreamDelegate> delegate;
    @synchronized(self.streamDelegates) {
        delegate = self.streamDelegates[@(task.taskIdentifier)];
        [self.streamDelegates removeObjectForKey:@(task.taskIdentifier)];
    }
    if (error) {
        if ([delegate respondsToSelector:@selector(httpClient:task:didFailWithError:)]) {
            [delegate httpClient:self task:task didFailWithError:error];
        }
    } else {
        if ([delegate respondsToSelector:@selector(httpClient:didFinishTask:)]) {
            [delegate httpClient:self didFinishTask:task];
        }
    }
}

@end
