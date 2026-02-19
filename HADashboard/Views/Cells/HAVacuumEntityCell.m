#import "HAVacuumEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HAHaptics.h"
#import "HATheme.h"
#import "HAIconMapper.h"
#import "HAEntityDisplayHelper.h"

static const CGFloat kIconCircleSize = 60.0;
static const CGFloat kIconFontSize   = 32.0;
static const CGFloat kButtonSize     = 36.0;
static const CGFloat kButtonIconSize = 18.0;
static const CGFloat kButtonSpacing  = 12.0;

@interface HAVacuumEntityCell ()
@property (nonatomic, strong) UIView  *iconCircle;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *statusLabel2;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIButton *returnHomeButton;
@property (nonatomic, strong) UIButton *powerButton;
@property (nonatomic, copy)   NSArray<NSString *> *configuredCommands;
@end

@implementation HAVacuumEntityCell

- (void)setupSubviews {
    [super setupSubviews];
    // Hide base cell labels — vacuum card has its own centered layout
    self.nameLabel.hidden = YES;
    self.stateLabel.hidden = YES;

    CGFloat padding = 10.0;

    // -- Icon circle (centered, top area) --
    self.iconCircle = [[UIView alloc] init];
    self.iconCircle.layer.cornerRadius = kIconCircleSize / 2.0;
    self.iconCircle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.iconCircle];

    self.iconLabel = [[UILabel alloc] init];
    self.iconLabel.textAlignment = NSTextAlignmentCenter;
    self.iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.iconCircle addSubview:self.iconLabel];

    // -- Status label --
    self.statusLabel2 = [[UILabel alloc] init];
    self.statusLabel2.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.statusLabel2.textColor = [HATheme secondaryTextColor];
    self.statusLabel2.textAlignment = NSTextAlignmentCenter;
    self.statusLabel2.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.statusLabel2];

    // -- Command buttons --
    self.playPauseButton  = [self makeCommandButton];
    self.returnHomeButton = [self makeCommandButton];
    self.powerButton      = [self makeCommandButton];

    [self.playPauseButton  addTarget:self action:@selector(playPauseTapped)  forControlEvents:UIControlEventTouchUpInside];
    [self.returnHomeButton addTarget:self action:@selector(returnHomeTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.powerButton      addTarget:self action:@selector(powerTapped)      forControlEvents:UIControlEventTouchUpInside];

    // --- Layout constraints ---
    // Icon circle and status label use auto layout. Buttons are positioned in layoutSubviews
    // to handle dynamic visibility (only configured commands shown).

    // Icon circle: centered horizontally, near top
    [NSLayoutConstraint activateConstraints:@[
        [self.iconCircle.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.iconCircle.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:padding + 4],
        [self.iconCircle.widthAnchor constraintEqualToConstant:kIconCircleSize],
        [self.iconCircle.heightAnchor constraintEqualToConstant:kIconCircleSize],
    ]];

    // Icon label: centered inside circle
    [NSLayoutConstraint activateConstraints:@[
        [self.iconLabel.centerXAnchor constraintEqualToAnchor:self.iconCircle.centerXAnchor],
        [self.iconLabel.centerYAnchor constraintEqualToAnchor:self.iconCircle.centerYAnchor],
    ]];

    // Status label: below icon circle, centered
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel2.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.statusLabel2.topAnchor constraintEqualToAnchor:self.iconCircle.bottomAnchor constant:4],
        [self.statusLabel2.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.statusLabel2.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
    ]];

    // Buttons don't use auto layout — positioned in layoutSubviews for dynamic visibility
    self.playPauseButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.returnHomeButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.powerButton.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat padding = 10.0;
    CGFloat contentW = self.contentView.bounds.size.width;
    CGFloat contentH = self.contentView.bounds.size.height;

    // Collect visible buttons
    NSMutableArray<UIButton *> *visibleButtons = [NSMutableArray array];
    if (!self.playPauseButton.hidden) [visibleButtons addObject:self.playPauseButton];
    if (!self.returnHomeButton.hidden) [visibleButtons addObject:self.returnHomeButton];
    if (!self.powerButton.hidden) [visibleButtons addObject:self.powerButton];

    NSUInteger count = visibleButtons.count;
    if (count == 0) return;

    CGFloat totalButtonsWidth = count * kButtonSize + (count - 1) * kButtonSpacing;
    CGFloat startX = (contentW - totalButtonsWidth) / 2.0;
    CGFloat btnY = contentH - padding - kButtonSize;

    for (NSUInteger i = 0; i < count; i++) {
        UIButton *btn = visibleButtons[i];
        btn.frame = CGRectMake(startX + i * (kButtonSize + kButtonSpacing), btnY, kButtonSize, kButtonSize);
    }
}

