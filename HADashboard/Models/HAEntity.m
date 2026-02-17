#import "HAEntity.h"

NSString *const HAEntityDomainLight        = @"light";
NSString *const HAEntityDomainSwitch       = @"switch";
NSString *const HAEntityDomainSensor       = @"sensor";
NSString *const HAEntityDomainBinarySensor = @"binary_sensor";
NSString *const HAEntityDomainClimate      = @"climate";
NSString *const HAEntityDomainCover        = @"cover";
NSString *const HAEntityDomainCamera       = @"camera";
NSString *const HAEntityDomainLock         = @"lock";
NSString *const HAEntityDomainFan          = @"fan";
NSString *const HAEntityDomainMediaPlayer  = @"media_player";
NSString *const HAEntityDomainAutomation   = @"automation";
NSString *const HAEntityDomainScene        = @"scene";
NSString *const HAEntityDomainScript       = @"script";
NSString *const HAEntityDomainInputBoolean = @"input_boolean";
NSString *const HAEntityDomainInputNumber  = @"input_number";
NSString *const HAEntityDomainInputSelect = @"input_select";
NSString *const HAEntityDomainWeather     = @"weather";
NSString *const HAEntityDomainInputDatetime = @"input_datetime";
NSString *const HAEntityDomainInputText     = @"input_text";
NSString *const HAEntityDomainNumber       = @"number";
NSString *const HAEntityDomainSelect       = @"select";
NSString *const HAEntityDomainButton       = @"button";
NSString *const HAEntityDomainInputButton  = @"input_button";
NSString *const HAEntityDomainHumidifier   = @"humidifier";
NSString *const HAEntityDomainVacuum       = @"vacuum";
NSString *const HAEntityDomainAlarmControlPanel = @"alarm_control_panel";
NSString *const HAEntityDomainTimer        = @"timer";
NSString *const HAEntityDomainCounter      = @"counter";
NSString *const HAEntityDomainPerson       = @"person";
NSString *const HAEntityDomainSiren        = @"siren";
NSString *const HAEntityDomainUpdate       = @"update";
NSString *const HAEntityDomainCalendar     = @"calendar";

@implementation HAEntity

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self updateWithDictionary:dict];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return;

    self.entityId    = dict[@"entity_id"];
    self.state       = dict[@"state"];
    self.attributes  = dict[@"attributes"] ?: @{};
    self.lastChanged = dict[@"last_changed"];
    self.lastUpdated = dict[@"last_updated"];
}

#pragma mark - Derived Properties

- (NSString *)domain {
    NSRange dotRange = [self.entityId rangeOfString:@"."];
    if (dotRange.location == NSNotFound) return nil;
    return [self.entityId substringToIndex:dotRange.location];
}

