#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
swiftc -module-cache-path /tmp/chjkl-module-cache Sources/Remapper.swift Tests/main.swift -o build/remapper-tests
build/remapper-tests
