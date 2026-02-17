# Home Assistant Circular Thermostat Gauge - iOS Native Implementation Spec

## Overview
This document provides exact specifications for replicating the Home Assistant web thermostat card's circular gauge in iOS native code using Objective-C and Core Animation.

## Source Files Reference
- `src/components/ha-control-circular-slider.ts` - Base circular slider SVG component
- `src/state-control/climate/ha-state-control-climate-temperature.ts` - Climate control wrapper
- `src/common/color/state_color.ts` - Color mapping system
- `src/data/climate.ts` - HVAC mode constants

---

## 1. SVG Coordinate System & Layout

### Base Dimensions
- **SVG ViewBox**: `0 0 320 320` (320x320 units)
- **Center Point**: `(160, 160)`
- **Arc Radius (RADIUS)**: `145` units
- **Container Size**: For iOS, scale to fit view bounds (e.g., 280x280 pts recommended)

### Proportions (as ratios of container width)
```
Arc radius / container half-width = 145 / 160 = 0.90625
```

---

## 2. Arc Geometry Constants

### Angular Constants
```
MAX_ANGLE = 270°         // Total arc sweep (270° out of 360°)
ROTATE_ANGLE = 135°      // Rotation to position arc gap at bottom
                         // Formula: 360 - MAX_ANGLE/2 - 90 = 135
```

