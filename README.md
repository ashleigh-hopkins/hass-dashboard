# HA Dashboard

A native iOS app that renders your [Home Assistant](https://www.home-assistant.io/) Lovelace dashboards natively — no web views.

Built to run on everything from a jailbroken iPad 2 (iOS 9.3.5, armv7) wall-mounted as a kiosk, to an iPhone 17 Pro Max running iOS 26.

## Features

- **Native rendering** of HA Lovelace sections-layout dashboards (entities, lights, climate, sensors, cameras, graphs, gauges, badges, and more)
- **Real-time updates** via WebSocket — entity states update live
- **33 cell types** — covers controls, inputs, composite cards, and entity detail views
- **Themes** — Auto, Dark, Light, and Gradient modes with 5 gradient presets plus custom hex colors
- **Kiosk mode** — hides navigation, prevents sleep, triple-tap to escape
- **Demo mode** — 3 built-in dashboards (Home, Monitoring, Media) with simulated entities and history — no server needed
- **Dashboard switcher** — switch between multiple HA dashboards
- **mDNS discovery** — finds Home Assistant servers on your local network
- **Dual auth** — long-lived access token or full OAuth login flow with token refresh
- **Universal binary** — armv7 + arm64 in a single build for legacy device support
- **165 snapshot regression tests** covering 33 cell types across multiple themes (291 reference images)

## Screenshots

*Coming soon*

## Requirements

- **Xcode 26** (for modern devices and simulators)
- **Xcode 13.2.1** (optional — only needed if targeting iPad 2 / armv7)
- **XcodeGen** (`brew install xcodegen`)
- A Home Assistant server with a Lovelace dashboard (or use demo mode)

## Getting Started

1. **Clone the repo**
   ```bash
   git clone https://github.com/ha-dashboard/ios-app.git
   cd ios-app
   ```

2. **Set up environment**
   ```bash
   cp .env.example .env
   # Edit .env with your Apple Team ID, Bundle ID, and HA credentials
   ```

3. **Generate the Xcode project**
   ```bash
   scripts/regen.sh
   ```

4. **Build and run in the simulator**
   ```bash
   scripts/deploy.sh sim
   ```

## Deploy to Devices

```bash
scripts/deploy.sh sim              # iPad simulator
scripts/deploy.sh sim iphone       # iPhone simulator
scripts/deploy.sh iphone           # Physical iPhone (devicectl)
scripts/deploy.sh mini5            # iPad Mini 5 (devicectl, WiFi)
scripts/deploy.sh mini4            # iPad Mini 4 (ios-deploy, WiFi)
scripts/deploy.sh ipad2            # iPad 2 (WiFi SSH, jailbroken)
scripts/deploy.sh all --kiosk      # All targets in kiosk mode
```

See `.env.example` for the device UDIDs and credentials needed for each target.

## Architecture

- Pure **Objective-C** — no Swift, no storyboards, no XIBs
- Programmatic Auto Layout (`NSLayoutConstraint` anchors, iOS 9+)
- **SocketRocket** for WebSocket, **NSURLSession** for REST
- Custom 12-column `UICollectionViewLayout` for iPad multi-column dashboards
- Performance optimizations for iPad 2: deferred loading, coalesced reloads, cell rasterization, lightweight graph mode

## Testing

```bash
# Run 165 snapshot regression tests
scripts/test-snapshots.sh

# Visual parity test harness (requires Docker)
cd test-harness
./run.sh setup    # One-time: install deps
./run.sh full     # Capture HA web screenshots for comparison
```

## Project Structure

```
HADashboard/         Source code (Auth, Controllers, Models, Networking, Theme, Views)
HADashboardTests/    165 snapshot tests + 291 reference images
Vendor/              SocketRocket, MDI icon font, iOSSnapshotTestCase
test-harness/        Docker-based visual parity testing
scripts/             Build, deploy, test, project generation
project.yml          XcodeGen project definition
.env.example         Environment variable template
```

## Privacy

HA Dashboard does not collect, store, or transmit any personal data. All communication is directly between your device and your Home Assistant server. See [PRIVACY.md](PRIVACY.md) for the full privacy policy.

## License

Licensed under the [Apache License, Version 2.0](LICENSE).
