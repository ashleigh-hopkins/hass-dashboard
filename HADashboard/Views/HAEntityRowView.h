#import <UIKit/UIKit.h>

@class HAEntity;

@interface HAEntityRowView : UIView

- (void)configureWithEntity:(HAEntity *)entity;
- (void)configureWithEntity:(HAEntity *)entity nameOverride:(NSString *)nameOverride;

@property (nonatomic, assign) BOOL showsSeparator;

/// The entity currently displayed by this row (nil if unconfigured).
@property (nonatomic, weak, readonly) HAEntity *entity;

/// Compact "Press" button shown for button / input_button domain entities
@property (nonatomic, strong, readonly) UIButton *pressButton;

/// Called when the row is tapped (non-control area). Used to open entity detail.
@property (nonatomic, copy) void(^entityTapBlock)(HAEntity *entity);

@end
