#!/bin/bash
# Create a DMG installer for Flowka.
#
# Имя приложения задаётся один раз здесь: раньше скрипт искал
# build/WhisperDictation.app, тогда как сборка давно называется Flowka.app,
# и `make dmg` падал ошибкой "not found" — то есть релизный workflow был
# сломан на шаге Create DMG и никогда бы не дошёл до публикации.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="Flowka"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME"
DMG_OUTPUT="$BUILD_DIR/${DMG_NAME}.dmg"
VOLUME_NAME="$APP_NAME"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: $APP_BUNDLE not found. Run './scripts/build-release.sh' first."
    exit 1
fi

# Remove previous DMG
rm -f "$DMG_OUTPUT"

# Create a temporary directory for DMG contents
TMP_DIR=$(mktemp -d)
cp -R "$APP_BUNDLE" "$TMP_DIR/"

# Remove quarantine attribute so the icon shows correctly in the DMG
xattr -cr "$TMP_DIR/$APP_NAME.app" 2>/dev/null || true

ln -s /Applications "$TMP_DIR/Applications"

echo "==> Creating DMG..."
hdiutil create \
    -volname "$VOLUME_NAME" \
    -srcfolder "$TMP_DIR" \
    -ov \
    -format UDZO \
    "$DMG_OUTPUT"

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "==> DMG created: $DMG_OUTPUT"
ls -lh "$DMG_OUTPUT"
