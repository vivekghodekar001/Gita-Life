#!/bin/bash
# Exit on error
set -e

echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

echo "Running Flutter Pub Get..."
flutter pub get

echo "Building Flutter Web App..."
flutter build web --release
