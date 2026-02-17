#import "HAMediaPlayerEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HATheme.h"
#import "HAHaptics.h"
#import "HAIconMapper.h"
#import "HAEntityDisplayHelper.h"

static const CGFloat kIconCircleSize = 36.0;
static const CGFloat kIconFontSize   = 20.0;
static const CGFloat kBtnSize        = 36.0;
static const CGFloat kBtnIconSize    = 18.0;
static const CGFloat kBtnSpacing     = 8.0;
static const CGFloat kPadding        = 12.0;

@interface HAMediaPlayerEntityCell ()
@property (nonatomic, strong) UIView  *iconCircle;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *mpNameLabel;
@property (nonatomic, strong) UILabel *mpStateLabel;
@property (nonatomic, strong) UILabel *mediaInfoLabel;
@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIButton *nextButton;
@end

@implementation HAMediaPlayerEntityCell

#pragma mark - Layout

- (void)setupSubviews {
    [super setupSubviews];
    // Hide base cell name/state — this cell has its own layout
    self.nameLabel.hidden = YES;
    self.stateLabel.hidden = YES;

    // ── Icon circle (top-left) ──
    self.iconCircle = [[UIView alloc] init];
    self.iconCircle.layer.cornerRadius = kIconCircleSize / 2.0;
    self.iconCircle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.iconCircle];

    self.iconLabel = [[UILabel alloc] init];
    self.iconLabel.font = [HAIconMapper mdiFontOfSize:kIconFontSize];
    self.iconLabel.textAlignment = NSTextAlignmentCenter;
    self.iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.iconCircle addSubview:self.iconLabel];

    // ── Name label (right of icon) ──
    self.mpNameLabel = [[UILabel alloc] init];
    self.mpNameLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.mpNameLabel.textColor = [HATheme primaryTextColor];
    self.mpNameLabel.numberOfLines = 1;
    self.mpNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.mpNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.mpNameLabel];

    // ── State label (below name, right of icon) ──
    self.mpStateLabel = [[UILabel alloc] init];
    self.mpStateLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    self.mpStateLabel.textColor = [HATheme secondaryTextColor];
    self.mpStateLabel.numberOfLines = 1;
    self.mpStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.mpStateLabel];

    // ── Media info (artist - title) ──
    self.mediaInfoLabel = [[UILabel alloc] init];
    self.mediaInfoLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    self.mediaInfoLabel.textColor = [HATheme secondaryTextColor];
    self.mediaInfoLabel.numberOfLines = 1;
    self.mediaInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.mediaInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.mediaInfoLabel];

    // ── Transport buttons (prev | play/pause | next) ──
    self.prevButton      = [self makeTransportButtonWithIconName:@"skip-previous" action:@selector(prevTapped)];
    self.playPauseButton = [self makeTransportButtonWithIconName:@"play"          action:@selector(playPauseTapped)];
    self.nextButton      = [self makeTransportButtonWithIconName:@"skip-next"     action:@selector(nextTapped)];

    // ── Constraints ──

    // Icon circle: top-left
    [NSLayoutConstraint activateConstraints:@[
        [self.iconCircle.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kPadding],
        [self.iconCircle.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:kPadding],
        [self.iconCircle.widthAnchor constraintEqualToConstant:kIconCircleSize],
        [self.iconCircle.heightAnchor constraintEqualToConstant:kIconCircleSize],
        [self.iconLabel.centerXAnchor constraintEqualToAnchor:self.iconCircle.centerXAnchor],
        [self.iconLabel.centerYAnchor constraintEqualToAnchor:self.iconCircle.centerYAnchor],
    ]];

    // Name: right of icon, vertically centered in top section
    [NSLayoutConstraint activateConstraints:@[
        [self.mpNameLabel.leadingAnchor constraintEqualToAnchor:self.iconCircle.trailingAnchor constant:10],
        [self.mpNameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-kPadding],
        [self.mpNameLabel.topAnchor constraintEqualToAnchor:self.iconCircle.topAnchor constant:1],
    ]];

    // State: below name
    [NSLayoutConstraint activateConstraints:@[
        [self.mpStateLabel.leadingAnchor constraintEqualToAnchor:self.mpNameLabel.leadingAnchor],
        [self.mpStateLabel.trailingAnchor constraintEqualToAnchor:self.mpNameLabel.trailingAnchor],
        [self.mpStateLabel.topAnchor constraintEqualToAnchor:self.mpNameLabel.bottomAnchor constant:1],
    ]];

    // Media info: below the icon/name row
    [NSLayoutConstraint activateConstraints:@[
        [self.mediaInfoLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kPadding],
        [self.mediaInfoLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-kPadding],
        [self.mediaInfoLabel.topAnchor constraintEqualToAnchor:self.iconCircle.bottomAnchor constant:8],
    ]];

    // Transport buttons: centered horizontal row below media info
    [NSLayoutConstraint activateConstraints:@[
        // Play/pause centered
        [self.playPauseButton.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.playPauseButton.topAnchor constraintEqualToAnchor:self.mediaInfoLabel.bottomAnchor constant:8],
        [self.playPauseButton.widthAnchor constraintEqualToConstant:kBtnSize],
        [self.playPauseButton.heightAnchor constraintEqualToConstant:kBtnSize],

        // Prev: left of play/pause
        [self.prevButton.trailingAnchor constraintEqualToAnchor:self.playPauseButton.leadingAnchor constant:-kBtnSpacing],
        [self.prevButton.centerYAnchor constraintEqualToAnchor:self.playPauseButton.centerYAnchor],
        [self.prevButton.widthAnchor constraintEqualToConstant:kBtnSize],
        [self.prevButton.heightAnchor constraintEqualToConstant:kBtnSize],

        // Next: right of play/pause
        [self.nextButton.leadingAnchor constraintEqualToAnchor:self.playPauseButton.trailingAnchor constant:kBtnSpacing],
        [self.nextButton.centerYAnchor constraintEqualToAnchor:self.playPauseButton.centerYAnchor],
        [self.nextButton.widthAnchor constraintEqualToConstant:kBtnSize],
        [self.nextButton.heightAnchor constraintEqualToConstant:kBtnSize],
    ]];
}

