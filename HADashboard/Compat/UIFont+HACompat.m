#import "UIFont+HACompat.h"

@implementation UIFont (HACompat)

+ (UIFont *)ha_systemFontOfSize:(CGFloat)size weight:(CGFloat)weight {
    if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        return [UIFont systemFontOfSize:size weight:weight];
    }
    // iOS 5-7 fallback: approximate weight with bold/system
    if (weight >= 0.23) { // HAFontWeightSemibold = 0.3, HAFontWeightBold = 0.4
        return [UIFont boldSystemFontOfSize:size];
    }
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)ha_monospacedDigitSystemFontOfSize:(CGFloat)size weight:(CGFloat)weight {
    if ([UIFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)]) {
        return [UIFont monospacedDigitSystemFontOfSize:size weight:weight];
    }
    // iOS 5-8 fallback: no monospaced digit variant, use regular system font
    return [self ha_systemFontOfSize:size weight:weight];
}

@end
