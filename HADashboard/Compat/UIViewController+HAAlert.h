#import <UIKit/UIKit.h>

@interface UIViewController (HAAlert)

/// Show an alert with a title, message, and action buttons.
/// On iOS 8+: UIAlertController.  On iOS 5-7: UIAlertView.
/// handler receives the index of the tapped button (0-based, matching actions array order).
/// Cancel button (if cancelTitle is non-nil) passes index -1.
- (void)ha_showAlertWithTitle:(NSString *)title
                      message:(NSString *)message
                  cancelTitle:(NSString *)cancelTitle
                 actionTitles:(NSArray<NSString *> *)actionTitles
                      handler:(void (^)(NSInteger index))handler;

/// Convenience: simple OK alert with no handler.
- (void)ha_showAlertWithTitle:(NSString *)title message:(NSString *)message;

/// Show an action sheet.
/// On iOS 8+: UIAlertController with UIAlertControllerStyleActionSheet.
/// On iOS 5-7: UIActionSheet.
/// sourceView is used for iPad popover anchoring on iOS 8+ (may be nil).
- (void)ha_showActionSheetWithTitle:(NSString *)title
                        cancelTitle:(NSString *)cancelTitle
                       actionTitles:(NSArray<NSString *> *)actionTitles
                         sourceView:(UIView *)sourceView
                            handler:(void (^)(NSInteger index))handler;

/// Show a brief auto-dismissing toast message.
/// On iOS 8+: UIAlertController dismissed after delay.
/// On iOS 5-7: UIAlertView dismissed after delay.
- (void)ha_showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration;

@end
