#import <UIKit/UIKit.h>

@class HAGraphView;

@protocol HAGraphViewDelegate <NSObject>
@optional
- (void)graphView:(HAGraphView *)graphView
  didInspectValue:(double)value
        timestamp:(NSTimeInterval)timestamp
            state:(NSString *)state
         duration:(NSTimeInterval)duration;
- (void)graphViewDidEndInspection:(HAGraphView *)graphView;
- (void)graphView:(HAGraphView *)graphView
  didZoomToStartTime:(NSTimeInterval)startTime
             endTime:(NSTimeInterval)endTime;
@end

@interface HAGraphView : UIView

/// Hidden series indices (for multi-series legend toggle). When a series is hidden, it is not drawn and excluded from Y-axis scaling.
@property (nonatomic, strong) NSMutableIndexSet *hiddenSeriesIndices;

/// Single-series data: Array of NSDictionary with keys @"value" (NSNumber) and @"timestamp" (NSNumber, Unix epoch)
/// Setting this clears any multi-series data and renders a single line.
@property (nonatomic, copy) NSArray<NSDictionary *> *dataPoints;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *fillColor;

/// Multi-series data: Array of NSDictionary, each with:
///   @"points" — NSArray<NSDictionary *> (same format as dataPoints)
///   @"color"  — UIColor
///   @"label"  — NSString (entity friendly name, shown in legend)
///   @"unit"   — NSString (unit of measurement, used for multi-axis grouping; empty string if no unit)
/// When set, dataPoints/lineColor are ignored. Gradient fill applies to first series only.
/// Series are grouped by unit; each group gets independent Y-axis scaling.
@property (nonatomic, copy) NSArray<NSDictionary *> *dataSeries;

/// State timeline data: Array of NSDictionary, each representing one entity's timeline:
///   @"segments" — NSArray<NSDictionary *> (each: @"state" NSString, @"start" NSNumber epoch, @"end" NSNumber epoch)
///   @"label"    — NSString (entity friendly name)
///   @"entityId" — NSString (entity ID, used to derive domain for coloring)
/// When set, line graph properties are ignored. Renders horizontal colored bars.
@property (nonatomic, copy) NSArray<NSDictionary *> *timelineData;

/// Show axis labels (time on bottom, values on left). Default NO.
@property (nonatomic, assign) BOOL showAxisLabels;

/// Delegate for inspection events.
@property (nonatomic, weak) id<HAGraphViewDelegate> delegate;

/// Enable touch-to-inspect mode (crosshair + tooltip). Default NO.
@property (nonatomic, assign) BOOL inspectionEnabled;

/// Currently visible time window (narrower than data when zoomed).
@property (nonatomic, assign) NSTimeInterval visibleStartTime;
@property (nonatomic, assign) NSTimeInterval visibleEndTime;

/// Current zoom level (1.0 = no zoom). Read-only.
@property (nonatomic, assign, readonly) CGFloat zoomScale;

/// Reset zoom to show all data.
- (void)resetZoom;

/// Maximum data points appropriate for this device (150 on armv7, 300 on modern).
+ (NSUInteger)maxPointsForDevice;

- (void)setDataPoints:(NSArray<NSDictionary *> *)points animated:(BOOL)animated;

@end
