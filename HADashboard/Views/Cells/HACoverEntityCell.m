#import "HACoverEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HATheme.h"
#import "HAHaptics.h"

@interface HACoverEntityCell ()
@property (nonatomic, strong) UIButton *openButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *positionLabel;
@end

@implementation HACoverEntityCell

- (void)setupSubviews {
    [super setupSubviews];
    self.stateLabel.hidden = YES;

    CGFloat btnHeight = 30.0;
    CGFloat btnWidth  = 56.0;
    CGFloat spacing   = 6.0;
    CGFloat padding   = 10.0;

    self.openButton = [self makeButtonWithTitle:@"\u25B2 Open" action:@selector(openTapped)];
    self.stopButton = [self makeButtonWithTitle:@"\u25A0 Stop" action:@selector(stopTapped)];
    self.closeButton = [self makeButtonWithTitle:@"\u25BC Close" action:@selector(closeTapped)];

    self.stopButton.backgroundColor = [HATheme buttonBackgroundColor];

    self.positionLabel = [[UILabel alloc] init];
    self.positionLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.positionLabel.textColor = [HATheme secondaryTextColor];
    self.positionLabel.textAlignment = NSTextAlignmentRight;
    self.positionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.positionLabel];

    // Position label: top-right
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.positionLabel attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.positionLabel attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:padding]];

    // Buttons: bottom row, centered
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.stopButton attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.stopButton attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.stopButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:btnWidth]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.stopButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:btnHeight]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.openButton attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.stopButton attribute:NSLayoutAttributeLeading multiplier:1 constant:-spacing]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.openButton attribute:NSLayoutAttributeCenterY
        relatedBy:NSLayoutRelationEqual toItem:self.stopButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.openButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:btnWidth]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.openButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:btnHeight]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationEqual toItem:self.stopButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:spacing]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeCenterY
        relatedBy:NSLayoutRelationEqual toItem:self.stopButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:btnWidth]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:btnHeight]];
}

- (UIButton *)makeButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    btn.backgroundColor = [HATheme buttonBackgroundColor];
    btn.layer.cornerRadius = 4.0;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btn];
    return btn;
}

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];

    BOOL available = entity.isAvailable;
    self.openButton.enabled = available;
    self.stopButton.enabled = available;
    self.closeButton.enabled = available;

    NSInteger position = [entity coverPosition];
    NSNumber *posAttr = HAAttrNumber(entity.attributes, HAAttrCurrentPosition);
    if (posAttr) {
        self.positionLabel.text = [NSString stringWithFormat:@"%ld%%", (long)position];
        self.positionLabel.hidden = NO;
    } else {
        self.positionLabel.hidden = YES;
    }

    // Highlight state
    NSString *state = entity.state;
    if ([state isEqualToString:@"open"]) {
        self.contentView.backgroundColor = [HATheme activeTintColor];
    } else if ([state isEqualToString:@"opening"] || [state isEqualToString:@"closing"]) {
        self.contentView.backgroundColor = [HATheme onTintColor];
    } else {
        self.contentView.backgroundColor = [HATheme cellBackgroundColor];
    }
}

#pragma mark - Actions

- (void)openTapped {
    if (!self.entity) return;

    [HAHaptics mediumImpact];

    [[HAConnectionManager sharedManager] callService:@"open_cover"
                                            inDomain:@"cover"
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)stopTapped {
    if (!self.entity) return;

    [HAHaptics mediumImpact];

    [[HAConnectionManager sharedManager] callService:@"stop_cover"
                                            inDomain:@"cover"
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)closeTapped {
    if (!self.entity) return;

    [HAHaptics mediumImpact];

    [[HAConnectionManager sharedManager] callService:@"close_cover"
                                            inDomain:@"cover"
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.positionLabel.text = nil;
    self.positionLabel.hidden = YES;
    self.contentView.backgroundColor = [HATheme cellBackgroundColor];
}

@end
