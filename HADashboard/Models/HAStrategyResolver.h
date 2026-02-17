#import <Foundation/Foundation.h>

@class HALovelaceDashboard;
@class HAEntity;

/// Resolves strategy-based dashboard configs into concrete HALovelaceDashboard objects.
/// Supports "original-states" (default overview) and "home" (auto-generated home) strategies.
@interface HAStrategyResolver : NSObject

/// Resolve a strategy config into a concrete dashboard.
/// @param strategyConfig The full strategy dictionary (contains "type", "areas", etc.)
/// @param entities All known entities keyed by entity_id
/// @param areaNames Area name lookup: area_id -> area name
/// @param entityAreaMap Entity area lookup: entity_id -> area_id
/// @param deviceAreaMap Device area lookup: device_id -> area_id
/// @param floors Floor registry entries (NSArray of HAFloor) or nil if unavailable
/// @param entityRegistry Raw entity registry entries (NSArray of NSDictionary)
/// @return A resolved HALovelaceDashboard, or nil if the strategy type is unknown
+ (HALovelaceDashboard *)resolveDashboardWithStrategy:(NSDictionary *)strategyConfig
                                             entities:(NSDictionary<NSString *, HAEntity *> *)entities
                                            areaNames:(NSDictionary<NSString *, NSString *> *)areaNames
                                        entityAreaMap:(NSDictionary<NSString *, NSString *> *)entityAreaMap
                                       deviceAreaMap:(NSDictionary<NSString *, NSString *> *)deviceAreaMap
                                               floors:(NSArray *)floors
                                       entityRegistry:(NSArray *)entityRegistry;

/// Resolve "original-states" strategy into a dashboard.
+ (HALovelaceDashboard *)resolveOriginalStatesWithConfig:(NSDictionary *)strategyConfig
                                                entities:(NSDictionary<NSString *, HAEntity *> *)entities
                                               areaNames:(NSDictionary<NSString *, NSString *> *)areaNames
                                           entityAreaMap:(NSDictionary<NSString *, NSString *> *)entityAreaMap
                                          deviceAreaMap:(NSDictionary<NSString *, NSString *> *)deviceAreaMap;

/// Resolve "home" strategy into a multi-view dashboard.
+ (HALovelaceDashboard *)resolveHomeWithConfig:(NSDictionary *)strategyConfig
                                      entities:(NSDictionary<NSString *, HAEntity *> *)entities
                                     areaNames:(NSDictionary<NSString *, NSString *> *)areaNames
                                 entityAreaMap:(NSDictionary<NSString *, NSString *> *)entityAreaMap
                                deviceAreaMap:(NSDictionary<NSString *, NSString *> *)deviceAreaMap
                                        floors:(NSArray *)floors;

@end
