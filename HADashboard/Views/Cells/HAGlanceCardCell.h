#import <UIKit/UIKit.h>
#import "HACellCompat.h"

@class HAEntity;
@class HADashboardConfigSection;
@class HADashboardConfigItem;

/// Renders a Glance card: a grid of entity icons with optional names and states.
@interface HAGlanceCardCell : HACollectionViewCellBase

/// Called when a glance item is tapped. Passes the entity and per-entity action config.
@property (nonatomic, copy) void (^entityTapBlock)(HAEntity *entity, NSDictionary *actionConfig);

/// Configure the cell with a composite section (entityIds + customProperties).
- (void)configureWithSection:(HADashboardConfigSection *)section
                    entities:(NSDictionary<NSString *, HAEntity *> *)allEntities
                  configItem:(HADashboardConfigItem *)configItem;

/// Compute preferred height for the card.
+ (CGFloat)preferredHeightForSection:(HADashboardConfigSection *)section
                               width:(CGFloat)width
                          configItem:(HADashboardConfigItem *)configItem;

@end
