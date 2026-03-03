# Parity Sprint — Complete Field-Level Gap Closure

**Status**: 79/79 tasks addressed — 72 implemented, 4 pre-existing, 3 deferred (see [deferred-items.md](deferred-items.md))
**Created**: 2026-03-01
**Last Updated**: 2026-03-03
**Source**: entity-field-parity.md audit

Every missing field from the audit, organized into implementation waves. All tasks addressed — implemented, verified pre-existing, or deferred with documented reason. Note: code existence verified for all implemented tasks, but some features are not exercised by the demo dashboard (see deferred-items.md §7 "Demo Data Gaps").

---

## Wave 1 — Cross-Domain Systemic Fixes

These affect every entity type and provide the highest leverage.

### 1.1 state_color on Entity Rows

Tint the icon color in HAEntityRowView based on entity active state.

- **Files**: `HAEntityRowView.m`
- **What**: After setting icon glyph, call `HAEntityDisplayHelper.iconColorForEntity:` and apply to iconLabel. Only when `state_color` config is true.
- **Parser**: Already parsed as `state_color` in customProperties (for glance). Need to propagate to entity rows via section config.
- **Lines**: ~10
- **Dependencies**: None

### 1.2 secondary_info on Entity Rows

Add a secondary label below the entity name in HAEntityRowView, showing one of 7 info types.

- **Files**: `HAEntityRowView.h`, `HAEntityRowView.m`, `HALovelaceParser.m`, `HAEntitiesCardCell.m`
- **What**:
  - Add `secondaryInfoLabel` (UILabel, 11pt, secondary color) below nameLabel
  - Add `secondaryInfo` property on HAEntityRowView
  - Parse `secondary_info` from per-entity config in entities card YAML
  - Render based on type:
    - `entity-id` → entity.entityId
    - `last-changed` → relative time from entity.lastChanged
    - `last-updated` → relative time from entity.lastUpdated
    - `last-triggered` → from `last_triggered` attribute (automations/scripts)
    - `position` → entity.coverPosition + "%"
    - `tilt-position` → entity.attributes[current_tilt_position] + "%"
    - `brightness` → entity.brightnessPercent + "%"
  - Adjust nameLabel constraints to accommodate secondary label
- **Parser**: Extract `secondary_info` from per-entity dict in entities card, store in entityConfigs
- **Lines**: ~80 (row view) + ~15 (parser) + ~5 (cell) = ~100
- **Dependencies**: None

### 1.3 attribute Display (Show Specific Attribute Instead of State)

Allow cards to display a specific entity attribute value instead of the state.

- **Files**: `HAEntityRowView.m`, `HATileEntityCell.m`, `HAGlanceItemView.m`, `HALovelaceParser.m`
- **What**:
  - Parse `attribute` field from card/entity config
  - When configured, display `entity.attributes[attribute]` instead of `entity.state`
  - Apply optional `unit` override for the displayed value
- **Parser**: Extract `attribute` and `unit` from card config, store in customProperties
- **Lines**: ~30 per cell type × 3 = ~90 + ~10 parser = ~100
- **Dependencies**: None

### 1.4 state_content on Tile Cards

Allow tile cards to display last_changed, last_updated, or entity attributes as the state text.

- **Files**: `HATileEntityCell.m`, `HALovelaceParser.m`
- **What**:
  - Parse `state_content` (string or list) from tile card config
  - When configured, replace the state label with:
    - `"last_changed"` → relative time from entity.lastChanged
    - `"last_updated"` → relative time from entity.lastUpdated
    - attribute name → entity.attributes[name] with optional unit
  - If list, join multiple values with " · "
- **Parser**: Extract `state_content` from card config
- **Lines**: ~40 (cell) + ~5 (parser) = ~45
- **Dependencies**: None

### 1.5 format (Relative/Total/Date/Time/Datetime Formatting)

Format timestamp states and secondary_info values.

- **Files**: `HAEntityDisplayHelper.h/.m`
- **What**:
  - Add `+ (NSString *)formattedValue:(NSString *)value withFormat:(NSString *)format` method
  - Format types:
    - `relative` → "2 minutes ago", "1 hour ago" (NSDate relative formatting)
    - `total` → duration since epoch
    - `date` → date-only from ISO string
    - `time` → time-only from ISO string
    - `datetime` → date + time from ISO string
  - Use NSDateFormatter / NSRelativeDateTimeFormatter (iOS 13+)
- **Lines**: ~60
- **Dependencies**: None (used by 1.2 and 1.4)

### 1.6 show_entity_picture on Tile Cards

Show entity picture instead of icon when configured.

- **Files**: `HATileEntityCell.m`
- **What**:
  - Parse `show_entity_picture` from tile config
  - When true and entity has `entity_picture` attribute, load image URL into a circular UIImageView replacing the icon label
  - Use NSURLSession for async image loading
- **Lines**: ~50
- **Dependencies**: None

### 1.7 vertical Layout on Tile Cards

Icon above name+state layout variant for tiles.

- **Files**: `HATileEntityCell.m`
- **What**:
  - Parse `vertical` boolean from tile config
  - When true, rearrange layout: icon centered on top, name + state below
  - Similar to existing compact mode stack but with horizontal text alignment
- **Lines**: ~30 (constraints adjustment)
- **Dependencies**: None

### 1.8 hide_state on Tile Cards

Tile-specific hide state field (separate from show_state for backward compat).

- **Files**: `HATileEntityCell.m`
- **What**:
  - Parse `hide_state` from tile config
  - When true, hide tileStateLabel (same effect as show_state=false)
- **Lines**: ~5
- **Dependencies**: None

---

