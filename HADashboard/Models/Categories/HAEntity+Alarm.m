#import "HAEntity+Alarm.h"

@implementation HAEntity (Alarm)

- (BOOL)alarmCodeArmRequired {
    return HAAttrBool(self.attributes, HAAttrCodeArmRequired, NO);
}

@end
