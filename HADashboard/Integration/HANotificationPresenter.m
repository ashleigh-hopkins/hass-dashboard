#import "HANotificationPresenter.h"
#import "HALog.h"
#import <UIKit/UIKit.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif

NSString *const HADisplayNotificationReceivedNotification = @"HADisplayNotificationReceived";

@interface HANotificationPresenter ()
@property (nonatomic, assign) BOOL listening;
@property (nonatomic, assign) BOOL permissionRequested;
@end

@implementation HANotificationPresenter

+ (instancetype)sharedPresenter {
    static HANotificationPresenter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HANotificationPresenter alloc] init];
    });
    return instance;
}

#pragma mark - Start / Stop

- (void)start {
    if (self.listening) return;
    self.listening = YES;

    [self requestPermissionIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:HADisplayNotificationReceivedNotification
                                               object:nil];
    HALogI(@"notif", @"Started listening");
}

- (void)stop {
    if (!self.listening) return;
    self.listening = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HADisplayNotificationReceivedNotification
                                                  object:nil];
    HALogI(@"notif", @"Stopped");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Permission

- (void)requestPermissionIfNeeded {
    if (self.permissionRequested) return;
    self.permissionRequested = YES;

    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
                              completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
                HALogI(@"notif", @"Notification permission granted");
            } else {
                HALogW(@"notif", @"Notification permission denied: %@", error.localizedDescription);
            }
        }];
    } else {
        // iOS 9 fallback
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound)
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        HALogI(@"notif", @"Registered iOS 9 notification settings");
    }
}

#pragma mark - Notification Handling

- (void)notificationReceived:(NSNotification *)note {
    NSDictionary *eventData = note.userInfo;
    if (![eventData isKindOfClass:[NSDictionary class]]) return;

    NSString *title = eventData[@"title"];
    NSString *message = eventData[@"message"];

    // Normalize: ensure we have at least a body
    if (![title isKindOfClass:[NSString class]] || title.length == 0) {
        title = nil;
    }
    if (![message isKindOfClass:[NSString class]] || message.length == 0) {
        message = title ?: @"Notification";
        title = nil;
    }

    [self fireLocalNotificationWithTitle:title message:message];
}

- (void)fireLocalNotificationWithTitle:(NSString *)title message:(NSString *)message {
    HALogI(@"notif", @"Firing local notification: %@ — %@", title ?: @"(no title)", message);

    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        if (title) content.title = title;
        content.body = message;
        content.sound = [UNNotificationSound defaultSound];

        NSString *identifier = [[NSUUID UUID] UUIDString];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                              content:content
                                                                              trigger:nil]; // immediate
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request
                                                               withCompletionHandler:^(NSError *error) {
            if (error) {
                HALogE(@"notif", @"Failed to fire notification: %@", error.localizedDescription);
            }
        }];
    } else {
        // iOS 9 fallback
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UILocalNotification *local = [[UILocalNotification alloc] init];
        local.alertTitle = title;
        local.alertBody = message;
        local.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:local];
#pragma clang diagnostic pop
    }
}

@end
