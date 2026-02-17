#import "HAEntity.h"

@interface HAEntity (Climate)

// Existing are in HAEntity.h already: currentTemperature, targetTemperature, minTemperature, maxTemperature, hvacMode

// New accessors
- (NSArray<NSString *> *)hvacModes;
- (NSString *)hvacAction;                // "heating", "cooling", "idle", etc.
- (NSString *)climateFanMode;
- (NSArray<NSString *> *)climateFanModes;

@end
