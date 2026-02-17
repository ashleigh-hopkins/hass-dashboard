#!/bin/bash
set -euo pipefail

# Snapshot Regression Tests
# Usage:
#   scripts/test-snapshots.sh          # Run tests (compare against references)
#   scripts/test-snapshots.sh record   # Record new reference images

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

SCHEME="HADashboard"
DESTINATION="platform=iOS Simulator,name=iPad (10th generation),OS=17.4"
TEST_TARGET="HADashboardTests"

# Check if recording mode
RECORD_MODE="NO"
if [[ "${1:-}" == "record" ]]; then
    RECORD_MODE="YES"
    echo "📸 Recording reference images..."
else
    echo "🔍 Running snapshot regression tests..."
fi

# Regenerate project if needed
if command -v xcodegen &>/dev/null; then
    echo "   Regenerating Xcode project..."
    xcodegen generate --spec project.yml --quiet 2>/dev/null || true
fi

# Build and run tests
echo "   Building and testing..."
RESULT=0
RECORD_DEFINE=""
if [[ "$RECORD_MODE" == "YES" ]]; then
    RECORD_DEFINE='GCC_PREPROCESSOR_DEFINITIONS=$(inherited) RECORD_SNAPSHOTS=1'
fi

xcodebuild test \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -only-testing:"$TEST_TARGET" \
    ${RECORD_DEFINE:+"$RECORD_DEFINE"} \
    2>&1 | while IFS= read -r line; do
        # Show test results
        if echo "$line" | grep -q "Test Case.*started"; then
            TEST_NAME=$(echo "$line" | sed 's/.*-\[//' | sed 's/\].*//')
            echo "   ▶ $TEST_NAME"
        elif echo "$line" | grep -q "Test Case.*passed"; then
            TEST_NAME=$(echo "$line" | sed 's/.*-\[//' | sed 's/\].*//')
            echo "   ✅ $TEST_NAME"
        elif echo "$line" | grep -q "Test Case.*failed"; then
            TEST_NAME=$(echo "$line" | sed 's/.*-\[//' | sed 's/\].*//')
            echo "   ❌ $TEST_NAME"
            RESULT=1
        elif echo "$line" | grep -q "TEST.*SUCCEEDED"; then
            echo ""
            echo "✅ All snapshot tests passed"
        elif echo "$line" | grep -q "TEST.*FAILED"; then
            echo ""
            echo "❌ Snapshot tests FAILED — check diffs in HADashboardTests/FailureDiffs/"
            RESULT=1
        fi
    done || RESULT=$?

# List failure diffs if any exist
DIFF_DIR="$PROJECT_DIR/HADashboardTests/FailureDiffs"
if [[ -d "$DIFF_DIR" ]] && [[ $(find "$DIFF_DIR" -name "*.png" 2>/dev/null | wc -l) -gt 0 ]]; then
    echo ""
    echo "📋 Failure diff images:"
    find "$DIFF_DIR" -name "*.png" | while read -r f; do
        echo "   $(basename "$f")"
    done
fi

exit ${RESULT:-0}
