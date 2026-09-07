#!/usr/bin/env bash
#
# Релизная сборка Flowka.app — universal (arm64 + x86_64), со ВСЕМИ движками.
#
# Почему не `make app`. Голый swiftc-путь в Makefile не умеет SPM, поэтому
# FluidAudioEngine там компилируется в пустоту под `#if canImport(FluidAudio)`.
# Собранный так DMG приезжал бы пользователю без Parakeet v3 — то есть без
# движка, который включён по умолчанию, и приложение сразу писало бы
# «Parakeet v3 недоступен в этой сборке». `make app` остаётся быстрым
# whisper-only путём для разработки.
#
# Обе архитектуры реально доступны: lib/*.a собираются универсальными
# (scripts/build-whisper.sh), а xcframework FluidAudio содержит слайс
# macos-arm64_x86_64. Intel-маки поэтому не теряем.
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="Flowka"
BUILD_DIR="build"
DERIVED="$BUILD_DIR/DerivedData-release"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

if [ ! -f lib/libwhisper.a ]; then
    echo "Error: lib/libwhisper.a отсутствует. Сначала ./scripts/build-whisper.sh" >&2
    exit 1
fi

command -v xcodegen >/dev/null 2>&1 || { echo "Error: нужен xcodegen (brew install xcodegen)" >&2; exit 1; }

echo "==> Генерирую проект"
xcodegen generate

echo "==> Собираю (Release, arm64 + x86_64)"
# generic/platform=macOS + явные ARCHS: без ONLY_ACTIVE_ARCH=NO xcodebuild
# собрал бы только архитектуру раннера, и на Intel приложение бы не запустилось.
xcodebuild \
    -project WhisperDictation.xcodeproj \
    -scheme WhisperDictation \
    -configuration Release \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$DERIVED" \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    build

PRODUCT="$DERIVED/Build/Products/Release/WhisperDictation.app"
[ -d "$PRODUCT" ] || { echo "Error: не нашёл $PRODUCT" >&2; exit 1; }

echo "==> Собираю бандл $APP_BUNDLE"
rm -rf "$APP_BUNDLE"
cp -R "$PRODUCT" "$APP_BUNDLE"

# CFBundleName приходит из PRODUCT_NAME = имени таргета. Переименовать сам
# таргет нельзя: PRODUCT_MODULE_NAME пошёл бы следом, и `@testable import
# WhisperDictation` перестал бы собираться во всех тестах. Поэтому правим plist
# после сборки — ровно так же, как это делает Makefile. CFBundleExecutable при
# этом остаётся WhisperDictation: так называется файл в Contents/MacOS.
/usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$APP_BUNDLE/Contents/Info.plist"

python3 scripts/generate-icon.py "$APP_BUNDLE/Contents/Resources" 2>/dev/null || true

# Ad-hoc: у CI нет Developer ID. Для пользователя это означает предупреждение
# Gatekeeper при первом запуске (обходится правым кликом → Open).
echo "==> Подписываю (ad-hoc)"
codesign --force --deep --options runtime \
    --entitlements WhisperDictation/WhisperDictation.entitlements \
    --sign - "$APP_BUNDLE"

echo "==> Готово: $APP_BUNDLE"
lipo -info "$APP_BUNDLE/Contents/MacOS/WhisperDictation"
