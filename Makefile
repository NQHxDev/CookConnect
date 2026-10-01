# Default target
.PHONY: help
help:
	@echo "CookConnect - Flutter Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make run          - Run app on connected device (debug mode)"
	@echo "  make run-release  - Run app on connected device (release mode)"
	@echo "  make run-profile  - Run app on connected device (profile mode)"
	@echo "  make build        - Build APK (release)"
	@echo "  make build-debug  - Build APK (debug)"
	@echo "  make build-bundle - Build Android App Bundle"
	@echo "  make install      - Install APK to device"
	@echo "  make devices      - List connected devices"
	@echo "  make doctor       - Run flutter doctor"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make deps         - Get dependencies"
	@echo "  make format       - Format code"
	@echo "  make lint         - Run linter"
	@echo "  make test         - Run tests"
	@echo "  make check        - Run format, lint, and test"

# Run app on device
.PHONY: run
run:
	@echo "Running app on device (debug mode)..."
	flutter run -d $(shell adb devices | grep -w device | head -1 | awk '{print $$1}')

.PHONY: run-release
run-release:
	@echo "Running app on device (release mode)..."
	flutter run --release -d $(shell adb devices | grep -w device | head -1 | awk '{print $$1}')

.PHONY: run-profile
run-profile:
	@echo "Running app on device (profile mode)..."
	flutter run --profile -d $(shell adb devices | grep -w device | head -1 | awk '{print $$1}')

# Build APK
.PHONY: build
build:
	@echo "Building release APK..."
	flutter build apk --release

.PHONY: build-debug
build-debug:
	@echo "Building debug APK..."
	flutter build apk --debug

.PHONY: build-bundle
build-bundle:
	@echo "Building Android App Bundle..."
	flutter build appbundle --release

# Install APK to device
.PHONY: install
install: build
	@echo "Installing APK to device..."
	adb install -r build/app/outputs/flutter-apk/app-release.apk

.PHONY: install-debug
install-debug: build-debug
	@echo "Installing debug APK to device..."
	adb install -r build/app/outputs/flutter-apk/app-debug.apk

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
	@echo "Getting dependencies..."
	flutter pub get

.PHONY: upgrade
upgrade:
	@echo "Upgrading dependencies..."
	flutter pub upgrade

# Code quality
.PHONY: format
format:
	@echo "Formatting code..."
	dart format lib/ test/

.PHONY: lint
lint:
	@echo "Running linter..."
	flutter analyze

.PHONY: test
test:
	@echo "Running tests..."
	flutter test

.PHONY: check
check: format lint test
	@echo "All checks passed!"

# Clean
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	flutter clean
	rm -rf build/

.PHONY: clean-all
clean-all: clean
	@echo "Deep cleaning..."
	rm -rf .dart_tool/
	rm -rf .packages
	flutter pub get

# Hot reload/restart helpers
.PHONY: hot-reload
hot-reload:
	@echo "Sending hot reload command..."
	@echo "r" | nc localhost 8181 2>/dev/null || echo "No active flutter run session"

.PHONY: hot-restart
hot-restart:
	@echo "Sending hot restart command..."
	@echo "R" | nc localhost 8181 2>/dev/null || echo "No active flutter run session"
