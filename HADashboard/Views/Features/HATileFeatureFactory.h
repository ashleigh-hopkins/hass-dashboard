#import <UIKit/UIKit.h>

@class HAEntity;
@class HATileFeatureView;

/// Factory that maps tile feature type strings to concrete HATileFeatureView subclasses.
@interface HATileFeatureFactory : NSObject

/// Create a feature view for the given feature config and entity.
/// Returns nil for unsupported feature types (caller should skip silently).
+ (HATileFeatureView *)featureViewForConfig:(NSDictionary *)config entity:(HAEntity *)entity;

/// Return the preferred height for a feature type string.
/// Returns 0 for unsupported types.
+ (CGFloat)heightForFeatureType:(NSString *)featureType;

@end
