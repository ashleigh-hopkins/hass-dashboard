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

/// Per-row action configuration (tap_action, hold_action, double_tap_action dicts).
/// Populated from per-entity config in entities card. nil = use card-level defaults.
@property (nonatomic, copy) NSDictionary *actionConfig;

/// Whether to color the icon based on entity active state.
/// HA default for entities card rows is NO. Set from card config's state_color field.
@property (nonatomic, assign) BOOL stateColor;

/// When set, display this entity attribute value instead of the state.
/// Matches HA's "attribute" field on entity/card configs.
@property (nonatomic, copy) NSString *attributeOverride;

/// Secondary info type to display below the entity name.
/// Supported values: "entity-id", "last-changed", "last-updated",
/// "last-triggered", "position", "tilt-position", "brightness".
/// Set before calling configureWithEntity:.
@property (nonatomic, copy) NSString *secondaryInfo;

/// Format for secondary_info timestamps: "relative", "date", "time", "datetime", "total".
/// Defaults to "relative" if not set.
@property (nonatomic, copy) NSString *secondaryInfoFormat;

@end
