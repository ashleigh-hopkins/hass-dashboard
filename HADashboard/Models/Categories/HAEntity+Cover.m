#import "HAEntity+Cover.h"

@implementation HAEntity (Cover)

- (NSInteger)coverTiltPosition {
    return HAAttrInteger(self.attributes, HAAttrCurrentTiltPosition, 0);
}

@end
