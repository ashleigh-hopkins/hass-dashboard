#import "HABaseEntityCell.h"

@interface HAThermostatGaugeCell : HABaseEntityCell

/// Preferred height for the thermostat gauge cell (fixed fallback)
+ (CGFloat)preferredHeight;

/// Preferred height computed from available width — arc fills full width as a square, mode bar below
+ (CGFloat)preferredHeightForWidth:(CGFloat)width;

@end
