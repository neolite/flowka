SDK := $(shell xcrun --sdk macosx --show-sdk-path)
MIN_MACOS := 14.0
BUILD_DIR := build
APP_NAME := Flowka
BUNDLE_ID := com.rafkat.flowka
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app

# Подпись кода.
#
# TCC (Accessibility, Microphone) привязывает выданные разрешения к
# ИДЕНТИЧНОСТИ ПОДПИСИ. Ad-hoc подпись (`codesign --sign -`) порождает новую
# идентичность при каждой сборке, поэтому macOS молча теряет разрешения после
# каждой пересборки — а выглядит это как «приложение перестало печатать».
#
# Поэтому подписываем стабильным Development-сертификатом, если он есть.
# Если сертификата нет, откатываемся на ad-hoc, но предупреждаем: работать
# будет, разрешения переживать пересборку — нет.
SIGN_IDENTITY := $(shell security find-identity -v -p codesigning 2>/dev/null | \
	grep -o '"Apple Development: [^"]*"' | head -1 | tr -d '"')

# Build universal binary (arm64 + x86_64). The Swift binary is built once per
# architecture and then merged with `lipo`. whisper.cpp's static libs are also
# built fat (see scripts/build-whisper.sh: CMAKE_OSX_ARCHITECTURES). This is
# what we ship — Apple Silicon and Intel users both need to be able to run it.

SWIFT_FILES := \
	WhisperDictation/Utilities/Settings.swift \
	WhisperDictation/Utilities/KeyCodeNames.swift \
	WhisperDictation/Utilities/AppInfo.swift \
	WhisperDictation/Engine/WhisperBridge.swift \
	WhisperDictation/Engine/AudioCapture.swift \
	WhisperDictation/Engine/TextInjector.swift \
	WhisperDictation/Engine/SoundFeedback.swift \
	WhisperDictation/Engine/ModelManager.swift \
	WhisperDictation/Engine/TextCorrector.swift \
	WhisperDictation/Engine/GlossaryCleaner.swift \
	WhisperDictation/Engine/TextPipeline.swift \
	WhisperDictation/Engine/VADSegmenter.swift \
	WhisperDictation/Utilities/HotkeyMonitor.swift \
	WhisperDictation/Utilities/PermissionManager.swift \
	WhisperDictation/Utilities/LaunchAtLoginHelper.swift \
	WhisperDictation/Utilities/AudioDeviceManager.swift \
	WhisperDictation/Engine/DictationEngine.swift \
	WhisperDictation/UI/DictationOverlay.swift \
	WhisperDictation/UI/MenuBarView.swift \
	WhisperDictation/UI/SettingsView.swift \
	WhisperDictation/UI/OnboardingView.swift \
	WhisperDictation/App/WhisperDictationApp.swift

LIBS := -lwhisper -lggml -lggml-base -lggml-cpu -lggml-metal -lggml-blas -lc++
FRAMEWORKS := -framework Accelerate -framework Metal -framework MetalKit -framework AVFoundation -framework CoreGraphics -framework AppKit -framework Foundation -framework ServiceManagement -framework CoreAudio

.PHONY: all clean whisper model app run dmg

all: whisper app

whisper: lib/libwhisper.a

lib/libwhisper.a:
	./scripts/build-whisper.sh

model:
	./scripts/download-model.sh small.en

define BUILD_SLICE
xcrun swiftc \
	-sdk "$(SDK)" \
	-target $(1)-apple-macos$(MIN_MACOS) \
	-import-objc-header WhisperDictation/WhisperDictation-Bridging-Header.h \
	-I lib -L lib \
	$(LIBS) $(FRAMEWORKS) \
	-parse-as-library \
	$(SWIFT_FILES) \
	-o $(BUILD_DIR)/WhisperDictation-$(1)
endef

$(BUILD_DIR)/WhisperDictation-arm64: $(SWIFT_FILES) lib/libwhisper.a
	@mkdir -p $(BUILD_DIR)
	$(call BUILD_SLICE,arm64)

$(BUILD_DIR)/WhisperDictation-x86_64: $(SWIFT_FILES) lib/libwhisper.a
	@mkdir -p $(BUILD_DIR)
	$(call BUILD_SLICE,x86_64)

$(BUILD_DIR)/WhisperDictation: $(BUILD_DIR)/WhisperDictation-arm64 $(BUILD_DIR)/WhisperDictation-x86_64
	lipo -create $^ -output $@
	@lipo -info $@

app: $(BUILD_DIR)/WhisperDictation
	@mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	@mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	@cp $(BUILD_DIR)/WhisperDictation "$(APP_BUNDLE)/Contents/MacOS/"
	@# EXECUTABLE_NAME остаётся WhisperDictation: так называется файл, который
	@# кладётся в Contents/MacOS, и CFBundleExecutable обязан ему соответствовать.
	@sed \
		-e 's/$$(EXECUTABLE_NAME)/WhisperDictation/g' \
		-e 's/$$(PRODUCT_BUNDLE_IDENTIFIER)/$(BUNDLE_ID)/g' \
		-e 's/$$(PRODUCT_NAME)/$(APP_NAME)/g' \
		-e 's/$$(DEVELOPMENT_LANGUAGE)/ru/g' \
		WhisperDictation/Info.plist > "$(APP_BUNDLE)/Contents/Info.plist"
	@# Add LSMinimumSystemVersion (required for macOS to recognize the app)
	@/usr/libexec/PlistBuddy -c "Add :LSMinimumSystemVersion string $(MIN_MACOS)" "$(APP_BUNDLE)/Contents/Info.plist" 2>/dev/null || \
		/usr/libexec/PlistBuddy -c "Set :LSMinimumSystemVersion $(MIN_MACOS)" "$(APP_BUNDLE)/Contents/Info.plist"
	@echo "APPL????" > "$(APP_BUNDLE)/Contents/PkgInfo"
	@# Generate app icon
	@python3 scripts/generate-icon.py "$(APP_BUNDLE)/Contents/Resources" 2>/dev/null || true
	@# Подпись: стабильная идентичность сохраняет выданные TCC-разрешения
	@if [ -n "$(SIGN_IDENTITY)" ]; then \
		echo "[sign] $(SIGN_IDENTITY)"; \
		codesign --force --deep --options runtime --sign "$(SIGN_IDENTITY)" "$(APP_BUNDLE)"; \
	else \
		echo "[sign] ВНИМАНИЕ: Development-сертификат не найден, подпись ad-hoc."; \
		echo "[sign] Разрешения Accessibility и Microphone будут теряться при каждой пересборке."; \
		codesign --force --deep --sign - "$(APP_BUNDLE)"; \
	fi
	@echo "Built $(APP_BUNDLE)"

run: app
	open "$(APP_BUNDLE)"

dmg: app
	./scripts/create-dmg.sh

clean:
	rm -rf $(BUILD_DIR)
