#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "HAAutoLayout.h"

/// When Auto Layout is force-disabled (developer toggle or iOS 5), swizzle
/// UIView methods to make constraint operations no-ops, preventing crashes
/// from code that adds constraints without HAAutoLayoutAvailable() guards.

static void (*sOrigSetTranslates)(id, SEL, BOOL);
static void (*sOrigAddConstraint)(id, SEL, id);
static void (*sOrigAddConstraints)(id, SEL, id);
static void (*sOrigRemoveConstraint)(id, SEL, id);
static void (*sOrigRemoveConstraints)(id, SEL, id);

static void HASwizzledSetTranslates(id self, SEL _cmd, BOOL val) {
    if (!val && !HAAutoLayoutAvailable()) return;
    sOrigSetTranslates(self, _cmd, val);
}

static void HASwizzledAddConstraint(id self, SEL _cmd, id constraint) {
    if (!HAAutoLayoutAvailable()) return;
    sOrigAddConstraint(self, _cmd, constraint);
}

static void HASwizzledAddConstraints(id self, SEL _cmd, id constraints) {
    if (!HAAutoLayoutAvailable()) return;
    sOrigAddConstraints(self, _cmd, constraints);
}

static void HASwizzledRemoveConstraint(id self, SEL _cmd, id constraint) {
    if (!HAAutoLayoutAvailable()) return;
    sOrigRemoveConstraint(self, _cmd, constraint);
}

static void HASwizzledRemoveConstraints(id self, SEL _cmd, id constraints) {
    if (!HAAutoLayoutAvailable()) return;
    sOrigRemoveConstraints(self, _cmd, constraints);
}

// NSLayoutConstraint.active = YES and +[activateConstraints:] bypass addConstraint:
static void (*sOrigSetActive)(id, SEL, BOOL);
static void (*sOrigActivate)(id, SEL, id);
static void (*sOrigDeactivate)(id, SEL, id);

static void HASwizzledSetActive(id self, SEL _cmd, BOOL active) {
    if (!HAAutoLayoutAvailable()) return;
    sOrigSetActive(self, _cmd, active);
}

static void HASwizzledActivate(id self, SEL _cmd, id constraints) {
    if (!HAAutoLayoutAvailable()) return;
    sOrigActivate(self, _cmd, constraints);
}

static void HASwizzledDeactivate(id self, SEL _cmd, id constraints) {
    if (!HAAutoLayoutAvailable()) return;
    sOrigDeactivate(self, _cmd, constraints);
}

static void HASwizzleInstance(Class cls, SEL sel, IMP newImp, IMP *origOut) {
    Method m = class_getInstanceMethod(cls, sel);
    if (!m) return;
    *origOut = method_getImplementation(m);
    method_setImplementation(m, newImp);
}

static void HASwizzleClass(Class cls, SEL sel, IMP newImp, IMP *origOut) {
    Method m = class_getClassMethod(cls, sel);
    if (!m) return;
    *origOut = method_getImplementation(m);
    method_setImplementation(m, newImp);
}

__attribute__((constructor))
static void HAAutoLayoutSwizzleInstall(void) {
    if (!HAForceDisableAutoLayout() &&
        NSClassFromString(@"NSLayoutConstraint") != nil) {
        return;  // Auto Layout available and not force-disabled
    }

    Class uiview = [UIView class];
    HASwizzleInstance(uiview, @selector(setTranslatesAutoresizingMaskIntoConstraints:),
                      (IMP)HASwizzledSetTranslates, (IMP *)&sOrigSetTranslates);
    HASwizzleInstance(uiview, @selector(addConstraint:),
                      (IMP)HASwizzledAddConstraint, (IMP *)&sOrigAddConstraint);
    HASwizzleInstance(uiview, @selector(addConstraints:),
                      (IMP)HASwizzledAddConstraints, (IMP *)&sOrigAddConstraints);
    HASwizzleInstance(uiview, @selector(removeConstraint:),
                      (IMP)HASwizzledRemoveConstraint, (IMP *)&sOrigRemoveConstraint);
    HASwizzleInstance(uiview, @selector(removeConstraints:),
                      (IMP)HASwizzledRemoveConstraints, (IMP *)&sOrigRemoveConstraints);

    // NSLayoutConstraint instance: .active = YES
    Class nslc = NSClassFromString(@"NSLayoutConstraint");
    if (nslc) {
        HASwizzleInstance(nslc, @selector(setActive:),
                          (IMP)HASwizzledSetActive, (IMP *)&sOrigSetActive);
        HASwizzleClass(nslc, @selector(activateConstraints:),
                       (IMP)HASwizzledActivate, (IMP *)&sOrigActivate);
        HASwizzleClass(nslc, @selector(deactivateConstraints:),
                       (IMP)HASwizzledDeactivate, (IMP *)&sOrigDeactivate);
    }
}
