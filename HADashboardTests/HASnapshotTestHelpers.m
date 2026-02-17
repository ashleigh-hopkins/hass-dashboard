#import "HASnapshotTestHelpers.h"
#import "HAEntity.h"
#import "HADashboardConfig.h"

@implementation HASnapshotTestHelpers

#pragma mark - Core Factories

+ (HAEntity *)entityWithId:(NSString *)entityId
                     state:(NSString *)state
                attributes:(NSDictionary *)attributes {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"entity_id"] = entityId;
    dict[@"state"] = state;
    dict[@"attributes"] = attributes ?: @{};
    dict[@"last_changed"] = @"2026-01-01T00:00:00Z";
    dict[@"last_updated"] = @"2026-01-01T00:00:00Z";
    return [[HAEntity alloc] initWithDictionary:dict];
}

+ (HADashboardConfigItem *)itemWithEntityId:(NSString *)entityId
                                   cardType:(NSString *)cardType
                                 columnSpan:(NSInteger)columnSpan
                                headingIcon:(NSString *)headingIcon
                                displayName:(NSString *)displayName {
    HADashboardConfigItem *item = [[HADashboardConfigItem alloc] init];
    item.entityId = entityId;
    item.cardType = cardType;
    item.columnSpan = columnSpan;
    item.rowSpan = 1;
    item.displayName = displayName;
    if (headingIcon) {
        NSMutableDictionary *props = [NSMutableDictionary dictionary];
        props[@"headingIcon"] = headingIcon;
        item.customProperties = [props copy];
    }
    return item;
}

+ (HADashboardConfigSection *)sectionWithTitle:(NSString *)title
                                          icon:(NSString *)icon
                                     entityIds:(NSArray<NSString *> *)entityIds {
    HADashboardConfigSection *section = [[HADashboardConfigSection alloc] init];
    section.title = title;
    section.icon = icon;
    section.entityIds = entityIds;
    return section;
}

+ (NSDictionary<NSString *, HAEntity *> *)livingRoomEntities {
    NSMutableDictionary *entities = [NSMutableDictionary dictionary];

    // Thermostat
    entities[@"climate.aidoo"] = [self entityWithId:@"climate.aidoo"
        state:@"heat"
        attributes:@{
            @"friendly_name": @"Aidoo",
            @"current_temperature": @22.0,
            @"temperature": @22.0,
            @"hvac_action": @"idle",
            @"hvac_modes": @[@"off", @"heat", @"cool", @"auto"],
            @"temperature_unit": @"\u00B0C"
        }];

    // Vacuum
    entities[@"vacuum.saros_10"] = [self entityWithId:@"vacuum.saros_10"
        state:@"docked"
        attributes:@{
            @"friendly_name": @"Ribbit",
            @"battery_level": @100,
            @"status": @"Docked"
        }];

    // Lights
    entities[@"light.office_3"] = [self entityWithId:@"light.office_3"
        state:@"on"
        attributes:@{@"friendly_name": @"Office", @"brightness": @255}];

    entities[@"light.downstairs"] = [self entityWithId:@"light.downstairs"
        state:@"off"
        attributes:@{@"friendly_name": @"Downstairs"}];

    entities[@"light.upstairs"] = [self entityWithId:@"light.upstairs"
        state:@"off"
        attributes:@{@"friendly_name": @"Upstairs"}];

    return [entities copy];
}

#pragma mark - Light (4 variants)

+ (HAEntity *)lightEntityOnBrightness {
    return [self entityWithId:@"light.kitchen"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"Kitchen",
        @"brightness": @178,
        @"color_temp_kelvin": @2583,
        @"color_mode": @"color_temp",
        @"supported_color_modes": @[@"color_temp", @"xy"],
        @"icon": @"mdi:ceiling-light"
    }];
}

+ (HAEntity *)lightEntityOnRGB {
    return [self entityWithId:@"light.living_room_accent"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"Living Room Accent",
        @"brightness": @200,
        @"rgb_color": @[@255, @175, @96],
        @"color_mode": @"rgb",
        @"supported_color_modes": @[@"rgb"],
        @"icon": @"mdi:led-strip-variant"
    }];
}

+ (HAEntity *)lightEntityOnDimmed {
    return [self entityWithId:@"light.bedroom"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"Bedroom",
        @"brightness": @50,
        @"color_mode": @"brightness",
        @"supported_color_modes": @[@"brightness"]
    }];
}

