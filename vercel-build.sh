#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.2}"
SDK_DIR="$PROJECT_ROOT/.flutter-sdk"

if [[ ! -x "$SDK_DIR/bin/flutter" ]]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$SDK_DIR"
fi
export PATH="$SDK_DIR/bin:$PATH"
flutter config --no-analytics
flutter pub get

if [[ "${1:-}" != "--dependencies-only" ]]; then
  flutter build web --release
fi
