#import "HALoginViewController.h"
#import "HAConnectionFormView.h"
#import "HAConstellationView.h"
#import "HADashboardViewController.h"
#import "HAAuthManager.h"
#import "HAConnectionManager.h"
#import "HATheme.h"

@interface HALoginViewController () <HAConnectionFormDelegate>
@property (nonatomic, strong) HAConnectionFormView *connectionForm;
@property (nonatomic, strong) HAConstellationView *constellationView;
@property (nonatomic, strong) UISwitch *demoSwitch;
@property (nonatomic, strong) UIView *cardView;
@end

@implementation HALoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"HA Dashboard";
    self.view.backgroundColor = [HATheme backgroundColor];
    self.navigationController.navigationBarHidden = YES;

    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.connectionForm loadExistingCredentials];
    [self.connectionForm startDiscovery];
    [self.constellationView startAnimating];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.connectionForm stopDiscovery];
    [self.constellationView stopAnimating];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [HATheme effectiveDarkMode] ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

#pragma mark - UI Setup

- (void)setupUI {
    CGFloat padding = 24.0;
    CGFloat maxWidth = 460.0;
    CGFloat cardPadding = 28.0;
    CGFloat cardRadius = 16.0;

    // ── Constellation background ───────────────────────────────────────
    self.constellationView = [[HAConstellationView alloc] initWithFrame:self.view.bounds];
    self.constellationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.constellationView];

    // ── Scroll view (uses same iOS 9-safe VFL pattern as HASettingsViewController) ──
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:scrollView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sv]|"
        options:0 metrics:nil views:@{@"sv": scrollView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sv]|"
        options:0 metrics:nil views:@{@"sv": scrollView}]];

    UIView *container = [[UIView alloc] init];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:container];

    // ── App icon (loaded from bundle icon files) ──────────────────────
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    NSDictionary *icons = [[NSBundle mainBundle] infoDictionary][@"CFBundleIcons"];
    NSString *iconName = [icons[@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"] lastObject];
    if (iconName) {
        iconView.image = [UIImage imageNamed:iconName];
    }
    iconView.layer.cornerRadius = 20;
    iconView.layer.masksToBounds = YES;
    [container addSubview:iconView];

    // ── Card container ─────────────────────────────────────────────────
    self.cardView = [[UIView alloc] init];
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cardView.backgroundColor = [HATheme cellBackgroundColor];
    self.cardView.layer.cornerRadius = cardRadius;
    self.cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.cardView.layer.shadowOpacity = [HATheme effectiveDarkMode] ? 0.4f : 0.12f;
    self.cardView.layer.shadowRadius = 20;
    self.cardView.layer.shadowOffset = CGSizeMake(0, 4);
    [container addSubview:self.cardView];

    // ── "Connect to server" header inside card ─────────────────────────
    UILabel *cardTitle = [[UILabel alloc] init];
    cardTitle.text = @"Connect to your server";
    cardTitle.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
    cardTitle.textColor = [HATheme primaryTextColor];
    cardTitle.textAlignment = NSTextAlignmentCenter;
    cardTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:cardTitle];

    // ── Connection form ────────────────────────────────────────────────
    self.connectionForm = [[HAConnectionFormView alloc] initWithFrame:CGRectZero];
    self.connectionForm.delegate = self;
    self.connectionForm.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.connectionForm];

    // Card internal layout
    [NSLayoutConstraint activateConstraints:@[
        [cardTitle.topAnchor constraintEqualToAnchor:self.cardView.topAnchor constant:cardPadding],
        [cardTitle.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:cardPadding],
        [cardTitle.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-cardPadding],
        [self.connectionForm.topAnchor constraintEqualToAnchor:cardTitle.bottomAnchor constant:20],
        [self.connectionForm.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:cardPadding],
        [self.connectionForm.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-cardPadding],
        [self.connectionForm.bottomAnchor constraintEqualToAnchor:self.cardView.bottomAnchor constant:-cardPadding],
    ]];

    // ── Demo mode section (below card) ─────────────────────────────────
    UIView *demoRow = [[UIView alloc] init];
    demoRow.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:demoRow];

    UILabel *demoLabel = [[UILabel alloc] init];
    demoLabel.text = @"Try Demo Mode";
    demoLabel.font = [UIFont systemFontOfSize:14];
    demoLabel.textColor = [HATheme secondaryTextColor];
    demoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [demoRow addSubview:demoLabel];

    self.demoSwitch = [[UISwitch alloc] init];
    self.demoSwitch.on = [[HAAuthManager sharedManager] isDemoMode];
    [self.demoSwitch addTarget:self action:@selector(demoSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    self.demoSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [demoRow addSubview:self.demoSwitch];

    [NSLayoutConstraint activateConstraints:@[
        [demoLabel.topAnchor constraintEqualToAnchor:demoRow.topAnchor],
        [demoLabel.leadingAnchor constraintEqualToAnchor:demoRow.leadingAnchor],
        [demoLabel.bottomAnchor constraintEqualToAnchor:demoRow.bottomAnchor],
        [self.demoSwitch.trailingAnchor constraintEqualToAnchor:demoRow.trailingAnchor],
        [self.demoSwitch.centerYAnchor constraintEqualToAnchor:demoLabel.centerYAnchor],
    ]];

    // ── Icon constraints ───────────────────────────────────────────────
    [NSLayoutConstraint activateConstraints:@[
        [iconView.topAnchor constraintEqualToAnchor:container.topAnchor constant:8],
        [iconView.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [iconView.widthAnchor constraintEqualToConstant:88],
        [iconView.heightAnchor constraintEqualToConstant:88],
    ]];

    // ── Vertical chain: icon → card → demo → bottom (VFL) ─────────────
    NSDictionary *views = @{
        @"icon": iconView,
        @"card": self.cardView,
        @"demo": demoRow,
    };
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
        @"V:[icon]-24-[card]-20-[demo]-20-|"
        options:0 metrics:nil views:views]];

    // Pin card + demo to container edges
    for (NSString *name in @[@"card", @"demo"]) {
        UIView *v = views[name];
        [container addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeLeading
            relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [container addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeTrailing
            relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    }

    // ── ScrollView content (proven iOS 9-safe pattern from settings VC) ──
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:40]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:-padding]];

    // Horizontal: centered with max width (same as settings VC)
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:padding]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [container addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:maxWidth]];
}

#pragma mark - HAConnectionFormDelegate

- (void)connectionFormDidConnect:(HAConnectionFormView *)form {
    [self navigateToDashboard];
}

#pragma mark - Demo Mode

- (void)demoSwitchToggled:(UISwitch *)sender {
    [[HAAuthManager sharedManager] setDemoMode:sender.isOn];
    if (sender.isOn) {
        [[HAConnectionManager sharedManager] disconnect];
        [self navigateToDashboard];
    }
}

#pragma mark - Navigation

- (void)navigateToDashboard {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        HADashboardViewController *dashVC = [[HADashboardViewController alloc] init];
        UINavigationController *nav = self.navigationController;
        nav.navigationBarHidden = NO;
        [nav setViewControllers:@[dashVC] animated:YES];
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
