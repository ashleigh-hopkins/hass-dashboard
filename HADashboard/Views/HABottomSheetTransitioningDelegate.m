#import "HABottomSheetTransitioningDelegate.h"
#import "HABottomSheetPresentationController.h"

@implementation HABottomSheetTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
    return [[HABottomSheetPresentationController alloc] initWithPresentedViewController:presented
                                                              presentingViewController:presenting];
}

@end