+ (HAEntity *)lightEntityOff {
    return [self entityWithId:@"light.hallway"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"Hallway",
        @"supported_color_modes": @[@"brightness"]
    }];
}

#pragma mark - Climate (4 variants)

+ (HAEntity *)climateEntityHeat {
    return [self entityWithId:@"climate.living_room"
                        state:@"heat"
                   attributes:@{
        @"friendly_name": @"Living Room",
        @"temperature": @21,
        @"current_temperature": @20.8,
        @"preset_mode": @"comfort",
        @"hvac_action": @"heating",
        @"hvac_modes": @[@"off", @"heat", @"cool", @"auto"],
        @"min_temp": @7,
        @"max_temp": @35,
        @"target_temp_step": @0.5,
        @"temperature_unit": @"\u00B0C"
    }];
}

+ (HAEntity *)climateEntityCool {
    return [self entityWithId:@"climate.office"
                        state:@"cool"
                   attributes:@{
        @"friendly_name": @"Office",
        @"temperature": @24,
        @"current_temperature": @26.5,
        @"hvac_action": @"cooling",
        @"hvac_modes": @[@"off", @"heat", @"cool", @"auto"],
        @"min_temp": @7,
        @"max_temp": @35,
        @"temperature_unit": @"\u00B0C"
    }];
}

+ (HAEntity *)climateEntityAuto {
    return [self entityWithId:@"climate.bedroom"
                        state:@"auto"
                   attributes:@{
        @"friendly_name": @"Bedroom",
        @"target_temp_low": @20,
        @"target_temp_high": @24,
        @"current_temperature": @22,
        @"hvac_action": @"idle",
        @"hvac_modes": @[@"off", @"heat", @"cool", @"auto"],
        @"min_temp": @7,
        @"max_temp": @35,
        @"temperature_unit": @"\u00B0C"
    }];
}

+ (HAEntity *)climateEntityOff {
    return [self entityWithId:@"climate.guest_room"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"Guest Room",
        @"current_temperature": @19.5,
        @"hvac_modes": @[@"off", @"heat", @"cool", @"auto"],
        @"min_temp": @7,
        @"max_temp": @35,
        @"temperature_unit": @"\u00B0C"
    }];
}

#pragma mark - Switch (2 variants)

+ (HAEntity *)switchEntityOn {
    return [self entityWithId:@"switch.in_meeting"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"In Meeting",
        @"icon": @"mdi:laptop-account"
    }];
}

+ (HAEntity *)switchEntityOff {
    return [self entityWithId:@"switch.driveway"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"Driveway",
        @"icon": @"mdi:driveway"
    }];
}

#pragma mark - Cover (3 variants)

+ (HAEntity *)coverEntityOpenShutter {
    return [self entityWithId:@"cover.living_room_shutter"
                        state:@"open"
                   attributes:@{
        @"friendly_name": @"Living Room Shutter",
        @"current_position": @100,
        @"device_class": @"shutter"
    }];
}

+ (HAEntity *)coverEntityClosedGarage {
    return [self entityWithId:@"cover.garage_door"
                        state:@"closed"
                   attributes:@{
        @"friendly_name": @"Garage Door",
        @"device_class": @"garage"
    }];
}

+ (HAEntity *)coverEntityPartial {
    return [self entityWithId:@"cover.office_blinds"
                        state:@"open"
                   attributes:@{
        @"friendly_name": @"Office Blinds",
        @"current_position": @50,
        @"device_class": @"blind"
    }];
}

#pragma mark - Media Player (3 variants)

+ (HAEntity *)mediaPlayerPlaying {
    return [self entityWithId:@"media_player.living_room_speaker"
                        state:@"playing"
                   attributes:@{
        @"friendly_name": @"Living Room Speaker",
        @"media_title": @"I Wasn't Born To Follow",
        @"media_artist": @"The Byrds",
        @"media_album_name": @"The Notorious Byrd Brothers",
        @"volume_level": @0.18,
        @"is_volume_muted": @NO,
        @"media_content_type": @"music",
        @"icon": @"mdi:speaker"
    }];
}

+ (HAEntity *)mediaPlayerPaused {
    return [self entityWithId:@"media_player.bedroom_speaker"
                        state:@"paused"
                   attributes:@{
        @"friendly_name": @"Bedroom Speaker",
        @"media_title": @"Bohemian Rhapsody",
        @"media_artist": @"Queen",
        @"media_album_name": @"A Night at the Opera",
        @"volume_level": @0.5,
        @"is_volume_muted": @NO,
        @"media_content_type": @"music",
        @"icon": @"mdi:speaker"
    }];
}

