#import "HAPersonEntityCell.h"
#import "HAEntity.h"
#import "HADashboardConfig.h"
#import "HATheme.h"

@interface HAPersonEntityCell ()
@property (nonatomic, strong) UILabel *locationLabel;
@end

@implementation HAPersonEntityCell

- (void)setupSubviews {
    [super setupSubviews];
    self.stateLabel.hidden = YES;

    CGFloat padding = 10.0;

    // Location label (display-only)
    self.locationLabel = [[UILabel alloc] init];
    self.locationLabel.font = [UIFont boldSystemFontOfSize:18];
    self.locationLabel.textColor = [HATheme primaryTextColor];
    self.locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.locationLabel];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.locationLabel attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.locationLabel attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.locationLabel attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:4]];
}

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];

    NSString *state = entity.state;
    if ([state isEqualToString:@"home"]) {
        self.locationLabel.text = @"Home";
        self.locationLabel.textColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0];
    } else if ([state isEqualToString:@"not_home"]) {
        self.locationLabel.text = @"Away";
        self.locationLabel.textColor = [HATheme secondaryTextColor];
    } else {
        // Zone name
        self.locationLabel.text = [state stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        self.locationLabel.textColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.locationLabel.text = nil;
    self.locationLabel.textColor = [HATheme primaryTextColor];
}

@end
