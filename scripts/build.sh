#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
version="${CHJKL_VERSION:-0.1.0}"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf 'Invalid CHJKL_VERSION (expected major.minor.patch): %s\n' "$version" >&2
    exit 1
fi
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
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" "$app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $version" "$app/Contents/Info.plist"
# Use the same certificate on every build to preserve the signing identity.
identity="${CHJKL_SIGN_IDENTITY:--}"
codesign --force --sign "$identity" "$app"
codesign --verify --strict "$app"
if [[ "$identity" == "-" ]]; then
    printf '%s\n' 'Warning: ad-hoc signing; rebuilding may invalidate Accessibility permission.' 'For recovery, run ./scripts/reset-accessibility.sh, then grant permission again.' >&2
fi
printf 'Built %s\n' "$app"
