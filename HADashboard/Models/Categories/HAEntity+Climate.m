#import "HAEntity+Climate.h"
#import "HAEntityAttributes.h"

@implementation HAEntity (Climate)

- (NSArray<NSString *> *)hvacModes {
    return HAAttrArray(self.attributes, HAAttrHvacModes) ?: @[];
}

- (NSString *)hvacAction {
    return HAAttrString(self.attributes, HAAttrHvacAction);
}

- (NSString *)climateFanMode {
    return HAAttrString(self.attributes, HAAttrFanMode);
}

- (NSArray<NSString *> *)climateFanModes {
    return HAAttrArray(self.attributes, HAAttrFanModes) ?: @[];
}

@end
