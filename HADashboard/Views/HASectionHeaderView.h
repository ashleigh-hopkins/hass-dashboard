#import <UIKit/UIKit.h>

@class HADashboardConfigSection;

/// Custom section header for the dashboard collection view.
/// Displays an optional MDI icon (as Unicode symbol) and a section title.
@interface HASectionHeaderView : UICollectionReusableView

- (void)configureWithSection:(HADashboardConfigSection *)section;

@end
