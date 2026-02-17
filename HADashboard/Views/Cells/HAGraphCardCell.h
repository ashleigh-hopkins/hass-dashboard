#import <UIKit/UIKit.h>

@class HAEntity, HADashboardConfigItem, HADashboardConfigSection;

@interface HAGraphCardCell : UICollectionViewCell

/// Configure with a single entity (simple graph)
- (void)configureWithEntity:(HAEntity *)entity item:(HADashboardConfigItem *)item;

/// Configure with a section containing multiple entities (composite mini-graph-card)
- (void)configureWithSection:(HADashboardConfigSection *)section entities:(NSDictionary *)allEntities;

/// Deferred loading: call when cell becomes visible to start expensive work (history fetch)
- (void)beginLoading;

/// Cancel pending network requests when cell scrolls off screen
- (void)cancelLoading;

+ (CGFloat)preferredHeight;

@end
