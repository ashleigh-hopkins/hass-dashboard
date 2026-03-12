#import <UIKit/UIKit.h>

/// iOS 5-safe font weight constants matching UIFontWeight* values.
/// The UIFontWeight* extern symbols don't exist on iOS 5-7 (introduced iOS 8.2),
/// so accessing them causes a dyld lazy-binding crash. Use these instead.
static const CGFloat HAFontWeightUltraLight = -0.8;
static const CGFloat HAFontWeightThin       = -0.6;
static const CGFloat HAFontWeightLight      = -0.4;
static const CGFloat HAFontWeightRegular    =  0.0;
static const CGFloat HAFontWeightMedium     =  0.23;
static const CGFloat HAFontWeightSemibold   =  0.3;
static const CGFloat HAFontWeightBold       =  0.4;
static const CGFloat HAFontWeightHeavy      =  0.56;
static const CGFloat HAFontWeightBlack      =  0.62;

/// iOS 5-safe font helpers. On iOS 8.2+ these use the real weighted/monospaced
/// APIs. On older systems they fall back to bold/system variants.
@interface UIFont (HACompat)

/// Equivalent to +systemFontOfSize:weight: (iOS 8.2+).
/// Falls back to boldSystemFontOfSize: for semibold+ weights, systemFontOfSize: otherwise.
+ (UIFont *)ha_systemFontOfSize:(CGFloat)size weight:(CGFloat)weight;

/// Equivalent to +monospacedDigitSystemFontOfSize:weight: (iOS 9+).
/// Falls back to ha_systemFontOfSize:weight: on older systems.
+ (UIFont *)ha_monospacedDigitSystemFontOfSize:(CGFloat)size weight:(CGFloat)weight;

@end
