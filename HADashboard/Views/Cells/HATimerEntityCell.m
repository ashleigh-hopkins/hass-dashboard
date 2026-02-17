#import "HATimerEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HATheme.h"

@interface HATimerEntityCell ()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation HATimerEntityCell

- (void)setupSubviews {
    [super setupSubviews];
    self.stateLabel.hidden = YES;

    CGFloat padding = 10.0;

    // Time display
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont monospacedDigitSystemFontOfSize:20 weight:UIFontWeightMedium];
    self.timeLabel.textColor = [HATheme primaryTextColor];
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.timeLabel];

    CGFloat buttonWidth = 56.0;
    CGFloat buttonHeight = 28.0;
    CGFloat buttonSpacing = 4.0;

    // Start button
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    self.startButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.startButton.backgroundColor = [HATheme successColor];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startButton.layer.cornerRadius = 4.0;
    self.startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.startButton addTarget:self action:@selector(startTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.startButton];

    // Pause button
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    self.pauseButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.pauseButton.backgroundColor = [HATheme warningColor];
    [self.pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.pauseButton.layer.cornerRadius = 4.0;
    self.pauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pauseButton addTarget:self action:@selector(pauseTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.pauseButton];

    // Cancel button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.cancelButton.backgroundColor = [HATheme destructiveColor];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.layer.cornerRadius = 4.0;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelButton];

    // Time label: below name
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:4]];

    // Buttons: bottom-right row
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:buttonWidth]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:buttonHeight]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pauseButton attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.cancelButton attribute:NSLayoutAttributeLeading multiplier:1 constant:-buttonSpacing]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pauseButton attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pauseButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:buttonWidth]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pauseButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:buttonHeight]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.startButton attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.pauseButton attribute:NSLayoutAttributeLeading multiplier:1 constant:-buttonSpacing]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.startButton attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.startButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:buttonWidth]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.startButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:buttonHeight]];
}

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];

    NSString *state = entity.state;
    BOOL isActive = [state isEqualToString:@"active"];
    BOOL isPaused = [state isEqualToString:@"paused"];
    BOOL isIdle = [state isEqualToString:@"idle"];

    // Show remaining time if active/paused, otherwise duration
    NSString *remaining = [entity timerRemaining];
    NSString *duration = [entity timerDuration];
    if (isActive || isPaused) {
        self.timeLabel.text = remaining ?: duration ?: @"--:--:--";
    } else {
        self.timeLabel.text = duration ?: @"--:--:--";
    }

    if (isActive) {
        self.timeLabel.textColor = [HATheme accentColor];
    } else if (isPaused) {
        self.timeLabel.textColor = [HATheme warningColor];
    } else {
        self.timeLabel.textColor = [HATheme primaryTextColor];
    }

    BOOL available = entity.isAvailable;
    self.startButton.enabled = available && (isIdle || isPaused);
    self.pauseButton.enabled = available && isActive;
    self.cancelButton.enabled = available && (isActive || isPaused);
}

#pragma mark - Actions

- (void)startTapped {
    if (!self.entity) return;
    [[HAConnectionManager sharedManager] callService:@"start"
                                            inDomain:HAEntityDomainTimer
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)pauseTapped {
    if (!self.entity) return;
    [[HAConnectionManager sharedManager] callService:@"pause"
                                            inDomain:HAEntityDomainTimer
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)cancelTapped {
    if (!self.entity) return;
    [[HAConnectionManager sharedManager] callService:@"cancel"
                                            inDomain:HAEntityDomainTimer
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.timeLabel.text = nil;
    self.timeLabel.textColor = [HATheme primaryTextColor];
    self.startButton.backgroundColor = [HATheme successColor];
    self.pauseButton.backgroundColor = [HATheme warningColor];
    self.cancelButton.backgroundColor = [HATheme destructiveColor];
}

@end
