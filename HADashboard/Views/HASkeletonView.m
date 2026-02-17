#import "HASkeletonView.h"
#import "HATheme.h"

static NSString *const kShimmerAnimationKey = @"shimmerAnimation";

@interface HASkeletonView () {
    CGFloat _lastWidth;
}
@property (nonatomic, strong) NSMutableArray<UIView *> *cardViews;
@property (nonatomic, strong) CAGradientLayer *shimmerLayer;
@property (nonatomic, strong) CAShapeLayer *shimmerMask;
@end

@implementation HASkeletonView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.cardViews = [NSMutableArray array];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    if (width < 1) return;
    if (fabs(width - _lastWidth) < 1.0) return;
    _lastWidth = width;

    // Remove old cards
    for (UIView *v in self.cardViews) [v removeFromSuperview];
    [self.cardViews removeAllObjects];

    CGFloat padding = 16;
    CGFloat gap = 8;
    CGFloat cardRadius = 12;
    CGFloat contentWidth = width - padding * 2;
    CGFloat y = 12;

    UIColor *cardColor = [HATheme cellBackgroundColor];
    UIColor *lineColor = [[HATheme tertiaryTextColor] colorWithAlphaComponent:0.20];

    // Row 1: Large card (simulates thermostat/weather)
    y = [self addCardAtX:padding y:y width:contentWidth height:170 radius:cardRadius
               cardColor:cardColor lineColor:lineColor
              lineWidths:@[@0.35, @0.55, @0.25] lineOffsetY:30];
    y += gap;

    // Row 2: Two medium cards side by side (simulates entity tiles)
    CGFloat halfWidth = (contentWidth - gap) / 2.0;
    [self addCardAtX:padding y:y width:halfWidth height:100 radius:cardRadius
           cardColor:cardColor lineColor:lineColor
          lineWidths:@[@0.5, @0.7] lineOffsetY:20];
    y = [self addCardAtX:padding + halfWidth + gap y:y width:halfWidth height:100 radius:cardRadius
               cardColor:cardColor lineColor:lineColor
              lineWidths:@[@0.6, @0.4] lineOffsetY:20];
    y += gap;

    // Row 3: Full-width list card (simulates entities card with rows)
    y = [self addCardAtX:padding y:y width:contentWidth height:180 radius:cardRadius
               cardColor:cardColor lineColor:lineColor
              lineWidths:@[@0.4, @0.65, @0.5, @0.55] lineOffsetY:24];
    y += gap;

    // Row 4: Three small cards (simulates badges/sensors)
    CGFloat thirdWidth = (contentWidth - gap * 2) / 3.0;
    [self addCardAtX:padding y:y width:thirdWidth height:80 radius:cardRadius
           cardColor:cardColor lineColor:lineColor
          lineWidths:@[@0.5, @0.7] lineOffsetY:16];
    [self addCardAtX:padding + thirdWidth + gap y:y width:thirdWidth height:80 radius:cardRadius
           cardColor:cardColor lineColor:lineColor
          lineWidths:@[@0.6, @0.4] lineOffsetY:16];
    [self addCardAtX:padding + (thirdWidth + gap) * 2 y:y width:thirdWidth height:80 radius:cardRadius
           cardColor:cardColor lineColor:lineColor
          lineWidths:@[@0.45, @0.65] lineOffsetY:16];
    y += 80 + gap;

    // Row 5: Another full-width card
    [self addCardAtX:padding y:y width:contentWidth height:120 radius:cardRadius
           cardColor:cardColor lineColor:lineColor
          lineWidths:@[@0.3, @0.7, @0.45] lineOffsetY:20];

    // Update shimmer mask + layer
    [self updateShimmer];
}

/// Add a card placeholder and return the bottom Y coordinate.
- (CGFloat)addCardAtX:(CGFloat)x y:(CGFloat)y width:(CGFloat)w height:(CGFloat)h
               radius:(CGFloat)radius cardColor:(UIColor *)cardColor
            lineColor:(UIColor *)lineColor lineWidths:(NSArray<NSNumber *> *)lineWidths
          lineOffsetY:(CGFloat)startY {

    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    card.backgroundColor = cardColor;
    card.layer.cornerRadius = radius;
    card.clipsToBounds = YES;

    // Inner content line placeholders
    CGFloat lineH = 10;
    CGFloat lineGap = 12;
    CGFloat linePadding = 16;
    CGFloat lineY = startY;

    for (NSNumber *widthFraction in lineWidths) {
        CGFloat lineW = (w - linePadding * 2) * [widthFraction floatValue];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(linePadding, lineY, lineW, lineH)];
        line.backgroundColor = lineColor;
        line.layer.cornerRadius = lineH / 2.0;
        [card addSubview:line];
        lineY += lineH + lineGap;
    }

    [self addSubview:card];
    [self.cardViews addObject:card];

    return y + h;
}

#pragma mark - Shimmer Animation

- (void)updateShimmer {
    // Build a combined mask path from all card frames
    UIBezierPath *combinedPath = [UIBezierPath bezierPath];
    for (UIView *card in self.cardViews) {
        UIBezierPath *rect = [UIBezierPath bezierPathWithRoundedRect:card.frame cornerRadius:card.layer.cornerRadius];
        [combinedPath appendPath:rect];
    }

    if (!self.shimmerMask) {
        self.shimmerMask = [CAShapeLayer layer];
    }
    self.shimmerMask.path = combinedPath.CGPath;

    if (!self.shimmerLayer) {
        self.shimmerLayer = [CAGradientLayer layer];
        self.shimmerLayer.colors = @[
            (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
            (id)[UIColor colorWithWhite:1.0 alpha:0.12].CGColor,
            (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
        ];
        self.shimmerLayer.startPoint = CGPointMake(0, 0.5);
        self.shimmerLayer.endPoint = CGPointMake(1, 0.5);
        self.shimmerLayer.locations = @[@(-1.0), @(-0.5), @(0.0)];
        [self.layer addSublayer:self.shimmerLayer];
    }

    self.shimmerLayer.frame = self.bounds;
    self.shimmerLayer.mask = self.shimmerMask;
}

- (void)startAnimating {
    [self.shimmerLayer removeAnimationForKey:kShimmerAnimationKey];

    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"locations"];
    anim.fromValue = @[@(-1.0), @(-0.5), @(0.0)];
    anim.toValue = @[@(1.0), @(1.5), @(2.0)];
    anim.duration = 1.5;
    anim.repeatCount = HUGE_VALF;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    [self.shimmerLayer addAnimation:anim forKey:kShimmerAnimationKey];
}

- (void)stopAnimating {
    [self.shimmerLayer removeAnimationForKey:kShimmerAnimationKey];
}

@end
