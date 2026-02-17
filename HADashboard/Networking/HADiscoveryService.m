#import "HADiscoveryService.h"
#import "HADiscoveredServer.h"

static NSString *const kServiceType = @"_home-assistant._tcp.";
static NSString *const kServiceDomain = @"local.";

@interface HADiscoveryService () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@property (nonatomic, strong) NSNetServiceBrowser *browser;
@property (nonatomic, strong) NSMutableArray<HADiscoveredServer *> *mutableServers;
@property (nonatomic, strong) NSMutableArray<NSNetService *> *resolvingServices;
@property (nonatomic, assign, readwrite) BOOL searching;
@end

@implementation HADiscoveryService

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableServers = [NSMutableArray array];
        _resolvingServices = [NSMutableArray array];
    }
    return self;
}

- (NSArray<HADiscoveredServer *> *)discoveredServers {
    return [self.mutableServers copy];
}

#pragma mark - Search Control

- (void)startSearching {
    if (self.searching) return;

    NSLog(@"[HADiscovery] Starting mDNS search for %@", kServiceType);
    self.searching = YES;

    [self.mutableServers removeAllObjects];
    [self.resolvingServices removeAllObjects];

    self.browser = [[NSNetServiceBrowser alloc] init];
    self.browser.delegate = self;
    [self.browser searchForServicesOfType:kServiceType inDomain:kServiceDomain];
}

- (void)stopSearching {
    if (!self.searching) return;

    NSLog(@"[HADiscovery] Stopping search");
    self.searching = NO;

    [self.browser stop];
    self.browser.delegate = nil;
    self.browser = nil;

    for (NSNetService *service in self.resolvingServices) {
        [service stop];
        service.delegate = nil;
    }
    [self.resolvingServices removeAllObjects];
}

- (void)dealloc {
    [self stopSearching];
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    NSLog(@"[HADiscovery] Found service: %@ on %@:%ld", service.name, service.hostName, (long)service.port);

    // Resolve to get TXT record and address
    service.delegate = self;
    [self.resolvingServices addObject:service];
    [service resolveWithTimeout:5.0];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    NSLog(@"[HADiscovery] Removed service: %@", service.name);

    // Find and remove matching server
    HADiscoveredServer *toRemove = nil;
    for (HADiscoveredServer *server in self.mutableServers) {
        if ([server.name isEqualToString:service.name]) {
            toRemove = server;
            break;
        }
    }

    if (toRemove) {
        [self.mutableServers removeObject:toRemove];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate discoveryService:self didRemoveServer:toRemove];
        });
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    NSLog(@"[HADiscovery] Search failed: %@", errorDict);
    self.searching = NO;
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
    self.searching = NO;
}

#pragma mark - NSNetServiceDelegate (for resolving)

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"[HADiscovery] Resolved: %@ → %@:%ld", sender.name, sender.hostName, (long)sender.port);

    [self.resolvingServices removeObject:sender];
    sender.delegate = nil;

    HADiscoveredServer *server = [[HADiscoveredServer alloc] initWithNetService:sender];

    // Dedup by UUID or baseURL
    for (HADiscoveredServer *existing in self.mutableServers) {
        if (server.uuid && [existing.uuid isEqualToString:server.uuid]) return;
        if (server.baseURL && [existing.baseURL isEqualToString:server.baseURL]) return;
    }

    if (!server.baseURL) {
        NSLog(@"[HADiscovery] Skipping server with no URL: %@", server.name);
        return;
    }

    [self.mutableServers addObject:server];
    NSLog(@"[HADiscovery] Added server: %@", server);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate discoveryService:self didDiscoverServer:server];
    });
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    NSLog(@"[HADiscovery] Failed to resolve %@: %@", sender.name, errorDict);
    [self.resolvingServices removeObject:sender];
    sender.delegate = nil;
}

@end
