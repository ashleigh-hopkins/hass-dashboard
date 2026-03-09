#import "UIViewController+HAAlert.h"
#import <objc/runtime.h>

#pragma mark - Alert/ActionSheet Delegate Helper (iOS 5-7)

static char kHAAlertDelegateKey;

@interface HAAlertDelegateHelper : NSObject
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
<UIAlertViewDelegate, UIActionSheetDelegate>
#pragma clang diagnostic pop
@property (nonatomic, copy) void (^handler)(NSInteger index);
@property (nonatomic, assign) NSInteger cancelIndex;
@end

@implementation HAAlertDelegateHelper

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.handler) {
        if (buttonIndex == self.cancelIndex) {
            self.handler(-1);
        } else {
            NSInteger adjusted = buttonIndex;
            if (self.cancelIndex >= 0 && buttonIndex > self.cancelIndex) {
                adjusted = buttonIndex - 1;
            }
            self.handler(adjusted);
        }
    }
    // Release the helper by clearing the associated object
    objc_setAssociatedObject(alertView, &kHAAlertDelegateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.handler) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            self.handler(-1);
        } else {
            NSInteger adjusted = buttonIndex;
            if (actionSheet.cancelButtonIndex >= 0 && buttonIndex > actionSheet.cancelButtonIndex) {
                adjusted = buttonIndex - 1;
            }
            self.handler(adjusted);
        }
    }
    objc_setAssociatedObject(actionSheet, &kHAAlertDelegateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma clang diagnostic pop

@end

#pragma mark - UIViewController+HAAlert

@implementation UIViewController (HAAlert)

- (void)ha_showAlertWithTitle:(NSString *)title
                      message:(NSString *)message
                  cancelTitle:(NSString *)cancelTitle
                 actionTitles:(NSArray<NSString *> *)actionTitles
                      handler:(void (^)(NSInteger index))handler {

    if ([UIAlertController class]) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
        if (cancelTitle) {
            [ac addAction:[UIAlertAction actionWithTitle:cancelTitle
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction *a) {
                if (handler) handler(-1);
            }]];
        }
        [actionTitles enumerateObjectsUsingBlock:^(NSString *t, NSUInteger idx, BOOL *stop) {
            [ac addAction:[UIAlertAction actionWithTitle:t
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *a) {
                if (handler) handler((NSInteger)idx);
            }]];
        }];
        [self presentViewController:ac animated:YES completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        HAAlertDelegateHelper *helper = [[HAAlertDelegateHelper alloc] init];
        helper.handler = handler;

        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:helper
                                           cancelButtonTitle:cancelTitle
                                           otherButtonTitles:nil];
        helper.cancelIndex = cancelTitle ? av.cancelButtonIndex : -1;
        for (NSString *t in actionTitles) {
            [av addButtonWithTitle:t];
        }
        objc_setAssociatedObject(av, &kHAAlertDelegateKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [av show];
#pragma clang diagnostic pop
    }
}

- (void)ha_showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self ha_showAlertWithTitle:title
                       message:message
                   cancelTitle:@"OK"
                  actionTitles:nil
                       handler:nil];
}

- (void)ha_showActionSheetWithTitle:(NSString *)title
                        cancelTitle:(NSString *)cancelTitle
                       actionTitles:(NSArray<NSString *> *)actionTitles
                         sourceView:(UIView *)sourceView
                            handler:(void (^)(NSInteger index))handler {

    if ([UIAlertController class]) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
        [actionTitles enumerateObjectsUsingBlock:^(NSString *t, NSUInteger idx, BOOL *stop) {
            [ac addAction:[UIAlertAction actionWithTitle:t
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *a) {
                if (handler) handler((NSInteger)idx);
            }]];
        }];
        if (cancelTitle) {
            [ac addAction:[UIAlertAction actionWithTitle:cancelTitle
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction *a) {
                if (handler) handler(-1);
            }]];
        }
        if (sourceView) {
            ac.popoverPresentationController.sourceView = sourceView;
            ac.popoverPresentationController.sourceRect = sourceView.bounds;
        }
        [self presentViewController:ac animated:YES completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        HAAlertDelegateHelper *helper = [[HAAlertDelegateHelper alloc] init];
        helper.handler = handler;

        UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:title
                                                        delegate:helper
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
        for (NSString *t in actionTitles) {
            [as addButtonWithTitle:t];
        }
        if (cancelTitle) {
            NSInteger cancelIdx = [as addButtonWithTitle:cancelTitle];
            as.cancelButtonIndex = cancelIdx;
        }
        helper.cancelIndex = as.cancelButtonIndex;
        objc_setAssociatedObject(as, &kHAAlertDelegateKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        if (sourceView) {
            [as showFromRect:sourceView.bounds inView:sourceView animated:YES];
        } else {
            [as showInView:self.view];
        }
#pragma clang diagnostic pop
    }
}

- (void)ha_showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration {
    if ([UIAlertController class]) {
        UIAlertController *toast = [UIAlertController alertControllerWithTitle:nil
                                                                      message:message
                                                               preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:toast animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast dismissViewControllerAnimated:YES completion:nil];
        });
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:nil];
        [av show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [av dismissWithClickedButtonIndex:-1 animated:YES];
        });
#pragma clang diagnostic pop
    }
}

@end