+ (HAEntity *)mediaPlayerOff {
    return [self entityWithId:@"media_player.study_speaker"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"Study Speaker",
        @"volume_level": @0.18,
        @"is_volume_muted": @NO,
        @"icon": @"mdi:speaker"
    }];
}

#pragma mark - Sensor (6 variants)

+ (HAEntity *)sensorTemperature {
    return [self entityWithId:@"sensor.living_room_temperature"
                        state:@"22.8"
                   attributes:@{
        @"friendly_name": @"Living Room Temperature",
        @"unit_of_measurement": @"\u00B0C",
        @"device_class": @"temperature",
        @"state_class": @"measurement",
        @"icon": @"mdi:thermometer"
    }];
}

+ (HAEntity *)sensorHumidity {
    return [self entityWithId:@"sensor.living_room_humidity"
                        state:@"57"
                   attributes:@{
        @"friendly_name": @"Living Room Humidity",
        @"unit_of_measurement": @"%",
        @"device_class": @"humidity",
        @"state_class": @"measurement",
        @"icon": @"mdi:water-percent"
    }];
}

+ (HAEntity *)sensorEnergy {
    return [self entityWithId:@"sensor.power_consumption"
                        state:@"797.86"
                   attributes:@{
        @"friendly_name": @"Power Consumption",
        @"unit_of_measurement": @"W",
        @"device_class": @"power",
        @"state_class": @"measurement",
        @"icon": @"mdi:flash"
    }];
}

+ (HAEntity *)sensorBattery {
    return [self entityWithId:@"sensor.phone_battery"
                        state:@"11"
                   attributes:@{
        @"friendly_name": @"Phone Battery",
        @"unit_of_measurement": @"%",
        @"device_class": @"battery",
        @"icon": @"mdi:battery-charging"
    }];
}

+ (HAEntity *)sensorIlluminance {
    return [self entityWithId:@"sensor.office_illuminance"
                        state:@"555"
                   attributes:@{
        @"friendly_name": @"Office Illuminance",
        @"unit_of_measurement": @"lx",
        @"device_class": @"illuminance",
        @"icon": @"mdi:brightness-5"
    }];
}

+ (HAEntity *)sensorGenericText {
    return [self entityWithId:@"sensor.living_room_source"
                        state:@"YouTube"
                   attributes:@{
        @"friendly_name": @"Living Room",
        @"icon": @"mdi:television"
    }];
}

#pragma mark - Alarm Control Panel (4 variants)

+ (HAEntity *)alarmDisarmed {
    return [self entityWithId:@"alarm_control_panel.home_alarm"
                        state:@"disarmed"
                   attributes:@{
        @"friendly_name": @"Home Alarm",
        @"code_arm_required": @YES,
        @"supported_features": @31,
        @"icon": @"mdi:shield-check"
    }];
}

+ (HAEntity *)alarmArmedHome {
    return [self entityWithId:@"alarm_control_panel.home_alarm"
                        state:@"armed_home"
                   attributes:@{
        @"friendly_name": @"Home Alarm",
        @"code_arm_required": @YES,
        @"supported_features": @31,
        @"icon": @"mdi:shield-home"
    }];
}

+ (HAEntity *)alarmArmedAway {
    return [self entityWithId:@"alarm_control_panel.home_alarm"
                        state:@"armed_away"
                   attributes:@{
        @"friendly_name": @"Home Alarm",
        @"code_arm_required": @YES,
        @"supported_features": @31,
        @"icon": @"mdi:shield-lock"
    }];
}

+ (HAEntity *)alarmTriggered {
    return [self entityWithId:@"alarm_control_panel.home_alarm"
                        state:@"triggered"
                   attributes:@{
        @"friendly_name": @"Home Alarm",
        @"code_arm_required": @YES,
        @"supported_features": @31,
        @"icon": @"mdi:bell-ring"
    }];
}

#pragma mark - Person (2 variants)

+ (HAEntity *)personHome {
    return [self entityWithId:@"person.james"
                        state:@"home"
                   attributes:@{
        @"friendly_name": @"James",
        @"entity_picture": @"/local/james.jpg",
        @"latitude": @52.363,
        @"longitude": @4.890,
        @"gps_accuracy": @10,
        @"icon": @"mdi:account"
    }];
}

