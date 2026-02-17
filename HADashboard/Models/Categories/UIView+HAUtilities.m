#import "UIView+HAUtilities.h"

@implementation UIView (HAUtilities)

- (UIViewController *)ha_parentViewController {
    UIResponder *responder = self.nextResponder;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    return (UIViewController *)responder;
}

@end
