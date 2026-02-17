#import <UIKit/UIKit.h>

@class HADashboardConfigSection;
@class HAEntity;

/// Renders multiple entities as compact badge chips in a horizontal flow.
/// Used for custom:badge-card rendering.
@interface HABadgeRowCell : UICollectionViewCell

- (void)configureWithSection:(HADashboardConfigSection *)section entities:(NSDictionary *)entityDict;

/// Calculate preferred height for a given entity count and available width
+ (CGFloat)preferredHeightForEntityCount:(NSInteger)count width:(CGFloat)width;
+ (CGFloat)preferredHeightForEntityCount:(NSInteger)count width:(CGFloat)width chipStyle:(BOOL)chipStyle;

/// Called when a badge is tapped. Used to open entity detail.
@property (nonatomic, copy) void(^entityTapBlock)(HAEntity *entity);

@end
