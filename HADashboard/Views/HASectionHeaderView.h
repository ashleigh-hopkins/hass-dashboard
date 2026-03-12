#import <UIKit/UIKit.h>
#import "HACellCompat.h"

@class HADashboardConfigSection;

/// Custom section header for the dashboard collection view.
/// Displays an optional MDI icon (as Unicode symbol) and a section title.
@interface HASectionHeaderView : HACollectionReusableViewBase

- (void)configureWithSection:(HADashboardConfigSection *)section;

@end
