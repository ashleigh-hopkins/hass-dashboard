#!/bin/bash
set -euo pipefail

# HA Dashboard build script
# Uses Xcode 13.2.1 toolchain for iOS 9 armv7+arm64 builds

XCODE13="/Applications/Xcode-13.2.1.app"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${1:-Debug}"

if [ ! -d "$XCODE13" ]; then
    echo "❌ Xcode 13.2.1 not found at $XCODE13"
    echo "   Install it with: xcodes install 13.2.1"
    exit 1
fi

export DEVELOPER_DIR="$XCODE13/Contents/Developer"

echo "Building HA Dashboard ($CONFIG)..."
echo "  Xcode: $(xcodebuild -version | head -1)"
echo "  SDK:   $(xcodebuild -version -sdk iphoneos Path | xargs basename)"
echo "  Archs: armv7 arm64"
echo ""

xcodebuild \
    -project "$PROJECT_DIR/HADashboard.xcodeproj" \
    -target HADashboard \
    -sdk iphoneos \
    -configuration "$CONFIG" \
    IPHONEOS_DEPLOYMENT_TARGET=9.0 \
    "ARCHS=armv7 arm64" \
    "VALID_ARCHS=armv7 arm64" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGN_IDENTITY="" \
    build 2>&1 | \
    grep -E '(CompileC |Ld |error:|BUILD)' | \
    sed 's|.*/||; s| normal .*| |'

APP="$PROJECT_DIR/build/$CONFIG-iphoneos/HA Dashboard.app"
if [ -d "$APP" ]; then
    SIZE=$(du -sh "$APP" | cut -f1)
    ARCHS=$(file "$APP/HA Dashboard" | grep -o 'arm[a-z0-9_]*' | tr '\n' ' ')
    echo ""
    echo "✅ Build succeeded"
    echo "   App:   $APP"
    echo "   Size:  $SIZE"
    echo "   Archs: $ARCHS"
fi
