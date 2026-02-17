#import "HAEntityCellFactory.h"
#import "HAEntity.h"
#import "HABaseEntityCell.h"
#import "HASwitchEntityCell.h"
#import "HASensorEntityCell.h"
#import "HALightEntityCell.h"
#import "HAClimateEntityCell.h"
#import "HACoverEntityCell.h"
#import "HAMediaPlayerEntityCell.h"
#import "HASceneEntityCell.h"
#import "HAInputNumberEntityCell.h"
#import "HAFanEntityCell.h"
#import "HAInputSelectEntityCell.h"
#import "HALockEntityCell.h"
#import "HACameraEntityCell.h"
#import "HAWeatherEntityCell.h"
#import "HAInputDateTimeEntityCell.h"
#import "HAInputTextEntityCell.h"
#import "HAButtonEntityCell.h"
#import "HAHumidifierEntityCell.h"
#import "HAVacuumEntityCell.h"
#import "HAAlarmEntityCell.h"
#import "HATimerEntityCell.h"
#import "HACounterEntityCell.h"
#import "HAPersonEntityCell.h"
#import "HAUpdateEntityCell.h"
#import "HAEntitiesCardCell.h"
#import "HAThermostatGaugeCell.h"
#import "HABadgeRowCell.h"
#import "HAGraphCardCell.h"
#import "HAHeadingCell.h"
#import "HAClockWeatherCell.h"
#import "HATileEntityCell.h"
#import "HAGaugeCardCell.h"
#import "HACalendarCardCell.h"

static NSString *const kBaseCellId             = @"HABaseEntityCell";
static NSString *const kTileCellId            = @"HATileEntityCell";
static NSString *const kHeadingCellId          = @"HAHeadingCell";
static NSString *const kEntitiesCardCellId     = @"HAEntitiesCardCell";
static NSString *const kThermostatGaugeCellId  = @"HAThermostatGaugeCell";
static NSString *const kBadgeRowCellId         = @"HABadgeRowCell";
static NSString *const kGraphCardCellId        = @"HAGraphCardCell";
static NSString *const kClockWeatherCellId     = @"HAClockWeatherCell";
static NSString *const kGaugeCardCellId        = @"HAGaugeCardCell";
static NSString *const kCalendarCardCellId     = @"HACalendarCardCell";
static NSString *const kSwitchCellId       = @"HASwitchEntityCell";
static NSString *const kSensorCellId       = @"HASensorEntityCell";
static NSString *const kLightCellId        = @"HALightEntityCell";
static NSString *const kClimateCellId      = @"HAClimateEntityCell";
static NSString *const kCoverCellId        = @"HACoverEntityCell";
static NSString *const kMediaPlayerCellId  = @"HAMediaPlayerEntityCell";
static NSString *const kSceneCellId        = @"HASceneEntityCell";
static NSString *const kInputNumberCellId  = @"HAInputNumberEntityCell";
static NSString *const kFanCellId          = @"HAFanEntityCell";
static NSString *const kInputSelectCellId  = @"HAInputSelectEntityCell";
static NSString *const kLockCellId         = @"HALockEntityCell";
static NSString *const kCameraCellId       = @"HACameraEntityCell";
static NSString *const kWeatherCellId      = @"HAWeatherEntityCell";
static NSString *const kInputDateTimeCellId = @"HAInputDateTimeEntityCell";
static NSString *const kInputTextCellId     = @"HAInputTextEntityCell";
static NSString *const kButtonCellId        = @"HAButtonEntityCell";
static NSString *const kHumidifierCellId    = @"HAHumidifierEntityCell";
static NSString *const kVacuumCellId        = @"HAVacuumEntityCell";
static NSString *const kAlarmCellId         = @"HAAlarmEntityCell";
static NSString *const kTimerCellId         = @"HATimerEntityCell";
static NSString *const kCounterCellId       = @"HACounterEntityCell";
static NSString *const kPersonCellId        = @"HAPersonEntityCell";
static NSString *const kUpdateCellId        = @"HAUpdateEntityCell";

@implementation HAEntityCellFactory

