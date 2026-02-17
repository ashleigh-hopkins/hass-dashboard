#import <Foundation/Foundation.h>

@class HADiscoveredServer, HADiscoveryService;

@protocol HADiscoveryServiceDelegate <NSObject>
@optional
- (void)discoveryService:(HADiscoveryService *)service didDiscoverServer:(HADiscoveredServer *)server;
- (void)discoveryService:(HADiscoveryService *)service didRemoveServer:(HADiscoveredServer *)server;
@end

@interface HADiscoveryService : NSObject

@property (nonatomic, weak) id<HADiscoveryServiceDelegate> delegate;
@property (nonatomic, copy, readonly) NSArray<HADiscoveredServer *> *discoveredServers;
@property (nonatomic, readonly) BOOL searching;

- (void)startSearching;
- (void)stopSearching;

@end