## Wave 2 — High-Impact Entity Controls

### 2.1 Light: Color Temperature Slider

- **Files**: `HALightEntityCell.m`, `HAEntity.h/.m` (add accessors)
- **What**:
  - Add `colorTempSlider` (UISlider) below brightness slider
  - Read `min_color_temp_kelvin` and `max_color_temp_kelvin` from entity attributes (constants already defined: HAAttrMinColorTempKelvin, HAAttrMaxColorTempKelvin)
  - Read current `color_temp_kelvin` (HAAttrColorTempKelvin already defined)
  - On slider change, call `light.turn_on` with `{color_temp_kelvin: value}`
  - Only show slider when `supported_color_modes` includes `color_temp`
- **Entity accessors needed**: `colorTempKelvin`, `minColorTempKelvin`, `maxColorTempKelvin`, `supportedColorModes`
- **Lines**: ~60 (cell) + ~20 (entity accessors) = ~80
- **Dependencies**: None

### 2.2 Light: RGB Color Picker

- **Files**: New `HAColorPickerView.h/.m`, `HALightEntityCell.m` or `HAEntityDetailViewController.m`
- **What**:
  - Create circular color wheel view (HSB color space)
  - Read `hs_color` [hue 0-360, saturation 0-100] from entity attributes
  - On selection change, call `light.turn_on` with `{hs_color: [h, s]}`
  - Only show when `supported_color_modes` includes `hs`, `rgb`, `xy`, `rgbw`, or `rgbww`
  - Consider placing in detail view rather than cell (space constraints)
- **Lines**: ~250 (color wheel) + ~40 (integration) = ~290
- **Dependencies**: 2.1 (color_mode awareness)

### 2.3 Light: Effects Selector

- **Files**: `HALightEntityCell.m` or detail view
- **What**:
  - Read `effect_list` (HAAttrEffectList, already defined) and `effect` (HAAttrEffect)
  - Show action sheet with available effects
  - Call `light.turn_on` with `{effect: selected_effect}`
- **Entity accessors needed**: `effectList`, `currentEffect`
- **Lines**: ~40
- **Dependencies**: None

### 2.4 Light: Color Mode Display

- **Files**: `HATileEntityCell.m`, `HALightEntityCell.m`
- **What**:
  - Read `color_mode` attribute (HAAttrColorMode, already defined)
  - Display current mode (brightness, color_temp, hs, rgb, etc.) as secondary text
  - Use to conditionally show/hide color temp slider vs color picker
- **Lines**: ~15
- **Dependencies**: None

### 2.5 Light: Remaining Color Modes (rgbw, rgbww, xy)

- **Files**: `HAColorPickerView.m` (from 2.2), `HAEntity.m`
- **What**:
  - Convert between hs_color and rgb_color/xy_color/rgbw_color/rgbww_color
  - Send appropriate color format based on `color_mode`
- **Entity accessors**: `rgbColor`, `rgbwColor`, `rgbwwColor`, `xyColor`
- **Lines**: ~60
- **Dependencies**: 2.2

### 2.6 Light: Transition and Flash

- **Files**: `HALightEntityCell.m`
- **What**:
  - Add optional `transition` parameter to turn_on/turn_off service calls
  - Configurable in entity detail view as a numeric input
  - `flash` parameter (short/long) — button in detail view
- **Lines**: ~30
- **Dependencies**: None

### 2.7 Media Player: Volume Slider

- **Files**: `HAMediaPlayerEntityCell.m`
- **What**:
  - Add `volumeSlider` (UISlider, 0-1.0) below playback controls
  - Read `volume_level` (HAAttrVolumeLevel, already defined) from entity
  - On change, call `media_player.volume_set` with `{volume_level: value}`
  - Debounce on touch-up
- **Lines**: ~40
- **Dependencies**: None

### 2.8 Media Player: Volume Mute Toggle

- **Files**: `HAMediaPlayerEntityCell.m`
- **What**:
  - Add mute button (speaker icon) next to volume slider
  - Read `is_volume_muted` (HAAttrIsVolumeMuted, already defined)
  - On tap, call `media_player.volume_mute` with `{is_volume_muted: !current}`
- **Lines**: ~25
- **Dependencies**: 2.7

### 2.9 Media Player: Album Art (entity_picture)

- **Files**: `HAMediaPlayerEntityCell.m`
- **What**:
  - Add `albumArtImageView` (UIImageView, rounded corners, left side or background)
  - Read `entity_picture` attribute → construct full URL from HA base URL
  - Load async via NSURLSession with auth header
  - Fall back to domain icon if no picture
- **Lines**: ~50
- **Dependencies**: None

### 2.10 Media Player: Source Selector

- **Files**: `HAMediaPlayerEntityCell.m`
- **What**:
  - Read `source_list` and `source` from entity attributes
  - Add source button showing current source name
  - On tap, show action sheet with available sources
  - Call `media_player.select_source` with `{source: selected}`
- **Entity accessors needed**: `sourceList`, `currentSource`
- **Lines**: ~40
- **Dependencies**: None

### 2.11 Media Player: Progress Bar with Seek

- **Files**: `HAMediaPlayerEntityCell.m`
- **What**:
  - Read `media_duration` (HAAttrMediaDuration) and `media_position` (HAAttrMediaPosition)
  - Add UISlider or UIProgressView showing position/duration
  - Display formatted time labels (MM:SS)
  - On slider change, call `media_player.media_seek` with `{seek_position: seconds}`
  - Update position periodically (timer or on state update)
- **Lines**: ~70
- **Dependencies**: None

### 2.12 Media Player: Shuffle and Repeat

