#import "HABaseEntityCell.h"

@interface HAClockWeatherCell : HABaseEntityCell

/// Preferred height for the clock-weather card (default 5 forecast rows)
+ (CGFloat)preferredHeight;

/// Preferred height for a given number of forecast rows
+ (CGFloat)preferredHeightForForecastRows:(NSInteger)rows;

/// When set, the clock and date labels use this fixed date instead of [NSDate date].
/// Used by snapshot tests to produce deterministic output.
@property (nonatomic, strong) NSDate *overrideDate;

@end
