#import "HATileEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HATheme.h"
#import "HAHaptics.h"
#import "HAIconMapper.h"
#import "HAEntityDisplayHelper.h"

@interface HATileEntityCell ()
@property (nonatomic, strong) UILabel *tileIconLabel;
@property (nonatomic, strong) UILabel *tileNameLabel;
@property (nonatomic, strong) UILabel *tileStateLabel;
/// Normal (tile) layout constraints
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *normalConstraints;
/// Compact (pill) layout constraints for button cards in horizontal-stack
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *compactConstraints;
@property (nonatomic, assign) BOOL isCompact;
@end

@implementation HATileEntityCell

+ (CGFloat)compactHeight {
    return 64.0;
}

+ (CGFloat)preferredHeight {
    return 72.0;
}

- (void)setupSubviews {
    [super setupSubviews];
    // Hide the base cell's name and state — tile has its own centered layout
    self.nameLabel.hidden = YES;
    self.stateLabel.hidden = YES;

    CGFloat padding = 10.0;

    // Icon label (left-aligned in both normal and compact modes)
    self.tileIconLabel = [[UILabel alloc] init];
    self.tileIconLabel.font = [HAIconMapper mdiFontOfSize:28];
    self.tileIconLabel.textColor = [HATheme primaryTextColor];
    self.tileIconLabel.textAlignment = NSTextAlignmentCenter;
    self.tileIconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.tileIconLabel];

    // Entity name (right of icon in both modes)
    self.tileNameLabel = [[UILabel alloc] init];
    self.tileNameLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.tileNameLabel.textColor = [HATheme primaryTextColor];
    self.tileNameLabel.textAlignment = NSTextAlignmentLeft;
    self.tileNameLabel.numberOfLines = 2;
    self.tileNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.tileNameLabel];

    // State label (below name, right of icon in normal mode; hidden in compact mode)
    self.tileStateLabel = [[UILabel alloc] init];
    self.tileStateLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    self.tileStateLabel.textColor = [HATheme secondaryTextColor];
    self.tileStateLabel.textAlignment = NSTextAlignmentLeft;
    self.tileStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.tileStateLabel];

    // Normal layout: icon on the left, name + state stacked to the right (HA web style)
    CGFloat iconWidth = 32.0;
    self.normalConstraints = @[
        [self.tileIconLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
        [self.tileIconLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.tileIconLabel.widthAnchor constraintEqualToConstant:iconWidth],
        [self.tileNameLabel.leadingAnchor constraintEqualToAnchor:self.tileIconLabel.trailingAnchor constant:10],
        [self.tileNameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.tileNameLabel.bottomAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant:-1],
        [self.tileStateLabel.leadingAnchor constraintEqualToAnchor:self.tileNameLabel.leadingAnchor],
        [self.tileStateLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.tileStateLabel.topAnchor constraintEqualToAnchor:self.tileNameLabel.bottomAnchor constant:2],
    ];

    // Compact layout: icon on left, name + state stacked to the right (tighter spacing for pill cards)
    self.compactConstraints = @[
        [self.tileIconLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10],
        [self.tileIconLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.tileIconLabel.widthAnchor constraintEqualToConstant:iconWidth],
        [self.tileNameLabel.leadingAnchor constraintEqualToAnchor:self.tileIconLabel.trailingAnchor constant:8],
        [self.tileNameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-6],
        [self.tileNameLabel.bottomAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant:-1],
        [self.tileStateLabel.leadingAnchor constraintEqualToAnchor:self.tileNameLabel.leadingAnchor],
        [self.tileStateLabel.topAnchor constraintEqualToAnchor:self.tileNameLabel.bottomAnchor constant:1],
    ];

    // Start with normal layout
    [NSLayoutConstraint activateConstraints:self.normalConstraints];

    // Tap toggles via didSelectItemAtIndexPath.
    // Long-press opens detail via the collection view's long-press gesture.
}

