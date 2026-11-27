#!/usr/bin/env bash
# Builds ArduCopter SITL (the real autopilot, compiled for macOS) into testing/.sitl.
# ~1.5 GB, ~10-20 min the first time. Remove with: rm -rf testing/.sitl testing/.venv
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SITL="$ROOT/testing/.sitl"; VENV="$ROOT/testing/.venv"
TAG="${ARDUPILOT_TAG:-Copter-4.7.3}"
[[ -d "$VENV" ]] || python3 -m venv "$VENV"
"$VENV/bin/pip" install -q --upgrade pip
"$VENV/bin/pip" install -q "empy==3.3.4" pexpect future setuptools
if [[ ! -d "$SITL/ardupilot" ]]; then
  mkdir -p "$SITL"
  git clone -q --depth 1 --branch "$TAG" --recurse-submodules --shallow-submodules \
      https://github.com/ArduPilot/ardupilot.git "$SITL/ardupilot"
fi
cd "$SITL/ardupilot"
# macOS ld (Xcode 15+/CLT) rejects the unaligned pointers in the PACKED AP_FWVersion struct
# ("ld: pointer not aligned in AP_FWVersion::fwver"). Packing only matters for firmware images, so drop it for SITL.
if [[ "$(uname)" == "Darwin" ]] && grep -q "^class PACKED AP_FWVersion" libraries/AP_Common/AP_FWVersion.h; then
  sed -i '' 's/^class PACKED AP_FWVersion/class AP_FWVersion/' libraries/AP_Common/AP_FWVersion.h
  echo "patched AP_FWVersion (macOS linker)"
fi
PATH="$VENV/bin:$PATH" ./waf configure --board sitl
PATH="$VENV/bin:$PATH" ./waf copter
ls -la build/sitl/bin/arducopter
