#!/bin/bash
# Builds Pulse and wraps it in Pulse.app (needed for notifications).
set -euo pipefail
swift build -c release
APP=Pulse.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/Pulse "$APP/Contents/MacOS/Pulse"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>Pulse</string>
  <key>CFBundleIdentifier</key><string>dev.example.pulse</string>
  <key>CFBundleName</key><string>Pulse</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$APP"
echo "Built $APP — run: open $APP"
