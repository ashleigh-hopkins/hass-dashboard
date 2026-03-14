#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import "HAAutoLayout.h"

/// Developer toggle: intercept Auto Layout operations that originate from
/// our app code (not UIKit internals) when HAForceDisableAutoLayout is on.
///
/// Strategy: check the caller's return address. If it's in our app binary,
/// suppress the operation. If it's in a system framework, let it through.
/// This preserves UIKit's own internal Auto Layout (nav bars, keyboards, etc.)
/// while disabling our app's constraint setup.
///
/// Swizzles are installed LAZILY — only when the toggle is first enabled,
/// not at app launch. This avoids modifying system class implementations
/// on normal App Store launches where the toggle is off.

static void *sAppTextStart = NULL;
static void *sAppTextEnd = NULL;
static BOOL sSwizzlesInstalled = NO;

static void HAFindAppTextRange(void) {
    Dl_info info;
    // Use our own function to find our binary's load address
    if (dladdr((void *)HAFindAppTextRange, &info)) {
        // The app binary's __TEXT segment starts at dli_fbase
        sAppTextStart = info.dli_fbase;
        // Estimate end — 20MB should cover any app binary
        sAppTextEnd = (void *)((uintptr_t)sAppTextStart + 20 * 1024 * 1024);
    }
}

static BOOL HACallerIsApp(void) {
    // Walk up the call stack: our swizzle (0) -> objc_msgSend (1) -> caller (2)
    void *ret = __builtin_return_address(1);
    return (ret >= sAppTextStart && ret < sAppTextEnd);
}

static IMP sOrigSetTranslates;
static IMP sOrigAddConstraint;
static IMP sOrigAddConstraints;
static IMP sOrigRemoveConstraint;
static IMP sOrigRemoveConstraints;
static IMP sOrigSetActive;
static IMP sOrigActivate;
static IMP sOrigDeactivate;

static void HASwizzledSetTranslates(id self, SEL _cmd, BOOL val) {
    if (!val && HACallerIsApp()) return;
    ((void(*)(id,SEL,BOOL))sOrigSetTranslates)(self, _cmd, val);
}

static void HASwizzledAddConstraint(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    ((void(*)(id,SEL,id))sOrigAddConstraint)(self, _cmd, c);
}

static void HASwizzledAddConstraints(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    ((void(*)(id,SEL,id))sOrigAddConstraints)(self, _cmd, c);
}

static void HASwizzledRemoveConstraint(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    ((void(*)(id,SEL,id))sOrigRemoveConstraint)(self, _cmd, c);
}

static void HASwizzledRemoveConstraints(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    ((void(*)(id,SEL,id))sOrigRemoveConstraints)(self, _cmd, c);
}

static void HASwizzledSetActive(id self, SEL _cmd, BOOL active) {
    if (HACallerIsApp()) return;
    ((void(*)(id,SEL,BOOL))sOrigSetActive)(self, _cmd, active);
}

static void HASwizzledActivate(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    ((void(*)(id,SEL,id))sOrigActivate)(self, _cmd, c);
}

static void HASwizzledDeactivate(id self, SEL _cmd, id c) {
    if (HACallerIsApp()) return;
    ((void(*)(id,SEL,id))sOrigDeactivate)(self, _cmd, c);
}

typedef struct {
    Class cls;
    SEL sel;
    BOOL isClass; // class method vs instance method
    IMP newImp;
    IMP *origOut;
} HASwizzleEntry;

static HASwizzleEntry sEntries[8];
static int sEntryCount = 0;

static void HARegisterSwizzle(Class cls, SEL sel, BOOL isClass, IMP newImp, IMP *origOut) {
    if (sEntryCount >= 8) return;
    sEntries[sEntryCount++] = (HASwizzleEntry){cls, sel, isClass, newImp, origOut};
}

void HAAutoLayoutSwizzleInstall(void) {
    if (sSwizzlesInstalled) return;

    HAFindAppTextRange();
    if (!sAppTextStart) return;

    Class uiview = [UIView class];
    sEntryCount = 0;

    HARegisterSwizzle(uiview, @selector(setTranslatesAutoresizingMaskIntoConstraints:), NO,
                      (IMP)HASwizzledSetTranslates, &sOrigSetTranslates);
    HARegisterSwizzle(uiview, @selector(addConstraint:), NO,
                      (IMP)HASwizzledAddConstraint, &sOrigAddConstraint);
    HARegisterSwizzle(uiview, @selector(addConstraints:), NO,
                      (IMP)HASwizzledAddConstraints, &sOrigAddConstraints);
    HARegisterSwizzle(uiview, @selector(removeConstraint:), NO,
                      (IMP)HASwizzledRemoveConstraint, &sOrigRemoveConstraint);
    HARegisterSwizzle(uiview, @selector(removeConstraints:), NO,
                      (IMP)HASwizzledRemoveConstraints, &sOrigRemoveConstraints);

    Class nslc = NSClassFromString(@"NSLayoutConstraint");
    if (nslc) {
        HARegisterSwizzle(nslc, @selector(setActive:), NO,
                          (IMP)HASwizzledSetActive, &sOrigSetActive);
        HARegisterSwizzle(nslc, @selector(activateConstraints:), YES,
                          (IMP)HASwizzledActivate, &sOrigActivate);
        HARegisterSwizzle(nslc, @selector(deactivateConstraints:), YES,
                          (IMP)HASwizzledDeactivate, &sOrigDeactivate);
    }

    for (int i = 0; i < sEntryCount; i++) {
        Method m = sEntries[i].isClass
            ? class_getClassMethod(sEntries[i].cls, sEntries[i].sel)
            : class_getInstanceMethod(sEntries[i].cls, sEntries[i].sel);
        if (!m) continue;
        *sEntries[i].origOut = method_getImplementation(m);
        method_setImplementation(m, sEntries[i].newImp);
    }

    sSwizzlesInstalled = YES;
}

/// Install at launch if the developer toggle was left on from a previous session.
/// This ensures the app boots into iOS 5 simulation mode without needing to
/// visit Settings first. The swizzles can still be installed/uninstalled live
/// via the Settings toggle calling HAAutoLayoutSwizzleInstall/Uninstall.
__attribute__((constructor))
static void HAAutoLayoutSwizzleBootCheck(void) {
    if (HAForceDisableAutoLayout()) {
        HAAutoLayoutSwizzleInstall();
    }
}

void HAAutoLayoutSwizzleUninstall(void) {
    if (!sSwizzlesInstalled) return;

    for (int i = 0; i < sEntryCount; i++) {
        if (!*sEntries[i].origOut) continue;
        Method m = sEntries[i].isClass
            ? class_getClassMethod(sEntries[i].cls, sEntries[i].sel)
            : class_getInstanceMethod(sEntries[i].cls, sEntries[i].sel);
        if (m) method_setImplementation(m, *sEntries[i].origOut);
        *sEntries[i].origOut = NULL;
    }

    sSwizzlesInstalled = NO;
}