- (void)applyCompactMode:(BOOL)compact {
    if (self.isCompact == compact) return;
    self.isCompact = compact;

    if (compact) {
        [NSLayoutConstraint deactivateConstraints:self.normalConstraints];
        [NSLayoutConstraint activateConstraints:self.compactConstraints];
        self.tileIconLabel.font = [HAIconMapper mdiFontOfSize:24];
        self.tileNameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        self.tileNameLabel.textAlignment = NSTextAlignmentLeft;
        self.tileNameLabel.numberOfLines = 1;
        self.tileStateLabel.hidden = NO;
        self.contentView.layer.cornerRadius = 12.0;
    } else {
        [NSLayoutConstraint deactivateConstraints:self.compactConstraints];
        [NSLayoutConstraint activateConstraints:self.normalConstraints];
        self.tileIconLabel.font = [HAIconMapper mdiFontOfSize:28];
        self.tileNameLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        self.tileNameLabel.textAlignment = NSTextAlignmentLeft;
        self.tileNameLabel.numberOfLines = 2;
        self.tileStateLabel.hidden = NO;
        self.contentView.layer.cornerRadius = 12.0;
    }
}

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];
    self.nameLabel.hidden = YES;
    self.stateLabel.hidden = YES;

    // Determine if this is a compact button card (inside horizontal-stack)
    BOOL compact = [configItem.customProperties[@"compact"] boolValue];
    [self applyCompactMode:compact];

    // Apply icon_height from card config (e.g. "36px") — parse numeric value
    NSString *iconHeightStr = configItem.customProperties[@"icon_height"];
    if (iconHeightStr.length > 0) {
        CGFloat iconPx = [[iconHeightStr stringByReplacingOccurrencesOfString:@"px" withString:@""] floatValue];
        if (iconPx > 0) {
            self.tileIconLabel.font = [HAIconMapper mdiFontOfSize:iconPx];
        }
    }

    NSString *name = [HAEntityDisplayHelper displayNameForEntity:entity configItem:configItem nameOverride:nil];
    self.tileNameLabel.text = name;

    // State: formatted state with human-readable text + unit (shown in both normal and compact modes)
    NSString *formattedState = [HAEntityDisplayHelper formattedStateForEntity:entity decimals:2];
    NSString *displayState = [HAEntityDisplayHelper humanReadableState:formattedState];
    NSString *unit = entity.unitOfMeasurement;
    // Append unit unless binary_sensor or duration (already includes units)
    if (unit.length > 0 &&
        ![[entity domain] isEqualToString:@"binary_sensor"] &&
        ![unit isEqualToString:@"h"] && ![unit isEqualToString:@"min"] &&
        ![unit isEqualToString:@"s"] && ![unit isEqualToString:@"d"]) {
        displayState = [NSString stringWithFormat:@"%@ %@", displayState, unit];
    }

    // Domain-specific secondary detail (e.g. "71%", "Open · 70%", "Heat · 22°C")
    NSString *domain = [entity domain];
    if ([domain isEqualToString:@"light"]) {
        if ([entity isOn]) {
            NSInteger pct = [entity brightnessPercent];
            if (pct > 0) {
                displayState = [NSString stringWithFormat:@"%ld%%", (long)pct];
            }
        }
    } else if ([domain isEqualToString:@"humidifier"]) {
        NSNumber *targetHumidity = [entity humidifierTargetHumidity];
        if (targetHumidity) {
            displayState = [NSString stringWithFormat:@"%@ · %@%%", displayState, targetHumidity];
        }
    } else if ([domain isEqualToString:@"cover"]) {
        NSInteger pos = [entity coverPosition];
        // coverPosition returns 0 as default; check if attribute actually exists
        if (HAAttrNumber(entity.attributes, HAAttrCurrentPosition)) {
            displayState = [NSString stringWithFormat:@"%@ · %ld%%", displayState, (long)pos];
        }
    } else if ([domain isEqualToString:@"climate"]) {
        // Format HVAC mode with "/" separator: "heat_cool" → "Heat/Cool"
        NSString *hvacMode = entity.state;
        NSString *formattedMode = [[hvacMode stringByReplacingOccurrencesOfString:@"_" withString:@"/"] capitalizedString];
        displayState = formattedMode;
        NSNumber *targetTemp = [entity targetTemperature];
        if (targetTemp) {
            NSString *tempUnit = [entity weatherTemperatureUnit];
            if (!tempUnit || tempUnit.length == 0) {
                tempUnit = @"°C";
            }
            displayState = [NSString stringWithFormat:@"%@ · %@%@", displayState, targetTemp, tempUnit];
        }
    } else if ([domain isEqualToString:@"fan"]) {
        if ([entity isOn]) {
            NSInteger pct = [entity fanSpeedPercent];
            if (pct > 0) {
                displayState = [NSString stringWithFormat:@"%ld%%", (long)pct];
            }
        }
    } else if ([domain isEqualToString:@"media_player"]) {
        NSString *title = [entity mediaTitle];
        NSString *artist = [entity mediaArtist];
        if (title.length > 0 && artist.length > 0) {
            displayState = [NSString stringWithFormat:@"%@ · %@", artist, title];
        } else if (title.length > 0) {
            displayState = title;
        }
    }

    self.tileStateLabel.text = displayState;

    // Icon: from card config override, else centralized entity icon resolution
    NSString *iconName = configItem.customProperties[@"icon"];
    NSString *glyph = nil;
    if (iconName) {
        if ([iconName hasPrefix:@"mdi:"]) iconName = [iconName substringFromIndex:4];
        glyph = [HAIconMapper glyphForIconName:iconName];
    }
    if (!glyph) glyph = [HAEntityDisplayHelper iconGlyphForEntity:entity];
    self.tileIconLabel.text = glyph ?: @"?";

    // Color: domain+state-aware icon color from centralized helper
    UIColor *iconColor = [HAEntityDisplayHelper iconColorForEntity:entity];
    self.tileIconLabel.textColor = iconColor;
    // State label matches icon color when entity is active, secondary otherwise
    BOOL isActive = [entity isOn] ||
                    [entity.state isEqualToString:@"open"] ||
                    [entity.state isEqualToString:@"opening"] ||
                    [entity.state isEqualToString:@"locked"] ||
                    [entity.state isEqualToString:@"playing"] ||
                    [entity.state hasPrefix:@"armed"];
    self.tileStateLabel.textColor = isActive ? iconColor : [HATheme secondaryTextColor];

    self.contentView.backgroundColor = [HATheme cellBackgroundColor];
}

