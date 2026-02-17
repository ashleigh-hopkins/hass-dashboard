#import "HAHaptics.h"

@implementation HAHaptics

+ (void)lightImpact {
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [gen impactOccurred];
    }
}

+ (void)mediumImpact {
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [gen impactOccurred];
    }
}

+ (void)heavyImpact {
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
        [gen impactOccurred];
    }
}

+ (void)notifySuccess {
    if (@available(iOS 10.0, *)) {
        UINotificationFeedbackGenerator *gen = [[UINotificationFeedbackGenerator alloc] init];
        [gen notificationOccurred:UINotificationFeedbackTypeSuccess];
    }
}

+ (void)selectionChanged {
    if (@available(iOS 10.0, *)) {
        UISelectionFeedbackGenerator *gen = [[UISelectionFeedbackGenerator alloc] init];
        [gen selectionChanged];
    }
}

@end
