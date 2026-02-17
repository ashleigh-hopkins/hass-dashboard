#import <UIKit/UIKit.h>

@class HAEntity;
@class HADashboardConfigItem;

@interface HABaseEntityCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, weak)   HAEntity *entity;

/// Heading label rendered above the card (for grid headings like
/// "House Climate", "Ribbit"). Added to the cell itself (not contentView).
/// When visible, contentView is pushed down to make room.
@property (nonatomic, strong) UILabel *headingLabel;

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem;
- (void)setupSubviews;

/// Returns the extra height needed for the heading area (0 if no heading).
+ (CGFloat)headingHeight;

@end
