#import "HASceneEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HATheme.h"
#import "HAHaptics.h"

static const NSTimeInterval kActivationFeedbackDuration = 1.5;

@interface HASceneEntityCell ()
@property (nonatomic, strong) UIButton *activateButton;
@property (nonatomic, strong) UILabel *feedbackLabel;
@property (nonatomic, assign) BOOL activating;
@end

@implementation HASceneEntityCell

- (void)setupSubviews {
    [super setupSubviews];
    self.stateLabel.hidden = YES;

    CGFloat padding = 10.0;

    // Activate button
    self.activateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.activateButton setTitle:@"Activate" forState:UIControlStateNormal];
    self.activateButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.activateButton.backgroundColor = [HATheme accentColor];
    [self.activateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.activateButton.layer.cornerRadius = 6.0;
    self.activateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.activateButton addTarget:self action:@selector(activateTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.activateButton];

    // Feedback label (shown briefly after activation)
    self.feedbackLabel = [[UILabel alloc] init];
    self.feedbackLabel.text = @"Activated";
    self.feedbackLabel.font = [UIFont boldSystemFontOfSize:13];
    self.feedbackLabel.textColor = [HATheme successColor];
    self.feedbackLabel.textAlignment = NSTextAlignmentCenter;
    self.feedbackLabel.alpha = 0.0;
    self.feedbackLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.feedbackLabel];

    // Activate button: centered bottom
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.activateButton attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.activateButton attribute:NSLayoutAttributeCenterY
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.activateButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:80]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.activateButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:32]];

    // Feedback label: same position as button
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.feedbackLabel attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual toItem:self.activateButton attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.feedbackLabel attribute:NSLayoutAttributeCenterY
        relatedBy:NSLayoutRelationEqual toItem:self.activateButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];

    self.activateButton.enabled = entity.isAvailable;

    NSString *domain = [entity domain];
    if ([domain isEqualToString:HAEntityDomainScript]) {
        [self.activateButton setTitle:@"Run" forState:UIControlStateNormal];
        self.activateButton.backgroundColor = [HATheme accentColor];
    } else {
        [self.activateButton setTitle:@"Activate" forState:UIControlStateNormal];
        self.activateButton.backgroundColor = [HATheme accentColor];
    }

    // Reset feedback state if not currently animating
    if (!self.activating) {
        self.activateButton.alpha = 1.0;
        self.feedbackLabel.alpha = 0.0;
    }
}

#pragma mark - Actions

- (void)activateTapped {
    if (!self.entity || self.activating) return;

    self.activating = YES;

    [HAHaptics notifySuccess];

    // Call the service
    NSString *domain = [self.entity domain];
    [[HAConnectionManager sharedManager] callService:@"turn_on"
                                            inDomain:domain
                                            withData:nil
                                            entityId:self.entity.entityId];

    // Visual feedback: flash the button, show "Activated"
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        self.activateButton.alpha = 0.0;
        self.feedbackLabel.alpha = 1.0;
        self.contentView.backgroundColor = [HATheme onTintColor];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kActivationFeedbackDuration * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                [UIView animateWithDuration:0.3 animations:^{
                    strongSelf.activateButton.alpha = 1.0;
                    strongSelf.feedbackLabel.alpha = 0.0;
                    strongSelf.contentView.backgroundColor = [HATheme cellBackgroundColor];
                } completion:^(BOOL finished2) {
                    strongSelf.activating = NO;
                }];
            });
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.activating = NO;
    self.activateButton.alpha = 1.0;
    self.feedbackLabel.alpha = 0.0;
    self.contentView.backgroundColor = [HATheme cellBackgroundColor];
    self.activateButton.backgroundColor = [HATheme accentColor];
    self.feedbackLabel.textColor = [HATheme successColor];
}

@end