- (UIButton *)makeTransportButtonWithIconName:(NSString *)iconName action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = kBtnSize / 2.0;
    btn.backgroundColor = [HATheme buttonBackgroundColor];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    NSString *glyph = [HAIconMapper glyphForIconName:iconName];
    UIFont *iconFont = [HAIconMapper mdiFontOfSize:kBtnIconSize];
    NSDictionary *attrs = @{
        NSFontAttributeName: iconFont,
        NSForegroundColorAttributeName: [HATheme primaryTextColor],
    };
    NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:(glyph ?: @"?") attributes:attrs];
    [btn setAttributedTitle:attrTitle forState:UIControlStateNormal];

    [self.contentView addSubview:btn];
    return btn;
}

/// Update a transport button's icon glyph (e.g. switching play <-> pause).
- (void)setButton:(UIButton *)btn iconName:(NSString *)iconName color:(UIColor *)color {
    NSString *glyph = [HAIconMapper glyphForIconName:iconName];
    UIFont *iconFont = [HAIconMapper mdiFontOfSize:kBtnIconSize];
    NSDictionary *attrs = @{
        NSFontAttributeName: iconFont,
        NSForegroundColorAttributeName: color ?: [HATheme primaryTextColor],
    };
    NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:(glyph ?: @"?") attributes:attrs];
    [btn setAttributedTitle:attrTitle forState:UIControlStateNormal];
}

#pragma mark - Preferred Height

+ (CGFloat)preferredHeight {
    // icon row (padding + icon + padding) + media info + button row + bottom padding
    // 12 + 36 + 8 + 16 + 8 + 36 + 10 = 126
    return 126.0;
}

