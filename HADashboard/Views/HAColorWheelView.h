#import <UIKit/UIKit.h>

@class HAColorWheelView;

@protocol HAColorWheelViewDelegate <NSObject>
/// Called continuously during drag. Use for live label updates.
- (void)colorWheelView:(HAColorWheelView *)view didChangeHue:(CGFloat)hue saturation:(CGFloat)saturation;
/// Called on touch-up. Use for committing the service call.
- (void)colorWheelViewDidFinishChanging:(HAColorWheelView *)view hue:(CGFloat)hue saturation:(CGFloat)saturation;
@end

@interface HAColorWheelView : UIView

@property (nonatomic, weak) id<HAColorWheelViewDelegate> delegate;

/// Current hue (0-360 degrees)
@property (nonatomic, assign, readonly) CGFloat hue;
/// Current saturation (0-100 percent)
@property (nonatomic, assign, readonly) CGFloat saturation;

/// Set hue/saturation programmatically (e.g. from entity state).
- (void)setHue:(CGFloat)hue saturation:(CGFloat)saturation animated:(BOOL)animated;

@end