+ (void)registerCellClassesWithCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[HABaseEntityCell class]    forCellWithReuseIdentifier:kBaseCellId];
    [collectionView registerClass:[HASwitchEntityCell class]  forCellWithReuseIdentifier:kSwitchCellId];
    [collectionView registerClass:[HASensorEntityCell class]  forCellWithReuseIdentifier:kSensorCellId];
    [collectionView registerClass:[HALightEntityCell class]   forCellWithReuseIdentifier:kLightCellId];
    [collectionView registerClass:[HAClimateEntityCell class] forCellWithReuseIdentifier:kClimateCellId];
    [collectionView registerClass:[HACoverEntityCell class]       forCellWithReuseIdentifier:kCoverCellId];
    [collectionView registerClass:[HAMediaPlayerEntityCell class] forCellWithReuseIdentifier:kMediaPlayerCellId];
    [collectionView registerClass:[HASceneEntityCell class]       forCellWithReuseIdentifier:kSceneCellId];
    [collectionView registerClass:[HAInputNumberEntityCell class] forCellWithReuseIdentifier:kInputNumberCellId];
    [collectionView registerClass:[HAFanEntityCell class]         forCellWithReuseIdentifier:kFanCellId];
    [collectionView registerClass:[HAInputSelectEntityCell class] forCellWithReuseIdentifier:kInputSelectCellId];
    [collectionView registerClass:[HALockEntityCell class]        forCellWithReuseIdentifier:kLockCellId];
    [collectionView registerClass:[HACameraEntityCell class]      forCellWithReuseIdentifier:kCameraCellId];
    [collectionView registerClass:[HAWeatherEntityCell class]     forCellWithReuseIdentifier:kWeatherCellId];
    [collectionView registerClass:[HAInputDateTimeEntityCell class] forCellWithReuseIdentifier:kInputDateTimeCellId];
    [collectionView registerClass:[HAInputTextEntityCell class]     forCellWithReuseIdentifier:kInputTextCellId];
    [collectionView registerClass:[HAButtonEntityCell class]        forCellWithReuseIdentifier:kButtonCellId];
    [collectionView registerClass:[HAHumidifierEntityCell class]    forCellWithReuseIdentifier:kHumidifierCellId];
    [collectionView registerClass:[HAVacuumEntityCell class]        forCellWithReuseIdentifier:kVacuumCellId];
    [collectionView registerClass:[HAAlarmEntityCell class]         forCellWithReuseIdentifier:kAlarmCellId];
    [collectionView registerClass:[HATimerEntityCell class]         forCellWithReuseIdentifier:kTimerCellId];
    [collectionView registerClass:[HACounterEntityCell class]       forCellWithReuseIdentifier:kCounterCellId];
    [collectionView registerClass:[HAPersonEntityCell class]        forCellWithReuseIdentifier:kPersonCellId];
    [collectionView registerClass:[HAUpdateEntityCell class]        forCellWithReuseIdentifier:kUpdateCellId];
    [collectionView registerClass:[HAEntitiesCardCell class]       forCellWithReuseIdentifier:kEntitiesCardCellId];
    [collectionView registerClass:[HAThermostatGaugeCell class]    forCellWithReuseIdentifier:kThermostatGaugeCellId];
    [collectionView registerClass:[HABadgeRowCell class]           forCellWithReuseIdentifier:kBadgeRowCellId];
    [collectionView registerClass:[HAGraphCardCell class]         forCellWithReuseIdentifier:kGraphCardCellId];
    [collectionView registerClass:[HAHeadingCell class]           forCellWithReuseIdentifier:kHeadingCellId];
    [collectionView registerClass:[HAClockWeatherCell class]      forCellWithReuseIdentifier:kClockWeatherCellId];
    [collectionView registerClass:[HATileEntityCell class]       forCellWithReuseIdentifier:kTileCellId];
    [collectionView registerClass:[HAGaugeCardCell class]       forCellWithReuseIdentifier:kGaugeCardCellId];
    [collectionView registerClass:[HACalendarCardCell class]   forCellWithReuseIdentifier:kCalendarCardCellId];
}

