#import <Foundation/Foundation.h>

/// Fetches logbook (activity) entries from the HA REST API.
/// Entries include state changes, automations triggered, scripts run, etc.
@interface HALogbookManager : NSObject

+ (instancetype)sharedManager;

/// Fetch recent logbook entries for the last N hours.
/// Returns array of dictionaries with keys: name, message, entity_id, when, icon, domain, state.
- (void)fetchRecentEntries:(NSInteger)hours
                completion:(void (^)(NSArray *entries, NSError *error))completion;

/// Fetch logbook entries for a specific entity.
- (void)fetchEntriesForEntityId:(NSString *)entityId
                      hoursBack:(NSInteger)hours
                     completion:(void (^)(NSArray *entries, NSError *error))completion;

/// Fetch logbook entries for multiple entities.
/// Prefers WebSocket (logbook/get_events) when connected, falls back to REST.
- (void)fetchEntriesForEntityIds:(NSArray<NSString *> *)entityIds
                       hoursBack:(NSInteger)hours
                      completion:(void (^)(NSArray *entries, NSError *error))completion;

@end