- (NSString *)friendlyName {
    NSString *name = HAAttrString(self.attributes, HAAttrFriendlyName);
    if (name.length > 0) return name;

    // Fall back to entity_id after the dot, replacing underscores
    NSRange dotRange = [self.entityId rangeOfString:@"."];
    if (dotRange.location != NSNotFound) {
        NSString *objectId = [self.entityId substringFromIndex:dotRange.location + 1];
        return [objectId stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    }
    return self.entityId;
}

- (NSString *)icon {
    return HAAttrString(self.attributes, HAAttrIcon);
}

- (NSString *)unitOfMeasurement {
    return HAAttrString(self.attributes, HAAttrUnitOfMeasurement);
}

- (NSInteger)supportedFeatures {
    return HAAttrInteger(self.attributes, HAAttrSupportedFeatures, 0);
}

- (NSString *)deviceClass {
    return HAAttrString(self.attributes, HAAttrDeviceClass);
}

- (BOOL)isOn {
    return [self.state isEqualToString:@"on"];
}

- (BOOL)isAvailable {
    return ![self.state isEqualToString:@"unavailable"] &&
           ![self.state isEqualToString:@"unknown"];
}

#pragma mark - Climate

- (NSNumber *)currentTemperature {
    return HAAttrNumber(self.attributes, HAAttrCurrentTemperature);
}

- (NSNumber *)targetTemperature {
    return HAAttrNumber(self.attributes, HAAttrTemperature);
}

- (NSNumber *)minTemperature {
    NSNumber *val = HAAttrNumber(self.attributes, HAAttrMinTemp);
    return val ?: @7.0; // HA default
}

- (NSNumber *)maxTemperature {
    NSNumber *val = HAAttrNumber(self.attributes, HAAttrMaxTemp);
    return val ?: @35.0; // HA default
}

- (NSString *)hvacMode {
    return HAAttrString(self.attributes, HAAttrHvacMode) ?: self.state;
}

#pragma mark - Cover

- (NSInteger)coverPosition {
    return HAAttrInteger(self.attributes, HAAttrCurrentPosition, 0);
}

#pragma mark - Media Player

- (NSString *)mediaTitle {
    return HAAttrString(self.attributes, HAAttrMediaTitle);
}

- (NSString *)mediaArtist {
    return HAAttrString(self.attributes, HAAttrMediaArtist);
}

- (NSNumber *)volumeLevel {
    return HAAttrNumber(self.attributes, HAAttrVolumeLevel);
}

- (BOOL)isVolumeMuted {
    return HAAttrBool(self.attributes, HAAttrIsVolumeMuted, NO);
}

- (BOOL)isPlaying {
    return [self.state isEqualToString:@"playing"];
}

- (BOOL)isPaused {
    return [self.state isEqualToString:@"paused"];
}

- (BOOL)isIdle {
    return [self.state isEqualToString:@"idle"] || [self.state isEqualToString:@"standby"];
}

#pragma mark - Input Number

- (double)inputNumberValue {
    return [self.state doubleValue];
}

- (double)inputNumberMin {
    return HAAttrDouble(self.attributes, HAAttrMin, 0.0);
}

- (double)inputNumberMax {
    return HAAttrDouble(self.attributes, HAAttrMax, 100.0);
}

- (double)inputNumberStep {
    return HAAttrDouble(self.attributes, HAAttrStep, 1.0);
}

- (NSString *)inputNumberMode {
    return HAAttrString(self.attributes, HAAttrMode) ?: @"slider";
}

#pragma mark - Fan

- (NSInteger)fanSpeedPercent {
    return HAAttrInteger(self.attributes, HAAttrPercentage, 0);
}

- (NSArray<NSString *> *)fanPresetModes {
    return HAAttrArray(self.attributes, HAAttrPresetModes) ?: @[];
}

- (NSString *)fanPresetMode {
    return HAAttrString(self.attributes, HAAttrPresetMode);
}

#pragma mark - Input Select

- (NSArray<NSString *> *)inputSelectOptions {
    return HAAttrArray(self.attributes, HAAttrOptions) ?: @[];
}

- (NSString *)inputSelectCurrentOption {
    return self.state;
}

#pragma mark - Lock

- (BOOL)isLocked {
    return [self.state isEqualToString:@"locked"];
}

- (BOOL)isUnlocked {
    return [self.state isEqualToString:@"unlocked"];
}

- (BOOL)isJammed {
    return [self.state isEqualToString:@"jammed"];
}

#pragma mark - Input Text

- (NSString *)inputTextValue {
    return self.state;
}

- (NSInteger)inputTextMinLength {
    return HAAttrInteger(self.attributes, HAAttrMin, 0);
}

- (NSInteger)inputTextMaxLength {
    return HAAttrInteger(self.attributes, HAAttrMax, 100);
}

- (NSString *)inputTextMode {
    return HAAttrString(self.attributes, HAAttrMode) ?: @"text";
}

- (NSString *)inputTextPattern {
    return HAAttrString(self.attributes, HAAttrPattern);
}

#pragma mark - Input Datetime

- (BOOL)inputDatetimeHasDate {
    return HAAttrBool(self.attributes, HAAttrHasDate, NO);
}

- (BOOL)inputDatetimeHasTime {
    return HAAttrBool(self.attributes, HAAttrHasTime, NO);
}

- (NSDate *)inputDatetimeValue {
    // HA state is "2024-01-15 14:30:00", "14:30:00", or "2024-01-15"
    NSString *s = self.state;
    if (!s || [s isEqualToString:@"unknown"]) return nil;

    static NSDateFormatter *datetimeFmt = nil;
    static NSDateFormatter *dateFmt = nil;
    static NSDateFormatter *timeFmt = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        datetimeFmt = [[NSDateFormatter alloc] init];
        datetimeFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        datetimeFmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

        dateFmt = [[NSDateFormatter alloc] init];
        dateFmt.dateFormat = @"yyyy-MM-dd";
        dateFmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

        timeFmt = [[NSDateFormatter alloc] init];
        timeFmt.dateFormat = @"HH:mm:ss";
        timeFmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    });

    NSDate *date = [datetimeFmt dateFromString:s];
    if (!date) date = [dateFmt dateFromString:s];
    if (!date) date = [timeFmt dateFromString:s];
    return date;
}

