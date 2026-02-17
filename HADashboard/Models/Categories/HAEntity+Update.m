#import "HAEntity+Update.h"

@implementation HAEntity (Update)

- (NSString *)updateReleaseSummary {
    return HAAttrString(self.attributes, HAAttrReleaseSummary);
}

@end
