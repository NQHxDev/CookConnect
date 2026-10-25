APP ?= customer
APP_DIR = apps/$(APP)

# Parse positional arguments for targets like:
#   make customer [device]
#   make supplier [device]
#   make run [customer|supplier] [device]
#   make run [device]
FIRST_GOAL := $(firstword $(MAKECMDGOALS))

ifeq ($(FIRST_GOAL),customer)
  DEVICE := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(DEVICE):;@:)
else ifeq ($(FIRST_GOAL),supplier)
  DEVICE := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(DEVICE):;@:)
endif

RUN_DEVICE_FLAG = $(if $(DEVICE),-d $(DEVICE),$(if $(shell adb devices 2>/dev/null | grep -w device | head -1 | awk '{print $$1}'),-d $(shell adb devices 2>/dev/null | grep -w device | head -1 | awk '{print $$1}'),))

# Default target
.PHONY: help
help:
	@echo "CookConnect - Monorepo Flutter Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make customer [device]          - Run customer app (e.g. make customer iPhonee)"
	@echo "  make supplier [device]          - Run supplier app (e.g. make supplier iPhonee)"
	@echo ""
	@echo "Available targets:"
	@echo "  make customer [device]          - Run customer app (debug mode)"
	@echo "  make supplier [device]          - Run supplier app (debug mode)"
	@echo "  make install                    - Build & Install release APK for both apps"
	@echo "  make install-debug              - Build & Install debug APK for both apps"
	@echo "  make devices                    - List connected devices"
	@echo "  make doctor                     - Run flutter doctor"
	@echo "  make clean [APP=supplier]       - Clean build artifacts"
	@echo "  make clean-all [APP=supplier]   - Deep clean Flutter packages"
	@echo "  make reset-ios [APP=supplier]   - Full clean iOS cache, DerivedData & re-pod"
	@echo "  make reset-supplier-ios         - Fast reset & re-install Pods for Supplier iOS"
	@echo "  make reset-customer-ios         - Fast reset & re-install Pods for Customer iOS"
	@echo "  make reset-all-ios              - Reset both Supplier and Customer iOS"
	@echo "  make deps [APP=supplier]        - Get dependencies"
	@echo "  make format                     - Format code"
	@echo "  make lint                       - Run linter"
	@echo "  make test                       - Run tests"
	@echo "  make check                      - Run format, lint, and test"

# Run app directly for customer
.PHONY: customer
customer:
ifeq ($(FIRST_GOAL),customer)
	@echo "Running customer $(if $(DEVICE),on device $(DEVICE)...,app...)"
	cd apps/customer && flutter run $(RUN_DEVICE_FLAG)
endif

# Run app directly for supplier
.PHONY: supplier
supplier:
ifeq ($(FIRST_GOAL),supplier)
	@echo "Running supplier $(if $(DEVICE),on device $(DEVICE)...,app...)"
	cd apps/supplier && flutter run $(RUN_DEVICE_FLAG)
endif

# Install APK to device for both apps
.PHONY: install
install:
	@echo "Building & Installing Customer APK (release)..."
	cd apps/customer && flutter build apk --release
	adb install -r apps/customer/build/app/outputs/flutter-apk/app-release.apk
	@echo "Building & Installing Supplier APK (release)..."
	cd apps/supplier && flutter build apk --release
	adb install -r apps/supplier/build/app/outputs/flutter-apk/app-release.apk
	@echo "Successfully installed both apps!"

.PHONY: install-debug
install-debug:
	@echo "Building & Installing Customer APK (debug)..."
	cd apps/customer && flutter build apk --debug
	adb install -r apps/customer/build/app/outputs/flutter-apk/app-debug.apk
	@echo "Building & Installing Supplier APK (debug)..."
	cd apps/supplier && flutter build apk --debug
	adb install -r apps/supplier/build/app/outputs/flutter-apk/app-debug.apk
	@echo "Successfully installed both debug apps!"

# Device management
.PHONY: devices
devices:
	@echo "Connected devices:"
	@adb devices -l

.PHONY: logcat
logcat:
	@echo "Android logcat (Flutter only)..."
	adb logcat | grep -i flutter

# Flutter commands
.PHONY: doctor
doctor:
	@echo "Running flutter doctor..."
	flutter doctor -v

.PHONY: deps
deps:
	@echo "Getting dependencies for $(APP)..."
	cd $(APP_DIR) && flutter pub get

.PHONY: upgrade
upgrade:
	@echo "Upgrading dependencies for $(APP)..."
	cd $(APP_DIR) && flutter pub upgrade

# Code quality
.PHONY: format
format:
	@echo "Formatting code for $(APP)..."
	cd $(APP_DIR) && dart format lib/ test/

.PHONY: lint
lint:
	@echo "Running linter for $(APP)..."
	cd $(APP_DIR) && flutter analyze

.PHONY: test
test:
	@echo "Running tests for $(APP)..."
	cd $(APP_DIR) && flutter test

.PHONY: check
check: format lint test
	@echo "All checks passed for $(APP)!"

# Clean
.PHONY: clean
clean:
	@echo "Cleaning build artifacts for $(APP)..."
	cd $(APP_DIR) && flutter clean
	rm -rf $(APP_DIR)/build/

.PHONY: clean-all
clean-all: clean
	@echo "Deep cleaning for $(APP)..."
	rm -rf $(APP_DIR)/.dart_tool/
	rm -rf $(APP_DIR)/.packages
	cd $(APP_DIR) && flutter pub get

# iOS Reset & Fix Stale Cache
.PHONY: reset-ios
reset-ios:
	@echo "=========================================="
	@echo "🚀 Resetting iOS build environment for: $(APP)"
	@echo "=========================================="
	@echo "🧹 [1/5] Removing Xcode DerivedData..."
	rm -rf ~/Library/Developer/Xcode/DerivedData
	@echo "🧹 [2/5] Removing Flutter build & .dart_tool..."
	rm -rf $(APP_DIR)/build $(APP_DIR)/.dart_tool $(APP_DIR)/.flutter-plugins-dependencies
	@echo "🧹 [3/5] Removing iOS Pods & build artifacts..."
	rm -rf $(APP_DIR)/ios/Pods $(APP_DIR)/ios/Podfile.lock $(APP_DIR)/ios/.symlinks
	@echo "📦 [4/5] Running flutter clean & flutter pub get..."
	cd $(APP_DIR) && flutter clean && flutter pub get
	@echo "🍎 [5/5] Running pod install..."
	cd $(APP_DIR)/ios && pod install
	@echo ""
	@echo "🎉 Done! Clean and setup completed for $(APP) iOS."
	@echo "👉 Bạn hãy mở lại Runner.xcworkspace và nhấn Cmd + R để Run!"

.PHONY: reset-supplier-ios
reset-supplier-ios:
	@$(MAKE) reset-ios APP=supplier

.PHONY: reset-customer-ios
reset-customer-ios:
	@$(MAKE) reset-ios APP=customer

.PHONY: reset-all-ios
reset-all-ios:
	@$(MAKE) reset-supplier-ios
	@$(MAKE) reset-customer-ios

# Hot reload/restart helpers
.PHONY: hot-reload
hot-reload:
	@echo "Sending hot reload command..."
	@echo "r" | nc localhost 8181 2>/dev/null || echo "No active flutter run session"

.PHONY: hot-restart
hot-restart:
	@echo "Sending hot restart command..."
	@echo "R" | nc localhost 8181 2>/dev/null || echo "No active flutter run session"
