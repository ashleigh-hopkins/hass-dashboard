#import <UIKit/UIKit.h>

/// Custom UIPresentationController (iOS 8+) that presents a view controller
/// as a bottom sheet with dimming overlay and pan-to-dismiss support.
@interface HABottomSheetPresentationController : UIPresentationController

/// The scroll view inside the presented content whose offset is coordinated
/// with pan-to-dismiss. Set by the presented VC after loading its view.
@property (nonatomic, weak) UIScrollView *trackedScrollView;

@end