- **Files**: `HAMediaPlayerEntityCell.m`
- **What**:
  - Add shuffle button (toggle, highlighted when active)
  - Add repeat button (cycle: off → all → one)
  - Read `shuffle` and `repeat` attributes
  - Call `media_player.shuffle_set` and `media_player.repeat_set`
- **Lines**: ~40
- **Dependencies**: None

### 2.13 Climate: Preset Mode Selector

- **Files**: `HAClimateEntityCell.m`, `HAThermostatGaugeCell.m`
- **What**:
  - Read `preset_modes` and `preset_mode` from entity attributes (constants exist: need to add to HAEntityAttributes.h or use string literals)
  - Add button showing current preset, action sheet for selection
  - Call `climate.set_preset_mode` with `{preset_mode: selected}`
- **Entity accessors needed**: `presetModes`, `currentPresetMode`
- **Lines**: ~50 per cell × 2 = ~100
- **Dependencies**: None

### 2.14 Climate: Fan Mode Selector

- **Files**: `HAClimateEntityCell.m`, `HAThermostatGaugeCell.m`
- **What**:
  - Read `fan_modes` (HAAttrFanModes) and `fan_mode` (HAAttrFanMode)
  - Add button showing current fan mode, action sheet for selection
  - Call `climate.set_fan_mode` with `{fan_mode: selected}`
- **Lines**: ~50 per cell × 2 = ~100
- **Dependencies**: None

### 2.15 Climate: Swing Mode Selector

- **Files**: `HAClimateEntityCell.m`, `HAThermostatGaugeCell.m`
- **What**:
  - Read `swing_modes` and `swing_mode` from entity attributes
  - Add button for selection
  - Call `climate.set_swing_mode` with `{swing_mode: selected}`
- **Entity accessors needed**: `swingModes`, `currentSwingMode`
- **Lines**: ~50 per cell × 2 = ~100
- **Dependencies**: None

### 2.16 Climate: Dual Setpoint (target_temp_high / target_temp_low)

- **Files**: `HAClimateEntityCell.m`, `HAThermostatGaugeCell.m`, `HAEntity.m`
- **What**:
  - Read `target_temp_high` and `target_temp_low` attributes
  - When HVAC mode is `heat_cool`, show two steppers/sliders instead of one
  - Call `climate.set_temperature` with `{target_temp_high: h, target_temp_low: l}`
  - On thermostat gauge, show two thumb positions on the arc
- **Entity accessors needed**: `targetTemperatureHigh`, `targetTemperatureLow`
- **Lines**: ~80 (compact cell) + ~120 (gauge cell) + ~10 (entity) = ~210
- **Dependencies**: None

### 2.17 Climate: Humidity Control

- **Files**: `HAThermostatGaugeCell.m`
- **What**:
  - Read `humidity` (current) and `target_humidity` from climate entity attributes
  - Add humidity display and slider if target_humidity is supported
  - Call `climate.set_humidity` with `{humidity: value}`
- **Lines**: ~40
- **Dependencies**: None

### 2.18 Climate: Aux Heat Toggle

- **Files**: `HAClimateEntityCell.m`
- **What**:
  - Read `aux_heat` attribute (on/off)
  - Add toggle switch for auxiliary heater
  - Call `climate.set_aux_heat` with `{aux_heat: on/off}`
- **Lines**: ~20
- **Dependencies**: None

### 2.19 Climate: Turn On/Off

- **Files**: `HAClimateEntityCell.m`
- **What**:
  - Add power toggle button
  - Call `climate.turn_on` / `climate.turn_off`
- **Lines**: ~15
- **Dependencies**: None

### 2.20 Cover: Position Slider

- **Files**: `HACoverEntityCell.m`
- **What**:
  - Replace position label with interactive UISlider (0-100%)
  - On touch-up, call `cover.set_cover_position` with `{position: value}`
  - Debounce on touch-up
- **Lines**: ~30
- **Dependencies**: None

### 2.21 Cover: Tilt Controls (6 services)

- **Files**: `HACoverEntityCell.m`, `HAEntity.m`
- **What**:
  - Read `current_tilt_position` (HAAttrCurrentTiltPosition, already defined)
  - Add tilt position slider (0-100%)
  - Add open_tilt/close_tilt/stop_tilt buttons
  - Services: `cover.set_cover_tilt_position`, `cover.open_cover_tilt`, `cover.close_cover_tilt`, `cover.stop_cover_tilt`, `cover.toggle_tilt`
  - Only show tilt controls if `current_tilt_position` attribute exists
- **Entity accessor needed**: `coverTiltPosition`
- **Lines**: ~60
- **Dependencies**: None

### 2.22 Cover: Device Class Icons

- **Files**: `HAEntityDisplayHelper.m`
- **What**:
  - Read `device_class` from cover entity (blind, door, garage, gate, shutter, window, etc.)
  - Map each device_class to appropriate MDI icon (mdi:blinds, mdi:door, mdi:garage, etc.)
  - Override default cover icon with device_class-specific icon
- **Lines**: ~20
- **Dependencies**: None

### 2.23 Cover: Toggle Service

- **Files**: `HACoverEntityCell.m`
- **What**:
  - Add toggle button that calls `cover.toggle`
  - Alternative to separate open/close buttons
- **Lines**: ~10
- **Dependencies**: None

---

## Wave 3 — Medium-Impact Entity Controls

### 3.1 Alarm: arm_night Button

- **Files**: `HAAlarmEntityCell.m`
- **What**:
  - Add "Arm Night" button alongside existing arm_away/arm_home buttons
  - Call `alarm_control_panel.alarm_arm_night` with optional code
- **Lines**: ~15
- **Dependencies**: None

