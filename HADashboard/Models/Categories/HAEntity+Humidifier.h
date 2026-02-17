#import "HAEntity.h"

@interface HAEntity (Humidifier)
// Existing in HAEntity.h: humidifierTargetHumidity, humidifierCurrentHumidity, humidifierMinHumidity, humidifierMaxHumidity
- (NSString *)humidifierMode;
- (NSArray<NSString *> *)humidifierAvailableModes;
@end
