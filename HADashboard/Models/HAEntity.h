#import <Foundation/Foundation.h>
#import "HAEntityAttributes.h"

/// Known entity domains
extern NSString *const HAEntityDomainLight;
extern NSString *const HAEntityDomainSwitch;
extern NSString *const HAEntityDomainSensor;
extern NSString *const HAEntityDomainBinarySensor;
extern NSString *const HAEntityDomainClimate;
extern NSString *const HAEntityDomainCover;
extern NSString *const HAEntityDomainCamera;
extern NSString *const HAEntityDomainLock;
extern NSString *const HAEntityDomainFan;
extern NSString *const HAEntityDomainMediaPlayer;
extern NSString *const HAEntityDomainAutomation;
extern NSString *const HAEntityDomainScene;
extern NSString *const HAEntityDomainScript;
extern NSString *const HAEntityDomainInputBoolean;
extern NSString *const HAEntityDomainInputNumber;
extern NSString *const HAEntityDomainInputSelect;
extern NSString *const HAEntityDomainWeather;
extern NSString *const HAEntityDomainInputDatetime;
extern NSString *const HAEntityDomainInputText;
extern NSString *const HAEntityDomainNumber;
extern NSString *const HAEntityDomainSelect;
extern NSString *const HAEntityDomainButton;
extern NSString *const HAEntityDomainInputButton;
extern NSString *const HAEntityDomainHumidifier;
extern NSString *const HAEntityDomainVacuum;
extern NSString *const HAEntityDomainAlarmControlPanel;
extern NSString *const HAEntityDomainTimer;
extern NSString *const HAEntityDomainCounter;
extern NSString *const HAEntityDomainPerson;
extern NSString *const HAEntityDomainSiren;
extern NSString *const HAEntityDomainUpdate;
extern NSString *const HAEntityDomainCalendar;

@interface HAEntity : NSObject

@property (nonatomic, copy) NSString *entityId;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSDictionary *attributes;
@property (nonatomic, copy) NSString *lastChanged;
@property (nonatomic, copy) NSString *lastUpdated;

/// Registry-sourced fields (populated from config/entity_registry/list)
@property (nonatomic, copy) NSString *entityCategory; // "config", "diagnostic", or nil
@property (nonatomic, copy) NSString *hiddenBy;        // "user", "integration", or nil
@property (nonatomic, copy) NSString *disabledBy;      // non-nil if disabled
@property (nonatomic, copy) NSString *platform;        // integration name (e.g. "mobile_app")

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)updateWithDictionary:(NSDictionary *)dict;

/// Derived properties
- (NSString *)domain;
- (NSString *)friendlyName;
- (NSString *)icon;
- (NSString *)unitOfMeasurement;
- (BOOL)isOn;
- (BOOL)isAvailable;

/// Cross-domain
- (NSInteger)supportedFeatures;
- (NSString *)deviceClass;

/// Light-specific
- (NSInteger)brightness;       // 0-255 from HA, converted to 0-100 in brightnessPercent
- (NSInteger)brightnessPercent; // 0-100

/// Climate-specific
- (NSNumber *)currentTemperature;
- (NSNumber *)targetTemperature;
- (NSNumber *)minTemperature;   // min_temp attribute (fallback 7)
- (NSNumber *)maxTemperature;   // max_temp attribute (fallback 35)
- (NSString *)hvacMode;

/// Cover-specific
- (NSInteger)coverPosition; // 0-100

/// Media player-specific
- (NSString *)mediaTitle;
- (NSString *)mediaArtist;
- (NSNumber *)volumeLevel;  // 0.0-1.0
- (BOOL)isVolumeMuted;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)isIdle;

/// Input number-specific
- (double)inputNumberValue;
- (double)inputNumberMin;
- (double)inputNumberMax;
- (double)inputNumberStep;
- (NSString *)inputNumberMode; // "slider" or "box"