### 3.2 Alarm: arm_vacation Button

- **Files**: `HAAlarmEntityCell.m`
- **What**:
  - Add "Arm Vacation" button
  - Call `alarm_control_panel.alarm_arm_vacation` with optional code
  - May need to use horizontal scroll for button row if too many buttons
- **Lines**: ~15
- **Dependencies**: None

### 3.3 Alarm: arm_custom_bypass

- **Files**: `HAAlarmEntityCell.m`
- **What**:
  - Add "Bypass" button
  - Call `alarm_control_panel.alarm_arm_custom_bypass` with optional code
- **Lines**: ~15
- **Dependencies**: 3.1, 3.2 (button row layout must accommodate)

### 3.4 Alarm: code_arm_required Awareness

- **Files**: `HAAlarmEntityCell.m`
- **What**:
  - Read `code_arm_required` attribute (HAAttrCodeArmRequired, already defined)
  - When false, hide code field for arm actions (only show for disarm)
  - When true (default), show code field for all actions
- **Lines**: ~15
- **Dependencies**: None

### 3.5 Alarm: Text Code Format

- **Files**: `HAAlarmEntityCell.m`
- **What**:
  - Currently only supports numeric keypad
  - When `code_format` is "text", show full keyboard text field instead of numeric keypad
- **Lines**: ~20
- **Dependencies**: None

### 3.6 Fan: Preset Mode Selector

- **Files**: `HAFanEntityCell.m`
- **What**:
  - Read `preset_modes` from entity (accessor exists: `fanPresetModes`)
  - Replace preset label with tappable button showing current preset
  - On tap, show action sheet with available presets
  - Call `fan.set_preset_mode` with `{preset_mode: selected}`
- **Lines**: ~30
- **Dependencies**: None

### 3.7 Fan: Oscillate Toggle

- **Files**: `HAFanEntityCell.m`
- **What**:
  - Read `oscillating` attribute (HAAttrOscillating, already defined)
  - Add oscillation toggle button (wave icon)
  - Call `fan.oscillate` with `{oscillating: true/false}`
- **Lines**: ~20
- **Dependencies**: None

### 3.8 Fan: Direction Control

- **Files**: `HAFanEntityCell.m`
- **What**:
  - Read `direction` attribute (HAAttrDirection, already defined)
  - Add direction toggle button (forward ⟳ / reverse ⟲)
  - Call `fan.set_direction` with `{direction: "forward"/"reverse"}`
- **Lines**: ~20
- **Dependencies**: None

### 3.9 Fan: Increase/Decrease Speed

- **Files**: `HAFanEntityCell.m`
- **What**:
  - Add +/- speed step buttons alongside slider
  - Call `fan.increase_speed` / `fan.decrease_speed`
- **Lines**: ~20
- **Dependencies**: None

### 3.10 Humidifier: Mode Selector

- **Files**: `HAHumidifierEntityCell.m`, `HAEntity.m`
- **What**:
  - Read `available_modes` (HAAttrAvailableModes, already defined) and current mode
  - Add button showing current mode, action sheet for selection
  - Call `humidifier.set_mode` with `{mode: selected}`
- **Entity accessor needed**: `humidifierMode`, `humidifierAvailableModes`
- **Lines**: ~40
- **Dependencies**: None

### 3.11 Humidifier: Current Humidity Display

- **Files**: `HAHumidifierEntityCell.m`
- **What**:
  - Read `current_humidity` (HAAttrCurrentHumidity, already defined)
  - Display as label alongside target humidity: "Current: 45% → Target: 50%"
- **Lines**: ~10
- **Dependencies**: None

### 3.12 Humidifier: Action Display

- **Files**: `HAHumidifierEntityCell.m`
- **What**:
  - Read `action` attribute (humidifying/drying/idle/off)
  - Display current action as secondary text
- **Lines**: ~10
- **Dependencies**: None

### 3.13 Vacuum: Fan Speed Control

- **Files**: `HAVacuumEntityCell.m`
- **What**:
  - Read `fan_speed` (HAAttrFanSpeed) and `fan_speed_list` (HAAttrFanSpeedList)
  - Add speed selector button/dropdown
  - Call `vacuum.set_fan_speed` with `{fan_speed: selected}`
- **Lines**: ~35
- **Dependencies**: None

### 3.14 Vacuum: Locate

- **Files**: `HAVacuumEntityCell.m`
- **What**:
  - Add "Locate" button (🔔 icon)
  - Call `vacuum.locate`
  - Check supported_features bitmask before showing
- **Lines**: ~15
- **Dependencies**: None

### 3.15 Vacuum: Stop and Clean Spot

- **Files**: `HAVacuumEntityCell.m`
- **What**:
  - Add "Stop" button → `vacuum.stop`
  - Add "Spot Clean" button → `vacuum.clean_spot`
  - Check supported_features for each
- **Lines**: ~20
- **Dependencies**: None

### 3.16 Lock: Open (Unlatch)

- **Files**: `HALockEntityCell.m`
- **What**:
  - Add "Open" button for door unlatch
  - Call `lock.open`
  - Only show if entity supports open action (check supported_features)
- **Lines**: ~15
- **Dependencies**: None

### 3.17 Lock: Code Format Support

- **Files**: `HALockEntityCell.m`
- **What**:
  - Read `code_format` attribute
  - When set, show code entry field before lock/unlock
  - Send code with lock/unlock service calls
- **Lines**: ~30
- **Dependencies**: None

---

## Wave 4 — Lower-Impact Completeness

### 4.1 Sensor/Binary Sensor: Device Class Icon Selection