+ (HAEntity *)personNotHome {
    return [self entityWithId:@"person.olivia"
                        state:@"not_home"
                   attributes:@{
        @"friendly_name": @"Olivia",
        @"entity_picture": @"/local/olivia.jpg",
        @"latitude": @52.357,
        @"longitude": @4.866,
        @"gps_accuracy": @25,
        @"icon": @"mdi:account"
    }];
}

#pragma mark - Lock (3 variants)

+ (HAEntity *)lockLocked {
    return [self entityWithId:@"lock.frontdoor"
                        state:@"locked"
                   attributes:@{
        @"friendly_name": @"Frontdoor",
        @"icon": @"mdi:lock"
    }];
}

+ (HAEntity *)lockUnlocked {
    return [self entityWithId:@"lock.frontdoor"
                        state:@"unlocked"
                   attributes:@{
        @"friendly_name": @"Frontdoor",
        @"icon": @"mdi:lock-open"
    }];
}

+ (HAEntity *)lockJammed {
    return [self entityWithId:@"lock.frontdoor"
                        state:@"jammed"
                   attributes:@{
        @"friendly_name": @"Frontdoor",
        @"icon": @"mdi:lock-alert"
    }];
}

#pragma mark - Weather (3 variants)

+ (HAEntity *)weatherSunny {
    return [self entityWithId:@"weather.home"
                        state:@"sunny"
                   attributes:@{
        @"friendly_name": @"Home",
        @"temperature": @-5,
        @"humidity": @75,
        @"pressure": @1012,
        @"wind_speed": @8,
        @"wind_bearing": @"NW",
        @"temperature_unit": @"\u00B0C",
        @"forecast": [self forecastArrayForDays:9],
        @"icon": @"mdi:weather-sunny"
    }];
}

+ (HAEntity *)weatherCloudy {
    return [self entityWithId:@"weather.office"
                        state:@"cloudy"
                   attributes:@{
        @"friendly_name": @"Office",
        @"temperature": @12,
        @"humidity": @85,
        @"pressure": @1008,
        @"wind_speed": @15,
        @"wind_bearing": @"SW",
        @"temperature_unit": @"\u00B0C",
        @"icon": @"mdi:weather-cloudy"
    }];
}

+ (HAEntity *)weatherRainy {
    return [self entityWithId:@"weather.garden"
                        state:@"rainy"
                   attributes:@{
        @"friendly_name": @"Garden",
        @"temperature": @8,
        @"humidity": @95,
        @"pressure": @1002,
        @"wind_speed": @22,
        @"wind_bearing": @"S",
        @"temperature_unit": @"\u00B0C",
        @"icon": @"mdi:weather-pouring"
    }];
}

#pragma mark - Input Select (2 variants)

+ (HAEntity *)inputSelectThreeOptions {
    return [self entityWithId:@"input_select.media_source"
                        state:@"Shield"
                   attributes:@{
        @"friendly_name": @"Media Source",
        @"options": @[@"AppleTV", @"FireTV", @"Shield"],
        @"icon": @"mdi:remote"
    }];
}

+ (HAEntity *)inputSelectFiveOptions {
    return [self entityWithId:@"input_select.living_room_app"
                        state:@"YouTube"
                   attributes:@{
        @"friendly_name": @"Living Room App",
        @"options": @[@"PowerOff", @"YouTube", @"Netflix", @"Plex", @"AppleTV"],
        @"icon": @"mdi:application"
    }];
}

#pragma mark - Input Number (2 variants)

+ (HAEntity *)inputNumberSlider {
    return [self entityWithId:@"input_number.target_temperature"
                        state:@"18.0"
                   attributes:@{
        @"friendly_name": @"Target Temperature",
        @"min": @1,
        @"max": @100,
        @"step": @1,
        @"mode": @"slider",
        @"icon": @"mdi:thermometer"
    }];
}

+ (HAEntity *)inputNumberBox {
    return [self entityWithId:@"input_number.standing_desk_height"
                        state:@"72"
                   attributes:@{
        @"friendly_name": @"Standing Desk Height",
        @"min": @60,
        @"max": @120,
        @"step": @1,
        @"mode": @"box",
        @"unit_of_measurement": @"cm",
        @"icon": @"mdi:desk"
    }];
}

#pragma mark - Button (2 variants)

+ (HAEntity *)buttonDefault {
    return [self entityWithId:@"button.tv_off"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"TV Off",
        @"icon": @"mdi:television-off"
    }];
}

