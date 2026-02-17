#import <Foundation/Foundation.h>

@class HADashboardConfig;

/// Represents a single Lovelace view (tab) in a HA dashboard
@interface HALovelaceView : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, strong) NSArray<NSDictionary *> *rawCards;
/// HA 2024+ sections: array of @{@"title": NSString, @"cards": NSArray}
/// nil for classic (non-sections) views.
@property (nonatomic, strong) NSArray<NSDictionary *> *rawSections;
/// Maximum columns for sections layout (from HA view config "max_columns"). 0 = use default (4).
@property (nonatomic, assign) NSInteger maxColumns;
/// View layout type: "masonry" (default classic), "panel", "sidebar", or "sections".
@property (nonatomic, copy) NSString *viewType;
@end


/// Parsed result of a full Lovelace dashboard configuration
@interface HALovelaceDashboard : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<HALovelaceView *> *views;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

/// Get a view by index
- (HALovelaceView *)viewAtIndex:(NSUInteger)index;
@end


/// Parses Lovelace config JSON into our native HADashboardConfig format
@interface HALovelaceParser : NSObject

/// Parse the full Lovelace config response from HA WebSocket API
+ (HALovelaceDashboard *)parseDashboardFromDictionary:(NSDictionary *)dict;

/// Convert a single Lovelace view into our native HADashboardConfig
/// @param view The Lovelace view to convert
/// @param columns Number of grid columns
+ (HADashboardConfig *)dashboardConfigFromView:(HALovelaceView *)view columns:(NSInteger)columns;

/// Extract all entity IDs from a Lovelace card dictionary (recursively handles stacks)
+ (NSArray<NSDictionary *> *)extractEntitiesFromCard:(NSDictionary *)card;

@end
