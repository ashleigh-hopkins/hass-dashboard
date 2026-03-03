# Entity Field Parity Audit

**Status**: Post-Sprint (Updated 2026-03-03)
**Created**: 2026-03-01
**Author**: Agent C (initial), Agent B (post-sprint update)
**Sprint**: 80+ commits, 79/79 parity tasks addressed (72 implemented, 4 pre-existing, 3 deferred)

> **Verification note (2026-03-03)**: Code existence verified for all ✅ items via grep/build. Visual rendering partially verified via simulator audit — some features (state_color, secondary_info, attribute override, state_content, show_entity_picture, vertical, hide_state, light color_temp/effects) have working code but are **not exercised by the demo dashboard**. These require a parity showcase demo section or real HA testing to confirm visual correctness. See [deferred-items.md](deferred-items.md) §7 for the full list.

Comprehensive per-entity-domain audit of every HA attribute/field versus our app's support. Each table covers attributes displayed, services called, and controls provided.

**Legend**: ✅ Supported | ⚠️ Partial | ❌ Not supported | ➖ N/A (not applicable to native app)

---

## Cross-Domain Display Options

| HA Field | Default (tile) | Default (button) | Default (entity row) | Default (glance) | Our Support | Commit |
|---|---|---|---|---|---|---|
| `show_state` | true | **false** | true | true | ✅ Supported | Pre-existing |
| `show_name` | true | true | true | true | ✅ Supported | Pre-existing |
| `show_icon` | true | true | true | true | ✅ Supported | Pre-existing |
| `name` override | — | — | — | — | ✅ Supported | Pre-existing |
| `icon` override | — | — | — | — | ✅ Supported | Pre-existing |
| `icon_height` | auto | auto | — | — | ✅ Supported | Pre-existing |
| `color` override | state | state | — | — | ⚠️ Partial | Pre-existing |
| `state_color` | — | — | false | true | ✅ Supported | `86d1748` |
| `secondary_info` | — | — | see below | — | ✅ Supported | `b25df77` |
| `attribute` display | — | — | optional | — | ✅ Supported | `6aa30b3` |
| `format` (time) | — | — | optional | — | ✅ Supported | `8fac9c7` |
| `state_content` | optional | — | — | — | ✅ Supported | `6c48c30` |
| `show_entity_picture` | false | — | — | — | ✅ Supported | `e26b3bd` |
| `vertical` | false | — | — | — | ✅ Supported | `eff7077` |
| `hide_state` | false | — | — | — | ✅ Supported | `a3e7e09` |
| `theme` override | — | — | — | — | ➖ N/A | Our own theme system |

### secondary_info Values (Entity Rows)

| Value | Description | Our Support | Commit |
|---|---|---|---|
| `entity-id` | Show entity ID | ✅ Supported | `b25df77` |
| `last-changed` | Relative time since last state change | ✅ Supported | `b25df77` |
| `last-updated` | Relative time since last update | ✅ Supported | `b25df77` |
| `last-triggered` | Last automation/script trigger time | ✅ Supported | `b25df77` |
| `position` | Cover position percentage | ✅ Supported | `b25df77` |
| `tilt-position` | Cover tilt percentage | ✅ Supported | `b25df77` |
| `brightness` | Light brightness percentage | ✅ Supported | `b25df77` |

---

## light

**Cell**: HALightEntityCell (toggle + brightness + color temp + effects), HATileEntityCell (features), Detail: HAColorWheelView

| HA Field/Attribute | Our Support | Commit | Notes |
|---|---|---|---|
| state (on/off) | ✅ | Pre-existing | UISwitch |
| brightness (0-255) | ✅ | Pre-existing | Slider 0-100% |
| color_temp_kelvin | ✅ | `f505fb9` | Warm-cool slider in cell |
| color_temp (mireds) | ✅ | `ae5ea75` | Fallback conversion to kelvin |
| rgb_color | ✅ | Pre-existing | HAColorWheelView in detail |
| rgbw_color | ✅ | `20bb9cd` | Accessor + display |
| rgbww_color | ✅ | `20bb9cd` | Accessor |
| xy_color | ✅ | `20bb9cd` | Accessor |
| hs_color | ✅ | Pre-existing | Color wheel uses hs_color |
| color_mode | ✅ | `c24fe68` | Displayed below name |
| supported_color_modes | ✅ | `20bb9cd` | Controls color temp/wheel visibility |
| effect | ✅ | `c24fe68` | Shown on effects button |
| effect_list | ✅ | `c24fe68` | Action sheet selector |
| min/max_color_temp_kelvin | ✅ | `f505fb9` | Slider range |
| min/max_mireds | ✅ | `ae5ea75` | Fallback conversion |
| transition | ❌ | — | Deferred (config-level param) |
| flash | ✅ | `b01d337` | Flash button in detail view |
| **Services** | | | |
| light.turn_on | ✅ | Multiple | With brightness/color_temp/hs_color/effect params |
| light.turn_off | ✅ | Pre-existing | |
| light.toggle | ✅ | Pre-existing | |

