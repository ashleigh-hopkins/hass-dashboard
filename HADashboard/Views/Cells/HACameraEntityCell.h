#import "HABaseEntityCell.h"

@interface HACameraEntityCell : HABaseEntityCell

/// Stop the periodic snapshot refresh (call when cell goes off-screen)
- (void)stopRefresh;

/// Deferred loading: call when cell becomes visible to start snapshot fetching
- (void)beginLoading;

/// Cancel pending fetches when cell scrolls off screen
- (void)cancelLoading;

@end
