#import <Foundation/Foundation.h>

@class HAEntity;
@class HADashboardConfigItem;
@class HADashboardConfigSection;

/// Factory methods for creating mock data in snapshot tests.
/// Avoids needing a live HA connection — creates entities and config items
/// with known, deterministic values.
@interface HASnapshotTestHelpers : NSObject

#pragma mark - Core Factories

/// Create a mock entity with the given ID, state, and attributes.
+ (HAEntity *)entityWithId:(NSString *)entityId
                     state:(NSString *)state
                attributes:(NSDictionary *)attributes;

/// Create a config item for a single-entity card with optional heading.
+ (HADashboardConfigItem *)itemWithEntityId:(NSString *)entityId
                                   cardType:(NSString *)cardType
                                 columnSpan:(NSInteger)columnSpan
                                headingIcon:(NSString *)headingIcon
                                displayName:(NSString *)displayName;

/// Create an entities section for composite cards.
+ (HADashboardConfigSection *)sectionWithTitle:(NSString *)title
                                          icon:(NSString *)icon
                                     entityIds:(NSArray<NSString *> *)entityIds;

/// Create a dictionary of mock entities for the standard test dashboards.
+ (NSDictionary<NSString *, HAEntity *> *)livingRoomEntities;

#pragma mark - Light (4 variants)

+ (HAEntity *)lightEntityOnBrightness;
+ (HAEntity *)lightEntityOnRGB;
+ (HAEntity *)lightEntityOnDimmed;
+ (HAEntity *)lightEntityOff;

#pragma mark - Climate (4 variants)

+ (HAEntity *)climateEntityHeat;
+ (HAEntity *)climateEntityCool;
+ (HAEntity *)climateEntityAuto;
+ (HAEntity *)climateEntityOff;

#pragma mark - Switch (2 variants)

+ (HAEntity *)switchEntityOn;
+ (HAEntity *)switchEntityOff;

#pragma mark - Cover (3 variants)

+ (HAEntity *)coverEntityOpenShutter;
+ (HAEntity *)coverEntityClosedGarage;
+ (HAEntity *)coverEntityPartial;

#pragma mark - Media Player (3 variants)

+ (HAEntity *)mediaPlayerPlaying;
+ (HAEntity *)mediaPlayerPaused;
+ (HAEntity *)mediaPlayerOff;

#pragma mark - Sensor (6 variants)

+ (HAEntity *)sensorTemperature;
+ (HAEntity *)sensorHumidity;
+ (HAEntity *)sensorEnergy;
+ (HAEntity *)sensorBattery;
+ (HAEntity *)sensorIlluminance;
+ (HAEntity *)sensorGenericText;

#pragma mark - Alarm Control Panel (4 variants)

+ (HAEntity *)alarmDisarmed;
+ (HAEntity *)alarmArmedHome;
+ (HAEntity *)alarmArmedAway;
+ (HAEntity *)alarmTriggered;

#pragma mark - Person (2 variants)

+ (HAEntity *)personHome;
+ (HAEntity *)personNotHome;

#pragma mark - Lock (3 variants)

+ (HAEntity *)lockLocked;
+ (HAEntity *)lockUnlocked;
+ (HAEntity *)lockJammed;

#pragma mark - Weather (3 variants)

+ (HAEntity *)weatherSunny;
+ (HAEntity *)weatherCloudy;
+ (HAEntity *)weatherRainy;

#pragma mark - Input Select (2 variants)

+ (HAEntity *)inputSelectThreeOptions;
+ (HAEntity *)inputSelectFiveOptions;

#pragma mark - Input Number (2 variants)

+ (HAEntity *)inputNumberSlider;
+ (HAEntity *)inputNumberBox;

#pragma mark - Button (2 variants)

+ (HAEntity *)buttonDefault;
+ (HAEntity *)buttonPressed;

#pragma mark - Update (2 variants)

+ (HAEntity *)updateAvailable;
+ (HAEntity *)updateUpToDate;

#pragma mark - Counter (2 variants)

+ (HAEntity *)counterLow;
+ (HAEntity *)counterHigh;

#pragma mark - Binary Sensor (3 variants)

+ (HAEntity *)binarySensorMotionOn;
+ (HAEntity *)binarySensorDoorOff;
+ (HAEntity *)binarySensorMoistureOff;

#pragma mark - Device Tracker (1 variant)

+ (HAEntity *)deviceTrackerNotHome;

#pragma mark - Fan (3 variants)

+ (HAEntity *)fanEntityOnHalf;
+ (HAEntity *)fanEntityOnFull;
+ (HAEntity *)fanEntityOff;

#pragma mark - Vacuum (4 variants)

+ (HAEntity *)vacuumDocked;
+ (HAEntity *)vacuumCleaning;
+ (HAEntity *)vacuumReturning;
+ (HAEntity *)vacuumError;

#pragma mark - Humidifier (2 variants)

+ (HAEntity *)humidifierOn;
+ (HAEntity *)humidifierOff;

#pragma mark - Timer (3 variants)

+ (HAEntity *)timerActive;
+ (HAEntity *)timerPaused;
+ (HAEntity *)timerIdle;

#pragma mark - Input Text (2 variants)

+ (HAEntity *)inputTextWithValue;
+ (HAEntity *)inputTextEmpty;

#pragma mark - Input DateTime (3 variants)

+ (HAEntity *)inputDateTimeDate;
+ (HAEntity *)inputDateTimeTime;
+ (HAEntity *)inputDateTimeBoth;

#pragma mark - Camera (2 variants)

+ (HAEntity *)cameraStreaming;
+ (HAEntity *)cameraUnavailable;

#pragma mark - Scene (2 variants)

+ (HAEntity *)sceneDefault;
+ (HAEntity *)sceneActivated;

#pragma mark - Clock Weather (2 variants)

+ (HAEntity *)clockWeatherSunny;
+ (HAEntity *)clockWeatherCloudy;

#pragma mark - Edge Cases (Tier C)

+ (HAEntity *)unavailableEntity:(NSString *)entityId;
+ (HAEntity *)longNameEntity:(NSString *)entityId;
+ (HAEntity *)minimalEntity:(NSString *)entityId;

#pragma mark - Section / Config Helpers

/// Entities section with 3 lights (office on, downstairs off, upstairs off).
+ (HADashboardConfigSection *)entitiesSectionWithLights;
/// Entities section with 5 mixed entity rows (light, switch, sensor, cover, lock).
+ (HADashboardConfigSection *)entitiesSectionFiveRows;

/// Badge section with 2 items (temperature + humidity sensors).
+ (HADashboardConfigSection *)badgeSection2Items;
/// Badge section with 4 items (temperature, humidity, motion, door sensors).
+ (HADashboardConfigSection *)badgeSection4Items;

/// Gauge card item at 50%.
+ (HADashboardConfigItem *)gaugeCardItem50Percent;
/// Gauge card item at 0%.
+ (HADashboardConfigItem *)gaugeCardItem0Percent;
/// Gauge card item at 100%.
+ (HADashboardConfigItem *)gaugeCardItem100Percent;
/// Gauge card item with severity color bands (green/yellow/red).
+ (HADashboardConfigItem *)gaugeCardItemSeverity;

/// Graph card item with a single sensor entity.
+ (HADashboardConfigItem *)graphCardSingleEntity;
/// Graph card item with 3 sensor entities.
+ (HADashboardConfigItem *)graphCardMultiEntity;

#pragma mark - Weather Forecast Helper

/// Returns an array of forecast dictionaries for the given number of days.
+ (NSArray *)forecastArrayForDays:(NSInteger)days;

@end