- **Files**: `HAEntityDisplayHelper.m`
- **What**:
  - Read `device_class` from sensor/binary_sensor entities
  - Map 60+ device_classes to appropriate MDI icons:
    - temperature → mdi:thermometer
    - humidity → mdi:water-percent
    - motion → mdi:motion-sensor
    - door → mdi:door-open / mdi:door-closed (based on state)
    - battery → mdi:battery (with level variants)
    - etc.
  - Override default sensor/binary_sensor icon
- **Lines**: ~100 (mapping table)
- **Dependencies**: None

### 4.2 Person: Entity Picture

- **Files**: `HAPersonEntityCell.m`
- **What**:
  - Read `entity_picture` attribute
  - Show circular avatar image instead of/alongside location text
  - Load async with auth header
- **Lines**: ~40
- **Dependencies**: None

### 4.3 Person: GPS Display

- **Files**: `HAPersonEntityCell.m`
- **What**:
  - Read `latitude`, `longitude`, `gps_accuracy` from attributes
  - Display coordinates as secondary text (or link to map)
- **Lines**: ~15
- **Dependencies**: None

### 4.4 Input Number: mode="box" Rendering

- **Files**: `HAInputNumberEntityCell.m`
- **What**:
  - Read `mode` attribute (HAAttrMode, already defined)
  - When mode is "box", show text input field instead of slider
  - Validate numeric input, enforce min/max/step
- **Lines**: ~40
- **Dependencies**: None

### 4.5 Script: turn_off

- **Files**: `HASceneEntityCell.m`
- **What**:
  - For script entities, add "Stop" button
  - Call `script.turn_off`
- **Lines**: ~15
- **Dependencies**: None

### 4.6 Automation: trigger

- **Files**: `HASwitchEntityCell.m` (automation uses switch cell)
- **What**:
  - For automation entities, add "Trigger" button (run now without conditions)
  - Call `automation.trigger`
- **Lines**: ~20
- **Dependencies**: None

### 4.7 Weather: Visibility

- **Files**: `HAWeatherEntityCell.m`
- **What**:
  - Read `visibility` attribute
  - Add to details display row
- **Lines**: ~5
- **Dependencies**: None

### 4.8 Weather: UV Index

- **Files**: `HAWeatherEntityCell.m`
- **What**:
  - Read `uv_index` attribute
  - Add to details display row
- **Lines**: ~5
- **Dependencies**: None

### 4.9 Weather: Precipitation

- **Files**: `HAWeatherEntityCell.m`
- **What**:
  - Read `precipitation` attribute
  - Add to details display row
- **Lines**: ~5
- **Dependencies**: None

### 4.10 Weather: Dew Point and Cloud Coverage

- **Files**: `HAWeatherEntityCell.m`
- **What**:
  - Read `dew_point` and `cloud_coverage` attributes
  - Add to details display or show on tap
- **Lines**: ~10
- **Dependencies**: None

### 4.11 Light: min/max Mireds (Legacy)

- **Files**: `HAEntity.m`
- **What**:
  - Add accessors for `min_mireds`, `max_mireds` (legacy color temp range)
  - Convert to Kelvin if `min_color_temp_kelvin` not available
- **Lines**: ~10
- **Dependencies**: 2.1

### 4.12 Light: Transition Parameter

- **Files**: `HALightEntityCell.m`
- **What**:
  - Add `transition` parameter to turn_on/turn_off calls if configured
  - Read from card config or a default setting
- **Lines**: ~10
- **Dependencies**: None

### 4.13 Counter: minimum/maximum Enforcement

- **Files**: `HACounterEntityCell.m`
- **What**:
  - Read `minimum` and `maximum` attributes (HAAttrMinimum/HAAttrMaximum, already defined)
  - Disable increment button at maximum, decrement at minimum
- **Lines**: ~10
- **Dependencies**: None

### 4.14 Counter: step and set_value

- **Files**: `HACounterEntityCell.m`
- **What**:
  - Read `step` attribute, use for increment/decrement calls
  - Add `counter.set_value` support (long-press on value to edit)
- **Lines**: ~20
- **Dependencies**: None

### 4.15 Update: release_url, release_summary, skip

- **Files**: `HAUpdateEntityCell.m`
- **What**:
  - Read `release_url` (HAAttrReleaseURL) → add "Release Notes" button → open URL
  - Read `release_summary` (HAAttrReleaseSummary) → display below version
  - Add "Skip" button → call `update.skip`
- **Lines**: ~30
- **Dependencies**: None

### 4.16 Update: in_progress

- **Files**: `HAUpdateEntityCell.m`
- **What**:
  - Read `in_progress` attribute
  - Show progress indicator during install
  - Disable install button while in progress
- **Lines**: ~15
- **Dependencies**: None

### 4.17 Timer: finish and change

- **Files**: `HATimerEntityCell.m`
- **What**:
  - Add "Finish" button → `timer.finish`
  - Add "Change" button → `timer.change` with duration parameter (show time picker)
- **Lines**: ~30
- **Dependencies**: None

### 4.18 Camera: Live Streaming

- **Files**: `HACameraEntityCell.m`
- **What**:
  - Read `stream_source` attribute
  - When available and camera_view is "live", use AVPlayer for HLS stream
  - Fall back to snapshot refresh when streaming unavailable
- **Lines**: ~80
- **Dependencies**: None

### 4.19 Camera: turn_on/turn_off and snapshot

- **Files**: `HACameraEntityCell.m`
- **What**:
  - Add power toggle for camera
  - Add snapshot button → `camera.snapshot`
- **Lines**: ~20
- **Dependencies**: None

---

## Wave 5 — New Entity Domains

