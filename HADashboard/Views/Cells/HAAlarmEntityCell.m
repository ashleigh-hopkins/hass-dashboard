#import "HAAlarmEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HATheme.h"
#import "HAHaptics.h"

static const CGFloat kPadding = 10.0;
static const CGFloat kActionButtonWidth = 70.0;
static const CGFloat kActionButtonHeight = 28.0;
static const CGFloat kActionButtonSpacing = 4.0;
static const CGFloat kKeypadButtonSize = 44.0;
static const CGFloat kKeypadButtonSpacing = 8.0;
static const CGFloat kCodeFieldHeight = 36.0;

// Tags for keypad digit buttons (tag = digit value, 10 = clear, 11 = enter)
static const NSInteger kKeypadTagClear = 10;
static const NSInteger kKeypadTagEnter = 11;

@interface HAAlarmEntityCell () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *alarmStateLabel;
@property (nonatomic, strong) UIButton *armAwayButton;
@property (nonatomic, strong) UIButton *armHomeButton;
@property (nonatomic, strong) UIButton *disarmButton;
@property (nonatomic, strong) UITextField *codeTextField;
@property (nonatomic, strong) UIView *keypadContainer;
@property (nonatomic, strong) NSMutableArray<UIButton *> *keypadButtons;
@property (nonatomic, copy) NSString *pendingService;
@property (nonatomic, assign) BOOL keypadVisible;
@end

@implementation HAAlarmEntityCell

#pragma mark - Height Calculations

+ (CGFloat)preferredHeightWithoutKeypad {
    // nameLabel (padding + ~16) + alarmState (~20 + 4 gap) + action buttons (28) + padding top/bottom
    return 100.0;
}

+ (CGFloat)preferredHeightWithKeypad {
    // Base layout: name + state + action buttons row = ~70pt from top
    // Then: gap(8) + code field(36) + gap(8) + 4 rows of keypad buttons (4*44 + 3*8) + padding(10)
    CGFloat baseTop = 70.0; // name + state + buttons
    CGFloat codeSection = 8.0 + kCodeFieldHeight; // gap + text field
    CGFloat keypadRows = 4.0 * kKeypadButtonSize + 3.0 * kKeypadButtonSpacing; // 4 rows
    CGFloat bottomPad = kPadding;
    return baseTop + codeSection + 8.0 + keypadRows + bottomPad;
}

#pragma mark - Setup

- (void)setupSubviews {
    [super setupSubviews];
    self.stateLabel.hidden = YES;
    self.keypadButtons = [NSMutableArray array];

    // Alarm state label (prominent display)
    self.alarmStateLabel = [[UILabel alloc] init];
    self.alarmStateLabel.font = [UIFont boldSystemFontOfSize:16];
    self.alarmStateLabel.textColor = [HATheme primaryTextColor];
    self.alarmStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.alarmStateLabel];

    // Action buttons: Disarm / Home / Away
    self.armAwayButton = [self createActionButtonWithTitle:@"Away"
                                                    color:[HATheme destructiveColor]
                                                   action:@selector(armAwayTapped)];
    self.armHomeButton = [self createActionButtonWithTitle:@"Home"
                                                    color:[HATheme warningColor]
                                                   action:@selector(armHomeTapped)];
    self.disarmButton = [self createActionButtonWithTitle:@"Disarm"
                                                   color:[HATheme successColor]
                                                  action:@selector(disarmTapped)];

    // Code text field (secure entry, monospaced, centered)
    self.codeTextField = [[UITextField alloc] init];
    self.codeTextField.font = [UIFont monospacedDigitSystemFontOfSize:18 weight:UIFontWeightMedium];
    self.codeTextField.textColor = [HATheme primaryTextColor];
    self.codeTextField.textAlignment = NSTextAlignmentCenter;
    self.codeTextField.secureTextEntry = YES;
    self.codeTextField.placeholder = @"Code";
    self.codeTextField.backgroundColor = [HATheme controlBackgroundColor];
    self.codeTextField.layer.cornerRadius = 8.0;
    self.codeTextField.layer.borderWidth = 1.0;
    self.codeTextField.layer.borderColor = [HATheme controlBorderColor].CGColor;
    self.codeTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.codeTextField.delegate = self;
    // Prevent system keyboard from appearing; we use the keypad
    self.codeTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.codeTextField];

    // Keypad container
    self.keypadContainer = [[UIView alloc] init];
    self.keypadContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.keypadContainer];

    [self buildKeypad];
    [self setupConstraints];

    // Initially hidden until configureWithEntity determines visibility
    self.codeTextField.hidden = YES;
    self.keypadContainer.hidden = YES;
}

