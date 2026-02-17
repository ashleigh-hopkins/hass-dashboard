#import "HALockEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HATheme.h"
#import "HAHaptics.h"

@interface HALockEntityCell ()
@property (nonatomic, strong) UIButton *lockButton;
@property (nonatomic, strong) UILabel *lockStateLabel;
@end

@implementation HALockEntityCell

- (void)setupSubviews {
    [super setupSubviews];
    self.stateLabel.hidden = YES;

    CGFloat padding = 10.0;

    // Lock state indicator
    self.lockStateLabel = [[UILabel alloc] init];
    self.lockStateLabel.font = [UIFont systemFontOfSize:24];
    self.lockStateLabel.textAlignment = NSTextAlignmentCenter;
    self.lockStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.lockStateLabel];

    // Lock/unlock button
    self.lockButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.lockButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.lockButton.layer.cornerRadius = 6.0;
    self.lockButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.lockButton addTarget:self action:@selector(lockButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.lockButton];

    // State icon: right of name
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lockStateLabel attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lockStateLabel attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:padding]];

    // Button: bottom-right
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lockButton attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lockButton attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lockButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:80]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lockButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:32]];
}

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];

    self.lockButton.enabled = entity.isAvailable;

    if ([entity isLocked]) {
        self.lockStateLabel.text = @"\U0001F512"; // locked padlock
        [self.lockButton setTitle:@"Unlock" forState:UIControlStateNormal];
        self.lockButton.backgroundColor = [HATheme destructiveColor];
        [self.lockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.contentView.backgroundColor = [HATheme onTintColor];
    } else if ([entity isJammed]) {
        self.lockStateLabel.text = @"\u26A0"; // warning
        [self.lockButton setTitle:@"Lock" forState:UIControlStateNormal];
        self.lockButton.backgroundColor = [HATheme warningColor];
        [self.lockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.contentView.backgroundColor = [HATheme onTintColor];
    } else {
        // unlocked or unlocking/locking
        self.lockStateLabel.text = @"\U0001F513"; // unlocked padlock
        [self.lockButton setTitle:@"Lock" forState:UIControlStateNormal];
        self.lockButton.backgroundColor = [HATheme successColor];
        [self.lockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.contentView.backgroundColor = [HATheme cellBackgroundColor];
    }
}

#pragma mark - Actions

- (void)lockButtonTapped {
    if (!self.entity) return;

    BOOL isLocked = [self.entity isLocked];
    NSString *actionTitle = isLocked ? @"Unlock" : @"Lock";
    NSString *message = [NSString stringWithFormat:@"%@ %@?", actionTitle, [self.entity friendlyName]];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:actionTitle
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:actionTitle
                                              style:isLocked ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *a) {
        [self performLockAction:isLocked];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    // Walk up responder chain to find the view controller
    UIResponder *responder = self;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    UIViewController *vc = (UIViewController *)responder;
    if (vc) {
        [vc presentViewController:alert animated:YES completion:nil];
    }
}

- (void)performLockAction:(BOOL)currentlyLocked {
    [HAHaptics heavyImpact];

    NSString *service = currentlyLocked ? @"unlock" : @"lock";
    [[HAConnectionManager sharedManager] callService:service
                                            inDomain:@"lock"
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.lockStateLabel.text = nil;
    self.contentView.backgroundColor = [HATheme cellBackgroundColor];
}

@end