### Visual Description
- Arc starts at **225°** (bottom-left, measured clockwise from 3 o'clock)
- Arc ends at **135°** (bottom-right)
- **Gap at bottom**: 90° opening (from 135° to 225°)
- Arc sweeps **270°** clockwise through the top

### Arc Length Calculation
```javascript
const track = (RADIUS * 2 * Math.PI * MAX_ANGLE) / 360
            = (145 * 2 * π * 270) / 360
            ≈ 682.59 units
```

---

## 3. Stroke Widths (Exact Values)

All widths are in SVG units (scale proportionally for iOS):

| Element | Stroke Width | Purpose |
|---------|--------------|---------|
| Background track | **24** | Dim gray circular track showing full range |
| Active arc | **24** | Colored arc showing current value/range |
| Target indicator (thumb) | **18** | Inner stroke of draggable thumb |
| Target border | **24** | Outer border of thumb (same as arc) |
| Current temperature indicator | **8** | Thin indicator showing actual temp |
| Interaction hit area (invisible) | **48** | `24 + 2 * 12` (margin) |

### iOS Scaling Example
For a 280pt container (scale factor = 280/320 = 0.875):
```
Background track:    24 * 0.875 = 21pt
Target thumb:        18 * 0.875 = 15.75pt
Current indicator:   8 * 0.875 = 7pt
```

---

## 4. Target Thumb (Draggable Handle)

### Rendering Details
- **Type**: Circular "dot" at the end of the active arc
- **Outer radius**: 24 units (includes stroke width consideration)
- **Inner stroke width**: 18 units
- **Fill**: Background color (dark gray in dark mode)
- **Stroke**: Same color as active arc (heat/cool mode color)
- **Position**: At the end angle of the active arc, on the RADIUS circle

### Calculation (for single target mode)
```javascript
const valueAngle = (value - min) / (max - min) * MAX_ANGLE;
const angle = ROTATE_ANGLE + valueAngle;
const x = 160 + RADIUS * Math.cos(angle * Math.PI / 180);
const y = 160 + RADIUS * Math.sin(angle * Math.PI / 180);
```

### iOS Implementation (Core Animation)
```objc
CGFloat radius = 145.0 * scale;
CGFloat valueAngle = ((value - min) / (max - min)) * 270.0;
CGFloat angle = (135.0 + valueAngle) * M_PI / 180.0;
CGPoint thumbCenter = CGPointMake(
    centerX + radius * cos(angle),
    centerY + radius * sin(angle)
);

// Thumb: outer circle with stroke
CAShapeLayer *thumbLayer = [CAShapeLayer layer];
thumbLayer.path = [UIBezierPath bezierPathWithArcCenter:thumbCenter
                                                 radius:12.0 * scale
                                             startAngle:0
                                               endAngle:2 * M_PI
                                              clockwise:YES].CGPath;
thumbLayer.fillColor = backgroundColor.CGColor;
thumbLayer.strokeColor = arcColor.CGColor;
thumbLayer.lineWidth = 18.0 * scale;
```

---

## 5. Current Temperature Indicator

### Rendering Details
- **Type**: Small circular marker on the arc
- **Stroke width**: 8 units
- **Color**: Match mode color but dimmed (lower opacity ~0.7)
- **Position**: At angle corresponding to current_temperature value
- **Shape**: Circle outline at the arc radius

### Display Logic
- Only shown when `current_temperature` attribute exists
- Position calculated same as target thumb but at current temp angle
- Typically appears "behind" or "ahead" of target thumb

### iOS Implementation
```objc
if (currentTemp != nil) {
    CGFloat currentAngle = ((currentTemp - min) / (max - min)) * 270.0;
    CGFloat angle = (135.0 + currentAngle) * M_PI / 180.0;
    CGPoint indicatorCenter = CGPointMake(
        centerX + radius * cos(angle),
        centerY + radius * sin(angle)
    );

    CAShapeLayer *currentIndicator = [CAShapeLayer layer];
    currentIndicator.path = [UIBezierPath bezierPathWithArcCenter:indicatorCenter
                                                           radius:4.0 * scale
                                                       startAngle:0
                                                         endAngle:2 * M_PI
                                                        clockwise:YES].CGPath;
    currentIndicator.strokeColor = [arcColor colorWithAlphaComponent:0.7].CGColor;
    currentIndicator.lineWidth = 8.0 * scale;
    currentIndicator.fillColor = [UIColor clearColor].CGColor;
}
```

---

## 6. Arc Rendering (Single Mode)

### Background Track
- **Path**: Full 270° arc from ROTATE_ANGLE to ROTATE_ANGLE + MAX_ANGLE
- **Stroke**: 24 units
- **Color**: `--control-circular-slider-background` with opacity 0.3
- **Cap**: `round` (rounded ends)

### Active Arc (Heat/Cool/Auto)
- **Path**: From ROTATE_ANGLE to ROTATE_ANGLE + valueAngle
- **Stroke**: 24 units
- **Color**: Mode-specific color (see section 9)
- **Cap**: `round`

### iOS Implementation (Using UIBezierPath + CAShapeLayer)
```objc
// Background track (270° arc)
UIBezierPath *trackPath = [UIBezierPath bezierPathWithArcCenter:center
                                                         radius:radius
                                                     startAngle:135.0 * M_PI / 180.0
                                                       endAngle:(135.0 + 270.0) * M_PI / 180.0
                                                      clockwise:YES];
CAShapeLayer *trackLayer = [CAShapeLayer layer];
trackLayer.path = trackPath.CGPath;
trackLayer.strokeColor = [UIColor colorWithWhite:0.3 alpha:0.3].CGColor;
trackLayer.lineWidth = 24.0 * scale;
trackLayer.lineCap = kCALineCapRound;
trackLayer.fillColor = [UIColor clearColor].CGColor;

// Active arc
CGFloat valueAngle = ((value - min) / (max - min)) * 270.0;
UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:center
                                                       radius:radius
                                                   startAngle:135.0 * M_PI / 180.0
                                                     endAngle:(135.0 + valueAngle) * M_PI / 180.0
                                                    clockwise:YES];
CAShapeLayer *arcLayer = [CAShapeLayer layer];
arcLayer.path = arcPath.CGPath;
arcLayer.strokeColor = modeColor.CGColor;
arcLayer.lineWidth = 24.0 * scale;
arcLayer.lineCap = kCALineCapRound;
arcLayer.fillColor = [UIColor clearColor].CGColor;
```

---

## 7. Dual Mode (Heat/Cool Range)

### Behavior
When climate entity supports `target_temp_low` and `target_temp_high`:
- **Low thumb**: Positioned at target_temp_low angle (heat mode color)
- **High thumb**: Positioned at target_temp_high angle (cool mode color)
- **Gap arc**: From low to high shows the "allowed" temperature range
- **Outside arcs**: Dimmed or background color

### Slider Mode Mapping
```javascript
const SLIDER_MODES = {
  "heat": "start",      // Arc starts from beginning to value
  "cool": "end",        // Arc ends at value, works backwards
  "heat_cool": "full",  // Dual range with two thumbs
  "auto": "full",       // Dual range
  // ... other modes
};
```

### iOS Implementation Notes
- Render two thumb circles (one for low, one for high)
- Active arc between the two thumbs
- Allow dragging either thumb independently
- Snap to prevent low > high

---

## 8. Text & Button Positioning

### Text Elements (from climate temperature control)

#### Primary Display (Center, Large)
- **Font size**: ~48pt (adjust to container)
- **Position**: Centered in circle
- **Content**:
  - If `show_current_as_primary`: Show current_temperature
  - Otherwise: Show target temperature
- **Format**: `21.0°C` (monospaced digits)

#### Label (Above Primary)
- **Font size**: ~14pt
- **Position**: Above primary temp, centered
- **Content**: HVAC action (e.g., "Cooling", "Heating", "Idle")
- **Color**: Match mode color

#### Secondary Display (Below Primary)
- **Font size**: ~16pt
- **Position**: Below primary, centered
- **Content**:
  - If primary shows current: Display target with thermostat icon
  - If primary shows target: Display current with thermometer icon
- **Format**: `🌡️ 22 °C` or `🌡️ 22 °C`

### Button Positioning (+/- Controls)

**Location**: Bottom of circle, centered horizontally
**Layout**: Horizontal stack, side-by-side
**Size**: ~60pt diameter each
**Spacing**: ~12pt gap between buttons
**Style**: Outlined circular buttons
**Icons**: Minus (−) and Plus (+)
**Position calculation**:
```
Y position = centerY + radius * 0.65
```

### iOS Layout Example
```objc
// Primary temperature label
UILabel *primaryLabel = [[UILabel alloc] init];
primaryLabel.font = [UIFont monospacedDigitSystemFontOfSize:48 weight:UIFontWeightMedium];
primaryLabel.textAlignment = NSTextAlignmentCenter;
primaryLabel.center = circleCenter;

// +/- buttons at bottom
CGFloat buttonY = circleCenter.y + radius * 0.65;
CGFloat buttonSpacing = 12.0;
CGFloat buttonWidth = 60.0;

UIButton *minusButton = [UIButton buttonWithType:UIButtonTypeSystem];
minusButton.frame = CGRectMake(
    circleCenter.x - buttonWidth - buttonSpacing/2,
    buttonY - buttonWidth/2,
    buttonWidth,
    buttonWidth
);

UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeSystem];
plusButton.frame = CGRectMake(
    circleCenter.x + buttonSpacing/2,
    buttonY - buttonWidth/2,
    buttonWidth,
    buttonWidth
);
```

---

## 9. HVAC Mode Color Mapping

### Mode to Color System

Home Assistant uses domain state colors defined via CSS variables. For iOS native implementation, use these equivalent colors:

#### Heat Mode
- **CSS Variable**: `--state-climate-heat-color` (or falls back to domain color)
- **Typical Value**: Orange/amber tones
- **iOS Color**: `rgb(255, 152, 0)` or `#FF9800` (Material Orange 500)
- **Dark Mode**: Slightly dimmed, `rgb(251, 140, 0)` or `#FB8C00`

#### Cool Mode
- **CSS Variable**: `--state-climate-cool-color`
- **Typical Value**: Blue tones
- **iOS Color**: `rgb(33, 150, 243)` or `#2196F3` (Material Blue 500)
- **Dark Mode**: Lighter blue, `rgb(66, 165, 245)` or `#42A5F5`

#### Auto / Heat-Cool Mode
- **Behavior**: Dual gradient or split colors
- **Low (heat) side**: Orange (as above)
- **High (cool) side**: Blue (as above)
- **Alternative**: Use a purple/teal intermediate color

#### Off Mode
- **Color**: Gray, disabled appearance
- **iOS Color**: `rgb(158, 158, 158)` or `#9E9E9E` (Material Grey 500)
- **Dark Mode**: `rgb(189, 189, 189)` or `#BDBDBD`

### HVAC Action to Mode Mapping
Used to determine color when HVAC is active:

```javascript
CLIMATE_HVAC_ACTION_TO_MODE = {
  "heating": "heat",      // → Orange
  "cooling": "cool",      // → Blue
  "drying": "dry",        // → Amber
  "idle": "off",          // → Gray
  "off": "off",           // → Gray
  "fan": "fan_only",      // → Teal/Green
  "defrosting": "heat",   // → Orange
  "preheating": "heat"    // → Orange
};
```

### iOS Implementation
```objc
- (UIColor *)colorForHVACMode:(NSString *)mode action:(NSString *)action {
    BOOL isActive = action && ![action isEqualToString:@"idle"] && ![action isEqualToString:@"off"];

    if (!isActive) {
        return [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1.0]; // Gray
    }

    // Map action to mode if available
    NSDictionary *actionToMode = @{
        @"heating": @"heat",
        @"cooling": @"cool",
        @"drying": @"dry",
        @"fan": @"fan_only",
        @"defrosting": @"heat",
        @"preheating": @"heat"
    };

    NSString *effectiveMode = actionToMode[action] ?: mode;

    if ([effectiveMode isEqualToString:@"heat"]) {
        return [UIColor colorWithRed:1.0 green:0.596 blue:0.0 alpha:1.0]; // #FF9800
    } else if ([effectiveMode isEqualToString:@"cool"]) {
        return [UIColor colorWithRed:0.129 green:0.588 blue:0.953 alpha:1.0]; // #2196F3
    } else if ([effectiveMode isEqualToString:@"heat_cool"] || [effectiveMode isEqualToString:@"auto"]) {
        // Return low and high colors separately for dual mode
        return [UIColor colorWithRed:0.612 green:0.153 blue:0.690 alpha:1.0]; // Purple #9C27B0
    }

    return [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1.0]; // Default gray
}
```

### Existing HATheme Colors
Your current implementation has:
```objc
// Light mode
heatTintColor: rgb(255, 242, 230) // #FFF2E6 - Very light orange
coolTintColor: rgb(230, 242, 255) // #E6F2FF - Very light blue

// Dark mode
heatTintColor: rgb(56, 38, 26)    // #382614 - Dark orange-brown
coolTintColor: rgb(26, 38, 56)    // #1A2638 - Dark blue-gray
```

**Recommendation**: These are cell background tints. For the arc stroke, use more saturated colors:
```objc
+ (UIColor *)heatArcColor {
    return [self colorWithLight:[UIColor colorWithRed:1.0 green:0.596 blue:0.0 alpha:1.0]
                           dark:[UIColor colorWithRed:0.984 green:0.549 blue:0.0 alpha:1.0]];
}

+ (UIColor *)coolArcColor {
    return [self colorWithLight:[UIColor colorWithRed:0.129 green:0.588 blue:0.953 alpha:1.0]
                           dark:[UIColor colorWithRed:0.259 green:0.647 blue:0.961 alpha:1.0]];
}
```

---

## 10. CSS Custom Properties & Defaults

From the web component's `:host` CSS:

```css
:host {
  --control-circular-slider-color: var(--primary-color);
  --control-circular-slider-background: var(--disabled-color);
  --control-circular-slider-background-opacity: 0.3;
  --control-circular-slider-low-color: var(--control-circular-slider-color);
  --control-circular-slider-high-color: var(--control-circular-slider-color);
  --control-circular-slider-interaction-margin: 12px;
}
```

### iOS Equivalent
```objc
// Default colors (map to your HATheme)
UIColor *primaryColor = [HATheme accentColor];              // Control color
UIColor *backgroundColor = [HATheme secondaryTextColor];     // Background track
CGFloat backgroundOpacity = 0.3;                             // Track opacity
CGFloat interactionMargin = 12.0;                            // Hit area expansion
```

---

## 11. Interaction & Touch Handling

### Hit Areas
- **Thumb hit area**: Circle with radius `12 + interactionMargin = 24` units
- **Arc hit area**: Arc path with stroke width `24 + 2 * interactionMargin = 48` units
- Provides comfortable touch targets on mobile

### Gesture Handling
1. **Tap**: Jump to tapped angle (if on arc)
2. **Pan**: Drag thumb to new position
3. **Snap to step**: Round value to nearest step increment

### iOS Implementation
```objc
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];

    // Convert touch to angle
    CGFloat dx = location.x - self.center.x;
    CGFloat dy = location.y - self.center.y;
    CGFloat angle = atan2(dy, dx) * 180.0 / M_PI;

    // Normalize to 0-360
    if (angle < 0) angle += 360.0;

    // Map to value range (accounting for ROTATE_ANGLE and MAX_ANGLE)
    CGFloat normalizedAngle = angle - 135.0;
    if (normalizedAngle < 0) normalizedAngle += 360.0;

    if (normalizedAngle <= 270.0) {
        CGFloat ratio = normalizedAngle / 270.0;
        CGFloat newValue = self.minValue + ratio * (self.maxValue - self.minValue);

        // Snap to step
        newValue = round(newValue / self.step) * self.step;

        [self setValue:newValue animated:YES];
    }
}
```

---

## 12. Animation

### Value Changes
When value updates (from user interaction or state changes):
- **Duration**: ~200ms
- **Timing**: Ease-in-out
- **Properties**: Arc strokeEnd, thumb position

### iOS Core Animation
```objc
- (void)updateArcForValue:(CGFloat)value animated:(BOOL)animated {
    CGFloat valueAngle = ((value - self.minValue) / (self.maxValue - self.minValue)) * 270.0;
    CGFloat endAngle = (135.0 + valueAngle) * M_PI / 180.0;

    UIBezierPath *newPath = [UIBezierPath bezierPathWithArcCenter:self.center
                                                           radius:self.radius
                                                       startAngle:135.0 * M_PI / 180.0
                                                         endAngle:endAngle
                                                        clockwise:YES];

    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.duration = 0.2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = (__bridge id)self.arcLayer.path;
        animation.toValue = (__bridge id)newPath.CGPath;
        [self.arcLayer addAnimation:animation forKey:@"pathAnimation"];
    }

    self.arcLayer.path = newPath.CGPath;
    [self updateThumbPositionForAngle:endAngle animated:animated];
}
```

---

## 13. Padding & Container Layout

### Recommended Container Sizing
- **Minimum size**: 200pt × 200pt
- **Recommended size**: 280pt × 280pt (matches typical mobile card)
- **Padding from card edge**: 16pt

### Element Spacing
```
Card width: 280pt
Circle diameter: 280pt (fills card width)
Arc radius: 145pt (scaled from 145/160 * 140 = 127pt actual)
```

### Layout Math
```
Container: 280 × 280pt
Scale factor: 280 / 320 = 0.875
Radius: 145 * 0.875 = 126.875pt
Center: (140, 140)
Background track stroke: 24 * 0.875 = 21pt
```

---

## 14. Complete iOS Implementation Checklist

### Layer Stack (bottom to top)
1. Background track (270° arc, dim gray, 21pt stroke)
2. Current temperature indicator (if exists, small circle, dimmed mode color)
3. Active arc (colored based on mode, 21pt stroke)
4. Target thumb(s) (circle with stroke, draggable)
5. Center text labels (primary temp, mode, secondary temp)
6. Bottom buttons (+/- controls)

### State Properties
```objc
@property (nonatomic) CGFloat minValue;
@property (nonatomic) CGFloat maxValue;
@property (nonatomic) CGFloat value;           // Target temp
@property (nonatomic) CGFloat currentValue;    // Current temp (optional)
@property (nonatomic) CGFloat step;
@property (nonatomic, strong) NSString *hvacMode;
@property (nonatomic, strong) NSString *hvacAction;
@property (nonatomic) BOOL isDualMode;         // heat_cool/auto
@property (nonatomic) CGFloat lowValue;        // For dual mode
@property (nonatomic) CGFloat highValue;       // For dual mode
```

### Core Methods
```objc
- (void)setupLayers;
- (void)updateForMode:(NSString *)mode action:(NSString *)action;
- (UIColor *)colorForCurrentMode;
- (void)setValue:(CGFloat)value animated:(BOOL)animated;
- (void)setCurrentValue:(CGFloat)currentValue;
- (CGPoint)pointForValue:(CGFloat)value;
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture;
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture;
```

---

## 15. Screenshot Analysis Notes

From `/test-harness/screenshots/ha-web/section-climate-0.png`:

**Observed Details:**
- Entity name "Hvac" at top
- Mode label "Cooling" in blue (matches cool mode color)
- Primary temperature: `21.0°C` (large, centered, white text)
- Secondary display: `🌡️ 22 °C` (smaller, blue text with thermometer icon)
- Arc color: Blue (#2196F3 or similar)
- Arc approximately 70% filled (target at 21°, range likely 10-30°)
- Two circular buttons at bottom: − and +
- Toggle switch visible at top of arc (for mode switching)
- Background: Dark card (#1C1C1E or similar)
- Track background: Very dim gray, barely visible

**Key Visual Proportions:**
- Arc stroke appears to be ~7-8% of container width
- Gap at bottom is clearly 90° (symmetrical opening)
- Thumb size is ~1.5× the arc stroke width
- Text size: Primary temp is ~17% of container height
- Buttons are positioned at ~75% down from center

---

## 16. Key Differences from Current iOS Implementation

Your current `HAClimateEntityCell` implementation:
- Uses simple labels and stepper control (no circular gauge)
- Background tint only (no arc visualization)
- Target temp shown as text, not as arc position

**To Add:**
1. Replace stepper with circular arc gauge using Core Animation
2. Add CAShapeLayer for background track, active arc, and indicators
3. Implement pan gesture for dragging thumb
4. Add current temp indicator as separate visual element
5. Position +/- buttons over the arc (not in cell corner)
6. Center primary temperature display inside circle
7. Apply mode-specific arc colors (orange/blue)

---

## 17. Performance Considerations

### Layer Efficiency
- Use `CAShapeLayer` for all arc/circle elements (GPU accelerated)
- Cache UIBezierPath objects when possible
- Update only changed properties during animation
- Use `shouldRasterize = YES` for complex layer hierarchies

### Touch Optimization
- Implement efficient hit testing (check distance from arc/thumb)
- Debounce rapid gesture updates (throttle to 60fps)
- Use `UIGestureRecognizer` delegate for conflict resolution

---

## 18. Accessibility

### VoiceOver Support
```objc
self.isAccessibilityElement = YES;
self.accessibilityLabel = @"Temperature control";
self.accessibilityValue = [NSString stringWithFormat:@"Target %0.1f degrees, Current %0.1f degrees, %@",
                           self.value, self.currentValue, self.hvacMode];
self.accessibilityTraits = UIAccessibilityTraitAdjustable;
```

### Increment/Decrement Support
```objc
- (void)accessibilityIncrement {
    [self setValue:MIN(self.value + self.step, self.maxValue) animated:YES];
}

- (void)accessibilityDecrement {
    [self setValue:MAX(self.value - self.step, self.minValue) animated:YES];
}
```

---

## Summary of Exact Values

| Property | Value | iOS (at 280pt) |
|----------|-------|----------------|
| ViewBox | 320×320 | - |
| Radius | 145 | 126.875pt |
| Max Angle | 270° | 270° |
| Rotate Angle | 135° | 135° |
| Background stroke | 24 | 21pt |
| Arc stroke | 24 | 21pt |
| Thumb inner stroke | 18 | 15.75pt |
| Current indicator stroke | 8 | 7pt |
| Gap | 90° | 90° |
| Background opacity | 0.3 | 0.3 |
| Interaction margin | 12 | 10.5pt |

**Colors (Light Mode):**
- Heat: #FF9800 (Orange 500)
- Cool: #2196F3 (Blue 500)
- Off: #9E9E9E (Grey 500)
- Background track: 30% opacity gray

**Colors (Dark Mode):**
- Heat: #FB8C00 (Orange 600)
- Cool: #42A5F5 (Blue 400)
- Off: #BDBDBD (Grey 400)
- Background track: 30% opacity gray

---

## Implementation Priority Order

1. **Core arc rendering** - Background track + active arc
2. **Single target thumb** - Circle at value position
3. **Color mapping** - Heat/cool mode colors
4. **Center text** - Primary/secondary temperature display
5. **Pan gesture** - Drag to adjust
6. **Current temp indicator** - Small circle at actual temp
7. **Bottom buttons** - +/- controls
8. **Animation** - Smooth value transitions
9. **Dual mode** - Two thumbs for heat_cool/auto
10. **Polish** - Accessibility, haptics, edge cases

---

## References

- Home Assistant Frontend Repo: https://github.com/home-assistant/frontend
- Material Design Colors: https://material.io/design/color/the-color-system.html
- iOS Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/ios/

