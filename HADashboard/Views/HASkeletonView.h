#import <UIKit/UIKit.h>

/// Skeleton placeholder view shown while the dashboard loads.
/// Displays generic card-shaped blocks with a shimmer animation.
@interface HASkeletonView : UIView

- (void)startAnimating;
- (void)stopAnimating;

@end
