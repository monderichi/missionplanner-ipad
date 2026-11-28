#!/usr/bin/env bash
# Builds the headless GCS: the app's real App/Link, App/Vehicle and App/Storage sources (copied
# unmodified) + testing/harness/Sources/*.swift (driver + scenarios), for macOS, with CLT only.
# Output: testing/.build/harnesspkg/.build/debug/Harness (resources copied next to it).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PKG="$ROOT/testing/.build/harnesspkg"
mkdir -p "$ROOT/testing/logs"
rm -rf "$PKG/Sources"; mkdir -p "$PKG/Sources/Harness/App"
for d in Link Vehicle Storage; do cp "$ROOT"/App/$d/*.swift "$PKG/Sources/Harness/App/"; done
# App/Control: only the model (ManualControl); ControlView is SwiftUI. UIKit symbols come from UIKitShim.
[[ -f "$ROOT/App/Control/ManualControl.swift" ]] && cp "$ROOT/App/Control/ManualControl.swift" "$PKG/Sources/Harness/App/"
mkdir -p "$PKG/Sources/UIKit"; cp "$ROOT/testing/harness/UIKitShim/UIKit.swift" "$PKG/Sources/UIKit/"
cp "$ROOT"/testing/harness/Sources/*.swift "$PKG/Sources/Harness/"
cat > "$PKG/Package.swift" <<PKGEOF
// swift-tools-version:5.9
import PackageDescription
let package = Package(name: "Harness", platforms: [.macOS(.v13)],
  dependencies: [.package(path: "$ROOT/Packages/MAVLinkKit")],
  targets: [.target(name: "UIKit", path: "Sources/UIKit"),
            .executableTarget(name: "Harness", dependencies: ["UIKit", .product(name: "MAVLinkKit", package: "MAVLinkKit")],
                              path: "Sources/Harness", swiftSettings: [.unsafeFlags(["-swift-version", "5",
                                 // test code only: CI's slower compiler gave up on long probe closures at the default 600 ms
                                 "-Xfrontend", "-solver-expression-time-threshold=3000"])])])
PKGEOF
cd "$PKG"
# HARNESS_SANITIZE=thread|address builds a sanitizer variant in its own scratch dir
SAN=()
if [[ -n "${HARNESS_SANITIZE:-}" ]]; then SAN=(--sanitize="$HARNESS_SANITIZE" --scratch-path "$PKG/.build-$HARNESS_SANITIZE"); fi
if ! swift build ${HARNESS_CONFIG:+-c $HARNESS_CONFIG} ${SAN[@]+"${SAN[@]}"} > "$ROOT/testing/logs/harness_build.log" 2>&1; then
  echo "HARNESS BUILD FAILED (testing/logs/harness_build.log):"; grep -E "error:" "$ROOT/testing/logs/harness_build.log" | sed 's/\x1b\[[0-9;]*m//g' | head -20; exit 2
fi
BIN="$(swift build ${HARNESS_CONFIG:+-c $HARNESS_CONFIG} ${SAN[@]+"${SAN[@]}"} --show-bin-path)"
cp "$ROOT/App/Resources/MissionCommands.json" "$BIN/"
mkdir -p "$BIN/ParamMeta"; cp "$ROOT"/App/Resources/ParamMeta/*.json "$BIN/ParamMeta/"
echo "$BIN/Harness"
