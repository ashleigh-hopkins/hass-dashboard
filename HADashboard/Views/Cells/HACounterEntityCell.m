#import "HACounterEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HATheme.h"
#import "HAHaptics.h"

@interface HACounterEntityCell ()
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIButton *incrementButton;
@property (nonatomic, strong) UIButton *decrementButton;
@property (nonatomic, strong) UIButton *resetButton;
@end

@implementation HACounterEntityCell

- (void)setupSubviews {
    [super setupSubviews];
    self.stateLabel.hidden = YES;

    CGFloat padding = 10.0;

    // Value label (large, prominent)
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:28 weight:UIFontWeightBold];
    self.valueLabel.textColor = [HATheme primaryTextColor];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.valueLabel];

    CGFloat buttonSize = 32.0;
    CGFloat buttonSpacing = 6.0;

    // Decrement button
    self.decrementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.decrementButton setTitle:@"\u2212" forState:UIControlStateNormal]; // minus sign
    self.decrementButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.decrementButton.backgroundColor = [HATheme destructiveColor];
    [self.decrementButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.decrementButton.layer.cornerRadius = buttonSize / 2.0;
    self.decrementButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.decrementButton addTarget:self action:@selector(decrementTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.decrementButton];

    // Increment button
    self.incrementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.incrementButton setTitle:@"+" forState:UIControlStateNormal];
    self.incrementButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.incrementButton.backgroundColor = [HATheme successColor];
    [self.incrementButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.incrementButton.layer.cornerRadius = buttonSize / 2.0;
    self.incrementButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.incrementButton addTarget:self action:@selector(incrementTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.incrementButton];

    // Reset button
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    self.resetButton.titleLabel.font = [UIFont systemFontOfSize:11];
    self.resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.resetButton addTarget:self action:@selector(resetTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.resetButton];

    // Value label: top-right
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.valueLabel attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.valueLabel attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:padding]];

    // Buttons: bottom row
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.incrementButton attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.incrementButton attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.incrementButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:buttonSize]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.incrementButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:buttonSize]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.decrementButton attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.incrementButton attribute:NSLayoutAttributeLeading multiplier:1 constant:-buttonSpacing]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.decrementButton attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.decrementButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:buttonSize]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.decrementButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:buttonSize]];

    // Reset button: bottom-left
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.resetButton attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.resetButton attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-padding]];
}

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];

    self.valueLabel.text = [NSString stringWithFormat:@"%ld", (long)[entity counterValue]];

    BOOL available = entity.isAvailable;
    self.incrementButton.enabled = available;
    self.decrementButton.enabled = available;
    self.resetButton.enabled = available;
}

#pragma mark - Actions

- (void)incrementTapped {
    if (!self.entity) return;

    [HAHaptics lightImpact];

    [[HAConnectionManager sharedManager] callService:@"increment"
                                            inDomain:HAEntityDomainCounter
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)decrementTapped {
    if (!self.entity) return;

    [HAHaptics lightImpact];

    [[HAConnectionManager sharedManager] callService:@"decrement"
                                            inDomain:HAEntityDomainCounter
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)resetTapped {
    if (!self.entity) return;

    [HAHaptics mediumImpact];

    [[HAConnectionManager sharedManager] callService:@"reset"
                                            inDomain:HAEntityDomainCounter
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.valueLabel.text = nil;
    self.valueLabel.textColor = [HATheme primaryTextColor];
    self.decrementButton.backgroundColor = [HATheme destructiveColor];
    self.incrementButton.backgroundColor = [HATheme successColor];
}

@end
