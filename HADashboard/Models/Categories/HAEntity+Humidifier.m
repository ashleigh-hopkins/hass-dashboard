#import "HAEntity+Humidifier.h"

@implementation HAEntity (Humidifier)

- (NSString *)humidifierMode {
    return HAAttrString(self.attributes, HAAttrMode);
}

- (NSArray<NSString *> *)humidifierAvailableModes {
    return HAAttrArray(self.attributes, HAAttrAvailableModes) ?: @[];
}

@end
