#import <UIKit/UIKit.h>

/// Provides haptic feedback on devices that support it (iOS 10+).
/// Silently no-ops on iOS 9 and devices without a Taptic Engine.
@interface HAHaptics : NSObject

/// Light tap — toggle switches, minor state changes
+ (void)lightImpact;

/// Medium tap — button presses, slider commits
+ (void)mediumImpact;

/// Heavy tap — destructive actions, lock/unlock
+ (void)heavyImpact;

/// Success — connection established, scene activated
+ (void)notifySuccess;

/// Selection changed — picker option, view tab switch
+ (void)selectionChanged;

@end
