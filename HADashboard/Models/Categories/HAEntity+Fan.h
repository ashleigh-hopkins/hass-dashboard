#import "HAEntity.h"

@interface HAEntity (Fan)

// Existing in HAEntity.h: fanSpeedPercent, fanPresetModes, fanPresetMode

// New
- (BOOL)fanOscillating;
- (NSString *)fanDirection;
- (NSString *)fanSpeed;
- (NSArray<NSString *> *)fanSpeedList;

@end
