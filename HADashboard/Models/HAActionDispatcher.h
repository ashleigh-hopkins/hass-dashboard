#import <UIKit/UIKit.h>

@class HAAction;
@class HAEntity;

/// Notification posted when a navigate action requests a view switch.
/// userInfo: @{@"path": NSString} — the navigation_path from the action config.
extern NSString *const HAActionNavigateNotification;

/// Centralized action executor for tap/hold/double-tap actions.
@interface HAActionDispatcher : NSObject

+ (instancetype)sharedDispatcher;

/// Execute an action for an entity, presenting UI from the given view controller.
/// @param action The resolved HAAction to execute
/// @param entity The entity context (may be nil for navigate/url actions)
/// @param vc The presenting view controller (for more-info sheets, confirmation dialogs)
- (void)executeAction:(HAAction *)action
            forEntity:(HAEntity *)entity
  fromViewController:(UIViewController *)vc;

@end
