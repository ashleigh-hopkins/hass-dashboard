# Privacy Policy — HA Dashboard

**Last updated:** February 2026

HA Dashboard is a native iOS app that connects to your self-hosted Home Assistant server. This policy explains how the app handles your data.

## Data Collection

HA Dashboard does **not** collect, store, or transmit any personal data to the developer or any third party. The app contains no analytics, tracking, advertising, or telemetry SDKs.

## How the App Works

- The app connects directly to a Home Assistant server URL that **you** configure.
- All communication occurs between your device and your Home Assistant server.
- No data passes through any intermediary servers.

## Credentials

- Your Home Assistant access token or OAuth credentials are stored locally in the iOS Keychain on your device.
- Credentials are never transmitted to the developer or any third party.
- Credentials are only sent to your configured Home Assistant server for authentication.

## Local Network Access

The app uses local network access (mDNS/Bonjour) to discover Home Assistant servers on your network. This requires the Local Network permission on iOS. The discovery data does not leave your device.

## Cookies and Web Tracking

The app does not use cookies, web views, or any form of web-based tracking.

## Data Storage

All app data (server configuration, dashboard preferences, cached entity states) is stored locally on your device. No data is synced to cloud services.

## Third-Party Services

The app does not integrate with any third-party services, SDKs, or APIs beyond your own Home Assistant server.

## Children's Privacy

The app does not knowingly collect any data from anyone, including children.

## Changes to This Policy

If this policy changes, the updated version will be published at the same URL.

## Contact

For questions about this privacy policy, open an issue on the GitHub repository.
