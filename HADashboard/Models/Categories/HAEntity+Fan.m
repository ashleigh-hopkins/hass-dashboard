#import "HAEntity+Fan.h"

@implementation HAEntity (Fan)

- (BOOL)fanOscillating {
    return HAAttrBool(self.attributes, HAAttrOscillating, NO);
}

- (NSString *)fanDirection {
    return HAAttrString(self.attributes, HAAttrDirection);
}

- (NSString *)fanSpeed {
    return HAAttrString(self.attributes, HAAttrFanSpeed);
}

- (NSArray<NSString *> *)fanSpeedList {
    return HAAttrArray(self.attributes, HAAttrFanSpeedList) ?: @[];
}

@end
