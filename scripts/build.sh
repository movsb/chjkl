#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
app="$PWD/build/Chjkl.app"
mkdir -p "$app/Contents/MacOS"
swiftc -O -target "$(uname -m)-apple-macosx13.0" -module-cache-path /tmp/chjkl-module-cache Sources/Remapper.swift Sources/main.swift -o "$app/Contents/MacOS/Chjkl"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>local.tao.chjkl</string>
<key>CFBundleName</key><string>Chjkl</string>
<key>CFBundleExecutable</key><string>Chjkl</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$app"
printf 'Built %s\n' "$app"