- (UIButton *)makeCommandButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = kButtonSize / 2.0;
    btn.clipsToBounds = YES;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:btn];
    return btn;
}

#pragma mark - Configuration

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];

    // Keep base labels hidden
    self.nameLabel.hidden = YES;
    self.stateLabel.hidden = YES;

    // Read configured commands from card config (e.g. ["start_pause", "return_home", "on_off"])
    // Mushroom default: no buttons unless commands are explicitly configured.
    NSArray *commands = configItem.customProperties[@"commands"];
    if ([commands isKindOfClass:[NSArray class]] && commands.count > 0) {
        self.configuredCommands = commands;
    } else {
        self.configuredCommands = @[]; // mushroom default: no buttons
    }

    // Filter commands by entity supported_features bitmask (matching mushroom behavior).
    // Even if a command is configured, hide it if the vacuum doesn't support the feature.
    NSInteger features = [entity supportedFeatures];
    BOOL supportsStart    = (features & (1 << 13)) != 0; // START = 8192
    BOOL supportsPause    = (features & (1 << 2)) != 0;  // PAUSE = 4
    BOOL supportsStop     = (features & (1 << 3)) != 0;  // STOP = 8
    BOOL supportsReturn   = (features & (1 << 4)) != 0;  // RETURN_HOME = 16
    BOOL supportsTurnOn   = (features & (1 << 0)) != 0;  // TURN_ON = 1
    BOOL supportsTurnOff  = (features & (1 << 1)) != 0;  // TURN_OFF = 2

    BOOL showPlayPause = [self.configuredCommands containsObject:@"start_pause"]
                         && (supportsStart || supportsPause);
    BOOL showReturnHome = [self.configuredCommands containsObject:@"return_home"]
                          && supportsReturn;
    BOOL showPower = [self.configuredCommands containsObject:@"on_off"]
                     && (supportsTurnOn || supportsTurnOff);

    self.playPauseButton.hidden = !showPlayPause;
    self.returnHomeButton.hidden = !showReturnHome;
    self.powerButton.hidden = !showPower;

    if (!entity) {
        self.statusLabel2.text = @"Unavailable";
        [self applyIconColorForState:nil];
        [self updateButtonIcons:nil];
        return;
    }

    // Status text: vacuum status with optional battery
    NSString *vacuumState = [entity vacuumStatus] ?: entity.state ?: @"unknown";
    NSNumber *battery = [entity vacuumBatteryLevel];
    NSMutableString *display = [NSMutableString stringWithString:[HAEntityDisplayHelper humanReadableState:vacuumState]];
    if (battery) {
        [display appendFormat:@" \u2022 %@%%", battery];
    }
    self.statusLabel2.text = display;

    // Icon color based on state
    [self applyIconColorForState:vacuumState];

    // Button states
    [self updateButtonIcons:vacuumState];

    BOOL available = entity.isAvailable;
    self.playPauseButton.enabled = available;
    self.returnHomeButton.enabled = available;
    self.powerButton.enabled = available;
    self.playPauseButton.alpha = available ? 1.0 : 0.4;
    self.returnHomeButton.alpha = available ? 1.0 : 0.4;
    self.powerButton.alpha = available ? 1.0 : 0.4;
}

