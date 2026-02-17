#import <Foundation/Foundation.h>

@interface HADiscoveredServer : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *baseURL;
@property (nonatomic, copy, readonly) NSString *version;
@property (nonatomic, copy, readonly) NSString *uuid;

- (instancetype)initWithName:(NSString *)name
                      baseURL:(NSString *)baseURL
                      version:(NSString *)version
                         uuid:(NSString *)uuid;

/// Construct from resolved NSNetService and its TXT record
- (instancetype)initWithNetService:(NSNetService *)service;

@end