---

## climate

**Cell**: HAClimateEntityCell (compact), HAThermostatGaugeCell (full thermostat)

| HA Field/Attribute | Our Support | Commit | Notes |
|---|---|---|---|
| state (hvac mode) | ✅ | Pre-existing | |
| current_temperature | ✅ | Pre-existing | |
| target_temperature | ✅ | Pre-existing | Stepper + gauge drag |
| target_temp_high | ✅ | `32f91e3` | Dual setpoint mode |
| target_temp_low | ✅ | `32f91e3` | Dual setpoint mode |
| hvac_modes | ✅ | Pre-existing | Mode button bar |
| hvac_action | ✅ | Pre-existing | |
| preset_mode | ✅ | `3fa0e52` | Selector on gauge |
| preset_modes | ✅ | `3fa0e52` | Action sheet |
| fan_mode | ✅ | `3fa0e52` | Selector on gauge |
| fan_modes | ✅ | `3fa0e52` | Action sheet |
| swing_mode | ✅ | `3fa0e52` | Selector on gauge |
| swing_modes | ✅ | `3fa0e52` | Action sheet |
| humidity | ✅ | `ab7f922` | Displayed on gauge |
| target_humidity | ✅ | `ab7f922` | Displayed on gauge |
| min_temp / max_temp | ✅ | `98989fb` | Stepper/gauge bounds |
| target_temp_step | ✅ | `98989fb` | From entity attributes |
| aux_heat | ✅ | `f28f773` | Toggle in detail |
| **Services** | | | |
| climate.set_temperature | ✅ | Multiple | Single + dual setpoint |
| climate.set_hvac_mode | ✅ | Pre-existing | |
| climate.set_preset_mode | ✅ | `3fa0e52` | |
| climate.set_fan_mode | ✅ | `3fa0e52` | |
| climate.set_swing_mode | ✅ | `3fa0e52` | |
| climate.set_humidity | ✅ | `ab7f922` | |
| climate.turn_on/off | ✅ | Via HVAC mode buttons | Off mode = turn off |

---

## cover

**Cell**: HACoverEntityCell (buttons + position + tilt)

| HA Field/Attribute | Our Support | Commit | Notes |
|---|---|---|---|
| state | ✅ | Pre-existing | |
| current_position | ✅ | `051f937` | Slider control |
| current_tilt_position | ✅ | `051f937` | Tilt slider |
| device_class | ✅ | `e303d24` | Icon mapping |
| supported_features | ✅ | `8888b36` | Filters button visibility |
| **Services** | | | |
| cover.open/close/stop | ✅ | Pre-existing + `8888b36` | Feature-gated |
| cover.set_cover_position | ✅ | `051f937` | Position slider |
| cover.set_cover_tilt_position | ✅ | `051f937` | Tilt slider |
| cover.toggle | ❌ | — | Open/close buttons suffice |
| cover.open/close/stop_cover_tilt | ❌ | — | Tilt slider covers this |

---

## fan

**Cell**: HAFanEntityCell (toggle + speed + presets + oscillate + direction)

| HA Field/Attribute | Our Support | Commit | Notes |
|---|---|---|---|
| state | ✅ | Pre-existing | |
| percentage | ✅ | Pre-existing | Slider |
| preset_mode | ✅ | `78036f6` | Action sheet selector |
| preset_modes | ✅ | `78036f6` | |
| oscillating | ✅ | `78036f6` | Toggle button |
| direction | ✅ | `78036f6` | Forward/reverse button |
| **Services** | | | |
| fan.turn_on/off | ✅ | Pre-existing | |
| fan.set_percentage | ✅ | Pre-existing | |
| fan.set_preset_mode | ✅ | `78036f6` | |
| fan.oscillate | ✅ | `78036f6` | |
| fan.set_direction | ✅ | `78036f6` | |

---

## lock

**Cell**: HALockEntityCell (lock/unlock/open + code entry)

