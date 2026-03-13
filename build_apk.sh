#!/bin/bash

# ================================
# Flutter APK Update & Build Script
# ================================

# Exit immediately if a command fails
set -e

PROJECT_DIR=~/photo-sync-mobile-app

echo "=== Pulling latest changes from Git ==="
git pull origin main  # change 'main' if your branch is different

echo "=== Getting Flutter packages ==="
flutter pub get

echo "=== Cleaning previous builds (optional) ==="
flutter clean

echo "=== Building release APK ==="
flutter build apk --release --no-daemon

# Optional: path to APK output
APK_PATH="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
echo "=== Build finished! APK located at: $APK_PATH ==="
