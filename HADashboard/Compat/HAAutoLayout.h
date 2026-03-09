#import <UIKit/UIKit.h>

/// Force-disable Auto Layout for testing iOS 5 layout fallbacks on modern devices.
/// Set via developer settings toggle.  Defaults to NO.
static inline BOOL HAForceDisableAutoLayout(void) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"HAForceDisableAutoLayout"];
}

/// Returns YES if Auto Layout (NSLayoutConstraint) is available at runtime
/// AND the developer hasn't force-disabled it for testing.
/// On iOS 5.x this returns NO.  On iOS 6+ this returns YES (unless overridden).
static inline BOOL HAAutoLayoutAvailable(void) {
    if (HAForceDisableAutoLayout()) return NO;
    static BOOL checked = NO, available = NO;
    if (!checked) {
        available = (NSClassFromString(@"NSLayoutConstraint") != nil);
        checked = YES;
    }
    return available;
}
