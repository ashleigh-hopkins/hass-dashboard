#import <Foundation/Foundation.h>

@class HAWebSocketClient;

@protocol HAWebSocketClientDelegate <NSObject>

- (void)webSocketClientDidConnect:(HAWebSocketClient *)client;
- (void)webSocketClientDidAuthenticate:(HAWebSocketClient *)client;
- (void)webSocketClient:(HAWebSocketClient *)client didReceiveMessage:(NSDictionary *)message;
- (void)webSocketClient:(HAWebSocketClient *)client didDisconnectWithError:(NSError *)error;

@end


@interface HAWebSocketClient : NSObject

@property (nonatomic, weak) id<HAWebSocketClientDelegate> delegate;
@property (nonatomic, readonly, getter=isConnected) BOOL connected;
@property (nonatomic, readonly, getter=isAuthenticated) BOOL authenticated;

- (instancetype)initWithURL:(NSURL *)url token:(NSString *)token;

- (void)connect;
- (void)disconnect;

/// Subscribe to state_changed events. Returns the subscription message ID.
- (NSInteger)subscribeToStateChanges;

/// Call a service via WebSocket
- (NSInteger)callService:(NSString *)service
                inDomain:(NSString *)domain
                withData:(NSDictionary *)data;

/// Fetch the list of available Lovelace dashboards. Returns the message ID.
- (NSInteger)fetchDashboardList;

/// Fetch Lovelace dashboard config. Returns the message ID.
- (NSInteger)fetchLovelaceConfig;

/// Fetch a specific Lovelace dashboard by URL path (e.g. "lovelace-bedroom").
/// Pass nil for the default dashboard.
- (NSInteger)fetchLovelaceConfigForDashboard:(NSString *)urlPath;

/// Fetch HA registries for area-based entity grouping
- (NSInteger)fetchAreaRegistry;
- (NSInteger)fetchEntityRegistry;
- (NSInteger)fetchDeviceRegistry;

/// Send a raw command dictionary
- (NSInteger)sendCommand:(NSDictionary *)command;

@end