### 5.1 Valve (Cover-Like Cell)

- **Files**: New `HAValveEntityCell.h/.m`, `HAEntityCellFactory.m`, `HAEntity.h`
- **What**:
  - Reuse cover cell pattern: open/close/stop buttons + position slider
  - Read: state, current_position
  - Services: `valve.open_valve`, `valve.close_valve`, `valve.stop_valve`, `valve.set_valve_position`, `valve.toggle`
  - Add domain constant `HAEntityDomainValve`
- **Lines**: ~120 (mostly adapting HACoverEntityCell)
- **Dependencies**: None

### 5.2 Water Heater (Dedicated Cell)

- **Files**: New `HAWaterHeaterEntityCell.h/.m`, `HAEntityCellFactory.m`, `HAEntity+WaterHeater.h/.m` (may already exist)
- **What**:
  - Temperature display (current + target) with stepper
  - Operation mode selector (action sheet from `operation_list`)
  - Away mode toggle
  - Services: `water_heater.set_temperature`, `water_heater.set_operation_mode`, `water_heater.turn_away_mode_on/off`, `water_heater.turn_on/off`
- **Lines**: ~180
- **Dependencies**: None

### 5.3 Lawn Mower

- **Files**: New `HALawnMowerEntityCell.h/.m`, `HAEntityCellFactory.m`
- **What**:
  - Status display (mowing/docked/paused/error)
  - Command buttons: Start/Pause, Dock
  - Services: `lawn_mower.start_mowing`, `lawn_mower.pause`, `lawn_mower.dock`
  - Reuse vacuum cell pattern
- **Lines**: ~100
- **Dependencies**: None

### 5.4 Device Tracker

- **Files**: Map to `HAPersonEntityCell` or new cell
- **What**:
  - Display state (home/not_home/zone_name)
  - Show source_type attribute
  - Same pattern as person entity
- **Lines**: ~10 (add domain routing to person cell)
- **Dependencies**: None

### 5.5 Remote

- **Files**: New `HARemoteEntityCell.h/.m`, `HAEntityCellFactory.m`
- **What**:
  - On/off toggle
  - Send command button → `remote.send_command`
  - Activity selector from activity_list
  - Services: `remote.turn_on/off`, `remote.send_command`, `remote.learn_command`
- **Lines**: ~100
- **Dependencies**: None

### 5.6 Image

- **Files**: New `HAImageEntityCell.h/.m`, `HAEntityCellFactory.m`
- **What**:
  - Display entity_picture URL as image
  - Load async with auth header
  - Tap to view fullscreen
- **Lines**: ~80
- **Dependencies**: None

### 5.7 Todo

- **Files**: New `HATodoEntityCell.h/.m`, `HAEntityCellFactory.m`
- **What**:
  - Display todo item count from state
  - Requires WebSocket subscription to `todo/item/list`
  - Interactive checklist with add/complete/delete
  - Services: `todo.add_item`, `todo.update_item`, `todo.remove_item`
- **Lines**: ~250 (complex interactive list)
- **Dependencies**: WebSocket subscription for item list

### 5.8 Text (vs input_text)

- **Files**: `HAEntityCellFactory.m`
- **What**:
  - Route `text` domain to HAInputTextEntityCell (same UI)
  - Service: `text.set_value` instead of `input_text.set_value`
- **Lines**: ~5
- **Dependencies**: None

### 5.9 Event

- **Files**: New `HAEventEntityCell.h/.m` or map to base cell
- **What**:
  - Display last event type and timestamp
  - Read `event_type` and `event_types` attributes
  - Read-only display (events are triggered externally)
- **Lines**: ~40
- **Dependencies**: None

### 5.10 Date / Time (Separate Domains)

- **Files**: `HAEntityCellFactory.m`
- **What**:
  - Route `date` and `time` domains to HAInputDateTimeEntityCell
  - Services: `date.set_value`, `time.set_value`
  - `date` → date picker mode, `time` → time picker mode
- **Lines**: ~10
- **Dependencies**: None

### 5.11 Sun

- **Files**: Map to `HASensorEntityCell` or base cell
- **What**:
  - Display state (above_horizon / below_horizon)
  - Show next_rising and next_setting as secondary info
  - Read-only
- **Lines**: ~10 (domain routing)
- **Dependencies**: None

### 5.12 Group

- **Files**: Map to appropriate cell based on group type, or HAEntitiesCardCell
- **What**:
  - Groups contain entity_id list
  - If group has a domain (light group, cover group), render as that domain
  - Toggle all entities in group
  - Services: `homeassistant.turn_on/off/toggle` with group entity_id
- **Lines**: ~30
- **Dependencies**: None

---

## Total Estimates

| Wave | Tasks | Estimated Lines | Description |
|---|---|---|---|
| Wave 1 | 8 tasks | ~500 lines | Cross-domain systemic |
| Wave 2 | 23 tasks | ~1,600 lines | High-impact controls |
| Wave 3 | 17 tasks | ~400 lines | Medium-impact controls |
| Wave 4 | 19 tasks | ~500 lines | Completeness |
| Wave 5 | 12 tasks | ~935 lines | New domains |
| **Total** | **79 tasks** | **~3,935 lines** | |

---

## Dependency Graph

Most tasks are independent. Key dependencies:

```
1.5 (format helper) ← 1.2 (secondary_info), 1.4 (state_content)
2.1 (color_temp) ← 2.5 (remaining color modes), 4.11 (mireds)
2.2 (color picker) ← 2.5 (remaining color modes)
3.1 + 3.2 (alarm buttons) ← 3.3 (bypass — layout must accommodate all buttons)
```

