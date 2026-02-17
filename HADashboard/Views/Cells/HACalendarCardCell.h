#import <UIKit/UIKit.h>

@class HADashboardConfigItem, HADashboardConfigSection;

typedef NS_ENUM(NSInteger, HACalendarViewMode) {
    HACalendarViewModeList,      // listWeek / list
    HACalendarViewModeMonth,     // dayGridMonth (default)
};

@interface HACalendarCardCell : UICollectionViewCell

/// Configure with entity IDs and config. Defers event fetch until beginLoading.
- (void)configureWithEntityIds:(NSArray<NSString *> *)entityIds configItem:(HADashboardConfigItem *)configItem;

/// Deferred loading: call when cell becomes visible to start event fetch
- (void)beginLoading;

/// Cancel pending network requests when cell scrolls off screen
- (void)cancelLoading;

+ (CGFloat)preferredHeightForMode:(HACalendarViewMode)mode;

@end
