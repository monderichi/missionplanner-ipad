#!/usr/bin/env bash
# Builds an UNSIGNED MissionPlanner-iPad-Sideloadly.ipa (Payload/MissionPlannerPad.app zipped).
# Sideloadly signs it with your Apple ID when you install it.
# Runs on macOS with Xcode + XcodeGen (the GitHub Actions workflow does exactly this).
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"
BUILD="$ROOT/build"
APP_NAME="MissionPlannerPad"
IPA="$BUILD/MissionPlanner-iPad-Sideloadly.ipa"

command -v xcodegen >/dev/null || { echo "xcodegen not found (brew install xcodegen)"; exit 1; }
xcodegen generate

rm -rf "$BUILD"
mkdir -p "$BUILD"

xcodebuild \
  -project "$APP_NAME.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$BUILD/DerivedData" \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  CURRENT_PROJECT_VERSION="${GITHUB_RUN_NUMBER:-1}" GIT_COMMIT="${GITHUB_SHA:0:7}" \
  build | tee "$BUILD/xcodebuild.log" | grep -E "error:|warning: .*deprecated|BUILD (SUCCEEDED|FAILED)" || true

# grep's exit status is ignored above; check the real build result
if ! grep -q "BUILD SUCCEEDED" "$BUILD/xcodebuild.log"; then
  echo "xcodebuild failed; last 80 lines:"
  tail -80 "$BUILD/xcodebuild.log"
  exit 1
fi

APP="$BUILD/DerivedData/Build/Products/Release-iphoneos/$APP_NAME.app"
[ -d "$APP" ] || { echo "missing $APP"; exit 1; }

mkdir -p "$BUILD/Payload"
cp -R "$APP" "$BUILD/Payload/"
(cd "$BUILD" && zip -qry "$IPA" Payload)

echo "Built $IPA"
ls -lh "$IPA"
/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP/Info.plist"
/usr/libexec/PlistBuddy -c "Print :UIFileSharingEnabled" "$APP/Info.plist"
