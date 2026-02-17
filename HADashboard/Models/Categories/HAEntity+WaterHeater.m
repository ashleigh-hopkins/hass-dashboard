#import "HAEntity+WaterHeater.h"

@implementation HAEntity (WaterHeater)

- (NSArray<NSString *> *)waterHeaterOperationList {
    return HAAttrArray(self.attributes, HAAttrOperationList) ?: @[];
}

- (NSString *)waterHeaterOperationMode {
    return HAAttrString(self.attributes, HAAttrOperationMode);
}

- (NSNumber *)waterHeaterTemperature {
    return HAAttrNumber(self.attributes, HAAttrTemperature);
}

- (NSNumber *)waterHeaterMinTemp {
    return HAAttrNumber(self.attributes, HAAttrMinTemp);
}

- (NSNumber *)waterHeaterMaxTemp {
    return HAAttrNumber(self.attributes, HAAttrMaxTemp);
}

@end
