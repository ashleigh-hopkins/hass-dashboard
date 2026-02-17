#import <UIKit/UIKit.h>

@class HAEntity, HADashboardConfigItem;

/// A standalone gauge card cell displaying a semicircular (180-degree) arc
/// gauge with colored fill proportional to the entity's state value.
/// Supports configurable min/max, unit of measurement, and severity thresholds.
@interface HAGaugeCardCell : UICollectionViewCell

/// Configure the gauge with an entity and its card configuration.
- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem;

/// Preferred cell height for layout calculations.
+ (CGFloat)preferredHeight;

/// Preferred cell height for a given cell width (accounts for arc radius constraint).
+ (CGFloat)preferredHeightForWidth:(CGFloat)width;

@end
