#import <Foundation/Foundation.h>

@class HAEntity;

/// Shared weather utilities used by HAWeatherEntityCell and HAClockWeatherCell.
@interface HAWeatherHelper : NSObject

/// Maps a Home Assistant weather condition string to an MDI icon name.
+ (NSString *)mdiIconNameForCondition:(NSString *)condition;

/// Fetches forecast data for a weather entity via the modern WebSocket API,
/// falling back to legacy entity attributes for older HA versions.
/// Completion is called on the main queue.
+ (void)fetchForecastForEntity:(HAEntity *)entity
                    completion:(void(^)(NSArray *forecast, NSError *error))completion;

@end