+ (HAEntity *)buttonPressed {
    return [self entityWithId:@"button.restart"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"Restart",
        @"icon": @"mdi:restart"
    }];
}

#pragma mark - Update (2 variants)

+ (HAEntity *)updateAvailable {
    return [self entityWithId:@"update.home_assistant_core"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"Home Assistant Core",
        @"installed_version": @"2024.2.0",
        @"latest_version": @"2024.4.0",
        @"title": @"Home Assistant Core",
        @"release_url": @"https://www.home-assistant.io/blog/",
        @"icon": @"mdi:package-up"
    }];
}

+ (HAEntity *)updateUpToDate {
    return [self entityWithId:@"update.home_assistant_core"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"Home Assistant Core",
        @"installed_version": @"2024.4.0",
        @"latest_version": @"2024.4.0",
        @"title": @"Home Assistant Core",
        @"icon": @"mdi:package-check"
    }];
}

#pragma mark - Counter (2 variants)

+ (HAEntity *)counterLow {
    return [self entityWithId:@"counter.litterbox_visits"
                        state:@"3"
                   attributes:@{
        @"friendly_name": @"Litterbox Visits",
        @"icon": @"mdi:cat",
        @"step": @1
    }];
}

+ (HAEntity *)counterHigh {
    return [self entityWithId:@"counter.page_views"
                        state:@"42"
                   attributes:@{
        @"friendly_name": @"Page Views",
        @"icon": @"mdi:counter",
        @"step": @1
    }];
}

#pragma mark - Binary Sensor (3 variants)

+ (HAEntity *)binarySensorMotionOn {
    return [self entityWithId:@"binary_sensor.hallway_motion"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"Hallway Motion",
        @"device_class": @"motion",
        @"icon": @"mdi:motion-sensor"
    }];
}

+ (HAEntity *)binarySensorDoorOff {
    return [self entityWithId:@"binary_sensor.front_door"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"Front Door",
        @"device_class": @"door",
        @"icon": @"mdi:door-closed"
    }];
}

+ (HAEntity *)binarySensorMoistureOff {
    return [self entityWithId:@"binary_sensor.kitchen_leak"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"Kitchen Leak",
        @"device_class": @"moisture",
        @"battery_level": @47,
        @"icon": @"mdi:water-off"
    }];
}

#pragma mark - Device Tracker (1 variant)

+ (HAEntity *)deviceTrackerNotHome {
    return [self entityWithId:@"device_tracker.car"
                        state:@"not_home"
                   attributes:@{
        @"friendly_name": @"Car",
        @"icon": @"mdi:car",
        @"source_type": @"gps"
    }];
}

#pragma mark - Fan (3 variants)

+ (HAEntity *)fanEntityOnHalf {
    return [self entityWithId:@"fan.living_room"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"Living Room Fan",
        @"percentage": @50,
        @"oscillating": @NO,
        @"preset_mode": @"normal",
        @"preset_modes": @[@"normal", @"sleep", @"nature"],
        @"percentage_step": @(100.0 / 3.0),
        @"icon": @"mdi:fan"
    }];
}

+ (HAEntity *)fanEntityOnFull {
    return [self entityWithId:@"fan.bedroom"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"Bedroom Fan",
        @"percentage": @100,
        @"oscillating": @YES,
        @"percentage_step": @(100.0 / 3.0),
        @"icon": @"mdi:fan"
    }];
}

+ (HAEntity *)fanEntityOff {
    return [self entityWithId:@"fan.office"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"Office Fan",
        @"percentage": @0,
        @"oscillating": @NO,
        @"icon": @"mdi:fan-off"
    }];
}

#pragma mark - Vacuum (4 variants)

+ (HAEntity *)vacuumDocked {
    return [self entityWithId:@"vacuum.roborock"
                        state:@"docked"
                   attributes:@{
        @"friendly_name": @"Roborock",
        @"battery_level": @100,
        @"status": @"Docked",
        @"icon": @"mdi:robot-vacuum"
    }];
}

+ (HAEntity *)vacuumCleaning {
    return [self entityWithId:@"vacuum.roborock"
                        state:@"cleaning"
                   attributes:@{
        @"friendly_name": @"Roborock",
        @"battery_level": @65,
        @"status": @"Cleaning",
        @"fan_speed": @"balanced",
        @"icon": @"mdi:robot-vacuum"
    }];
}

