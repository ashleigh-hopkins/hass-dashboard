#import <UIKit/UIKit.h>

@class HAEntity;
@class HAEntityDetailViewController;

/// Protocol for domain-specific control sections in the entity detail view.
@protocol HAEntityDetailSection <NSObject>

/// Create the view for the given entity. The view is added to the detail stack.
- (UIView *)viewForEntity:(HAEntity *)entity;

/// Preferred height for the section view.
- (CGFloat)preferredHeight;

/// Update the section when the entity state changes.
- (void)updateWithEntity:(HAEntity *)entity;

@end

/// Callback for service calls from detail sections.
/// The detail VC implements this and routes to HAConnectionManager via its delegate.
typedef void(^HADetailServiceBlock)(NSString *service, NSString *domain, NSDictionary *data, NSString *entityId);

/// Factory that returns the appropriate section for an entity's domain.
@interface HAEntityDetailSectionFactory : NSObject

+ (id<HAEntityDetailSection>)sectionForEntity:(HAEntity *)entity
                                 serviceBlock:(HADetailServiceBlock)serviceBlock;

@end