- (UIButton *)createActionButtonWithTitle:(NSString *)title color:(UIColor *)color action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    button.backgroundColor = color;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 4.0;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    return button;
}

- (void)buildKeypad {
    // 4x3 grid: [1][2][3] / [4][5][6] / [7][8][9] / [Clear][0][Enter]
    NSArray *rows = @[
        @[@"1", @"2", @"3"],
        @[@"4", @"5", @"6"],
        @[@"7", @"8", @"9"],
        @[@"\u2715", @"0", @"\u2713"],  // multiply-x for clear, checkmark for enter
    ];

    CGFloat totalWidth = 3.0 * kKeypadButtonSize + 2.0 * kKeypadButtonSpacing;
    CGFloat totalHeight = 4.0 * kKeypadButtonSize + 3.0 * kKeypadButtonSpacing;

    // Size the container
    [NSLayoutConstraint activateConstraints:@[
        [self.keypadContainer.widthAnchor constraintEqualToConstant:totalWidth],
        [self.keypadContainer.heightAnchor constraintEqualToConstant:totalHeight],
    ]];

    for (NSInteger row = 0; row < 4; row++) {
        for (NSInteger col = 0; col < 3; col++) {
            NSString *label = rows[row][col];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn setTitle:label forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont monospacedDigitSystemFontOfSize:18 weight:UIFontWeightMedium];
            btn.translatesAutoresizingMaskIntoConstraints = NO;
            btn.layer.cornerRadius = kKeypadButtonSize / 2.0;
            btn.clipsToBounds = YES;

            // Determine tag and styling
            if (row == 3 && col == 0) {
                // Clear button
                btn.tag = kKeypadTagClear;
                btn.backgroundColor = [HATheme controlBackgroundColor];
                [btn setTitleColor:[HATheme destructiveColor] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
            } else if (row == 3 && col == 2) {
                // Enter button
                btn.tag = kKeypadTagEnter;
                btn.backgroundColor = [HATheme accentColor];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
            } else {
                // Digit button
                btn.tag = [label integerValue];
                btn.backgroundColor = [HATheme controlBackgroundColor];
                [btn setTitleColor:[HATheme primaryTextColor] forState:UIControlStateNormal];
            }

            [btn addTarget:self action:@selector(keypadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.keypadContainer addSubview:btn];
            [self.keypadButtons addObject:btn];

            CGFloat x = col * (kKeypadButtonSize + kKeypadButtonSpacing);
            CGFloat y = row * (kKeypadButtonSize + kKeypadButtonSpacing);

            [NSLayoutConstraint activateConstraints:@[
                [btn.leadingAnchor constraintEqualToAnchor:self.keypadContainer.leadingAnchor constant:x],
                [btn.topAnchor constraintEqualToAnchor:self.keypadContainer.topAnchor constant:y],
                [btn.widthAnchor constraintEqualToConstant:kKeypadButtonSize],
                [btn.heightAnchor constraintEqualToConstant:kKeypadButtonSize],
            ]];
        }
    }
}

- (void)setupConstraints {
    UIView *cv = self.contentView;

    // Alarm state label: below name
    [NSLayoutConstraint activateConstraints:@[
        [self.alarmStateLabel.leadingAnchor constraintEqualToAnchor:cv.leadingAnchor constant:kPadding],
        [self.alarmStateLabel.trailingAnchor constraintEqualToAnchor:cv.trailingAnchor constant:-kPadding],
        [self.alarmStateLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:4],
    ]];

    // Action buttons: row below alarm state
    [NSLayoutConstraint activateConstraints:@[
        // Disarm (rightmost)
        [self.disarmButton.trailingAnchor constraintEqualToAnchor:cv.trailingAnchor constant:-kPadding],
        [self.disarmButton.topAnchor constraintEqualToAnchor:self.alarmStateLabel.bottomAnchor constant:8],
        [self.disarmButton.widthAnchor constraintEqualToConstant:kActionButtonWidth],
        [self.disarmButton.heightAnchor constraintEqualToConstant:kActionButtonHeight],

        // Home (middle)
        [self.armHomeButton.trailingAnchor constraintEqualToAnchor:self.disarmButton.leadingAnchor constant:-kActionButtonSpacing],
        [self.armHomeButton.centerYAnchor constraintEqualToAnchor:self.disarmButton.centerYAnchor],
        [self.armHomeButton.widthAnchor constraintEqualToConstant:kActionButtonWidth],
        [self.armHomeButton.heightAnchor constraintEqualToConstant:kActionButtonHeight],

        // Away (leftmost)
        [self.armAwayButton.trailingAnchor constraintEqualToAnchor:self.armHomeButton.leadingAnchor constant:-kActionButtonSpacing],
        [self.armAwayButton.centerYAnchor constraintEqualToAnchor:self.disarmButton.centerYAnchor],
        [self.armAwayButton.widthAnchor constraintEqualToConstant:kActionButtonWidth],
        [self.armAwayButton.heightAnchor constraintEqualToConstant:kActionButtonHeight],
    ]];

    // Code text field: centered below buttons
    CGFloat codeFieldWidth = 3.0 * kKeypadButtonSize + 2.0 * kKeypadButtonSpacing;
    [NSLayoutConstraint activateConstraints:@[
        [self.codeTextField.centerXAnchor constraintEqualToAnchor:cv.centerXAnchor],
        [self.codeTextField.topAnchor constraintEqualToAnchor:self.disarmButton.bottomAnchor constant:8],
        [self.codeTextField.widthAnchor constraintEqualToConstant:codeFieldWidth],
        [self.codeTextField.heightAnchor constraintEqualToConstant:kCodeFieldHeight],
    ]];

    // Keypad container: centered below code field
    [NSLayoutConstraint activateConstraints:@[
        [self.keypadContainer.centerXAnchor constraintEqualToAnchor:cv.centerXAnchor],
        [self.keypadContainer.topAnchor constraintEqualToAnchor:self.codeTextField.bottomAnchor constant:8],
    ]];
}

#pragma mark - Configuration

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];

    NSString *state = [entity alarmState];
    self.alarmStateLabel.text = [self displayStringForState:state];

    // Color code the state
    if ([state isEqualToString:@"disarmed"]) {
        self.alarmStateLabel.textColor = [HATheme successColor];
    } else if ([state isEqualToString:@"triggered"]) {
        self.alarmStateLabel.textColor = [HATheme destructiveColor];
    } else if ([state isEqualToString:@"pending"]) {
        self.alarmStateLabel.textColor = [HATheme warningColor];
    } else {
        self.alarmStateLabel.textColor = [HATheme destructiveColor];
    }

    BOOL available = entity.isAvailable;
    self.armAwayButton.enabled = available;
    self.armHomeButton.enabled = available;
    self.disarmButton.enabled = available;

    // Show keypad only when code_format is non-nil (entity requires a code)
    BOOL showKeypad = ([entity alarmCodeFormat] != nil);
    self.keypadVisible = showKeypad;
    self.codeTextField.hidden = !showKeypad;
    self.keypadContainer.hidden = !showKeypad;
    self.codeTextField.text = @"";
    self.pendingService = nil;
}