+ (HAEntity *)vacuumReturning {
    return [self entityWithId:@"vacuum.roborock"
                        state:@"returning"
                   attributes:@{
        @"friendly_name": @"Roborock",
        @"battery_level": @20,
        @"status": @"Returning to dock",
        @"icon": @"mdi:robot-vacuum"
    }];
}

+ (HAEntity *)vacuumError {
    return [self entityWithId:@"vacuum.roborock"
                        state:@"error"
                   attributes:@{
        @"friendly_name": @"Roborock",
        @"battery_level": @45,
        @"status": @"Error",
        @"icon": @"mdi:robot-vacuum-alert"
    }];
}

#pragma mark - Humidifier (2 variants)

+ (HAEntity *)humidifierOn {
    return [self entityWithId:@"humidifier.bedroom"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"Bedroom Humidifier",
        @"humidity": @60,
        @"min_humidity": @30,
        @"max_humidity": @80,
        @"mode": @"normal",
        @"available_modes": @[@"normal", @"eco", @"boost"],
        @"icon": @"mdi:air-humidifier"
    }];
}

+ (HAEntity *)humidifierOff {
    return [self entityWithId:@"humidifier.bedroom"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"Bedroom Humidifier",
        @"min_humidity": @30,
        @"max_humidity": @80,
        @"icon": @"mdi:air-humidifier-off"
    }];
}

#pragma mark - Timer (3 variants)

+ (HAEntity *)timerActive {
    return [self entityWithId:@"timer.laundry"
                        state:@"active"
                   attributes:@{
        @"friendly_name": @"Laundry",
        @"duration": @"0:10:00",
        @"remaining": @"0:05:23",
        @"icon": @"mdi:timer-outline"
    }];
}

+ (HAEntity *)timerPaused {
    return [self entityWithId:@"timer.oven"
                        state:@"paused"
                   attributes:@{
        @"friendly_name": @"Oven",
        @"duration": @"0:30:00",
        @"remaining": @"0:15:00",
        @"icon": @"mdi:timer-pause"
    }];
}

+ (HAEntity *)timerIdle {
    return [self entityWithId:@"timer.meditation"
                        state:@"idle"
                   attributes:@{
        @"friendly_name": @"Meditation",
        @"duration": @"0:10:00",
        @"icon": @"mdi:timer-outline"
    }];
}

#pragma mark - Input Text (2 variants)

+ (HAEntity *)inputTextWithValue {
    return [self entityWithId:@"input_text.greeting"
                        state:@"Hello World"
                   attributes:@{
        @"friendly_name": @"Greeting",
        @"mode": @"text",
        @"min": @0,
        @"max": @100,
        @"icon": @"mdi:form-textbox"
    }];
}

+ (HAEntity *)inputTextEmpty {
    return [self entityWithId:@"input_text.notes"
                        state:@""
                   attributes:@{
        @"friendly_name": @"Notes",
        @"mode": @"text",
        @"min": @0,
        @"max": @100,
        @"icon": @"mdi:form-textbox"
    }];
}

#pragma mark - Input DateTime (3 variants)

+ (HAEntity *)inputDateTimeDate {
    return [self entityWithId:@"input_datetime.vacation_start"
                        state:@"2026-01-15"
                   attributes:@{
        @"friendly_name": @"Vacation Start",
        @"has_date": @YES,
        @"has_time": @NO,
        @"year": @2026,
        @"month": @1,
        @"day": @15,
        @"icon": @"mdi:calendar"
    }];
}

+ (HAEntity *)inputDateTimeTime {
    return [self entityWithId:@"input_datetime.morning_alarm"
                        state:@"14:30:00"
                   attributes:@{
        @"friendly_name": @"Morning Alarm",
        @"has_date": @NO,
        @"has_time": @YES,
        @"hour": @14,
        @"minute": @30,
        @"second": @0,
        @"icon": @"mdi:clock-outline"
    }];
}

+ (HAEntity *)inputDateTimeBoth {
    return [self entityWithId:@"input_datetime.appointment"
                        state:@"2026-01-15 14:30:00"
                   attributes:@{
        @"friendly_name": @"Appointment",
        @"has_date": @YES,
        @"has_time": @YES,
        @"year": @2026,
        @"month": @1,
        @"day": @15,
        @"hour": @14,
        @"minute": @30,
        @"second": @0,
        @"icon": @"mdi:calendar-clock"
    }];
}

#pragma mark - Camera (2 variants)

