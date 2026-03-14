#import "HASunBasedTheme.h"
#import "HADateUtils.h"
#import "HALog.h"
#import "HAAutoLayout.h"
#import "HATheme.h"
#import "HAConnectionManager.h"
#import "HAEntity.h"

static NSString *const kSunEntityId = @"sun.sun";

@interface HASunBasedTheme ()
@property (nonatomic, assign) BOOL running;
@property (nonatomic, readwrite, assign) BOOL isSunBelowHorizon;
@property (nonatomic, strong) NSTimer *transitionTimer;
@end

@implementation HASunBasedTheme

+ (instancetype)sharedInstance {
    static HASunBasedTheme *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HASunBasedTheme alloc] init];
    });
    return instance;
}

- (void)start {
    // iOS 13+ has native dark mode — only run the sun entity tracker if
    // the user has explicitly opted in via "Use Sun Entity" in settings.
    // Use NSProcessInfo version check instead of @available because
    // @available checks the SDK version on x86_64 simulators running
    // legacy runtimes under RosettaSim, causing it to return YES even
    // on iOS 9.3.
    if (HASystemMajorVersion() >= 13
        && ![HATheme forceSunEntity]) {
        return;
    }

    if (self.running) return;
    self.running = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(entityDidUpdate:)
                                                 name:HAConnectionManagerEntityDidUpdateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeDidChange:)
                                                 name:HAThemeDidChangeNotification
                                               object:nil];

    [self evaluate];
}

- (void)stop {
    if (!self.running) return;
    self.running = NO;
    [self.transitionTimer invalidate];
    self.transitionTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Evaluation

- (void)evaluate {
    if ([HATheme currentMode] != HAThemeModeAuto) return;

    HAEntity *sun = [[HAConnectionManager sharedManager] entityForId:kSunEntityId];
    if (!sun) return;

    // sun.sun state is "above_horizon" or "below_horizon"
    BOOL belowHorizon = [sun.state isEqualToString:@"below_horizon"];
    BOOL changed = (belowHorizon != self.isSunBelowHorizon);
    self.isSunBelowHorizon = belowHorizon;

    if (changed) {
        HALogI(@"theme", @"Sun is now %@ — switching to %@ mode",
              belowHorizon ? @"below horizon" : @"above horizon",
              belowHorizon ? @"dark" : @"light");
        // Update the window's overrideUserInterfaceStyle so dynamic colors
        // resolve correctly on iOS 13+ when forceSunEntity is enabled.
        [HATheme applyInterfaceStyle];
        [[NSNotificationCenter defaultCenter] postNotificationName:HAThemeDidChangeNotification object:nil];
    }

    // Schedule timer for the next transition
    [self scheduleNextTransition:sun];
}

- (void)scheduleNextTransition:(HAEntity *)sun {
    [self.transitionTimer invalidate];
    self.transitionTimer = nil;

    // Determine the next event: if below horizon → next_rising, else → next_setting
    NSString *key = self.isSunBelowHorizon ? @"next_rising" : @"next_setting";
    NSString *dateStr = sun.attributes[key];
    if (!dateStr) return;

    NSDate *nextEvent = [self parseISO8601:dateStr];
    if (!nextEvent) return;

    NSTimeInterval delay = [nextEvent timeIntervalSinceNow];
    if (delay <= 0) {
        // Already past — re-evaluate shortly (entity may be stale)
        delay = 30.0;
    }

    HALogD(@"theme", @"Next %@ in %.0f seconds", key, delay);

    __weak typeof(self) weakSelf = self;
    self.transitionTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                           target:weakSelf
                                                         selector:@selector(timerFired)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)timerFired {
    [self evaluate];
}

#pragma mark - Notifications

- (void)entityDidUpdate:(NSNotification *)notification {
    HAEntity *entity = notification.userInfo[@"entity"];
    if ([entity.entityId isEqualToString:kSunEntityId]) {
        [self evaluate];
    }
}

- (void)themeDidChange:(NSNotification *)notification {
    if ([HATheme currentMode] == HAThemeModeAuto) {
        [self evaluate];
    } else {
        // User switched away from Auto — cancel timer
        [self.transitionTimer invalidate];
        self.transitionTimer = nil;
    }
}

#pragma mark - Date Parsing

- (NSDate *)parseISO8601:(NSString *)string {
    return [HADateUtils dateFromISO8601String:string];
}

@end
