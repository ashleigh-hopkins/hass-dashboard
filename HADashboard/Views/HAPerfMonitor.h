#import <Foundation/Foundation.h>

/// Lightweight performance monitor that logs FPS, memory, and timing data to a CSV file.
/// Designed for minimal overhead on iPad 2 (A5, 512MB).
///
/// Log file: /tmp/perf.log (jailbroken) or Documents/perf.log (sandboxed).
/// Pull via SCP or Xcode organizer.
@interface HAPerfMonitor : NSObject

+ (instancetype)sharedMonitor;

/// Start collecting metrics (CADisplayLink + flush timer).
- (void)start;

/// Stop collecting and write final flush.
- (void)stop;

/// Bracket rebuildDashboard calls.
- (void)markRebuildStart;
- (void)markRebuildEnd;

/// Bracket cell configuration calls. Pass the cell class name.
- (void)markCellStart:(NSString *)cellType;
- (void)markCellEnd;

@end