- (NSString *)inputDatetimeDisplayString {
    BOOL hasDate = [self inputDatetimeHasDate];
    BOOL hasTime = [self inputDatetimeHasTime];
    NSDate *date = [self inputDatetimeValue];
    if (!date) return self.state;

    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    if (hasDate && hasTime) {
        fmt.dateStyle = NSDateFormatterMediumStyle;
        fmt.timeStyle = NSDateFormatterShortStyle;
    } else if (hasDate) {
        fmt.dateStyle = NSDateFormatterMediumStyle;
        fmt.timeStyle = NSDateFormatterNoStyle;
    } else {
        fmt.dateStyle = NSDateFormatterNoStyle;
        fmt.timeStyle = NSDateFormatterShortStyle;
    }
    return [fmt stringFromDate:date];
}

#pragma mark - Camera

- (NSString *)cameraProxyPath {
    if (!self.entityId) return nil;
    return [NSString stringWithFormat:@"/api/camera_proxy/%@", self.entityId];
}

#pragma mark - Weather

- (NSString *)weatherCondition {
    return self.state;
}

- (NSNumber *)weatherTemperature {
    return HAAttrNumber(self.attributes, HAAttrTemperature);
}

- (NSNumber *)weatherHumidity {
    return HAAttrNumber(self.attributes, HAAttrHumidity);
}

- (NSNumber *)weatherPressure {
    return HAAttrNumber(self.attributes, HAAttrPressure);
}

- (NSNumber *)weatherWindSpeed {
    return HAAttrNumber(self.attributes, HAAttrWindSpeed);
}

- (NSString *)weatherWindBearing {
    id bearing = self.attributes[HAAttrWindBearing];
    if ([bearing isKindOfClass:[NSNumber class]]) {
        // Convert degrees to compass direction
        static NSArray *directions = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            directions = @[@"N", @"NE", @"E", @"SE", @"S", @"SW", @"W", @"NW"];
        });
        NSInteger index = (NSInteger)round([bearing doubleValue] / 45.0) % 8;
        return directions[index];
    }
    return [bearing description];
}

- (NSString *)weatherTemperatureUnit {
    return HAAttrString(self.attributes, HAAttrTemperatureUnit) ?: @"\u00B0";
}

+ (NSString *)symbolForWeatherCondition:(NSString *)condition {
    if (!condition) return @"\u2601"; // cloud fallback
    static NSDictionary *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
            @"clear-night":    @"\u263E",   // crescent moon
            @"cloudy":         @"\u2601",   // cloud
            @"exceptional":    @"\u2757",   // exclamation
            @"fog":            @"\u2601",   // cloud (fog)
            @"hail":           @"\u2744",   // snowflake
            @"lightning":      @"\u26A1",   // lightning
            @"lightning-rainy":@"\u26A1",   // lightning
            @"partlycloudy":   @"\u26C5",   // sun behind cloud
            @"pouring":        @"\u2614",   // umbrella with rain
            @"rainy":          @"\u2602",   // umbrella
            @"snowy":          @"\u2744",   // snowflake
            @"snowy-rainy":    @"\u2744",   // snowflake
            @"sunny":          @"\u2600",   // sun
            @"windy":          @"\u2634",   // wind (wave)
            @"windy-variant":  @"\u2634",   // wind
        };
    });
    NSString *symbol = map[condition];
    return symbol ?: @"\u2601";
}

#pragma mark - Humidifier

- (NSNumber *)humidifierTargetHumidity {
    return HAAttrNumber(self.attributes, HAAttrHumidity);
}

- (NSNumber *)humidifierCurrentHumidity {
    return HAAttrNumber(self.attributes, HAAttrCurrentHumidity);
}

- (NSNumber *)humidifierMinHumidity {
    return HAAttrNumber(self.attributes, HAAttrMinHumidity) ?: @(0);
}

- (NSNumber *)humidifierMaxHumidity {
    return HAAttrNumber(self.attributes, HAAttrMaxHumidity) ?: @(100);
}

#pragma mark - Vacuum

- (NSNumber *)vacuumBatteryLevel {
    return HAAttrNumber(self.attributes, HAAttrBatteryLevel);
}

- (NSString *)vacuumStatus {
    return HAAttrString(self.attributes, HAAttrStatus) ?: self.state;
}

#pragma mark - Alarm Control Panel

- (NSString *)alarmState {
    return self.state;
}

- (BOOL)alarmCodeRequired {
    return HAAttrBool(self.attributes, HAAttrCodeRequired, NO);
}

- (NSString *)alarmCodeFormat {
    NSString *val = HAAttrString(self.attributes, HAAttrCodeFormat);
    return (val.length > 0) ? val : nil;
}

#pragma mark - Timer

- (NSString *)timerDuration {
    return HAAttrString(self.attributes, HAAttrDuration);
}

- (NSString *)timerRemaining {
    return HAAttrString(self.attributes, HAAttrRemaining);
}

