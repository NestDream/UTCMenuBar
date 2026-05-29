#!/bin/bash
# Builds UTCMenuBar.app — a runnable macOS .app bundle wrapping the SPM executable.
# Usage: ./scripts/build-app.sh [debug|release]   (default: release)
#
# Version: derived from the latest git tag matching `v*` (stripped of the leading "v").
# Falls back to "0.0.0-dev" when not in a git checkout or no tag exists.

set -euo pipefail

CONFIG="${1:-release}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/UTCMenuBar.app"

cd "$ROOT"

# Derive version from latest annotated tag like v0.6.0
if VERSION_TAG="$(git -C "$ROOT" describe --tags --match 'v*' --abbrev=0 2>/dev/null)"; then
    SHORT_VERSION="${VERSION_TAG#v}"
else
    SHORT_VERSION="0.0.0-dev"
fi
# Bundle version (CFBundleVersion) is a monotonic counter; use commit count
if BUILD_NUMBER="$(git -C "$ROOT" rev-list --count HEAD 2>/dev/null)"; then
    :
else
    BUILD_NUMBER="1"
fi

echo "==> version $SHORT_VERSION (build $BUILD_NUMBER)"
echo "==> swift build -c $CONFIG"
swift build -c "$CONFIG"

BIN_PATH="$(swift build -c "$CONFIG" --show-bin-path)"

echo "==> assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$BIN_PATH/UTCMenuBar" "$APP/Contents/MacOS/UTCMenuBar"

cp "$ROOT/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>UTCMenuBar</string>
	<key>CFBundleIdentifier</key>
	<string>com.utcmenubar.app</string>
	<key>CFBundleVersion</key>
	<string>$BUILD_NUMBER</string>
	<key>CFBundleShortVersionString</key>
	<string>$SHORT_VERSION</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleExecutable</key>
	<string>UTCMenuBar</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>
PLIST

echo "==> done: $APP"
echo "    run with: open $APP"
