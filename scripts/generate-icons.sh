#!/bin/bash
set -euo pipefail

# Generate all app icon sizes from a 1024x1024 source image
# Requires: sips (built into macOS)
# Usage: scripts/generate-icons.sh <path/to/icon-1024.png>

SOURCE="${1:-}"
if [[ -z "$SOURCE" || ! -f "$SOURCE" ]]; then
    echo "Usage: scripts/generate-icons.sh <path/to/1024x1024-icon.png>"
    exit 1
fi

# Verify source dimensions
WIDTH=$(sips -g pixelWidth "$SOURCE" 2>/dev/null | awk '/pixelWidth/{print $2}')
HEIGHT=$(sips -g pixelHeight "$SOURCE" 2>/dev/null | awk '/pixelHeight/{print $2}')
if [[ "$WIDTH" != "1024" || "$HEIGHT" != "1024" ]]; then
    echo "Source image is ${WIDTH}x${HEIGHT}, expected 1024x1024"
    echo "Proceeding anyway (will be resized)..."
fi

DEST="HADashboard/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$DEST"

generate() {
    local size=$1 name=$2
    sips -z "$size" "$size" "$SOURCE" --out "$DEST/$name" >/dev/null 2>&1
    echo "  $name (${size}x${size})"
}

echo "Generating icons..."

# iPhone
generate 40  "icon-20@2x.png"
generate 60  "icon-20@3x.png"
generate 58  "icon-29@2x.png"
generate 87  "icon-29@3x.png"
generate 80  "icon-40@2x.png"
generate 120 "icon-40@3x.png"
generate 120 "icon-60@2x.png"
generate 180 "icon-60@3x.png"

# iPad
generate 20  "icon-20@1x.png"
generate 40  "icon-20@2x-ipad.png"
generate 29  "icon-29@1x.png"
generate 58  "icon-29@2x-ipad.png"
generate 40  "icon-40@1x.png"
generate 80  "icon-40@2x-ipad.png"
generate 76  "icon-76@1x.png"
generate 152 "icon-76@2x.png"
generate 167 "icon-83.5@2x.png"

# App Store
generate 1024 "icon-1024.png"

echo ""
echo "Generated 20 icons in $DEST"
