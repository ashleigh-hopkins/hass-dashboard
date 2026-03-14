#import <UIKit/UIKit.h>

/// Backward-compatible stack view.
/// On iOS 9+ delegates to a real UIStackView internally.
/// On iOS 5-8 arranges subviews via frame math in layoutSubviews.
@interface HAStackView : UIView

@property (nonatomic, assign) NSInteger axis;         // 0=horizontal, 1=vertical (matches UILayoutConstraintAxis)
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) NSInteger distribution;  // 0=fill, 1=fillEqually, 2=fillProportionally, 3=equalSpacing, 4=equalCentering
@property (nonatomic, assign) NSInteger alignment;     // 0=fill, 1=leading/top, 2=firstBaseline, 3=center, 4=lastBaseline, 5=trailing/bottom
@property (nonatomic, readonly) NSArray<UIView *> *arrangedSubviews;

- (instancetype)initWithArrangedSubviews:(NSArray<UIView *> *)views;
- (void)addArrangedSubview:(UIView *)view;
- (void)removeArrangedSubview:(UIView *)view;
- (void)insertArrangedSubview:(UIView *)view atIndex:(NSUInteger)index;

@end
