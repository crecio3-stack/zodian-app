#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/tmp/ZodianDerivedData}"

xcodebuild \
  -project "$ROOT_DIR/Zodian.xcodeproj" \
  -scheme Zodian \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build
