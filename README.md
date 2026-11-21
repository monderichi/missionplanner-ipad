# Mission Planner for iPad (Sideloadly build)

A native SwiftUI ground control station for ArduPilot, rebuilt for iPadOS and modelled on
ArduPilot Mission Planner. Desktop Mission Planner is a Windows .NET/WinForms program and can't
run on an iPad, so this is a new app. Its MAVLink layer comes straight from Mission Planner's own
`MAVLink.dll` and is tested against packets that DLL produces.

## What works now (phases 1–2)

- **Links:** UDP listen (default 14550), UDP connect, TCP client (e.g. SITL 5760), and Bluetooth LE
  UART bridges (Nordic UART / HM-10). USB serial isn't possible because iPadOS blocks it for sideloaded apps.
- **MAVLink v1/v2:** all 349 messages Mission Planner knows (ardupilotmega dialect), CRC_EXTRA
  validation, v2 zero-truncation, signed-frame parsing (signatures are skipped, not verified),
  resync after line noise, and packet-loss stats.
- **GCS behaviour:** sends a 1 Hz heartbeat as sysid 255 / compid 190 (Mission Planner's ID) and
  requests data streams with REQUEST_DATA_STREAM when a vehicle appears.
- **.tlog recording:** logs both directions in Mission Planner's format (8-byte big-endian µs
  timestamp + raw frame). Files go to *Files › On My iPad › Mission Planner › logs* and open in
  desktop Mission Planner.
- **Screens:** HUD (horizon, pitch ladder, roll scale, heading tape, speed/alt), map with the
  vehicle marker, Quick tiles, a full status list and STATUSTEXT messages.

It's read-only so far: there's no arming, mode change, mission or parameter editing yet. Those
come in phases 3–6 (see `CLAUDE_PROMPTS.md`).

## Build the .ipa (no Mac needed)

GitHub's free macOS runners do the compiling.

1. Create a GitHub repository and push this folder to it. You can drag the files into the GitHub
   web page, use GitHub Desktop, or run:
   ```
   git init
   git add .
   git commit -m "Mission Planner iPad"
   git branch -M main
   git remote add origin https://github.com/<you>/<repo>.git
   git push -u origin main
   ```
2. On GitHub, open **Actions › Build Sideloadly IPA**. Each push runs it, and you can also start
   it with *Run workflow*. It runs the MAVLink tests, then builds an unsigned
   `MissionPlanner-iPad-Sideloadly.ipa`.
3. When the run goes green, download the **MissionPlanner-iPad-Sideloadly** artifact from the run
   page and unzip it to get the `.ipa`.

## Install with Sideloadly (Windows)

1. Install iTunes (the version from apple.com, not the Microsoft Store one) and Sideloadly
   (sideloadly.io).
2. Connect the iPad by USB and tap *Trust* on the iPad.
3. Drag the `.ipa` into Sideloadly, enter your Apple ID and click **Start**.
4. On the iPad, go to *Settings › General › VPN & Device Management*, then trust your Apple ID.
   On iPadOS 16+ you also need *Settings › Privacy & Security › Developer Mode* (this restarts the iPad).
5. With a free Apple ID the app expires after **7 days**. Re-run Sideloadly to refresh it, or turn
   on its auto-refresh. Your logs/params/missions in Documents are kept.

## Connect to a vehicle

| Setup | In the app |
|---|---|
| ESP8266/ESP32 Wi-Fi telemetry (iPad joined to its Wi-Fi) | UDP listen 14550, or UDP connect 192.168.4.1:14550 |
| SITL / MAVProxy / mavlink-router on a PC | `--out udp:<iPad-IP>:14550` → UDP listen, or TCP `<PC-IP>:5760` |
| BLE telemetry bridge | Bluetooth LE → pick the device |

The first time you connect, iPadOS asks for **Local Network** (or Bluetooth) permission. Allow it.
If you denied it, enable it again under *Settings › Mission Planner*.

## Layout

```
App/                      SwiftUI app (transports, link manager, vehicle model, UI)
Config/Info.plist         file sharing, local network, Bluetooth, landscape
Packages/MAVLinkKit/      MAVLink codec + tlog, with tests (runs on the CI Mac via `swift test`)
  Sources/MAVLinkKit/Generated/MAVLinkMessages.swift   generated, do not edit
tools/
  dump_mavlink_defs.ps1   reads Mission Planner's MAVLink.dll -> tools/mavlink_defs.json
  make_fixtures.ps1       encodes test packets with Mission Planner's own encoder
  gen_swift.py            mavlink_defs.json -> Swift message structs
  mavlink_ref.py          Python twin of the Swift codec, checked against the fixtures on Windows
project.yml               XcodeGen spec (the .xcodeproj is generated on CI)
scripts/package_ipa.sh    xcodebuild (unsigned) -> Payload/ -> .ipa
.github/workflows/build-sideloadly-ipa.yml
```

To regenerate after a Mission Planner update (Windows):
```
powershell -File tools\dump_mavlink_defs.ps1
powershell -File tools\make_fixtures.ps1
python -I tools\gen_swift.py
python -I tools\mavlink_ref.py
```

## License

Mission Planner is GPLv3, and this app reuses its message definitions, so distribute it under
GPLv3 too.
