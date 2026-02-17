#import <UIKit/UIKit.h>

/// Simple key-value row for displaying entity attributes.
/// Left-aligned key label, right-aligned value label (max 60% width).
@interface HAAttributeRowView : UIView

- (void)configureWithKey:(NSString *)key value:(NSString *)value;

@end
