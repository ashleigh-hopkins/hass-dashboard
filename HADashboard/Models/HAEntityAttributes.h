#import <Foundation/Foundation.h>

/// Safe extraction functions for entity attributes.
/// These handle NSNull (from JSON null), type mismatches, and nil — preventing
/// the "unrecognized selector sent to [NSNull]" crash class entirely.

#pragma mark - Safe Extraction Functions

/// Returns nil if value is nil, NSNull, or not an NSString.
NS_INLINE NSString *HAAttrString(NSDictionary *attrs, NSString *key) {
    id val = attrs[key];
    return ([val isKindOfClass:[NSString class]]) ? val : nil;
}

/// Returns nil if value is nil, NSNull, or not an NSNumber.
NS_INLINE NSNumber *HAAttrNumber(NSDictionary *attrs, NSString *key) {
    id val = attrs[key];
    return ([val isKindOfClass:[NSNumber class]]) ? val : nil;
}

/// Returns defaultValue if value is nil, NSNull, or not an NSNumber.
NS_INLINE NSInteger HAAttrInteger(NSDictionary *attrs, NSString *key, NSInteger defaultValue) {
    id val = attrs[key];
    return ([val isKindOfClass:[NSNumber class]]) ? [val integerValue] : defaultValue;
}

/// Returns defaultValue if value is nil, NSNull, or not an NSNumber.
NS_INLINE double HAAttrDouble(NSDictionary *attrs, NSString *key, double defaultValue) {
    id val = attrs[key];
    return ([val isKindOfClass:[NSNumber class]]) ? [val doubleValue] : defaultValue;
}

/// Returns defaultValue if value is nil, NSNull, or not an NSNumber.
NS_INLINE BOOL HAAttrBool(NSDictionary *attrs, NSString *key, BOOL defaultValue) {
    id val = attrs[key];
    return ([val isKindOfClass:[NSNumber class]]) ? [val boolValue] : defaultValue;
}

/// Returns nil if value is nil, NSNull, or not an NSArray.
NS_INLINE NSArray *HAAttrArray(NSDictionary *attrs, NSString *key) {
    id val = attrs[key];
    return ([val isKindOfClass:[NSArray class]]) ? val : nil;
}

#pragma mark - Cross-Domain Attribute Keys

extern NSString *const HAAttrFriendlyName;          // @"friendly_name"
extern NSString *const HAAttrIcon;                   // @"icon"
extern NSString *const HAAttrUnitOfMeasurement;      // @"unit_of_measurement"
extern NSString *const HAAttrDeviceClass;            // @"device_class"
extern NSString *const HAAttrSupportedFeatures;      // @"supported_features"
extern NSString *const HAAttrAttribution;            // @"attribution"

#pragma mark - Light Attribute Keys

extern NSString *const HAAttrBrightness;             // @"brightness"
extern NSString *const HAAttrColorMode;              // @"color_mode"
extern NSString *const HAAttrSupportedColorModes;    // @"supported_color_modes"
extern NSString *const HAAttrColorTempKelvin;        // @"color_temp_kelvin"
extern NSString *const HAAttrMinColorTempKelvin;     // @"min_color_temp_kelvin"
extern NSString *const HAAttrMaxColorTempKelvin;     // @"max_color_temp_kelvin"
extern NSString *const HAAttrHSColor;                // @"hs_color"
extern NSString *const HAAttrEffect;                 // @"effect"
extern NSString *const HAAttrEffectList;             // @"effect_list"

#pragma mark - Climate Attribute Keys

extern NSString *const HAAttrCurrentTemperature;     // @"current_temperature"
extern NSString *const HAAttrTemperature;            // @"temperature"
extern NSString *const HAAttrMinTemp;                // @"min_temp"
extern NSString *const HAAttrMaxTemp;                // @"max_temp"
extern NSString *const HAAttrHvacMode;               // @"hvac_mode"
extern NSString *const HAAttrHvacModes;              // @"hvac_modes"
extern NSString *const HAAttrHvacAction;             // @"hvac_action"
extern NSString *const HAAttrFanMode;                // @"fan_mode"
extern NSString *const HAAttrFanModes;               // @"fan_modes"

#pragma mark - Cover Attribute Keys

extern NSString *const HAAttrCurrentPosition;        // @"current_position"
extern NSString *const HAAttrCurrentTiltPosition;    // @"current_tilt_position"

