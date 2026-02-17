#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

usage() {
    echo "HA Test Harness — Visual Parity Pipeline"
    echo ""
    echo "Usage: ./run.sh <command>"
    echo ""
    echo "Commands:"
    echo "  setup       Install dependencies (npm + playwright browsers)"
    echo "  start       Start the HA Docker container"
    echo "  stop        Stop the HA Docker container"
    echo "  capture     Capture HA web dashboard screenshots"
    echo "  baseline    Save current captures as baseline for regression"
    echo "  compare     Compare current captures against baseline + app refs"
    echo "  full        Start HA, wait, capture, stop"
    echo "  status      Show container and screenshot status"
    echo ""
}

cmd_setup() {
    echo "Installing dependencies..."
    npm install
    npx playwright install chromium
    echo "Done."
}

cmd_start() {
    echo "Starting HA test harness (2026.2)..."
    docker compose up -d
    echo "Waiting for Home Assistant to be ready..."
    local attempts=0
    local max_attempts=60
    while ! curl -sf http://localhost:8124/api/ > /dev/null 2>&1; do
        attempts=$((attempts + 1))
        if [ $attempts -ge $max_attempts ]; then
            echo "HA did not start within ${max_attempts}s"
            docker compose logs --tail 20
            exit 1
        fi
        sleep 2
        printf "."
    done
    echo ""
    echo "HA ready at http://localhost:8124"
    echo "Test dashboard at http://localhost:8124/test-harness/lighting"
}

cmd_stop() {
    echo "Stopping HA test harness..."
    docker compose down
    echo "Stopped."
}

cmd_capture() {
    echo "Capturing HA web screenshots..."
    node capture-screenshots.mjs
}

cmd_baseline() {
    if [ ! -d screenshots/ha-web ]; then
        echo "No captures found. Run './run.sh capture' first."
        exit 1
    fi
    echo "Saving current captures as baseline..."
    rm -rf screenshots/baseline
    cp -r screenshots/ha-web screenshots/baseline
    echo "Baseline saved to screenshots/baseline/"
    echo "$(ls screenshots/baseline/*.png 2>/dev/null | wc -l) images saved."
}

cmd_compare() {
    echo "Running visual comparison..."
    node compare-screenshots.mjs
}

cmd_full() {
    cmd_start
    echo ""
    # Give HA a few more seconds to fully initialize demo entities
    echo "Waiting 10s for demo entities to initialize..."
    sleep 10
    cmd_capture
    echo ""
    cmd_stop
    echo ""
    echo "Full run complete. Run './run.sh compare' to analyze."
}

cmd_status() {
    echo "=== Container Status ==="
    docker compose ps 2>/dev/null || echo "No containers running"
    echo ""
    echo "=== Screenshots ==="
    if [ -d screenshots/ha-web ]; then
        echo "Current captures: $(ls screenshots/ha-web/*.png 2>/dev/null | wc -l) images"
    else
        echo "Current captures: none"
    fi
    if [ -d screenshots/baseline ]; then
        echo "Baseline: $(ls screenshots/baseline/*.png 2>/dev/null | wc -l) images"
    else
        echo "Baseline: none"
    fi
    if [ -d screenshots/diffs ]; then
        echo "Diffs: $(find screenshots/diffs -name '*.png' 2>/dev/null | wc -l) images"
    else
        echo "Diffs: none"
    fi
}

case "${1:-}" in
    setup)    cmd_setup ;;
    start)    cmd_start ;;
    stop)     cmd_stop ;;
    capture)  cmd_capture ;;
    baseline) cmd_baseline ;;
    compare)  cmd_compare ;;
    full)     cmd_full ;;
    status)   cmd_status ;;
    *)        usage ;;
esac
