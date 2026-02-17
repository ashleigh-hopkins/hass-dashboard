#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

rm -rf "$PROJECT_DIR/build"
echo "✅ Build directory cleaned"