+ (NSString *)reuseIdentifierForEntity:(HAEntity *)entity {
    if (!entity) return kBaseCellId;

    NSString *domain = [entity domain];

    if ([domain isEqualToString:HAEntityDomainLight]) {
        return kLightCellId;
    }
    if ([domain isEqualToString:HAEntityDomainSwitch] ||
        [domain isEqualToString:HAEntityDomainInputBoolean] ||
        [domain isEqualToString:HAEntityDomainAutomation] ||
        [domain isEqualToString:HAEntityDomainSiren]) {
        return kSwitchCellId;
    }
    if ([domain isEqualToString:HAEntityDomainLock]) {
        return kLockCellId;
    }
    if ([domain isEqualToString:HAEntityDomainFan]) {
        return kFanCellId;
    }
    if ([domain isEqualToString:HAEntityDomainInputNumber] ||
        [domain isEqualToString:HAEntityDomainNumber]) {
        return kInputNumberCellId;
    }
    if ([domain isEqualToString:HAEntityDomainInputSelect] ||
        [domain isEqualToString:HAEntityDomainSelect]) {
        return kInputSelectCellId;
    }
    if ([domain isEqualToString:HAEntityDomainInputDatetime]) {
        return kInputDateTimeCellId;
    }
    if ([domain isEqualToString:HAEntityDomainInputText]) {
        return kInputTextCellId;
    }
    if ([domain isEqualToString:HAEntityDomainSensor] ||
        [domain isEqualToString:HAEntityDomainBinarySensor]) {
        return kSensorCellId;
    }
    if ([domain isEqualToString:HAEntityDomainClimate]) {
        return kClimateCellId;
    }
    if ([domain isEqualToString:HAEntityDomainCover]) {
        return kCoverCellId;
    }
    if ([domain isEqualToString:HAEntityDomainCamera]) {
        return kCameraCellId;
    }
    if ([domain isEqualToString:HAEntityDomainWeather]) {
        return kWeatherCellId;
    }
    if ([domain isEqualToString:HAEntityDomainMediaPlayer]) {
        return kMediaPlayerCellId;
    }
    if ([domain isEqualToString:HAEntityDomainScene] ||
        [domain isEqualToString:HAEntityDomainScript]) {
        return kSceneCellId;
    }
    if ([domain isEqualToString:HAEntityDomainButton] ||
        [domain isEqualToString:HAEntityDomainInputButton]) {
        return kButtonCellId;
    }
    if ([domain isEqualToString:HAEntityDomainHumidifier]) {
        return kHumidifierCellId;
    }
    if ([domain isEqualToString:HAEntityDomainVacuum]) {
        return kVacuumCellId;
    }
    if ([domain isEqualToString:HAEntityDomainAlarmControlPanel]) {
        return kAlarmCellId;
    }
    if ([domain isEqualToString:HAEntityDomainTimer]) {
        return kTimerCellId;
    }
    if ([domain isEqualToString:HAEntityDomainCounter]) {
        return kCounterCellId;
    }
    if ([domain isEqualToString:HAEntityDomainPerson]) {
        return kPersonCellId;
    }
    if ([domain isEqualToString:HAEntityDomainUpdate]) {
        return kUpdateCellId;
    }
    if ([domain isEqualToString:HAEntityDomainCalendar]) {
        return kCalendarCardCellId;
    }

    // Unknown domains use the base cell
    return kBaseCellId;
}

+ (NSString *)reuseIdentifierForEntity:(HAEntity *)entity cardType:(NSString *)cardType {
    // Card-type-aware routing: specific card types override domain-based lookup
    if ([cardType isEqualToString:@"entities"]) {
        return kEntitiesCardCellId;
    }
    if ([cardType isEqualToString:@"badges"]) {
        return kBadgeRowCellId;
    }
    if ([cardType isEqualToString:@"thermostat"] && [[entity domain] isEqualToString:@"climate"]) {
        return kThermostatGaugeCellId;
    }
    if ([cardType isEqualToString:@"graph"] || [cardType isEqualToString:@"mini-graph-card"] ||
        [cardType isEqualToString:@"history-graph"]) {
        return kGraphCardCellId;
    }
    if ([cardType isEqualToString:@"heading"]) {
        return kHeadingCellId;
    }
    if ([cardType containsString:@"clock-weather"]) {
        return kClockWeatherCellId;
    }
    if ([cardType isEqualToString:@"gauge"]) {
        return kGaugeCardCellId;
    }
    if ([cardType isEqualToString:@"tile"] || [cardType isEqualToString:@"button"]) {
        return kTileCellId;
    }
    if ([cardType isEqualToString:@"calendar"]) {
        return kCalendarCardCellId;
    }

    // Fall through to domain-based lookup
    return [self reuseIdentifierForEntity:entity];
}

@end
