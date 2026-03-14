#import <UIKit/UIKit.h>
#import "HACellCompat.h"

@class HADashboardConfigSection;
@class HADashboardConfigItem;
@class HAEntity;

/// Renders a logbook/activity card showing recent state changes and events.
@interface HALogbookCardCell : HACollectionViewCellBase

- (void)configureWithSection:(HADashboardConfigSection *)section
                    entities:(NSDictionary<NSString *, HAEntity *> *)entityDict
                  configItem:(HADashboardConfigItem *)configItem;

/// Begin loading logbook data (called from willDisplayCell).
- (void)beginLoading;

/// Preferred height for the logbook card.
+ (CGFloat)preferredHeightForHours:(NSInteger)hours;

@end