| HA Field/Attribute | Our Support | Commit | Notes |
|---|---|---|---|
| state | ✅ | Pre-existing | All states incl. jammed, locking |
| code_format | ✅ | `173ff74`, `283a66e` | Numeric/text keyboard |
| **Services** | | | |
| lock.lock | ✅ | Pre-existing | With optional code |
| lock.unlock | ✅ | Pre-existing | With optional code |
| lock.open | ✅ | `25abd68`, `283a66e` | Feature bit = 1 |

---

## media_player

**Cell**: HAMediaPlayerEntityCell (full controls)

| HA Field/Attribute | Our Support | Commit | Notes |
|---|---|---|---|
| state | ✅ | Pre-existing | |
| media_title / media_artist | ✅ | Pre-existing | |
| media_album_name | ✅ | Displayed in metadata | |
| media_duration / media_position | ✅ | `a4fa433` | Progress bar |
| volume_level | ✅ | `490b375` | Slider |
| is_volume_muted | ✅ | `490b375` | Mute toggle |
| source / source_list | ✅ | `a4fa433` | Action sheet |
| shuffle | ✅ | `a4fa433` | Toggle button |
| repeat | ✅ | `a4fa433` | Cycle button |
| entity_picture | ✅ | `7ff70b4` | Album art image |
| **Services** | | | |
| media_play_pause | ✅ | Pre-existing | |
| media_previous/next_track | ✅ | Pre-existing | |
| volume_set | ✅ | `490b375` | |
| volume_mute | ✅ | `490b375` | |
| select_source | ✅ | `a4fa433` | |
| shuffle_set | ✅ | `a4fa433` | |
| repeat_set | ✅ | `a4fa433` | |
| media_seek | ❌ | — | Progress bar is display-only |

---

## alarm_control_panel

**Cell**: HAAlarmEntityCell (state + keypad + all arm modes)

| HA Field/Attribute | Our Support | Commit | Notes |
|---|---|---|---|
| state | ✅ | All states | incl. armed_night/vacation |
| code_format | ✅ | `0f9df85` | Number keypad + text keyboard |
| code_arm_required | ✅ | `698386f` | Hides keypad when false |
| **Services** | | | |
| alarm_arm_away | ✅ | Pre-existing | |
| alarm_arm_home | ✅ | Pre-existing | |
| alarm_arm_night | ✅ | `698386f` | |
| alarm_arm_vacation | ✅ | `698386f` | |
| alarm_disarm | ✅ | Pre-existing | |
| alarm_arm_custom_bypass | ✅ | `e96a877` | |

---

## vacuum

**Cell**: HAVacuumEntityCell (status + all command buttons)

| HA Field/Attribute | Our Support | Commit | Notes |
|---|---|---|---|
| state | ✅ | Pre-existing | |
| battery_level | ✅ | Pre-existing | |
| fan_speed | ✅ | `15f1dab` | Button shows current speed |
| fan_speed_list | ✅ | `15f1dab` | Action sheet selector |
| supported_features | ✅ | Pre-existing | |
| **Services** | | | |
| vacuum.start/pause | ✅ | Pre-existing | |
| vacuum.return_to_base | ✅ | Pre-existing | |
| vacuum.stop | ✅ | `15f1dab` | |
| vacuum.locate | ✅ | `15f1dab` | |
| vacuum.clean_spot | ✅ | `15f1dab` | |
| vacuum.set_fan_speed | ✅ | `15f1dab` | |

---

## sensor / binary_sensor

**Cell**: HASensorEntityCell (value display), HAGraphCardCell (with graph)

| HA Field/Attribute | Our Support | Commit | Notes |
|---|---|---|---|
| state | ✅ | Pre-existing | |
| unit_of_measurement | ✅ | Pre-existing | |
| device_class | ✅ | `e303d24` | Icon mapping for all classes |
| state_class | ➖ | — | Not needed for display |
| **Sensor card** | ✅ | `7dd9619` | graph:line → HAGraphCardCell |

---

## weather

**Cell**: HAWeatherEntityCell + HAClockWeatherCell

| HA Field/Attribute | Our Support | Commit |
|---|---|---|
| state/temperature/humidity/wind/pressure | ✅ | Pre-existing |
| visibility | ✅ | `1ea9304` |
| uv_index | ✅ | `1ea9304` |
| precipitation | ✅ | `1ea9304` |
| dew_point | ✅ | `1ea9304` |
| cloud_coverage | ✅ | `1ea9304` |
| forecast | ✅ | Pre-existing |

---

## humidifier

**Cell**: HAHumidifierEntityCell (toggle + slider + mode + current humidity)

