#import "HAEntity.h"

@interface HAEntity (Vacuum)
// Existing in HAEntity.h: vacuumBatteryLevel, vacuumStatus
- (NSString *)vacuumFanSpeed;
- (NSArray<NSString *> *)vacuumFanSpeedList;
@end