+ (HAEntity *)cameraStreaming {
    return [self entityWithId:@"camera.patio"
                        state:@"idle"
                   attributes:@{
        @"friendly_name": @"Patio",
        @"entity_picture": @"/api/camera_proxy/camera.patio",
        @"icon": @"mdi:cctv"
    }];
}

+ (HAEntity *)cameraUnavailable {
    return [self entityWithId:@"camera.driveway"
                        state:@"unavailable"
                   attributes:@{
        @"friendly_name": @"Driveway",
        @"icon": @"mdi:cctv"
    }];
}

#pragma mark - Scene (2 variants)

+ (HAEntity *)sceneDefault {
    return [self entityWithId:@"scene.movie_night"
                        state:@"off"
                   attributes:@{
        @"friendly_name": @"Movie Night",
        @"icon": @"mdi:movie-open"
    }];
}

+ (HAEntity *)sceneActivated {
    return [self entityWithId:@"scene.good_morning"
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"Good Morning",
        @"icon": @"mdi:weather-sunny"
    }];
}

#pragma mark - Clock Weather (2 variants)

+ (HAEntity *)clockWeatherSunny {
    return [self entityWithId:@"weather.clock_weather_home"
                        state:@"sunny"
                   attributes:@{
        @"friendly_name": @"Home",
        @"temperature": @22,
        @"humidity": @57,
        @"condition": @"sunny",
        @"pressure": @1015,
        @"wind_speed": @10,
        @"wind_bearing": @"E",
        @"temperature_unit": @"\u00B0C",
        @"forecast": [self forecastArrayForDays:5],
        @"icon": @"mdi:weather-sunny"
    }];
}

+ (HAEntity *)clockWeatherCloudy {
    return [self entityWithId:@"weather.clock_weather_home"
                        state:@"cloudy"
                   attributes:@{
        @"friendly_name": @"Home",
        @"temperature": @8,
        @"humidity": @85,
        @"condition": @"cloudy",
        @"pressure": @1005,
        @"wind_speed": @18,
        @"wind_bearing": @"W",
        @"temperature_unit": @"\u00B0C",
        @"forecast": [self forecastArrayForDays:5],
        @"icon": @"mdi:weather-cloudy"
    }];
}

#pragma mark - Edge Cases (Tier C)

