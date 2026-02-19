#import "HAConstellationView.h"
#import "HATheme.h"

/// A single dot in the constellation with its velocity and layer.
@interface HAConstellationDot : NSObject
@property (nonatomic, strong) CALayer *layer;
@property (nonatomic, assign) CGPoint velocity;  // points per second
@end

@implementation HAConstellationDot
@end

// ────────────────────────────────────────────────────────────────────────────

static const NSUInteger kDotCount        = 18;
static const CGFloat    kDotRadius       = 2.5;
static const CGFloat    kLineDistance    = 150.0;  // max distance for line connections
static const CGFloat    kDotAlpha        = 0.35;
static const CGFloat    kLineAlpha       = 0.12;
static const CGFloat    kMinSpeed        = 6.0;    // points/sec
static const CGFloat    kMaxSpeed        = 18.0;
static const NSTimeInterval kLineUpdateInterval = 0.15; // seconds between line redraws (~7 FPS)
static const NSTimeInterval kDotAnimDuration    = 12.0; // seconds per drift segment

@interface HAConstellationView ()
@property (nonatomic, strong) NSMutableArray<HAConstellationDot *> *dots;
@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) NSTimer *lineTimer;
@property (nonatomic, assign) BOOL animating;
@end

@implementation HAConstellationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.clipsToBounds = YES;
        self.dots = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [self stopAnimating];
}

#pragma mark - Public

- (void)startAnimating {
    if (self.animating) return;

    // Respect Reduce Motion
    if (UIAccessibilityIsReduceMotionEnabled()) {
        [self showStaticConstellation];
        return;
    }

    self.animating = YES;

    // Line layer (single shape layer for all connections)
    self.lineLayer = [CAShapeLayer layer];
    self.lineLayer.strokeColor = [self dotColor].CGColor;
    self.lineLayer.fillColor = nil;
    self.lineLayer.lineWidth = 1.0;
    self.lineLayer.opacity = kLineAlpha;
    [self.layer insertSublayer:self.lineLayer atIndex:0];

    // Create dots
    CGRect bounds = self.bounds;
    for (NSUInteger i = 0; i < kDotCount; i++) {
        HAConstellationDot *dot = [[HAConstellationDot alloc] init];

        CALayer *dotLayer = [CALayer layer];
        dotLayer.bounds = CGRectMake(0, 0, kDotRadius * 2, kDotRadius * 2);
        dotLayer.cornerRadius = kDotRadius;
        dotLayer.backgroundColor = [self dotColor].CGColor;
        dotLayer.opacity = kDotAlpha;

        // Random starting position
        CGFloat x = [self randomFloatMin:0 max:bounds.size.width];
        CGFloat y = [self randomFloatMin:0 max:bounds.size.height];
        dotLayer.position = CGPointMake(x, y);

        dot.layer = dotLayer;
        dot.velocity = [self randomVelocity];

        [self.layer addSublayer:dotLayer];
        [self.dots addObject:dot];

        // Start the first drift animation
        [self animateDot:dot inBounds:bounds];
    }

    // Timer for updating line connections
    self.lineTimer = [NSTimer scheduledTimerWithTimeInterval:kLineUpdateInterval
                                                     target:self
                                                   selector:@selector(updateLines)
                                                   userInfo:nil
                                                    repeats:YES];
    // Allow timer to fire during scroll tracking
    [[NSRunLoop mainRunLoop] addTimer:self.lineTimer forMode:NSRunLoopCommonModes];
}

- (void)stopAnimating {
    self.animating = NO;
    [self.lineTimer invalidate];
    self.lineTimer = nil;

    for (HAConstellationDot *dot in self.dots) {
        [dot.layer removeAllAnimations];
        [dot.layer removeFromSuperlayer];
    }
    [self.dots removeAllObjects];

    [self.lineLayer removeFromSuperlayer];
    self.lineLayer = nil;
}

#pragma mark - Static Constellation (Reduce Motion)

- (void)showStaticConstellation {
    self.animating = YES;

    self.lineLayer = [CAShapeLayer layer];
    self.lineLayer.strokeColor = [self dotColor].CGColor;
    self.lineLayer.fillColor = nil;
    self.lineLayer.lineWidth = 1.0;
    self.lineLayer.opacity = kLineAlpha;
    [self.layer insertSublayer:self.lineLayer atIndex:0];

    CGRect bounds = self.bounds;
    for (NSUInteger i = 0; i < kDotCount; i++) {
        HAConstellationDot *dot = [[HAConstellationDot alloc] init];
        CALayer *dotLayer = [CALayer layer];
        dotLayer.bounds = CGRectMake(0, 0, kDotRadius * 2, kDotRadius * 2);
        dotLayer.cornerRadius = kDotRadius;
        dotLayer.backgroundColor = [self dotColor].CGColor;
        dotLayer.opacity = kDotAlpha;
        CGFloat x = [self randomFloatMin:0 max:bounds.size.width];
        CGFloat y = [self randomFloatMin:0 max:bounds.size.height];
        dotLayer.position = CGPointMake(x, y);
        dot.layer = dotLayer;
        [self.layer addSublayer:dotLayer];
        [self.dots addObject:dot];
    }
    [self updateLines];
}

