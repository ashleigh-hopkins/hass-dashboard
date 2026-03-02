#import "HABaseEntityCell.h"

@class HADashboardConfigItem;

/// Tile card: large centered icon with entity name, tap to toggle.
/// Used for cover, switch, light, scene, script entities in tile card layout.
/// Supports a compact "pill" mode for button cards inside horizontal-stack:
/// small icon + name in a horizontal row, no state text.
/// Supports tile features (brightness slider, cover buttons, etc.) below the main area.
@interface HATileEntityCell : HABaseEntityCell

/// Height for compact pill-shaped button cards inside horizontal-stack.
+ (CGFloat)compactHeight;

/// Preferred height for normal (non-compact) tile cards without features.
+ (CGFloat)preferredHeight;

/// Dynamic height including tile features. Returns base height + feature heights.
+ (CGFloat)preferredHeightForConfigItem:(HADashboardConfigItem *)configItem;

/// Called when the icon area is tapped. If nil, the entire cell tap goes through
/// the normal collection view selection (more-info). When set, icon taps call this
/// block and body taps go through collection view selection.
@property (nonatomic, copy) void(^iconTapBlock)(void);

@end