- (NSString *)timerFinishesAt {
    return HAAttrString(self.attributes, HAAttrFinishesAt);
}

#pragma mark - Counter

- (NSInteger)counterValue {
    return [self.state integerValue];
}

- (NSNumber *)counterMinimum {
    return HAAttrNumber(self.attributes, HAAttrMinimum);
}

- (NSNumber *)counterMaximum {
    return HAAttrNumber(self.attributes, HAAttrMaximum);
}

- (NSInteger)counterStep {
    return HAAttrInteger(self.attributes, HAAttrStep, 1);
}

#pragma mark - Update

- (NSString *)updateInstalledVersion {
    return HAAttrString(self.attributes, HAAttrInstalledVersion);
}

- (NSString *)updateLatestVersion {
    return HAAttrString(self.attributes, HAAttrLatestVersion);
}

- (BOOL)updateAvailable {
    return [self.state isEqualToString:@"on"];
}

- (NSString *)updateReleaseURL {
    return HAAttrString(self.attributes, HAAttrReleaseURL);
}

#pragma mark - Default View Filtering

- (BOOL)shouldShowInDefaultView {
    // Entities with entity_category (config/diagnostic) are internal
    if (self.entityCategory.length > 0) return NO;

    // Entities hidden by user or integration
    if (self.hiddenBy.length > 0) return NO;

    // Disabled entities
    if (self.disabledBy.length > 0) return NO;

    // Unavailable entities
    if (![self isAvailable]) return NO;

    NSString *d = [self domain];
    if (!d) return NO;

    // HIDE_DOMAINS: domains that should never appear in default view
    static NSSet *hideDomains = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hideDomains = [NSSet setWithObjects:
            @"ai_task", @"automation", @"configurator", @"device_tracker",
            @"event", @"geo_location", @"notify", @"persistent_notification",
            @"script", @"sun", @"tag", @"todo", @"zone", nil];
    });
    if ([hideDomains containsObject:d]) return NO;

    // HIDE_PLATFORMS: integration platforms whose entities are internal
    static NSSet *hidePlatforms = nil;
    static dispatch_once_t platformToken;
    dispatch_once(&platformToken, ^{
        hidePlatforms = [NSSet setWithObjects:@"backup", @"mobile_app", nil];
    });
    if (self.platform.length > 0 && [hidePlatforms containsObject:self.platform]) return NO;

    return YES;
}

#pragma mark - Optimistic UI

- (void)applyOptimisticState:(NSString *)state attributeOverrides:(NSDictionary *)overrides {
    if (state) {
        self.state = state;
    }
    if (overrides.count > 0) {
        NSMutableDictionary *merged = [self.attributes mutableCopy];
        [merged addEntriesFromDictionary:overrides];
        self.attributes = [merged copy];
    }
}

#pragma mark - Service Helpers

- (NSString *)toggleService {
    NSString *d = [self domain];
    if ([d isEqualToString:HAEntityDomainLock]) return @"lock";
    if ([d isEqualToString:HAEntityDomainCover]) return @"toggle";
    if ([d isEqualToString:HAEntityDomainScene]) return @"turn_on";
    if ([d isEqualToString:HAEntityDomainScript]) return @"turn_on";
    if ([d isEqualToString:HAEntityDomainButton] ||
        [d isEqualToString:HAEntityDomainInputButton]) return @"press";
    // Only return toggle for domains that actually support it
    if ([d isEqualToString:HAEntityDomainLight] ||
        [d isEqualToString:HAEntityDomainSwitch] ||
        [d isEqualToString:HAEntityDomainInputBoolean] ||
        [d isEqualToString:HAEntityDomainFan] ||
        [d isEqualToString:HAEntityDomainAutomation] ||
        [d isEqualToString:HAEntityDomainSiren] ||
        [d isEqualToString:HAEntityDomainHumidifier]) {
        return @"toggle";
    }
    // Non-toggleable domains (sensor, binary_sensor, weather, person, etc.)
    return nil;
}

- (NSString *)turnOnService {
    NSString *d = [self domain];
    if ([d isEqualToString:HAEntityDomainLock]) return @"lock";
    if ([d isEqualToString:HAEntityDomainCover]) return @"open_cover";
    if ([d isEqualToString:HAEntityDomainScene]) return @"turn_on";
    if ([d isEqualToString:HAEntityDomainButton] ||
        [d isEqualToString:HAEntityDomainInputButton]) return @"press";
    return @"turn_on";
}

- (NSString *)turnOffService {
    NSString *d = [self domain];
    if ([d isEqualToString:HAEntityDomainLock]) return @"unlock";
    if ([d isEqualToString:HAEntityDomainCover]) return @"close_cover";
    return @"turn_off";
}

@end