- (void)tileLongPressed:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    if (!self.entity || !self.entity.isAvailable) return;

    [HAHaptics mediumImpact];

    NSString *domain = [self.entity domain];
    NSString *service = nil;

    if ([domain isEqualToString:@"cover"]) {
        // Toggle cover: open if closed, close if open, stop if moving
        NSString *state = self.entity.state;
        if ([state isEqualToString:@"open"] || [state isEqualToString:@"opening"]) {
            service = @"close_cover";
        } else {
            service = @"open_cover";
        }
    } else if ([domain isEqualToString:@"scene"] || [domain isEqualToString:@"script"]) {
        service = @"turn_on";
    } else {
        service = @"toggle";
    }

    [[HAConnectionManager sharedManager] callService:service
                                            inDomain:domain
                                            withData:nil
                                            entityId:self.entity.entityId];

    // Brief visual feedback
    [UIView animateWithDuration:0.15 animations:^{
        self.contentView.alpha = 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.contentView.alpha = 1.0;
        }];
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.tileIconLabel.text = nil;
    self.tileNameLabel.text = nil;
    self.tileStateLabel.text = nil;
    self.tileIconLabel.textColor = [HATheme primaryTextColor];
    self.tileStateLabel.textColor = [HATheme secondaryTextColor];
    self.contentView.backgroundColor = [HATheme cellBackgroundColor];
    // Reset to normal mode so reused cells don't retain compact layout
    [self applyCompactMode:NO];
}

@end
