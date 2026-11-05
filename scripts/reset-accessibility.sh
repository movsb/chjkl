#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
app="$PWD/build/Chjkl.app"
if [[ ! -x "$app/Contents/MacOS/Chjkl" ]]; then
    printf '%s\n' 'Build Chjkl first: ./scripts/build.sh' >&2
    exit 1
fi
# Stop only this bundle's executable, including copies installed elsewhere.
/usr/bin/pkill -x Chjkl || true
/usr/bin/tccutil reset Accessibility local.tao.chjkl
/usr/bin/open "$app"
/usr/bin/open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'
printf '%s\n' 'Add the current build/Chjkl.app in Accessibility and enable it.' 'If an old Chjkl entry remains, remove it with −, then add this app with +.'
