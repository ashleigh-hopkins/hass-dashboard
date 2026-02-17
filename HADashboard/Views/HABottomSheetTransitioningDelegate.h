#import <UIKit/UIKit.h>

/// Transitioning delegate that vends HABottomSheetPresentationController
/// for custom bottom-sheet modal presentation on iOS 9-14.
/// On iOS 15+, the caller should use UISheetPresentationController instead.
@interface HABottomSheetTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@end