All other tasks can be implemented in any order within their wave.

---

## Task Status Tracker

### Wave 1 — Cross-Domain Systemic Fixes

| Task | Description | Status | Commit/Note |
|---|---|---|---|
| 1.1 | state_color on entity rows | ✅ Done | `86d1748` |
| 1.2 | secondary_info on entity rows | ✅ Done | `b25df77` |
| 1.3 | attribute display | ✅ Done | `6aa30b3` (Agent D) |
| 1.4 | state_content on tile cards | ✅ Done | `6c48c30` (Agent D) |
| 1.5 | format (relative/total/date/time) | ✅ Done | `8fac9c7` |
| 1.6 | show_entity_picture on tiles | ✅ Done | `e26b3bd` (Agent D) |
| 1.7 | vertical layout on tiles | ✅ Done | Pre-existing in tile compact mode |
| 1.8 | hide_state on tiles | ✅ Done | `a3e7e09` (Agent D) |

### Wave 2 — High-Impact Entity Controls

| Task | Description | Status | Commit/Note |
|---|---|---|---|
| 2.1 | Light: color temp slider | ✅ Done | `f505fb9` (Agent D) |
| 2.2 | Light: RGB color picker | ✅ Done | `c24fe68` (Agent D, color picker in detail) |
| 2.3 | Light: effects selector | ✅ Done | `c24fe68` (Agent D) |
| 2.4 | Light: color mode display | ✅ Done | `c24fe68` (Agent D) |
| 2.5 | Light: remaining color modes | ✅ Done | `20bb9cd` (Agent D) |
| 2.6 | Light: transition + flash | ✅ Done | `b01d337` (Agent D, flash in detail) |
| 2.7 | Media player: volume slider | ✅ Done | `490b375` |
| 2.8 | Media player: volume mute | ✅ Done | `490b375` |
| 2.9 | Media player: album art | ✅ Done | `7ff70b4` |
| 2.10 | Media player: source selector | ✅ Done | `a4fa433` |
| 2.11 | Media player: progress bar | ⚠️ PARTIAL | `a4fa433` (read-only UIProgressView); seek interaction DEFERRED. See [deferred-items.md](deferred-items.md) |
| 2.12 | Media player: shuffle/repeat | ✅ Done | `a4fa433` |
| 2.13 | Climate: preset modes | ✅ Done | `3fa0e52` (Agent D) |
| 2.14 | Climate: fan modes | ✅ Done | `3fa0e52` (Agent D) |
| 2.15 | Climate: swing modes | ✅ Done | `3fa0e52` (Agent D) |
| 2.16 | Climate: dual setpoint | ✅ Done | `32f91e3` (Agent D) |
| 2.17 | Climate: humidity | ✅ Done | `ab7f922` (Agent D) |
| 2.18 | Climate: aux heat | ✅ Done | `f28f773` (Agent D) |
| 2.19 | Climate: turn on/off | ✅ Done | Pre-existing via HVAC mode "off" button |
| 2.20 | Cover: position slider | ✅ Done | `051f937` (Agent D) |
| 2.21 | Cover: tilt controls | ✅ Done | `051f937` (Agent D) |
| 2.22 | Cover: device class icons | ✅ Done | Pre-existing in HAEntityDisplayHelper |
| 2.23 | Cover: toggle service | ✅ Done | Pre-existing in toggleService |

### Wave 3 — Medium-Impact Entity Controls

| Task | Description | Status | Commit/Note |
|---|---|---|---|
| 3.1 | Alarm: arm_night | ✅ Done | `698386f` (Agent D) |
| 3.2 | Alarm: arm_vacation | ✅ Done | `698386f` (Agent D) |
| 3.3 | Alarm: arm_custom_bypass | ✅ Done | `e96a877` (Agent D) |
| 3.4 | Alarm: code_arm_required | ✅ Done | `698386f` (Agent D) |
| 3.5 | Alarm: text code format | ✅ Done | `0f9df85` (Agent D) |
| 3.6 | Fan: preset selector | ✅ Done | `78036f6` (Agent D) |
| 3.7 | Fan: oscillate toggle | ✅ Done | `78036f6` (Agent D) |
| 3.8 | Fan: direction control | ✅ Done | `78036f6` (Agent D) |
| 3.9 | Fan: increase/decrease speed | ✅ Done | Pre-existing via fan speed slider |
| 3.10 | Humidifier: mode selector | ✅ Done | `517fb14` (Agent D) |
| 3.11 | Humidifier: current humidity | ✅ Done | `517fb14` (Agent D) |
| 3.12 | Humidifier: action display | ✅ Done | `517fb14` (Agent D) |
| 3.13 | Vacuum: fan speed | ✅ Done | `15f1dab` (Agent D) |
| 3.14 | Vacuum: locate | ✅ Done | `15f1dab` (Agent D) |
| 3.15 | Vacuum: stop + clean spot | ✅ Done | `15f1dab` (Agent D) |
| 3.16 | Lock: open (unlatch) | ✅ Done | `25abd68` (Agent D) |
| 3.17 | Lock: code format support | ✅ Done | `173ff74` (Agent D) |

### Wave 4 — Lower-Impact Completeness

