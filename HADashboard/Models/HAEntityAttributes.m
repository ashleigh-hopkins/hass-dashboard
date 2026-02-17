#import "HAEntityAttributes.h"

#pragma mark - Cross-Domain Attribute Keys

NSString *const HAAttrFriendlyName       = @"friendly_name";
NSString *const HAAttrIcon               = @"icon";
NSString *const HAAttrUnitOfMeasurement  = @"unit_of_measurement";
NSString *const HAAttrDeviceClass        = @"device_class";
NSString *const HAAttrSupportedFeatures  = @"supported_features";
NSString *const HAAttrAttribution        = @"attribution";

#pragma mark - Light Attribute Keys

NSString *const HAAttrBrightness          = @"brightness";
NSString *const HAAttrColorMode           = @"color_mode";
NSString *const HAAttrSupportedColorModes = @"supported_color_modes";
NSString *const HAAttrColorTempKelvin     = @"color_temp_kelvin";
NSString *const HAAttrMinColorTempKelvin  = @"min_color_temp_kelvin";
NSString *const HAAttrMaxColorTempKelvin  = @"max_color_temp_kelvin";
NSString *const HAAttrHSColor             = @"hs_color";
NSString *const HAAttrEffect              = @"effect";
NSString *const HAAttrEffectList          = @"effect_list";

#pragma mark - Climate Attribute Keys

NSString *const HAAttrCurrentTemperature  = @"current_temperature";
NSString *const HAAttrTemperature         = @"temperature";
NSString *const HAAttrMinTemp             = @"min_temp";
NSString *const HAAttrMaxTemp             = @"max_temp";
NSString *const HAAttrHvacMode            = @"hvac_mode";
NSString *const HAAttrHvacModes           = @"hvac_modes";
NSString *const HAAttrHvacAction          = @"hvac_action";
NSString *const HAAttrFanMode             = @"fan_mode";
NSString *const HAAttrFanModes            = @"fan_modes";

#pragma mark - Cover Attribute Keys

NSString *const HAAttrCurrentPosition     = @"current_position";
NSString *const HAAttrCurrentTiltPosition = @"current_tilt_position";

#pragma mark - Media Player Attribute Keys

NSString *const HAAttrMediaTitle          = @"media_title";
NSString *const HAAttrMediaArtist         = @"media_artist";
NSString *const HAAttrMediaDuration       = @"media_duration";
NSString *const HAAttrMediaPosition       = @"media_position";
NSString *const HAAttrVolumeLevel         = @"volume_level";
NSString *const HAAttrIsVolumeMuted       = @"is_volume_muted";
NSString *const HAAttrAppName             = @"app_name";
NSString *const HAAttrSoundMode           = @"sound_mode";
NSString *const HAAttrSoundModeList       = @"sound_mode_list";

#pragma mark - Fan Attribute Keys

NSString *const HAAttrPercentage          = @"percentage";
NSString *const HAAttrPresetMode          = @"preset_mode";
NSString *const HAAttrPresetModes         = @"preset_modes";
NSString *const HAAttrOscillating         = @"oscillating";
NSString *const HAAttrDirection           = @"direction";
NSString *const HAAttrFanSpeed            = @"fan_speed";
NSString *const HAAttrFanSpeedList        = @"fan_speed_list";

#pragma mark - Vacuum Attribute Keys

NSString *const HAAttrBatteryLevel        = @"battery_level";
NSString *const HAAttrStatus              = @"status";

#pragma mark - Alarm Attribute Keys

NSString *const HAAttrCodeRequired        = @"code_required";
NSString *const HAAttrCodeArmRequired     = @"code_arm_required";
NSString *const HAAttrCodeFormat          = @"code_format";

#pragma mark - Weather Attribute Keys

NSString *const HAAttrHumidity            = @"humidity";
NSString *const HAAttrPressure            = @"pressure";
NSString *const HAAttrPressureUnit        = @"pressure_unit";
NSString *const HAAttrWindSpeed           = @"wind_speed";
NSString *const HAAttrWindSpeedUnit       = @"wind_speed_unit";
NSString *const HAAttrWindBearing         = @"wind_bearing";
NSString *const HAAttrTemperatureUnit     = @"temperature_unit";
NSString *const HAAttrForecast            = @"forecast";

#pragma mark - Humidifier Attribute Keys

NSString *const HAAttrCurrentHumidity     = @"current_humidity";
NSString *const HAAttrMinHumidity         = @"min_humidity";
NSString *const HAAttrMaxHumidity         = @"max_humidity";
NSString *const HAAttrAvailableModes      = @"available_modes";

#pragma mark - Input Number / Input Text / Counter Attribute Keys

NSString *const HAAttrMin                 = @"min";
NSString *const HAAttrMax                 = @"max";
NSString *const HAAttrStep                = @"step";
NSString *const HAAttrMode                = @"mode";
NSString *const HAAttrPattern             = @"pattern";
NSString *const HAAttrMinimum             = @"minimum";
NSString *const HAAttrMaximum             = @"maximum";
NSString *const HAAttrOptions             = @"options";

#pragma mark - Input Datetime Attribute Keys

NSString *const HAAttrHasDate             = @"has_date";
NSString *const HAAttrHasTime             = @"has_time";

#pragma mark - Timer Attribute Keys

NSString *const HAAttrDuration            = @"duration";
NSString *const HAAttrRemaining           = @"remaining";
NSString *const HAAttrFinishesAt          = @"finishes_at";

#pragma mark - Update Attribute Keys

NSString *const HAAttrInstalledVersion    = @"installed_version";
NSString *const HAAttrLatestVersion       = @"latest_version";
NSString *const HAAttrReleaseURL          = @"release_url";
NSString *const HAAttrReleaseSummary      = @"release_summary";

#pragma mark - Water Heater Attribute Keys

NSString *const HAAttrOperationList       = @"operation_list";
NSString *const HAAttrOperationMode       = @"operation_mode";