#pragma mark - Dot Animation

- (void)animateDot:(HAConstellationDot *)dot inBounds:(CGRect)bounds {
    if (!self.animating) return;

    // Current presentation position (where the dot actually is mid-animation)
    CALayer *pres = dot.layer.presentationLayer ?: dot.layer;
    CGPoint from = pres.position;

    // Calculate a target point based on velocity + duration, clamped to bounds
    CGFloat dx = dot.velocity.x * kDotAnimDuration;
    CGFloat dy = dot.velocity.y * kDotAnimDuration;
    CGFloat toX = from.x + dx;
    CGFloat toY = from.y + dy;

    // Bounce off edges
    if (toX < 0 || toX > bounds.size.width) {
        dot.velocity = CGPointMake(-dot.velocity.x, dot.velocity.y);
        toX = fmax(0, fmin(toX, bounds.size.width));
    }
    if (toY < 0 || toY > bounds.size.height) {
        dot.velocity = CGPointMake(dot.velocity.x, -dot.velocity.y);
        toY = fmax(0, fmin(toY, bounds.size.height));
    }

    CGPoint to = CGPointMake(toX, toY);

    // Update the model layer position
    dot.layer.position = to;

    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:from];
    anim.toValue = [NSValue valueWithCGPoint:to];
    anim.duration = kDotAnimDuration;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    // Use a completion block to chain the next drift segment
    __weak typeof(self) weakSelf = self;
    __weak HAConstellationDot *weakDot = dot;
    anim.delegate = nil; // We use removedOnCompletion + KVO trick below

    // Set a completion via CATransaction
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong HAConstellationDot *strongDot = weakDot;
        if (strongSelf && strongDot && strongSelf.animating) {
            // Slight random velocity perturbation each cycle
            CGFloat vx = strongDot.velocity.x + [strongSelf randomFloatMin:-2 max:2];
            CGFloat vy = strongDot.velocity.y + [strongSelf randomFloatMin:-2 max:2];
            // Clamp speed
            CGFloat speed = sqrt(vx * vx + vy * vy);
            if (speed < kMinSpeed) {
                CGFloat scale = kMinSpeed / fmax(speed, 0.01);
                vx *= scale; vy *= scale;
            } else if (speed > kMaxSpeed) {
                CGFloat scale = kMaxSpeed / speed;
                vx *= scale; vy *= scale;
            }
            strongDot.velocity = CGPointMake(vx, vy);
            [strongSelf animateDot:strongDot inBounds:strongSelf.bounds];
        }
    }];
    [dot.layer addAnimation:anim forKey:@"drift"];
    [CATransaction commit];
}

#pragma mark - Line Updates

- (void)updateLines {
    if (self.dots.count == 0) return;

    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat maxDist2 = kLineDistance * kLineDistance;

    // Get current presentation positions
    NSUInteger count = self.dots.count;
    CGPoint positions[count];
    for (NSUInteger i = 0; i < count; i++) {
        CALayer *pres = self.dots[i].layer.presentationLayer ?: self.dots[i].layer;
        positions[i] = pres.position;
    }

    // Draw lines between dots within kLineDistance
    for (NSUInteger i = 0; i < count; i++) {
        for (NSUInteger j = i + 1; j < count; j++) {
            CGFloat dx = positions[i].x - positions[j].x;
            CGFloat dy = positions[i].y - positions[j].y;
            CGFloat dist2 = dx * dx + dy * dy;
            if (dist2 < maxDist2) {
                CGPathMoveToPoint(path, NULL, positions[i].x, positions[i].y);
                CGPathAddLineToPoint(path, NULL, positions[j].x, positions[j].y);
            }
        }
    }

    self.lineLayer.path = path;
    CGPathRelease(path);
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lineLayer.frame = self.bounds;

    // If we have dots but aren't animating positions yet (static mode or first layout)
    if (!self.animating && self.dots.count == 0) return;
}

#pragma mark - Helpers

- (UIColor *)dotColor {
    return [HATheme accentColor];
}

- (CGPoint)randomVelocity {
    CGFloat angle = [self randomFloatMin:0 max:M_PI * 2];
    CGFloat speed = [self randomFloatMin:kMinSpeed max:kMaxSpeed];
    return CGPointMake(cos(angle) * speed, sin(angle) * speed);
}

- (CGFloat)randomFloatMin:(CGFloat)min max:(CGFloat)max {
    return min + (max - min) * ((CGFloat)arc4random() / (CGFloat)UINT32_MAX);
}

@end