| HA Field/Attribute | Our Support | Commit |
|---|---|---|
| state / target_humidity / min/max_humidity | ✅ | Pre-existing |
| current_humidity | ✅ | `517fb14` |
| mode / available_modes | ✅ | `517fb14` |
| action | ✅ | `517fb14` |
| humidifier.set_mode | ✅ | `517fb14` |

---

## person

**Cell**: HAPersonEntityCell (location + entity_picture)

| HA Field/Attribute | Our Support | Commit |
|---|---|---|
| state (home/away/zone) | ✅ | Pre-existing |
| entity_picture | ✅ | `0e6cb93` |
| latitude/longitude | ❌ | — | Would need map card |

---

## timer

| HA Field/Attribute | Our Support | Commit |
|---|---|---|
| state/duration/remaining | ✅ | Pre-existing |
| timer.start/pause/cancel | ✅ | Pre-existing |
| timer.finish | ✅ | `c8c64e1` |

---

## counter

| HA Field/Attribute | Our Support | Commit |
|---|---|---|
| state | ✅ | Pre-existing |
| minimum/maximum | ✅ | `7a45281` | Enforced on inc/dec |
| step | ✅ | `7a45281` | Used for increment size |
| counter.increment/decrement/reset | ✅ | Pre-existing |

---

## update

| HA Field/Attribute | Our Support | Commit |
|---|---|---|
| state/installed_version/latest_version | ✅ | Pre-existing |
| release_url / release_summary | ✅ | `f8688f3` |
| in_progress | ✅ | `ace263b` |
| update.install | ✅ | Pre-existing |
| update.skip | ✅ | `f8688f3` |

---

## camera

**Cell**: HACameraEntityCell (snapshot + overlays + service buttons)

| HA Field/Attribute | Our Support | Commit |
|---|---|---|
| entity_picture (snapshot) | ✅ | Pre-existing |
| state (recording/streaming) | ✅ | `d54f8af` | REC/LIVE badge |
| camera.turn_on/off | ✅ | `d3bc3ca` | Power button |
| camera.snapshot | ✅ | `d3bc3ca` | Snapshot button |

---

## New Domains (Wave 5)

| Domain | Our Support | Commit | Implementation |
|---|---|---|---|
| valve | ✅ | `d253048`, `a2d232b` | Routed to cover cell |
| water_heater | ✅ | `f5763d6` | Dedicated cell |
| lawn_mower | ✅ | `74a00d3`, `a2d232b` | Routed to vacuum cell |
| device_tracker | ✅ | `cf8e1a6`, `a2d232b` | Routed to person cell |
| remote | ✅ | `4e0ab98` | Dedicated cell (Agent D) |
| image | ✅ | `4e0ab98` | Dedicated cell (Agent D) |
| todo | ✅ | `a8fe737` | Basic count display cell |
| text | ✅ | `a2d232b` | Routed to input_text |
| date / time | ✅ | `a2d232b` | Routed to input_datetime |
| sun | ✅ | `a2d232b` | Routed to sensor cell |
| event | ⚠️ | `a2d232b` | Base cell (state display) |
| group | ❌ | — | Deferred |

---

## Card Types

| Card Type | Our Support | Commit |
|---|---|---|
| entities | ✅ | Pre-existing |
| tile / button | ✅ | Pre-existing + features |
| thermostat | ✅ | Pre-existing |
| graph / mini-graph / history-graph | ✅ | Pre-existing |
| sensor (with graph) | ✅ | `7dd9619` |
| heading | ✅ | Pre-existing |
| glance | ✅ | `edab9e2` |
| gauge | ✅ | Pre-existing |
| weather / clock-weather | ✅ | Pre-existing |
| alarm-panel | ✅ | Pre-existing |
| calendar | ✅ | Pre-existing |
| camera | ✅ | Pre-existing |
| entity (standalone) | ✅ | Agent C |
| statistic | ✅ | Agent C |
| markdown | ✅ | Agent C |
| entity-filter | ✅ | `d3f4c6f` |
| logbook | ❌ | — | Deferred (requires /api/logbook) |

---

## Remaining Gaps (Post-Sprint)

| Item | Domain | Description | Priority |
|---|---|---|---|
| media_seek | media_player | Seek to position on progress bar | Low |
| light.transition | light | Transition time parameter on service calls | Low |
| cover.toggle | cover | Single toggle button | Low (open/close suffice) |
| group entity | group | Dedicated group display with member toggle | Low |
| logbook card | card | Activity/logbook card type | Medium (needs API) |
| person GPS | person | Map display for coordinates | Low |
| event entity | event | Rich event data display | Low |
| todo items | todo | Full item listing with checkboxes | Medium (needs WS subscription) |
