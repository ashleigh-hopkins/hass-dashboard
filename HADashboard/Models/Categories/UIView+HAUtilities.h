#import <UIKit/UIKit.h>

@interface UIView (HAUtilities)

/// Walks the responder chain to find the nearest parent UIViewController.
- (UIViewController *)ha_parentViewController;

@end
