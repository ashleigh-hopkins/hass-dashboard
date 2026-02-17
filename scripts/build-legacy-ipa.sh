#!/bin/bash
set -euo pipefail

# Build a signed IPA for iPad 2 using Xcode 13.2.1 (local fallback)
# Usage: scripts/build-legacy-ipa.sh [version]

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
XCODE13="/Applications/Xcode-13.2.1.app"

if [ ! -d "$XCODE13" ]; then
    echo "Xcode 13.2.1 not found at $XCODE13"
    echo "Install with: xcodes install 13.2.1"
    exit 1
fi

# Load secrets
ENV_FILE="$PROJECT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
    set -a; source "$ENV_FILE"; set +a
fi

VERSION="${1:-$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo '1.0.0')}"
BUILD_NUMBER="$(git rev-list --count HEAD)"
APPLE_TEAM_ID="${APPLE_TEAM_ID:-}"
if [[ -z "$APPLE_TEAM_ID" ]]; then
    echo "❌ APPLE_TEAM_ID not set. Add it to .env"
    exit 1
fi

echo "Building legacy IPA v${VERSION} (build ${BUILD_NUMBER})..."

# Clean
rm -rf "$PROJECT_DIR/build/legacy"

# Auth flags
AUTH_FLAGS=()
if [[ -n "${ASC_KEY_PATH:-}" && -n "${ASC_KEY_ID:-}" && -n "${ASC_ISSUER_ID:-}" ]]; then
    expanded_key="${ASC_KEY_PATH/#\~/$HOME}"
    AUTH_FLAGS=(
        -authenticationKeyPath "$expanded_key"
        -authenticationKeyID "$ASC_KEY_ID"
        -authenticationKeyIssuerID "$ASC_ISSUER_ID"
        -allowProvisioningUpdates
    )
fi

# Build
DEVELOPER_DIR="$XCODE13/Contents/Developer" xcodebuild \
    -project "$PROJECT_DIR/HADashboard.xcodeproj" \
    -target HADashboard \
    -sdk iphoneos \
    -configuration Release \
    IPHONEOS_DEPLOYMENT_TARGET=9.0 \
    "ARCHS=armv7 arm64" \
    "VALID_ARCHS=armv7 arm64" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_STYLE=Automatic \
    "DEVELOPMENT_TEAM=$APPLE_TEAM_ID" \
    CODE_SIGN_IDENTITY="Apple Development" \
    MARKETING_VERSION="$VERSION" \
    CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
    "INFOPLIST_KEY_UIRequiredDeviceCapabilities=armv7" \
    ASSETCATALOG_COMPILER_APPICON_NAME="" \
    "${AUTH_FLAGS[@]}" \
    build 2>&1 | grep -E '(error:|BUILD)' | tail -10

APP="$PROJECT_DIR/build/Release-iphoneos/HA Dashboard.app"
if [ ! -d "$APP" ]; then
    echo "Build failed -- .app not found"
    exit 1
fi

# Package into IPA
mkdir -p "$PROJECT_DIR/build/legacy/Payload"
cp -r "$APP" "$PROJECT_DIR/build/legacy/Payload/"
cd "$PROJECT_DIR/build/legacy"
zip -qr "HADashboard-${VERSION}-legacy-armv7-arm64.ipa" Payload/
rm -rf Payload/
cd "$PROJECT_DIR"

IPA="build/legacy/HADashboard-${VERSION}-legacy-armv7-arm64.ipa"
echo ""
echo "IPA: $IPA"
echo "  Size: $(du -h "$IPA" | cut -f1)"
echo "  Archs: $(lipo -info "$APP/HA Dashboard" 2>/dev/null | sed 's/.*: //')"
echo ""
echo "To attach to a GitHub Release:"
echo "  gh release upload v${VERSION} \"$IPA\""