/// Fan-specific
- (NSInteger)fanSpeedPercent; // 0-100 percentage
- (NSArray<NSString *> *)fanPresetModes;
- (NSString *)fanPresetMode;

/// Input select-specific
- (NSArray<NSString *> *)inputSelectOptions;
- (NSString *)inputSelectCurrentOption; // same as state

/// Lock-specific
- (BOOL)isLocked;
- (BOOL)isUnlocked;
- (BOOL)isJammed;

/// Input datetime-specific
- (BOOL)inputDatetimeHasDate;
- (BOOL)inputDatetimeHasTime;
- (NSDate *)inputDatetimeValue;
- (NSString *)inputDatetimeDisplayString;

/// Input text-specific
- (NSString *)inputTextValue;       // same as state
- (NSInteger)inputTextMinLength;
- (NSInteger)inputTextMaxLength;
- (NSString *)inputTextMode;        // "text" or "password"
- (NSString *)inputTextPattern;     // regex pattern (may be nil)

/// Camera-specific
- (NSString *)cameraProxyPath; // /api/camera_proxy/<entity_id>

/// Weather-specific
- (NSString *)weatherCondition;       // state: sunny, cloudy, rainy, etc.
- (NSNumber *)weatherTemperature;
- (NSNumber *)weatherHumidity;
- (NSNumber *)weatherPressure;
- (NSNumber *)weatherWindSpeed;
- (NSString *)weatherWindBearing;
- (NSString *)weatherTemperatureUnit; // from attributes or "°"

/// Maps HA weather condition strings to simple display symbols
+ (NSString *)symbolForWeatherCondition:(NSString *)condition;

/// Humidifier-specific
- (NSNumber *)humidifierTargetHumidity;
- (NSNumber *)humidifierCurrentHumidity;
- (NSNumber *)humidifierMinHumidity;
- (NSNumber *)humidifierMaxHumidity;

/// Vacuum-specific
- (NSNumber *)vacuumBatteryLevel;
- (NSString *)vacuumStatus; // cleaning, docked, returning, etc.

/// Alarm control panel-specific
- (NSString *)alarmState; // armed_away, armed_home, disarmed, pending, triggered, etc.
- (BOOL)alarmCodeRequired;
- (NSString *)alarmCodeFormat; // "number", "text", or nil (no code needed)

/// Timer-specific
- (NSString *)timerDuration;   // HH:MM:SS
- (NSString *)timerRemaining;  // HH:MM:SS (in attributes when active)
- (NSString *)timerFinishesAt; // ISO datetime

/// Counter-specific
- (NSInteger)counterValue;
- (NSNumber *)counterMinimum;
- (NSNumber *)counterMaximum;
- (NSInteger)counterStep;

/// Update-specific
- (NSString *)updateInstalledVersion;
- (NSString *)updateLatestVersion;
- (BOOL)updateAvailable;
- (NSString *)updateReleaseURL;

/// Whether this entity should be shown in the default/overview dashboard.
/// Returns NO for hidden domains, hidden platforms, entities with entity_category,
/// entities hidden by user/integration, and disabled entities.
- (BOOL)shouldShowInDefaultView;

/// Optimistic UI: apply partial state update without replacing full attributes
- (void)applyOptimisticState:(NSString *)state attributeOverrides:(NSDictionary *)overrides;

/// Service call helpers
- (NSString *)toggleService;
- (NSString *)turnOnService;
- (NSString *)turnOffService;

@end

// Domain-specific category headers — importing HAEntity.h gives consumers all typed accessors
#import "HAEntity+Light.h"
#import "HAEntity+Climate.h"
#import "HAEntity+Cover.h"
#import "HAEntity+MediaPlayer.h"
#import "HAEntity+Fan.h"
#import "HAEntity+Vacuum.h"
#import "HAEntity+Alarm.h"
#import "HAEntity+Weather.h"
#import "HAEntity+Humidifier.h"
#import "HAEntity+Update.h"
#import "HAEntity+WaterHeater.h"
