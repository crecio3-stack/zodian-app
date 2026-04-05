#!/usr/bin/env bash

set -euo pipefail

# Simple iOS simulator route smoke checks for Expo Router paths.
# Assumes Metro is running and Expo Go is installed.

METRO_PORT="${1:-8081}"

echo "[qa] using Metro port: ${METRO_PORT}"

BOOTED_COUNT="$(xcrun simctl list devices booted | grep -c "(Booted)" || true)"
if [[ "${BOOTED_COUNT}" -eq 0 ]]; then
  echo "[qa] no booted simulator found, booting iPhone 15 Pro"
  xcrun simctl boot "iPhone 15 Pro" || true
fi

echo "[qa] launching Expo Go"
xcrun simctl launch booted host.exp.Exponent >/dev/null 2>&1 || true

BASE_URL="exp://127.0.0.1:${METRO_PORT}/--"

ROUTES=(
  "/onboarding/welcome"
  "/onboarding/name"
  "/onboarding/birthdate"
  "/onboarding/reveal"
  "/(tabs)"
  "/daily"
  "/premium"
  "/analytics-debug"
)

echo "[qa] opening routes"
for route in "${ROUTES[@]}"; do
  url="${BASE_URL}${route}"
  xcrun simctl openurl booted "${url}"
  echo "[qa] ok: ${route}"
done

echo "[qa] smoke route handoff complete"