#!/bin/bash
# Render the README's native views and style examples without launching the
# user's app, changing its preferences, or making update requests.
# Usage: ./scripts/render-readme.sh [output-directory]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSET_DIR="${1:-$REPO_ROOT/docs/assets}"
mkdir -p "$ASSET_DIR"
ASSET_DIR="$(cd "$ASSET_DIR" && pwd)"
RENDER_DIR="$(mktemp -d "${TMPDIR:-/tmp}/utcmenubar-readme.XXXXXX")"
trap 'rm -rf "$RENDER_DIR"' EXIT

cd "$REPO_ROOT"
swift build --product UTCMenuBar
BIN_DIR="$(swift build --show-bin-path)"

DOC_APP="$RENDER_DIR/UTCMenuBarDocs.app"
mkdir -p "$DOC_APP/Contents/MacOS"
VERSION="$(git describe --tags --match 'v*' --abbrev=0 2>/dev/null || echo v0.0.0)"
BUILD_NUMBER="$(git rev-list --count HEAD 2>/dev/null || echo 1)"
cat > "$DOC_APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.utcmenubar.documentation</string>
<key>CFBundleExecutable</key><string>UTCMenuBarDocs</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>${VERSION#v}</string>
<key>CFBundleVersion</key><string>$BUILD_NUMBER</string>
<key>LSUIElement</key><true/>
<key>NSPrincipalClass</key><string>NSApplication</string>
</dict></plist>
PLIST

# Compile the real UI sources against the library just built. The documentation
# entry point replaces the app delegate; the release app is never modified.
swiftc -swift-version 6 -parse-as-library \
  -target "$(uname -m)-apple-macosx13.0" \
  -I "$BIN_DIR/Modules" \
  "$REPO_ROOT/scripts/render-readme.swift" \
  "$REPO_ROOT/Sources/ClockPopoverView.swift" \
  "$REPO_ROOT/Sources/SettingsView.swift" \
  "$REPO_ROOT/Sources/TimezoneConverterWindowController.swift" \
  "$REPO_ROOT/Sources/LaunchAtLoginManager.swift" \
  "$BIN_DIR"/UTCMenuBarLib.build/*.swift.o \
  -o "$DOC_APP/Contents/MacOS/UTCMenuBarDocs"

codesign --force --sign - "$DOC_APP"
open -n -W "$DOC_APP" --args "$ASSET_DIR"
# `open` does not forward the child process's exit code.
test -f "$ASSET_DIR/.render-complete"
rm "$ASSET_DIR/.render-complete"
echo "README images written to $ASSET_DIR"
