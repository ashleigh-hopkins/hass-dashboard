# Product Roadmap — New Feature Epics

**Last updated**: 2026-03-03

## Epic Summary

| # | Epic | Priority | Complexity | Phases | Key Dependency |
|---|------|----------|------------|--------|----------------|
| 1 | [OS Integration](os-integration.md) | **High** | Medium-High | 3 | None |
| 2 | [Widgets & Live Activities](widgets-live-activities.md) | **High** | High | 4 | None (OS Integration recommended first) |
| 3 | [Siri & Shortcuts](siri-shortcuts.md) | **Medium-High** | Medium | 4 | Widgets Phase 1 (shared infra) |
| 4 | [Notifications](notifications.md) | **Medium-High** | High | 3 | OS Integration Phase 1 (device registration) |
| 5 | [Offline / Caching](offline-caching.md) | **Medium** | Medium | 3 | None |

## Recommended Implementation Sequence

```
                         ┌─────────────────┐
                         │ Offline/Caching  │  (independent — build anytime)
                         │ Phase 1          │
                         └─────────────────┘

  ┌──────────────────┐
  │  OS Integration   │
  │  Phase 1          │──────────────────────────────────────┐
  │  (device reg +    │                                      │
  │   battery sensors)│                                      ▼
  └────────┬─────────┘                            ┌──────────────────┐
           │                                      │  Notifications   │
           ▼                                      │  Phase 1 (local) │
  ┌──────────────────┐                            └────────┬─────────┘
  │  OS Integration   │                                    │
  │  Phase 2          │                                    ▼
  │  (device controls)│                            ┌──────────────────┐
  └──────────────────┘                             │  Notifications   │
                                                   │  Phase 2 (APNs)  │
  ┌──────────────────┐                             └──────────────────┘
  │  Widgets          │
  │  Phase 1 (static) │
  │  (App Group +     │
  │   entity cache)   │
  └────────┬─────────┘
           │
           ├─────────────────────────┐
           ▼                         ▼
  ┌──────────────────┐    ┌──────────────────┐
  │  Widgets          │    │  Siri/Shortcuts  │
  │  Phase 2          │    │  Phase 1         │
  │  (interactive,    │    │  (HAIntents      │
  │   iOS 17+)        │    │   framework)     │
  └────────┬─────────┘    └────────┬─────────┘
           │                       │
           ▼                       ▼
  ┌──────────────────┐    ┌──────────────────┐
  │  Widgets          │    │  Siri/Shortcuts  │
  │  Phase 3          │    │  Phase 2-3       │
  │  (Live Activities)│    │  (params, query, │
  └────────┬─────────┘    │   Spotlight)     │
           │               └──────────────────┘
           ▼
  ┌──────────────────┐
  │  Widgets Phase 4  │◄──── Notifications Phase 2
  │  (LA push updates)│      (shared APNs infra)
  └──────────────────┘
```

## Recommended Build Order

### Wave 0 — Parity Sprint ✅ COMPLETE

79/79 entity field parity tasks addressed (72 implemented, 4 pre-existing, 3 deferred). See [parity-sprint.md](parity-sprint.md) for full status. 11 additional card types implemented beyond the original sprint scope.

**Deferred items**: Camera live streaming, media seek interaction, timer change duration. See [deferred-items.md](deferred-items.md).

**Demo data gap**: Many implemented features (state_color, secondary_info, entity card, etc.) are not exercised by the demo dashboard. Demo data update needed to visually verify all features.

### Wave 1 — Foundation ✅ COMPLETE

**Both built in parallel:**

1. **OS Integration Phase 1+2** — Device registration, 6 sensors (battery level/state, brightness, storage, app state, active dashboard), remote commands (brightness, dashboard switch, theme, gradient, kiosk, reload). Phase 2 (device controls) completed as part of Phase 1 via HARemoteCommandHandler.
   - Status: Implemented and deployed. Registration crash fix (demo mode nil URL) resolved.
   - See [os-integration.md](os-integration.md)

