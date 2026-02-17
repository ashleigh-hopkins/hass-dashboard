#import "HAEntity.h"

@interface HAEntity (Light)

// Existing (moved from HAEntity.m — do NOT redeclare in this header since they're already in HAEntity.h)
// - (NSInteger)brightness;
// - (NSInteger)brightnessPercent;

// New accessors
- (NSArray<NSString *> *)supportedColorModes;
- (NSString *)colorMode;
- (NSNumber *)colorTempKelvin;
- (NSNumber *)minColorTempKelvin;
- (NSNumber *)maxColorTempKelvin;
- (NSArray<NSNumber *> *)hsColor;           // [hue (0-360), saturation (0-100)]
- (NSString *)effect;
- (NSArray<NSString *> *)effectList;

// Computed convenience
- (BOOL)supportsColorTemp;
- (BOOL)supportsHSColor;
- (BOOL)supportsEffects;

@end
