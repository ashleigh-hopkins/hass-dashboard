#import "HAUpdateEntityCell.h"
#import "HAEntity.h"
#import "HAConnectionManager.h"
#import "HADashboardConfig.h"
#import "HATheme.h"

@interface HAUpdateEntityCell ()
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UIButton *updateButton;
@end

@implementation HAUpdateEntityCell

- (void)setupSubviews {
    [super setupSubviews];
    self.stateLabel.hidden = YES;

    CGFloat padding = 10.0;

    // Version info label
    self.versionLabel = [[UILabel alloc] init];
    self.versionLabel.font = [UIFont systemFontOfSize:12];
    self.versionLabel.textColor = [HATheme secondaryTextColor];
    self.versionLabel.numberOfLines = 2;
    self.versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.versionLabel];

    // Update button
    self.updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.updateButton setTitle:@"Update" forState:UIControlStateNormal];
    self.updateButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    self.updateButton.backgroundColor = [HATheme accentColor];
    [self.updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.updateButton.layer.cornerRadius = 6.0;
    self.updateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.updateButton addTarget:self action:@selector(updateTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.updateButton];

    // Version label: below name
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.versionLabel attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.versionLabel attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.updateButton attribute:NSLayoutAttributeLeading multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.versionLabel attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:4]];

    // Update button: right side, vertically centered
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.updateButton attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.updateButton attribute:NSLayoutAttributeCenterY
        relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.updateButton attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:72]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.updateButton attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
}

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];

    NSString *installed = [entity updateInstalledVersion] ?: @"?";
    NSString *latest = [entity updateLatestVersion] ?: @"?";
    BOOL hasUpdate = [entity updateAvailable];

    if (hasUpdate) {
        self.versionLabel.text = [NSString stringWithFormat:@"%@ \u2192 %@", installed, latest];
        self.versionLabel.textColor = [HATheme accentColor];
        self.updateButton.hidden = NO;
        self.updateButton.enabled = entity.isAvailable;
        self.contentView.backgroundColor = [HATheme activeTintColor];
    } else {
        self.versionLabel.text = [NSString stringWithFormat:@"v%@ (up to date)", installed];
        self.versionLabel.textColor = [HATheme secondaryTextColor];
        self.updateButton.hidden = YES;
        self.contentView.backgroundColor = [HATheme cellBackgroundColor];
    }
}

#pragma mark - Actions

- (void)updateTapped {
    if (!self.entity) return;
    [[HAConnectionManager sharedManager] callService:@"install"
                                            inDomain:HAEntityDomainUpdate
                                            withData:nil
                                            entityId:self.entity.entityId];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.versionLabel.text = nil;
    self.versionLabel.textColor = [HATheme secondaryTextColor];
    self.updateButton.hidden = NO;
    self.updateButton.enabled = YES;
    self.contentView.backgroundColor = [HATheme cellBackgroundColor];
    self.updateButton.backgroundColor = [HATheme accentColor];
}

@end
