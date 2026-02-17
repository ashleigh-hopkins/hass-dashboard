#import "HABaseEntityCell.h"

/// Tile card: large centered icon with entity name, tap to toggle.
/// Used for cover, switch, light, scene, script entities in tile card layout.
/// Supports a compact "pill" mode for button cards inside horizontal-stack:
/// small icon + name in a horizontal row, no state text.
@interface HATileEntityCell : HABaseEntityCell

/// Height for compact pill-shaped button cards inside horizontal-stack.
+ (CGFloat)compactHeight;

/// Preferred height for normal (non-compact) tile cards.
+ (CGFloat)preferredHeight;

@end
