#import "HAEntity+Weather.h"

@implementation HAEntity (Weather)

- (NSString *)weatherPressureUnit {
    return HAAttrString(self.attributes, HAAttrPressureUnit);
}

- (NSString *)weatherWindSpeedUnit {
    return HAAttrString(self.attributes, HAAttrWindSpeedUnit);
}

- (NSString *)weatherAttribution {
    return HAAttrString(self.attributes, HAAttrAttribution);
}

- (NSArray *)weatherForecast {
    return HAAttrArray(self.attributes, HAAttrForecast);
}

@end