- (NSString *)displayStringForState:(NSString *)state {
    if ([state isEqualToString:@"armed_away"]) return @"Armed Away";
    if ([state isEqualToString:@"armed_home"]) return @"Armed Home";
    if ([state isEqualToString:@"armed_night"]) return @"Armed Night";
    if ([state isEqualToString:@"armed_vacation"]) return @"Armed Vacation";
    if ([state isEqualToString:@"disarmed"]) return @"Disarmed";
    if ([state isEqualToString:@"pending"]) return @"Pending";
    if ([state isEqualToString:@"arming"]) return @"Arming";
    if ([state isEqualToString:@"triggered"]) return @"TRIGGERED";
    return state ?: @"Unknown";
}

#pragma mark - Keypad Actions

- (void)keypadButtonTapped:(UIButton *)sender {
    [HAHaptics lightImpact];

    if (sender.tag == kKeypadTagClear) {
        self.codeTextField.text = @"";
    } else if (sender.tag == kKeypadTagEnter) {
        [self submitCodeForService:self.pendingService ?: @"alarm_disarm"];
    } else {
        // Digit button
        NSString *digit = [NSString stringWithFormat:@"%ld", (long)sender.tag];
        self.codeTextField.text = [self.codeTextField.text stringByAppendingString:digit];
    }
}

