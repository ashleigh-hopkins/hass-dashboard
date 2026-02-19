#import <UIKit/UIKit.h>

/// Animated constellation background with floating dots connected by lines.
/// Uses Core Animation for dot movement (GPU-composited) and a low-frequency
/// timer for line path updates. Respects Reduce Motion accessibility setting.
@interface HAConstellationView : UIView

/// Start the animation. Safe to call multiple times.
- (void)startAnimating;

/// Stop the animation and remove all layers.
- (void)stopAnimating;

@end