2. **Offline/Caching Phase 1** — Dashboard config cache with hash comparison, entity state cache with debounced writes, instant launch from cache.
   - Status: Implemented. HACacheManager + HAEntityStateCache + HADashboardConfigCache.

### Wave 2 — Notifications + Extended Sensors

3. **Notifications Phase 1** — Local notifications via WebSocket
   - Requires: OS Integration Phase 1 ✅
   - Ships: Notification support for kiosk users (foreground only)
   - Status: **Not started**

4. **OS Integration Phase 3** — Extended sensors (focus mode iOS 15+, WiFi SSID)
   - Ships: Additional device presence signals
   - Status: **Not started**. Volume control via MPVolumeView indefinitely deferred (App Store rejection risk).

### Wave 3 — Widgets + Siri Infrastructure

5. **Widgets Phase 1** — Static read-only widgets + App Group
   - Ships: Home Screen entity state widgets
   - Establishes: App Group, Swift extension target, entity cache infra

6. **Siri/Shortcuts Phase 1** — Core intents (toggle, scene, script)
   - Requires: Widgets Phase 1 (shared App Group infra)
   - Ships: Voice control + Shortcuts automation

### Wave 4 — Interactive + Rich Features

7. **Widgets Phase 2** — Interactive widgets (iOS 17+)
8. **Siri Phase 2** — Parameterized intents + queries
9. **Notifications Phase 2** — APNs background delivery + relay server
10. **Offline/Caching Phase 2** — History cache + staleness indicators

### Wave 5 — Advanced

11. **Widgets Phase 3-4** — Live Activities + push updates
12. **Siri Phase 3** — Spotlight + donation
13. **OS Integration Phase 3** — Extended sensors (focus, WiFi, storage)
14. **Offline/Caching Phase 3** — Registry caching for widgets/Siri

## Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| **Swift only in extension targets** | Main app stays pure Obj-C. Widget extension + HAIntents framework are Swift/SwiftUI. Clean boundary via App Group. |
| **App Group as the bridge** | NSUserDefaults suite shared between main app, widget extension, and intents. Keychain access group for shared credentials. |
| **HA Mobile App webhook API** | Same API as official Companion. Proven, documented, maintained. Enables device registration, sensors, notifications. |
| **Local notifications before APNs** | Ships value without server infrastructure. Kiosk users (always foreground) get full notification support immediately. |
| **Widgets before Siri** | Widgets establish the shared infrastructure (App Group, Swift target, entity cache). Siri builds on it. Don't design the shared framework speculatively. |
| **File-based caching over Core Data** | JSON files via NSJSONSerialization work on iOS 9. Simple, debuggable, no migration headaches. Cache is expendable. |

## What's NOT on the Roadmap (and Why)

| Idea | Reason to Skip |
|------|---------------|
| **Apple Watch** | High effort, low overlap with dashboard use case. Revisit after Widgets/Siri ship. |
| **Custom card types / themes** | Internal architecture topic, not a user-facing epic. Address within existing card implementation epics. |
| **Multi-server support** | Architectural change that touches auth, connection, caching. Low user demand. Revisit when requested. |
| **HomeKit bridge** | Different integration path entirely (exposing HA as HomeKit accessories). Better served by dedicated tools like `homebridge`. |
| **Location tracking / geofencing** | High privacy friction, not core to a dashboard app. Official Companion app handles this well. |

## Deferred Items

See [deferred-items.md](deferred-items.md) for the full list of intentionally deferred items with reasons and effort estimates. Key items:

| Item | Reason | Priority |
|------|--------|----------|
| Camera live streaming | Needs AVPlayer/HLS — separate epic | Low |
| Entity row weblink/button/conditional | Architecture change to mixed-type row rendering | Next sprint |
| Logbook card | Needs new API client (HALogbookManager) | Wave 2 |
| Media seek interaction | Progress bar is read-only; seek needs feedback loop handling | Low |
| MPVolumeView volume control | App Store rejection risk | Never |
| Demo data gaps | 18+ features not exercised by demo config | **Immediate** |