- (void)submitCodeForService:(NSString *)service {
    if (!self.entity) return;

    NSString *code = self.codeTextField.text;
    NSDictionary *data = nil;
    if (code.length > 0) {
        data = @{@"code": code};
    }

    [[HAConnectionManager sharedManager] callService:service
                                            inDomain:HAEntityDomainAlarmControlPanel
                                            withData:data
                                            entityId:self.entity.entityId];

    // Clear the code field after submission
    self.codeTextField.text = @"";
    self.pendingService = nil;
}

#pragma mark - Action Button Handlers

- (void)armAwayTapped {
    if (!self.entity) return;
    [HAHaptics mediumImpact];

    if (self.keypadVisible) {
        self.pendingService = @"alarm_arm_away";
        [self submitCodeForService:@"alarm_arm_away"];
    } else {
        [self callAlarmService:@"alarm_arm_away"];
    }
}

- (void)armHomeTapped {
    if (!self.entity) return;
    [HAHaptics mediumImpact];

    if (self.keypadVisible) {
        self.pendingService = @"alarm_arm_home";
        [self submitCodeForService:@"alarm_arm_home"];
    } else {
        [self callAlarmService:@"alarm_arm_home"];
    }
}

- (void)disarmTapped {
    if (!self.entity) return;
    [HAHaptics heavyImpact];

    if (self.keypadVisible) {
        self.pendingService = @"alarm_disarm";
        [self submitCodeForService:@"alarm_disarm"];
    } else {
        [self callAlarmService:@"alarm_disarm"];
    }
}

- (void)callAlarmService:(NSString *)service {
    [[HAConnectionManager sharedManager] callService:service
                                            inDomain:HAEntityDomainAlarmControlPanel
                                            withData:nil
                                            entityId:self.entity.entityId];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // We handle input via keypad; don't show system keyboard
    return NO;
}

#pragma mark - Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    self.alarmStateLabel.text = nil;
    self.alarmStateLabel.textColor = [HATheme primaryTextColor];
    self.armAwayButton.backgroundColor = [HATheme destructiveColor];
    self.armHomeButton.backgroundColor = [HATheme warningColor];
    self.disarmButton.backgroundColor = [HATheme successColor];
    self.codeTextField.text = @"";
    self.codeTextField.layer.borderColor = [HATheme controlBorderColor].CGColor;
    self.codeTextField.backgroundColor = [HATheme controlBackgroundColor];
    self.pendingService = nil;
    self.keypadVisible = NO;
    self.codeTextField.hidden = YES;
    self.keypadContainer.hidden = YES;

    // Refresh keypad button colors for theme changes
    for (UIButton *btn in self.keypadButtons) {
        if (btn.tag == kKeypadTagClear) {
            btn.backgroundColor = [HATheme controlBackgroundColor];
            [btn setTitleColor:[HATheme destructiveColor] forState:UIControlStateNormal];
        } else if (btn.tag == kKeypadTagEnter) {
            btn.backgroundColor = [HATheme accentColor];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            btn.backgroundColor = [HATheme controlBackgroundColor];
            [btn setTitleColor:[HATheme primaryTextColor] forState:UIControlStateNormal];
        }
    }
}

@end
