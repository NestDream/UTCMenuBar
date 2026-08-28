#!/bin/bash
# Builds UTCMenuBar.app — a runnable macOS .app bundle wrapping the SPM executable.
# Usage: ./scripts/build-app.sh [debug|release] [--universal]   (default: release)
#
# --universal builds an arm64 + x86_64 fat binary (use for release artifacts;
# the default single-arch build is faster for local iteration).
#
# Version: derived from the latest git tag matching `v*` (stripped of the leading "v").
# Falls back to "0.0.0-dev" when not in a git checkout or no tag exists.

set -euo pipefail

CONFIG="release"
# Plain string (not an array): macOS ships bash 3.2, where expanding an empty
# array under `set -u` errors out.
ARCH_FLAGS=""
for arg in "$@"; do
    case "$arg" in
        debug|release) CONFIG="$arg" ;;
        --universal) ARCH_FLAGS="--arch arm64 --arch x86_64" ;;
        *)
            echo "error: unknown argument '$arg'" >&2
            echo "usage: $0 [debug|release] [--universal]" >&2
            exit 2
            ;;
    esac
done
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
echo "==> swift build -c $CONFIG $ARCH_FLAGS"
# shellcheck disable=SC2086  # intentional word splitting of the flag string
swift build -c "$CONFIG" $ARCH_FLAGS

BIN_PATH="$(swift build -c "$CONFIG" $ARCH_FLAGS --show-bin-path)"

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
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.utilities</string>
	<key>NSHumanReadableCopyright</key>
	<string>© 2026 Li Guo. MIT License.</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>
PLIST

# Ad-hoc signature: keeps the bundle's code signature valid after assembly so
# macOS treats it consistently (TCC permission identity, launch services).
# Distribution builds still need Developer ID + notarization to skip Gatekeeper.
echo "==> codesign (ad-hoc)"
codesign --force --sign - "$APP"

echo "==> architectures: $(lipo -archs "$APP/Contents/MacOS/UTCMenuBar")"
echo "==> done: $APP"
echo "    run with: open $APP"
