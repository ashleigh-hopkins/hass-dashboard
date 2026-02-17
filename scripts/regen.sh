#!/bin/bash
set -euo pipefail

# Regenerate the Xcode project from project.yml
# Run this after adding/removing source files

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v xcodegen &>/dev/null; then
    echo "❌ xcodegen not found. Install with: brew install xcodegen"
    exit 1
fi

# Load .env for bundle ID and team ID
ENV_FILE="$PROJECT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
    set -a; source "$ENV_FILE"; set +a
fi

cd "$PROJECT_DIR"

# Create a temporary project.yml with substituted values
TEMP_YML=$(mktemp)
cp project.yml "$TEMP_YML"

if [[ -n "${BUNDLE_ID:-}" ]]; then
    sed -i '' "s/com.example.hadashboard/$BUNDLE_ID/g" project.yml
fi
if [[ -n "${APPLE_TEAM_ID:-}" ]]; then
    sed -i '' "s/DEVELOPMENT_TEAM: \"\"/DEVELOPMENT_TEAM: \"$APPLE_TEAM_ID\"/" project.yml
fi

xcodegen generate

# Restore the original project.yml (keep placeholders in source)
cp "$TEMP_YML" project.yml
rm "$TEMP_YML"

echo "✅ Project regenerated"