- (void)applyIconColorForState:(NSString *)vacuumState {
    UIColor *iconColor;
    UIColor *circleBg;

    NSString *state = [vacuumState lowercaseString];

    if ([state isEqualToString:@"cleaning"]) {
        iconColor = [UIColor colorWithRed:0.0 green:0.75 blue:0.65 alpha:1.0]; // Teal
        circleBg  = [UIColor colorWithRed:0.0 green:0.75 blue:0.65 alpha:0.15];
    } else if ([state isEqualToString:@"returning"]) {
        iconColor = [HATheme accentColor]; // Blue
        circleBg  = [[HATheme accentColor] colorWithAlphaComponent:0.15];
    } else if ([state isEqualToString:@"error"]) {
        iconColor = [HATheme destructiveColor]; // Red
        circleBg  = [[HATheme destructiveColor] colorWithAlphaComponent:0.15];
    } else {
        // Docked, idle, off, paused, unknown
        iconColor = [HATheme secondaryTextColor]; // Gray
        circleBg  = [HATheme tertiaryTextColor]; // Subtle gray
        circleBg  = [circleBg colorWithAlphaComponent:0.3];
    }

    self.iconCircle.backgroundColor = circleBg;

    // Set the robot-vacuum MDI glyph
    NSString *glyph = [HAIconMapper glyphForIconName:@"robot-vacuum"] ?: @"\u2699"; // fallback gear
    NSAttributedString *iconAttr = [[NSAttributedString alloc] initWithString:glyph
        attributes:@{
            NSFontAttributeName: [HAIconMapper mdiFontOfSize:kIconFontSize],
            NSForegroundColorAttributeName: iconColor
        }];
    self.iconLabel.attributedText = iconAttr;
}

- (void)updateButtonIcons:(NSString *)vacuumState {
    NSString *state = [vacuumState lowercaseString];
    BOOL isCleaning = [state isEqualToString:@"cleaning"];
    BOOL isOn = ![state isEqualToString:@"off"] && state != nil;

    // Play/Pause button: show pause icon when cleaning, play icon otherwise
    NSString *playPauseIcon = isCleaning ? @"pause" : @"play";
    [self setButton:self.playPauseButton iconName:playPauseIcon];

    // Return home button
    [self setButton:self.returnHomeButton iconName:@"home"];

    // Power button: show power-off styling when on, power-on when off
    [self setButton:self.powerButton iconName:@"power"];

    // Button background colors
    UIColor *btnBg = [HATheme tertiaryTextColor];
    btnBg = [btnBg colorWithAlphaComponent:0.25];

    self.playPauseButton.backgroundColor = btnBg;
    self.returnHomeButton.backgroundColor = btnBg;
    self.powerButton.backgroundColor = isOn ? btnBg : [[HATheme secondaryTextColor] colorWithAlphaComponent:0.15];
}

- (void)setButton:(UIButton *)button iconName:(NSString *)iconName {
    NSString *glyph = [HAIconMapper glyphForIconName:iconName] ?: @"?";
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:glyph
        attributes:@{
            NSFontAttributeName: [HAIconMapper mdiFontOfSize:kButtonIconSize],
            NSForegroundColorAttributeName: [HATheme primaryTextColor]
        }];
    [button setAttributedTitle:attr forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)playPauseTapped {
    if (!self.entity) return;
    [HAHaptics mediumImpact];

    NSString *state = [[self.entity vacuumStatus] ?: self.entity.state lowercaseString];
    NSString *service;
    if ([state isEqualToString:@"cleaning"]) {
        service = @"pause";
    } else {
        service = @"start";
    }

    [[HAConnectionManager sharedManager] callService:service
                                            inDomain:HAEntityDomainVacuum
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)returnHomeTapped {
    if (!self.entity) return;
    [HAHaptics mediumImpact];

    [[HAConnectionManager sharedManager] callService:@"return_to_base"
                                            inDomain:HAEntityDomainVacuum
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)powerTapped {
    if (!self.entity) return;
    [HAHaptics mediumImpact];

    NSString *state = [[self.entity vacuumStatus] ?: self.entity.state lowercaseString];
    NSString *service;
    if ([state isEqualToString:@"off"]) {
        service = @"turn_on";
    } else {
        service = @"turn_off";
    }

    [[HAConnectionManager sharedManager] callService:service
                                            inDomain:HAEntityDomainVacuum
                                            withData:nil
                                            entityId:self.entity.entityId];
}

#pragma mark - Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    self.statusLabel2.text = nil;
    self.iconLabel.attributedText = nil;
    self.iconCircle.backgroundColor = nil;
    self.configuredCommands = nil;
    self.playPauseButton.hidden = NO;
    self.returnHomeButton.hidden = NO;
    self.powerButton.hidden = NO;
    self.statusLabel2.textColor = [HATheme secondaryTextColor];
}

@end