#pragma mark - Configuration

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];
    self.nameLabel.hidden = YES;
    self.stateLabel.hidden = YES;

    if (!entity) return;

    BOOL available = entity.isAvailable;
    BOOL playing   = entity.isPlaying;
    BOOL paused    = entity.isPaused;
    BOOL active    = playing || paused;

    // ── Icon ──
    NSString *iconName = configItem.customProperties[@"icon"];
    NSString *glyph = nil;
    if (iconName) {
        if ([iconName hasPrefix:@"mdi:"]) iconName = [iconName substringFromIndex:4];
        glyph = [HAIconMapper glyphForIconName:iconName];
    }
    if (!glyph) glyph = [HAEntityDisplayHelper iconGlyphForEntity:entity];
    self.iconLabel.text = glyph ?: @"?";

    UIColor *iconColor = [HAEntityDisplayHelper iconColorForEntity:entity];
    self.iconLabel.textColor = iconColor;
    self.iconCircle.backgroundColor = [iconColor colorWithAlphaComponent:0.12];

    // ── Name ──
    self.mpNameLabel.text = [HAEntityDisplayHelper displayNameForEntity:entity configItem:configItem nameOverride:nil];

    // ── State ──
    NSString *stateText = [HAEntityDisplayHelper humanReadableState:entity.state];
    self.mpStateLabel.text = stateText;
    self.mpStateLabel.textColor = active ? iconColor : [HATheme secondaryTextColor];

    // ── Media info ──
    NSString *title  = [entity mediaTitle];
    NSString *artist = [entity mediaArtist];
    if (title.length > 0 && artist.length > 0) {
        self.mediaInfoLabel.text = [NSString stringWithFormat:@"%@ \u2014 %@", artist, title];
    } else if (title.length > 0) {
        self.mediaInfoLabel.text = title;
    } else {
        self.mediaInfoLabel.text = nil;
    }

    // ── Play/pause button icon ──
    if (playing) {
        [self setButton:self.playPauseButton iconName:@"pause" color:[HATheme primaryTextColor]];
    } else {
        [self setButton:self.playPauseButton iconName:@"play" color:[HATheme primaryTextColor]];
    }

    // ── Button enable states ──
    self.prevButton.enabled      = available && active;
    self.playPauseButton.enabled = available;
    self.nextButton.enabled      = available && active;
    self.prevButton.alpha      = (available && active) ? 1.0 : 0.4;
    self.playPauseButton.alpha = available ? 1.0 : 0.4;
    self.nextButton.alpha      = (available && active) ? 1.0 : 0.4;

    // ── Card background ──
    if (playing) {
        self.contentView.backgroundColor = [HATheme activeTintColor];
    } else {
        self.contentView.backgroundColor = [HATheme cellBackgroundColor];
    }
}

#pragma mark - Actions

- (void)prevTapped {
    if (!self.entity) return;
    [HAHaptics lightImpact];
    [[HAConnectionManager sharedManager] callService:@"media_previous_track"
                                            inDomain:@"media_player"
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)playPauseTapped {
    if (!self.entity) return;
    [HAHaptics mediumImpact];
    [[HAConnectionManager sharedManager] callService:@"media_play_pause"
                                            inDomain:@"media_player"
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)nextTapped {
    if (!self.entity) return;
    [HAHaptics lightImpact];
    [[HAConnectionManager sharedManager] callService:@"media_next_track"
                                            inDomain:@"media_player"
                                            withData:nil
                                            entityId:self.entity.entityId];
}

#pragma mark - Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    self.iconLabel.text = nil;
    self.mpNameLabel.text = nil;
    self.mpStateLabel.text = nil;
    self.mediaInfoLabel.text = nil;
    self.prevButton.alpha = 1.0;
    self.playPauseButton.alpha = 1.0;
    self.nextButton.alpha = 1.0;
    self.iconCircle.backgroundColor = nil;
    self.contentView.backgroundColor = [HATheme cellBackgroundColor];
}

@end
