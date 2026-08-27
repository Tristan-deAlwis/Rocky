#!/bin/bash
# Regenerates the app icon PNG from RockShape.
#
# Compiles the generator together with the app's own RockShape.swift so the icon
# is always the same vector the menu bar uses — there is no second copy of the
# mark to drift.

set -euo pipefail

cd "$(dirname "$0")/.."

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

BIN="$(mktemp -d)/generate-appicon"

xcrun swiftc \
    -target "$(uname -m)-apple-macos14.0" \
    -O \
    scripts/generate-appicon.swift \
    Sources/Views/RockShape.swift \
    -o "$BIN"

rm -f Sources/Assets.xcassets/AppIcon.appiconset/*.png

"$BIN" "Sources/Assets.xcassets/AppIcon.appiconset"
