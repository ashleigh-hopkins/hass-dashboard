#import <UIKit/UIKit.h>

@class HAEntity;

/// Abstract base class for tile card feature views (brightness slider, cover buttons, etc.).
/// Subclasses implement configureWithEntity:featureConfig: and updateWithEntity:.
@interface HATileFeatureView : UIView

@property (nonatomic, weak) HAEntity *entity;
@property (nonatomic, copy) NSDictionary *featureConfig;

/// Callback invoked when the feature needs to call an HA service.
/// Parameters: service name, domain, service data dictionary.
@property (nonatomic, copy) void (^serviceCallBlock)(NSString *service, NSString *domain, NSDictionary *data);

/// Initial configuration with entity and feature config dictionary.
- (void)configureWithEntity:(HAEntity *)entity featureConfig:(NSDictionary *)config;

/// Live state update — called when entity state changes via WebSocket.
/// Default implementation calls configureWithEntity:featureConfig: with existing config.
- (void)updateWithEntity:(HAEntity *)entity;

/// Preferred height for this feature type. Subclasses override.
+ (CGFloat)preferredHeight;

/// The feature type string (e.g. "light-brightness"). Set during configuration.
@property (nonatomic, copy) NSString *featureType;

@end
