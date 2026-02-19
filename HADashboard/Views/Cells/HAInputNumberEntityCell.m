#import "HAInputNumberEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HAHaptics.h"
#import "HATheme.h"

@interface HAInputNumberEntityCell ()
@property (nonatomic, strong) UISlider *valueSlider;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, assign) BOOL sliderDragging;
@property (nonatomic, assign) double entityMin;
@property (nonatomic, assign) double entityMax;
@property (nonatomic, assign) double entityStep;
@end

@implementation HAInputNumberEntityCell

- (void)setupSubviews {
    [super setupSubviews];
    self.stateLabel.hidden = YES;

    CGFloat padding = 10.0;

    // Value label (right side, shows current number)
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:20 weight:UIFontWeightMedium];
    self.valueLabel.textColor = [HATheme primaryTextColor];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.valueLabel];

    // Slider
    self.valueSlider = [[UISlider alloc] init];
    self.valueSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.valueSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.valueSlider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.valueSlider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:self.valueSlider];

    // Value label: top-right
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.valueLabel attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.valueLabel attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:padding]];

    // Slider: bottom
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.valueSlider attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.valueSlider attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.valueSlider attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-padding]];
}

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];

    self.entityMin  = [entity inputNumberMin];
    self.entityMax  = [entity inputNumberMax];
    self.entityStep = [entity inputNumberStep];

    self.valueSlider.minimumValue = (float)self.entityMin;
    self.valueSlider.maximumValue = (float)self.entityMax;
    self.valueSlider.enabled = entity.isAvailable;

    double currentValue = [entity inputNumberValue];
    if (!self.sliderDragging) {
        self.valueSlider.value = (float)currentValue;
    }

    self.valueLabel.text = [self formatValue:currentValue];

    NSString *unit = [entity unitOfMeasurement];
    if (unit) {
        self.valueLabel.text = [NSString stringWithFormat:@"%@ %@", [self formatValue:currentValue], unit];
    }
}

- (NSString *)formatValue:(double)value {
    // If step is a whole number, display without decimals
    if (self.entityStep >= 1.0 && fmod(self.entityStep, 1.0) == 0.0) {
        return [NSString stringWithFormat:@"%.0f", value];
    }
    // Determine decimal places from step
    NSString *stepStr = [NSString stringWithFormat:@"%g", self.entityStep];
    NSRange dotRange = [stepStr rangeOfString:@"."];
    if (dotRange.location != NSNotFound) {
        NSUInteger decimals = stepStr.length - dotRange.location - 1;
        NSString *fmt = [NSString stringWithFormat:@"%%.%luf", (unsigned long)decimals];
        return [NSString stringWithFormat:fmt, value];
    }
    return [NSString stringWithFormat:@"%g", value];
}

- (double)snapToStep:(double)value {
    if (self.entityStep <= 0) return value;
    double snapped = round((value - self.entityMin) / self.entityStep) * self.entityStep + self.entityMin;
    return MIN(MAX(snapped, self.entityMin), self.entityMax);
}

#pragma mark - Actions

- (void)sliderTouchDown:(UISlider *)sender {
    self.sliderDragging = YES;
}

- (void)sliderChanged:(UISlider *)sender {
    double snapped = [self snapToStep:sender.value];
    self.valueLabel.text = [self formatValue:snapped];

    NSString *unit = [self.entity unitOfMeasurement];
    if (unit) {
        self.valueLabel.text = [NSString stringWithFormat:@"%@ %@", [self formatValue:snapped], unit];
    }
}

- (void)sliderTouchUp:(UISlider *)sender {
    self.sliderDragging = NO;
    if (!self.entity) return;

    [HAHaptics lightImpact];

    double snapped = [self snapToStep:sender.value];
    sender.value = (float)snapped;

    NSDictionary *data = @{@"value": @(snapped)};
    [[HAConnectionManager sharedManager] callService:@"set_value"
                                            inDomain:[self.entity domain]
                                            withData:data
                                            entityId:self.entity.entityId];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.valueLabel.text = nil;
    self.valueSlider.value = 0;
    self.sliderDragging = NO;
    self.valueLabel.textColor = [HATheme primaryTextColor];
}

@end
