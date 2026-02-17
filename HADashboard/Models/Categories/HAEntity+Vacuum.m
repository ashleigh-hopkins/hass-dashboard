#import "HAEntity+Vacuum.h"

@implementation HAEntity (Vacuum)

- (NSString *)vacuumFanSpeed {
    return HAAttrString(self.attributes, HAAttrFanSpeed);
}

- (NSArray<NSString *> *)vacuumFanSpeedList {
    return HAAttrArray(self.attributes, HAAttrFanSpeedList) ?: @[];
}

@end