| Task | Description | Status | Commit/Note |
|---|---|---|---|
| 4.1 | Sensor/binary_sensor device class icons | ✅ Done | `e303d24` (wired binary_sensor mapping) |
| 4.2 | Person: entity picture | ✅ Done | `0e6cb93` (Agent D) |
| 4.3 | Person: GPS display | ✅ Done | Pre-existing (zone name shown) |
| 4.4 | Input number: mode="box" | ✅ Done | `0b206da` (Agent D) |
| 4.5 | Script: turn_off | ✅ Done | `e642329` (Agent D) |
| 4.6 | Automation: trigger | ✅ Done | `e642329` (Agent D) |
| 4.7 | Weather: visibility | ✅ Done | `1ea9304` |
| 4.8 | Weather: UV index | ✅ Done | `1ea9304` |
| 4.9 | Weather: precipitation/dew/cloud | ✅ Done | `1ea9304` |
| 4.10 | Weather: dew point + cloud coverage | ✅ Done | `1ea9304` |
| 4.11 | Light: min/max mireds fallback | ✅ Done | `ae5ea75` |
| 4.12 | Light: transition parameter | ✅ Done | `b01d337` (Agent D, flash/transition in detail) |
| 4.13 | Counter: min/max enforcement | ✅ Done | `7a45281` (Agent D) |
| 4.14 | Counter: step + set_value | ✅ Done | HA service handles step internally; `7a45281` |
| 4.15 | Update: release_url, summary, skip | ✅ Done | `f8688f3` + `ace263b` (Agent D, in_progress) |
| 4.16 | Update: in_progress | ✅ Done | `ace263b` (Agent D) |
| 4.17 | Timer: finish + change | ⚠️ PARTIAL | `c8c64e1` (finish implemented); `timer.change` DEFERRED — needs duration picker UI. See [deferred-items.md](deferred-items.md) |
| 4.18 | Camera: live streaming | 🔶 DEFERRED | Requires AVPlayer/HLS integration — separate epic. Snapshot refresh works. See [deferred-items.md](deferred-items.md) |
| 4.19 | Camera: turn_on/off + snapshot | ✅ Done | `d3bc3ca` (Agent D) |

### Wave 5 — New Entity Domains

| Task | Description | Status | Commit/Note |
|---|---|---|---|
| 5.1 | Valve | ✅ Done | `d253048` (via cover cell, domain-aware services) |
| 5.2 | Water heater | ✅ Done | `f5763d6` (Agent D, dedicated cell) |
| 5.3 | Lawn mower | ✅ Done | `74a00d3` (via vacuum cell, domain-aware services) |
| 5.4 | Device tracker | ✅ Done | `cf8e1a6` (routed to person cell) |
| 5.5 | Remote | ✅ Done | `4e0ab98` (Agent D, dedicated cell) |
| 5.6 | Image | ✅ Done | `4e0ab98` (Agent D, dedicated cell) |
| 5.7 | Todo | ✅ Done | `a8fe737` (Agent D, item count display) |
| 5.8 | Text (vs input_text) | ✅ Done | `a2d232b` (Agent D, routed to input_text cell) |
| 5.9 | Event | ✅ Done | `eee97e7` (routed to sensor cell) |
| 5.10 | Date / Time | ✅ Done | `a2d232b` (Agent D, routed to input_datetime cell) |
| 5.11 | Sun | ✅ Done | `a2d232b` (Agent D, routed to sensor cell) |
| 5.12 | Group | ✅ Done | `eee97e7` (routed to switch cell) |

---

## Additional Card Types Implemented (Beyond Original Sprint)

| Card Type | Status | Commit/Note |
|---|---|---|
| Glance card | ✅ Done | HAGlanceCardCell (Agent C) |
| Entity card (singular) | ✅ Done | `c8beda0` HAEntityCardCell |
| Statistic card | ✅ Done | `10e5688` HAStatisticCardCell |
| Statistics graph card | ✅ Done | `0205ee0` routed to graph cell |
| Markdown card | ✅ Done | `6c44dec` HAMarkdownCardCell |
| Area card | ✅ Done | `6c5a054` (Agent D) |
| Picture glance card | ✅ Done | `6c5a054` (Agent D) |
| Map card | ✅ Done | `6c5a054` (Agent D) |
| Sensor card (with graph) | ✅ Done | `7dd9619` (Agent D, routed to graph cell) |
| Entity filter card | ✅ Done | `d3f4c6f` (Agent D) |
| Activity/logbook card | ✅ Done | `af9a980` (Agent D) |

---

## Deferred Items

### Camera HLS Live Streaming (Task 4.18)

**Status**: Deferred — dedicated feature, not a parity task.

**Reason**: Live camera streaming requires AVPlayer integration with HLS (HTTP Live Streaming) via HA's `/api/camera_proxy_stream/<entity_id>` endpoint. This is a significant feature requiring:
- AVPlayer setup with auth headers
- Stream error handling and reconnection
- Battery/performance considerations (continuous video decode)
- `camera_view: live` config support
- Fallback to snapshot refresh when streaming unavailable

This should be tracked as a separate epic rather than a parity sprint task. The current snapshot-refresh approach (5-second intervals) provides adequate camera monitoring for dashboard use.

### Timer Change Duration (Task 4.17 partial)

**Status**: Deferred — `timer.finish` implemented, `timer.change` needs a duration picker UI.

**Reason**: The `timer.change` service requires a duration parameter (HH:MM:SS format). Implementing this requires a custom time picker UI component. The existing timer cell has start/pause/cancel/finish — the change service is a power-user feature that can be added later.

### Statistics API Integration (Tasks 2 + 3 — Statistic and Statistics Graph cards)

**Status**: Partial — cards render with current entity state as fallback.

**Reason**: The statistic card and statistics graph card are rendered but display current entity state rather than historical statistical aggregations (min/max/mean/change). Full support requires:
- WebSocket call to `recorder/statistics_during_period`
- Period parsing (calendar, rolling window, fixed)
- Caching of statistical data
- Periodic refresh

The cards are recognized and render correctly — they just show current data instead of computed statistics.
