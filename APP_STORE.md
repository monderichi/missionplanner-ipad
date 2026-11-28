# Getting the app onto the App Store (paid)

Section 1 is for people: what has to happen, and what only you can do. Section 2 is for Claude: the work it can do,
in order, with the files, commands and limits.

---

## 1. For humans: what needs to be done

**Decide these first. They can block the whole release.**
1. **License.** The README says the app is GPLv3 because it reuses Mission Planner's message definitions. The
   parameter metadata comes from ArduPilot, which is GPLv3 too. The App Store's terms are widely considered
   incompatible with GPL distribution: VLC was pulled for this reason in 2011.
   - You can only sell under your own license the code you, or contributors who agree, wrote yourselves.
   - Anything copied or derived from Mission Planner or ArduPilot must be replaced, or relicensed with permission.
   - Ask a lawyer, or the copyright holders, before you pay for anything.
2. **Name and branding.** "Mission Planner" is the name of an existing ArduPilot product. A paid app with that name
   will likely be rejected for copying (guideline 4.1) or intellectual property (5.2). Pick your own name and icon,
   and say "compatible with ArduPilot" instead.
3. **Map tiles.**
   - Esri World Imagery needs an Esri/ArcGIS license for commercial use.
   - OpenStreetMap's tile servers forbid heavy app use.
   - Either license a tile provider, or use Apple's own MapKit satellite map, which is free in the app.