+ (HAEntity *)unavailableEntity:(NSString *)entityId {
    // Derive friendly name from entity ID: "sensor.living_room_temp" -> "Living Room Temp"
    NSString *objectId = [[entityId componentsSeparatedByString:@"."] lastObject];
    NSString *friendlyName = [[objectId stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
    return [self entityWithId:entityId
                        state:@"unavailable"
                   attributes:@{
        @"friendly_name": friendlyName
    }];
}

+ (HAEntity *)longNameEntity:(NSString *)entityId {
    return [self entityWithId:entityId
                        state:@"on"
                   attributes:@{
        @"friendly_name": @"This Is An Extremely Long Entity Name That Should Test Truncation Behavior"
    }];
}

+ (HAEntity *)minimalEntity:(NSString *)entityId {
    return [self entityWithId:entityId
                        state:@"unknown"
                   attributes:@{}];
}

#pragma mark - Section / Config Helpers

+ (HADashboardConfigSection *)entitiesSectionWithLights {
    return [self sectionWithTitle:@"Lights"
                             icon:@"mdi:lightbulb-group"
                        entityIds:@[
        @"light.office_3",
        @"light.downstairs",
        @"light.upstairs"
    ]];
}

+ (HADashboardConfigSection *)entitiesSectionFiveRows {
    return [self sectionWithTitle:@"All Devices"
                             icon:@"mdi:devices"
                        entityIds:@[
        @"light.kitchen",
        @"switch.in_meeting",
        @"sensor.living_room_temperature",
        @"cover.office_blinds",
        @"lock.frontdoor"
    ]];
}

+ (HADashboardConfigSection *)badgeSection2Items {
    HADashboardConfigSection *section = [[HADashboardConfigSection alloc] init];
    section.title = @"Environment";
    section.icon = @"mdi:thermometer";
    section.entityIds = @[
        @"sensor.living_room_temperature",
        @"sensor.living_room_humidity"
    ];
    section.customProperties = @{@"chipStyle": @"badge"};
    return section;
}

+ (HADashboardConfigSection *)badgeSection4Items {
    HADashboardConfigSection *section = [[HADashboardConfigSection alloc] init];
    section.title = @"Status";
    section.icon = @"mdi:home";
    section.entityIds = @[
        @"sensor.living_room_temperature",
        @"sensor.living_room_humidity",
        @"binary_sensor.hallway_motion",
        @"binary_sensor.front_door"
    ];
    section.customProperties = @{@"chipStyle": @"badge"};
    return section;
}

+ (HADashboardConfigItem *)gaugeCardItem50Percent {
    HADashboardConfigItem *item = [[HADashboardConfigItem alloc] init];
    item.entityId = @"sensor.living_room_humidity";
    item.cardType = @"gauge";
    item.columnSpan = 1;
    item.rowSpan = 1;
    item.customProperties = @{
        @"min": @0,
        @"max": @100,
        @"name": @"Humidity"
    };
    return item;
}

+ (HADashboardConfigItem *)gaugeCardItem0Percent {
    HADashboardConfigItem *item = [[HADashboardConfigItem alloc] init];
    item.entityId = @"sensor.empty_tank";
    item.cardType = @"gauge";
    item.columnSpan = 1;
    item.rowSpan = 1;
    item.customProperties = @{
        @"min": @0,
        @"max": @100,
        @"name": @"Tank Level"
    };
    return item;
}

+ (HADashboardConfigItem *)gaugeCardItem100Percent {
    HADashboardConfigItem *item = [[HADashboardConfigItem alloc] init];
    item.entityId = @"sensor.full_battery";
    item.cardType = @"gauge";
    item.columnSpan = 1;
    item.rowSpan = 1;
    item.customProperties = @{
        @"min": @0,
        @"max": @100,
        @"name": @"Battery"
    };
    return item;
}

+ (HADashboardConfigItem *)gaugeCardItemSeverity {
    HADashboardConfigItem *item = [[HADashboardConfigItem alloc] init];
    item.entityId = @"sensor.cpu_temperature";
    item.cardType = @"gauge";
    item.columnSpan = 1;
    item.rowSpan = 1;
    item.customProperties = @{
        @"min": @0,
        @"max": @100,
        @"name": @"CPU Temperature",
        @"severity": @{
            @"green": @40,
            @"yellow": @70,
            @"red": @90
        }
    };
    return item;
}

+ (HADashboardConfigItem *)graphCardSingleEntity {
    HADashboardConfigItem *item = [[HADashboardConfigItem alloc] init];
    item.entityId = @"sensor.living_room_temperature";
    item.cardType = @"sensor";
    item.columnSpan = 2;
    item.rowSpan = 1;
    item.customProperties = @{
        @"graph": @"line",
        @"detail": @1,
        @"hours_to_show": @24
    };
    return item;
}

+ (HADashboardConfigItem *)graphCardMultiEntity {
    HADashboardConfigItem *item = [[HADashboardConfigItem alloc] init];
    item.entityId = @"sensor.living_room_temperature";
    item.cardType = @"sensor";
    item.columnSpan = 2;
    item.rowSpan = 1;
    item.customProperties = @{
        @"graph": @"line",
        @"detail": @1,
        @"hours_to_show": @24,
        @"entities": @[
            @"sensor.living_room_temperature",
            @"sensor.living_room_humidity",
            @"sensor.office_illuminance"
        ]
    };
    return item;
}

#pragma mark - Weather Forecast Helper

+ (NSArray *)forecastArrayForDays:(NSInteger)days {
    NSMutableArray *forecast = [NSMutableArray arrayWithCapacity:days];
    NSArray *conditions = @[@"sunny", @"partlycloudy", @"cloudy", @"rainy",
                            @"sunny", @"lightning-rainy", @"snowy", @"partlycloudy", @"windy"];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];

    for (NSInteger i = 0; i < days; i++) {
        NSDate *date = [cal dateByAddingUnit:NSCalendarUnitDay value:i + 1 toDate:today options:0];
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        fmt.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

        // Generate varying but deterministic temperatures
        NSInteger highTemp = 10 + (i * 3) % 15;   // range ~10-24
        NSInteger lowTemp  = highTemp - 5 - (i % 3);
        double precip      = (i % 3 == 0) ? 0.0 : (double)(i * 2 % 7);

        NSString *condition = conditions[i % (NSInteger)conditions.count];

        [forecast addObject:@{
            @"datetime": [fmt stringFromDate:date],
            @"temperature": @(highTemp),
            @"templow": @(lowTemp),
            @"condition": condition,
            @"precipitation": @(precip),
            @"precipitation_probability": @((i * 13) % 100),
            @"wind_speed": @(5 + (i * 4) % 20)
        }];
    }
    return [forecast copy];
}

@end
