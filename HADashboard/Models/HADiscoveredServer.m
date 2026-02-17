#import "HADiscoveredServer.h"

@interface HADiscoveredServer ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *baseURL;
@property (nonatomic, copy, readwrite) NSString *version;
@property (nonatomic, copy, readwrite) NSString *uuid;
@end

@implementation HADiscoveredServer

- (instancetype)initWithName:(NSString *)name
                      baseURL:(NSString *)baseURL
                      version:(NSString *)version
                         uuid:(NSString *)uuid {
    self = [super init];
    if (self) {
        _name = [name copy];
        _baseURL = [baseURL copy];
        _version = [version copy];
        _uuid = [uuid copy];
    }
    return self;
}

- (instancetype)initWithNetService:(NSNetService *)service {
    self = [super init];
    if (self) {
        _name = [service.name copy];

        // Parse TXT record
        NSData *txtData = service.TXTRecordData;
        if (txtData) {
            NSDictionary *txtDict = [NSNetService dictionaryFromTXTRecordData:txtData];

            _baseURL = [self stringFromTXTValue:txtDict[@"base_url"]];
            _version = [self stringFromTXTValue:txtDict[@"version"]];
            _uuid = [self stringFromTXTValue:txtDict[@"uuid"]];

            // Some HA versions use "internal_url" or "external_url"
            if (!_baseURL) {
                _baseURL = [self stringFromTXTValue:txtDict[@"internal_url"]];
            }
        }

        // Fallback: construct URL from resolved host + port
        if (!_baseURL && service.hostName && service.port > 0) {
            NSString *host = service.hostName;
            // Strip trailing dot from Bonjour hostname
            if ([host hasSuffix:@"."]) {
                host = [host substringToIndex:host.length - 1];
            }
            _baseURL = [NSString stringWithFormat:@"http://%@:%ld", host, (long)service.port];
        }
    }
    return self;
}

- (NSString *)stringFromTXTValue:(NSData *)data {
    if (!data || ![data isKindOfClass:[NSData class]]) return nil;
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return (str.length > 0) ? str : nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<HADiscoveredServer: %@ at %@ (v%@)>", self.name, self.baseURL, self.version];
}

@end