**Accounts and paperwork (only you can do these):**
- Join the **Apple Developer Program**: 99 USD a year, as an individual, or as a company with a D-U-N-S number.
- In **App Store Connect › Business**:
  - accept the **Paid Apps Agreement**;
  - add a **bank account**;
  - complete the **tax forms** (for example W-8BEN if you're outside the US);
  - for EU sales, declare **trader status**. Your address, phone and email are then shown publicly.
- Create the **app record** (name, bundle ID, SKU, primary language) and choose a **price**.
- Put up a **privacy policy URL** and a **support URL**, for example GitHub Pages. Claude can write the pages.
- Answer the **age rating**, **export compliance** and **App Privacy** questionnaires. Claude prepares the answers.

**Make the app reviewable.** Apple's reviewer has no drone. The app needs a **demo mode** with a built-in simulated or
replayed vehicle. Explain it in the review notes, with a short video of the app on a real vehicle.

**Build, upload, submit:**
- **Build and upload:** this needs a Mac with Xcode and your developer account. GitHub Actions isn't needed. Claude
  prepares everything, and you sign in and click Upload, or approve the command.
- **Before you submit:** test the build on your own iPad through TestFlight, ideally with a real vehicle.
- **Submit for review:** you press the button. Review usually takes 1–3 days. Expect questions about drone safety
  and the demo mode.

**Rough order:** license and name decision → developer account and agreements → Claude's tasks (section 2) →
TestFlight on a real iPad → submit.

---

## 2. For Claude: tasks you can do

Read `CLAUDE.md`, `COLLABORATOR_PROMPT.md` (rules and test commands) and section 1 above first.

### Ground rules for this work
- **Never do these for the user:**
  - accept agreements, pay, enter bank or tax data, or sign in to Apple;
  - enter passwords, API keys or certificates into any field;
  - press "Submit for Review", or set prices or availability.
- Prepare these instead and tell the user exactly what to click.
- **App Store Connect API key:** the user creates it and keeps the `.p8` file outside the repo. Never commit or print
  it. Refer to it through environment variables the user sets.
- **Stay truthful:**
  - Don't imply an affiliation with ArduPilot or Mission Planner, and don't use their logos.
  - Don't invent features, reviews, awards or test results.
  - Every screenshot must show the real app.
- **Licensing:** until the user confirms the license decision (section 1, item 1), you can still do the steps below,
  but don't change license files. List the GPL-derived files in a `docs/LICENSE_AUDIT.md`, so the user can decide.
- **Follow the repo rules:**
  - work on a branch;
  - get an independent review before merging;
  - use `[skip ci]` (no GitHub Actions minutes);
  - verify locally (unit tests, harness, Catalyst build).
- **Never connect to real hardware.**

### Facts about the project today
- **`project.yml`:**
  - bundle id `io.github.missionplannerpad.app`, which must change to a domain the user owns;
  - `PRODUCT_NAME` is `MissionPlannerPad`;
  - iPad only (`TARGETED_DEVICE_FAMILY "2"`), iOS 16;
  - signing is disabled (`CODE_SIGNING_ALLOWED NO`, empty `DEVELOPMENT_TEAM`), because the IPA is unsigned for
    Sideloadly.
- **`Config/Info.plist` already has:** `NSLocalNetworkUsageDescription`, `NSBluetoothAlwaysUsageDescription`,
  `NSBonjourServices`, ATS `NSAllowsLocalNetworking`, `UIRequiresFullScreen`, `UIFileSharingEnabled`.
- **Missing:**
  - an app icon (there is no asset catalog);
  - `PrivacyInfo.xcprivacy`;
  - `ITSAppUsesNonExemptEncryption`;
  - a demo mode;
  - a bundled sample flight;
  - store metadata, privacy policy and support pages.
- **Already there:**
  - The app uses no location services, no accounts, no analytics and no ads.
  - It stores tlogs, parameter files and DataFlash logs locally, in Documents.
  - It downloads map tiles from Esri/OSM (`App/Map/TileCache.swift`).
  - Screenshot automation: `scripts/sim_screenshots.sh` boots an iPad simulator, starts `tools/fake_vehicle.py` and
    takes shots. The app reads `-MPAutoConnect tcp:127.0.0.1:5760`, `-MPScreen <screen>` and `-MPTab <tab>` launch
    arguments (`App/UI/RootView.swift`).
  - Replay of `.tlog` files: `App/Link/ReplayTransport.swift`.

### Tasks, in order (each a small PR)
1. **License audit (docs only).** Write `docs/LICENSE_AUDIT.md` with:
   - every file with a `REA Parity Source` header or generated from Mission Planner or ArduPilot data:
     `Generated/MAVLinkMessages.swift`, `App/Resources/ParamMeta/*.json`, `MissionCommands.json`, `tools/gen_*`;
   - the third-party tile services.

   For each, give the origin, the license, and what would have to be replaced for a non-GPL release. Stop there: the
   user decides.
2. **Rename and branding (after the user picks a name).**
   - Set `CFBundleDisplayName` (30 chars max).
   - Set `PRODUCT_NAME` and the bundle id from the user.
   - Update in-app strings that say "Mission Planner" where they name this app. Keep them where they mean the desktop
     program.
   - Keep the `// REA Parity Source:` comments: they are attribution.
3. **App icon.**
   - Add `App/Resources/Assets.xcassets/AppIcon.appiconset`: a single 1024×1024 PNG, no transparency, no rounded
     corners, plus its `Contents.json`.
   - Wire it in `project.yml` with `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon` and add the asset catalog to the
     sources.
   - You can draw a simple original icon as SVG and render it, for example a stylised quad on a map grid. Ask the user
     to approve it, or to supply their own.
4. **Demo mode (needed for App Review).**
   - Add a "Try demo (simulated vehicle)" button to the Connect screen.
   - It starts an in-app simulated vehicle, or replays a bundled sample flight.
   - Simplest: record a real flight `.tlog` from SITL (`testing/sitl`, 2–3 minutes: takeoff, mission, RTL), bundle it
     under `App/Resources/Demo/`, and play it through `ReplayTransport` on a loop.
   - Show a clear "DEMO, no vehicle connected" banner, and make sure no command can be sent in demo mode.
   - Add a harness scenario that checks demo mode connects, shows telemetry and sends nothing.
5. **Privacy and compliance files.**
   - **`App/PrivacyInfo.xcprivacy`:**
     - `NSPrivacyTracking false`, with no tracking domains and no collected data types;
     - required-reason APIs: grep for `UserDefaults` (reason `CA92.1`), file timestamps (`C617.1` or `3B52.1`),
       `systemUptime` (`35F9.1`) and disk space (`E174.1`, used by `LogStore`).

     Check each reason code against Apple's current list before using it.
   - **`Config/Info.plist`:** add `ITSAppUsesNonExemptEncryption` `false`. The app only uses OS-provided TLS and
     plain MAVLink, but confirm that with the user.
   - **Answers for the user to paste:** write `docs/app-store/privacy-answers.md` with the App Privacy answers (Data
     Not Collected, if that is true) and the age rating answers (likely 4+), and `docs/app-store/export-compliance.md`.
6. **Map tiles.** Following the user's decision in section 1, item 3:
   - either make Apple MapKit satellite or standard the default, with Esri/OSM removed or behind a license setting;
   - or add the licensed provider.

   Keep the attribution on the map in every case.
7. **Release signing config (no secrets in the repo).** Add a `Release-AppStore` configuration, or an `xcodegen`
   variant, with `CODE_SIGN_STYLE Automatic`, `CODE_SIGNING_ALLOWED YES` and `DEVELOPMENT_TEAM` from an environment
   variable or an untracked `Config/Signing.xcconfig`. Keep the unsigned Sideloadly build working unchanged.
   - Add `scripts/archive_appstore.sh`. It runs `xcodegen`, then
     `xcodebuild archive -scheme ... -configuration Release-AppStore -archivePath build/App.xcarchive`, then
     `xcodebuild -exportArchive -exportOptionsPlist Config/ExportOptions-AppStore.plist`.
   - `Config/ExportOptions-AppStore.plist` uses `method app-store-connect` and `destination upload`.
   - The upload uses `-authenticationKeyPath "$ASC_KEY_PATH" -authenticationKeyID "$ASC_KEY_ID"
     -authenticationKeyIssuerID "$ASC_ISSUER_ID"`, which the user sets locally. Otherwise the user uploads from Xcode's
     Organizer.
   - Bump `CFBundleVersion` for every upload.
8. **Screenshots (iPad 13-inch: 2064×2752 portrait or 2752×2064 landscape; 3–10 shots).**
   - These need the **iOS Simulator runtime**, about 8 GB. The user has declined that download before, so ask first.
     Mac Catalyst screenshots are not acceptable: they come from the Mac app.
   - With the runtime installed, extend `scripts/sim_screenshots.sh` to target "iPad Pro 13-inch (M4)" and write
     `docs/app-store/screenshots/*.png`.
   - Suggested shots, all against `tools/fake_vehicle.py` or the demo flight:
     - HUD + map in flight (`-MPScreen data -MPTab quick`);
     - mission planning with a survey grid (`-MPScreen plan`);
     - Parameters with descriptions;
     - Setup › calibration;
     - Actions;
     - DataFlash log review / graph;
     - a Rover or Sub screen (`tools/fake_vehicle.py --type rover|sub`).
   - Check each PNG's pixel size with `sips -g pixelWidth -g pixelHeight`. Hide debug UI, and use realistic but
     clearly simulated data.
   - Optional: a 15–30 s App Preview video with `xcrun simctl io <udid> recordVideo`.
9. **Store text: `docs/app-store/metadata/en-US/*.txt`, one field per file, in the fastlane `deliver` layout.**
   | File | Content | Limit |
   |---|---|---|
   | `name.txt` | the app name | 30 characters |
   | `subtitle.txt` | a short tagline | 30 characters |
   | `promotional_text.txt` | promotional text | 170 characters |
   | `description.txt` | the full description | 4000 characters |
   | `keywords.txt` | comma-separated keywords | 100 characters |
   | `release_notes.txt` | what's new in this version | — |
   | `support_url.txt`, `privacy_url.txt` | the two page URLs | — |
   | `primary_category.txt` | likely Navigation or Utilities; let the user choose | — |

   - Describe only features listed under README "What works". Name the supported links (Wi-Fi/UDP/TCP,
     ExpressLRS backpack, BLE) and firmware (ArduCopter, ArduRover, ArduSub 4.x).
   - Put the safety note in the description: not certified for safety-critical use; follow local drone laws.
   - Write a script that checks every length limit.
   - Add other languages only if the user asks.
10. **Privacy policy and support pages.** Write `docs/site/privacy.md` and `docs/site/support.md`:
    - The privacy policy is plain and true: no data collected; logs stay on the device; map tiles are fetched from
      the named provider; Bluetooth and local network are used only to talk to the user's vehicle.
    - The support page gives a contact address the user chooses, a FAQ (connecting over ExpressLRS, demo mode,
      Local Network permission) and a link to issues.
    - The user publishes them, for example with GitHub Pages from `docs/`. Don't enable Pages yourself.
11. **Review notes.** Write `docs/app-store/review_notes.md` for the user to paste:
    - what the app does and that it needs an ArduPilot vehicle;
    - how to use demo mode, in three steps;
    - why it asks for Local Network and Bluetooth;
    - that no account is needed;
    - a link to the real-flight video, which the user records.
12. **Pre-flight checklist before upload.**
    - Run the unit tests, the harness, and the Catalyst build and UI tests (commands in `COLLABORATOR_PROMPT.md`).
    - Archive locally.
    - Run `xcrun altool --validate-app`, or Organizer › Validate, with the user's key.
    - Check all of these:
      - no private API;
      - no debug-only strings;
      - every `NS...UsageDescription` is present and accurate;
      - the iPad layout looks right in all supported orientations;
      - demo mode works offline.
    - Then tell the user it's ready for TestFlight.

### What to hand back to the user after each task
- what was done;
- what you verified, and how;
- the exact clicks or fields left for them, for example "App Store Connect › App Privacy › paste
  `docs/app-store/privacy-answers.md`".

Don't mark the release ready while license, name or tiles are undecided.
