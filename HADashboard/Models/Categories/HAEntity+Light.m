#import "HAEntity+Light.h"
#import "HAEntityAttributes.h"

@implementation HAEntity (Light)

#pragma mark - Existing (moved from HAEntity.m)

- (NSInteger)brightness {
    return HAAttrInteger(self.attributes, HAAttrBrightness, 0);
}

- (NSInteger)brightnessPercent {
    NSInteger raw = [self brightness];
    if (raw <= 0) return 0;
    return (NSInteger)round((raw / 255.0) * 100.0);
}

#pragma mark - Color Modes

- (NSArray<NSString *> *)supportedColorModes {
    return HAAttrArray(self.attributes, HAAttrSupportedColorModes);
}

- (NSString *)colorMode {
    return HAAttrString(self.attributes, HAAttrColorMode);
}

#pragma mark - Color Temperature

- (NSNumber *)colorTempKelvin {
    return HAAttrNumber(self.attributes, HAAttrColorTempKelvin);
}

- (NSNumber *)minColorTempKelvin {
    return HAAttrNumber(self.attributes, HAAttrMinColorTempKelvin);
}

- (NSNumber *)maxColorTempKelvin {
    return HAAttrNumber(self.attributes, HAAttrMaxColorTempKelvin);
}

#pragma mark - HS Color

- (NSArray<NSNumber *> *)hsColor {
    return HAAttrArray(self.attributes, HAAttrHSColor);
}

#pragma mark - Effects

- (NSString *)effect {
    return HAAttrString(self.attributes, HAAttrEffect);
}

- (NSArray<NSString *> *)effectList {
    return HAAttrArray(self.attributes, HAAttrEffectList) ?: @[];
}

#pragma mark - Computed Convenience

- (BOOL)supportsColorTemp {
    NSArray<NSString *> *modes = [self supportedColorModes];
    if (modes) {
        return [modes containsObject:@"color_temp"];
    }
    // Fallback: check current color mode
    return [[self colorMode] isEqualToString:@"color_temp"];
}

- (BOOL)supportsHSColor {
    NSArray<NSString *> *modes = [self supportedColorModes];
    if (modes) {
        static NSSet *colorModes = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            colorModes = [NSSet setWithObjects:@"hs", @"xy", @"rgb", @"rgbw", @"rgbww", nil];
        });
        for (NSString *mode in modes) {
            if ([colorModes containsObject:mode]) return YES;
        }
        return NO;
    }
    // Fallback: check current color mode
    NSString *current = [self colorMode];
    if (!current) return NO;
    static NSSet *fallbackModes = nil;
    static dispatch_once_t fallbackToken;
    dispatch_once(&fallbackToken, ^{
        fallbackModes = [NSSet setWithObjects:@"hs", @"xy", @"rgb", @"rgbw", @"rgbww", nil];
    });
    return [fallbackModes containsObject:current];
}

- (BOOL)supportsEffects {
    return [self effectList].count > 0;
}

@end
