#!/usr/bin/env bash
# Runs MAVLinkKit's XCTest suite (plus testing/unit/extra/*.swift) with Command Line Tools only.
# Copies the test sources into testing/.build/unitpkg, generates a main.swift that calls every
# `func test*()` in every XCTestCase subclass, builds and runs. Exit 0 = all passed.
# Usage: testing/unit/run_unit_tests.sh [--no-extra]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PKG="$ROOT/testing/.build/unitpkg"
LOG="$ROOT/testing/logs/unit_tests.log"
mkdir -p "$ROOT/testing/logs"
rm -rf "$PKG/Sources/RunTests"; mkdir -p "$PKG/Sources/RunTests"
cp -R "$ROOT/testing/unit/shim/Sources/XCTest" "$PKG/Sources/" 2>/dev/null || true
cp "$ROOT"/Packages/MAVLinkKit/Tests/MAVLinkKitTests/*.swift "$PKG/Sources/RunTests/"
cp -R "$ROOT/Packages/MAVLinkKit/Tests/MAVLinkKitTests/Fixtures" "$PKG/Sources/RunTests/"
if [[ "${1:-}" != "--no-extra" ]] && ls "$ROOT"/testing/unit/extra/*.swift >/dev/null 2>&1; then
  cp "$ROOT"/testing/unit/extra/*.swift "$PKG/Sources/RunTests/"
fi
cat > "$PKG/Package.swift" <<PKGEOF
// swift-tools-version:5.9
import PackageDescription
let package = Package(name: "UnitRunner", platforms: [.macOS(.v13)],
  dependencies: [.package(path: "$ROOT/Packages/MAVLinkKit")],
  targets: [
    .target(name: "XCTest", path: "Sources/XCTest"),
    .executableTarget(name: "RunTests", dependencies: ["XCTest", .product(name: "MAVLinkKit", package: "MAVLinkKit")],
                      path: "Sources/RunTests", resources: [.copy("Fixtures")]),
  ])
PKGEOF
python3 - "$PKG/Sources/RunTests" <<'PY'
import re, sys, pathlib
d = pathlib.Path(sys.argv[1]); calls = []
for f in sorted(d.glob("*.swift")):
    cls = None
    for line in f.read_text().splitlines():
        m = re.match(r'\s*(?:final\s+)?class\s+(\w+)\s*:\s*XCTestCase', line)
        if m: cls = m.group(1); continue
        if re.match(r'\s*(?:final\s+)?class\s+\w+', line): cls = None; continue
        m = re.match(r'\s*func\s+(test\w+)\(\)\s*(throws)?', line)
        if m and cls: calls.append((cls, m.group(1), bool(m.group(2))))
out = ["import Foundation", "import XCTest", "var ran = 0, failedTests: [String] = []",
       "func run(_ name: String, _ body: () throws -> Void) { ran += 1; XCTestShim.current = name; let before = XCTestShim.failures.count",
       "  do { try body() } catch { XCTestShim.failures.append(\"\\(name): threw \\(error)\") }",
       "  if XCTestShim.failures.count > before { failedTests.append(name); print(\"FAIL \\(name)\") } else { print(\"pass \\(name)\") } }"]
for cls, fn, thr in calls:
    out.append(f'run("{cls}.{fn}") {{ let t = {cls}(); t.setUp(); {"try " if thr else ""}t.{fn}(); t.tearDown() }}')
out += ['print("RESULT: \\(ran) tests, \\(failedTests.count) failed")', 'exit(failedTests.isEmpty ? 0 : 1)']
(d / "main.swift").write_text("\n".join(out) + "\n")
PY
cd "$PKG"
if ! swift build > "$LOG.build" 2>&1; then echo "BUILD FAILED, see $LOG.build"; grep -E "error:" "$LOG.build" | head -20; exit 2; fi
set +e; "$(swift build --show-bin-path)/RunTests" > "$LOG" 2>&1; rc=$?; set -e
grep -E "^FAIL|FAIL |RESULT" "$LOG" | head -40
exit $rc
