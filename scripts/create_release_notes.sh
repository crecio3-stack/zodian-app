#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FILE="$ROOT_DIR/Zodian.xcodeproj/project.pbxproj"
RELEASES_DIR="$ROOT_DIR/Releases"

MARKETING_VERSION="$(grep -m1 "MARKETING_VERSION =" "$PROJECT_FILE" | sed 's/.*= //; s/;//')"
BUILD_NUMBER="$(grep -m1 "CURRENT_PROJECT_VERSION =" "$PROJECT_FILE" | sed 's/.*= //; s/;//')"
TODAY="$(date +%F)"
OUTPUT_FILE="$RELEASES_DIR/$MARKETING_VERSION-build-$BUILD_NUMBER.md"

mkdir -p "$RELEASES_DIR"

if [[ -f "$OUTPUT_FILE" ]]; then
  echo "Release notes already exist: $OUTPUT_FILE"
  exit 0
fi

cat > "$OUTPUT_FILE" <<EOF
# Zodian $MARKETING_VERSION (Build $BUILD_NUMBER)

Date: $TODAY

## Build Intent

Describe why this build exists.

## What Changed

- Summarize the most important product or engineering changes

## Known Issues

- Call out anything testers or reviewers should know

## Tester Focus

- List the highest-value flows to validate

## Notes For App Store Connect

- Add any internal release note or metadata reminders here
EOF

echo "Created $OUTPUT_FILE"
