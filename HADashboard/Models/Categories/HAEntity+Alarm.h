#import "HAEntity.h"

@interface HAEntity (Alarm)
// Existing in HAEntity.h: alarmState, alarmCodeRequired, alarmCodeFormat
- (BOOL)alarmCodeArmRequired;
@end
