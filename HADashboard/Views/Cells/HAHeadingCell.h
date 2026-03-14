#import <UIKit/UIKit.h>
#import "HACellCompat.h"

@class HADashboardConfigItem;

@interface HAHeadingCell : HACollectionViewCellBase

- (void)configureWithItem:(HADashboardConfigItem *)item;

@end
