#import "HAEntity.h"

@interface HAEntity (Weather)
// Existing in HAEntity.h: weatherCondition, weatherTemperature, weatherHumidity, weatherPressure, weatherWindSpeed, weatherWindBearing, weatherTemperatureUnit
- (NSString *)weatherPressureUnit;
- (NSString *)weatherWindSpeedUnit;
- (NSString *)weatherAttribution;
- (NSArray *)weatherForecast;
@end