#pragma mark - Media Player Attribute Keys

extern NSString *const HAAttrMediaTitle;             // @"media_title"
extern NSString *const HAAttrMediaArtist;            // @"media_artist"
extern NSString *const HAAttrMediaDuration;          // @"media_duration"
extern NSString *const HAAttrMediaPosition;          // @"media_position"
extern NSString *const HAAttrVolumeLevel;            // @"volume_level"
extern NSString *const HAAttrIsVolumeMuted;          // @"is_volume_muted"
extern NSString *const HAAttrAppName;                // @"app_name"
extern NSString *const HAAttrSoundMode;              // @"sound_mode"
extern NSString *const HAAttrSoundModeList;          // @"sound_mode_list"

#pragma mark - Fan Attribute Keys

extern NSString *const HAAttrPercentage;             // @"percentage"
extern NSString *const HAAttrPresetMode;             // @"preset_mode"
extern NSString *const HAAttrPresetModes;            // @"preset_modes"
extern NSString *const HAAttrOscillating;            // @"oscillating"
extern NSString *const HAAttrDirection;              // @"direction"
extern NSString *const HAAttrFanSpeed;               // @"fan_speed"
extern NSString *const HAAttrFanSpeedList;           // @"fan_speed_list"

#pragma mark - Vacuum Attribute Keys

extern NSString *const HAAttrBatteryLevel;           // @"battery_level"
extern NSString *const HAAttrStatus;                 // @"status"

#pragma mark - Alarm Attribute Keys

extern NSString *const HAAttrCodeRequired;           // @"code_required"
extern NSString *const HAAttrCodeArmRequired;        // @"code_arm_required"
extern NSString *const HAAttrCodeFormat;             // @"code_format"

#pragma mark - Weather Attribute Keys

extern NSString *const HAAttrHumidity;               // @"humidity"
extern NSString *const HAAttrPressure;               // @"pressure"
extern NSString *const HAAttrPressureUnit;           // @"pressure_unit"
extern NSString *const HAAttrWindSpeed;              // @"wind_speed"
extern NSString *const HAAttrWindSpeedUnit;          // @"wind_speed_unit"
extern NSString *const HAAttrWindBearing;            // @"wind_bearing"
extern NSString *const HAAttrTemperatureUnit;        // @"temperature_unit"
extern NSString *const HAAttrForecast;               // @"forecast"

#pragma mark - Humidifier Attribute Keys

extern NSString *const HAAttrCurrentHumidity;        // @"current_humidity"
extern NSString *const HAAttrMinHumidity;            // @"min_humidity"
extern NSString *const HAAttrMaxHumidity;            // @"max_humidity"
extern NSString *const HAAttrAvailableModes;         // @"available_modes"

#pragma mark - Input Number / Input Text / Counter Attribute Keys

extern NSString *const HAAttrMin;                    // @"min"
extern NSString *const HAAttrMax;                    // @"max"
extern NSString *const HAAttrStep;                   // @"step"
extern NSString *const HAAttrMode;                   // @"mode"
extern NSString *const HAAttrPattern;                // @"pattern"
extern NSString *const HAAttrMinimum;                // @"minimum"  (counter)
extern NSString *const HAAttrMaximum;                // @"maximum"  (counter)
extern NSString *const HAAttrOptions;                // @"options"

#pragma mark - Input Datetime Attribute Keys

extern NSString *const HAAttrHasDate;                // @"has_date"
extern NSString *const HAAttrHasTime;                // @"has_time"

#pragma mark - Timer Attribute Keys

extern NSString *const HAAttrDuration;               // @"duration"
extern NSString *const HAAttrRemaining;              // @"remaining"
extern NSString *const HAAttrFinishesAt;             // @"finishes_at"

#pragma mark - Update Attribute Keys

extern NSString *const HAAttrInstalledVersion;       // @"installed_version"
extern NSString *const HAAttrLatestVersion;          // @"latest_version"
extern NSString *const HAAttrReleaseURL;             // @"release_url"
extern NSString *const HAAttrReleaseSummary;         // @"release_summary"

#pragma mark - Water Heater Attribute Keys

extern NSString *const HAAttrOperationList;          // @"operation_list"
extern NSString *const HAAttrOperationMode;          // @"operation_mode"
