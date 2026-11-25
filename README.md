# Mission Planner for iPad (Sideloadly build)

> Agents: development status and handoff notes are in `CLAUDE.md`.

A native SwiftUI ground control station for ArduPilot, rebuilt for iPadOS and modelled on
ArduPilot Mission Planner. Desktop Mission Planner is a Windows .NET/WinForms program and can't
run on an iPad, so this is a new app. Its MAVLink layer comes straight from Mission Planner's own
`MAVLink.dll` and is tested against packets that DLL produces.

## What works now (phases 1–3)

- **Links:** UDP listen (default 14550), UDP connect, TCP client (e.g. SITL 5760), ExpressLRS
  TX Backpack Wi-Fi (MAVLink link mode, 10.0.0.1:14555 ⇄ iPad:14550), and Bluetooth LE
  UART bridges (Nordic UART / HM-10). USB serial isn't possible because iPadOS blocks it for sideloaded apps.
- **MAVLink v1/v2:** all 349 messages Mission Planner knows (ardupilotmega dialect), CRC_EXTRA
  validation, v2 zero-truncation, signed-frame parsing (signatures are skipped, not verified),
  resync after line noise, and packet-loss stats.
- **GCS behaviour:** sends a 1 Hz heartbeat as sysid 255 / compid 190 (Mission Planner's ID) and
  requests data streams with REQUEST_DATA_STREAM when a vehicle appears. On ExpressLRS/BLE it asks
  for low rates (HUD 4 Hz) so the narrow link isn't flooded.
- **.tlog recording:** logs both directions in Mission Planner's format (8-byte big-endian µs
  timestamp + raw frame). Files go to *Files › On My iPad › Mission Planner › logs* and open in
  desktop Mission Planner.
- **Screens:** HUD (horizon, pitch ladder, roll scale, heading tape, speed/alt), map with the
  vehicle marker, Quick tiles, a full status list and STATUSTEXT messages.

- **Parameters (Phase 3):** the *Parameters* screen (top bar) downloads every parameter on connect,
  re-requesting lost ones by index (works over a lossy ELRS link). Search, group by prefix, and
  tap one to edit it. The editor shows Mission Planner's description, units and range, a list for
  value options, checkboxes for bitmasks, and an out-of-range warning. Each write waits for the
  vehicle to echo the value and retries if it doesn't. Reboot-required changes show a banner with
  *Reboot now*. **Save** writes a Mission Planner `.param` file to *Files › Mission Planner › params*.
  **Load** opens a `.param` file (Mission Planner or QGC format), lists only the differences, and
  writes the ones you tick.
- **Actions tab (Flight Data):** set flight mode, arm and disarm (with confirmation, plus an
  emergency force disarm), and reboot the autopilot. Every command is retried until a COMMAND_ACK
  arrives. Arming refusals are explained in *Messages* ("PreArm: …").

- **Map (Data and Plan screens):** vehicle arrow, home, red flight trail, the mission path, geofence
  and rally points. Sources are Apple satellite/map, Esri satellite and OpenStreetMap. Every Esri/OSM
  tile you view is cached in *Files › Mission Planner › tiles*. **Map › Download visible area**
  (Esri) pre-caches a region so the map works at the field, where the ExpressLRS hotspot has no
  internet. Do the download at home.
- **Plan screen (Phase 5):** tap the map to add waypoints, drag to move, tap a marker to edit it.
  The editor has Mission Planner's command list and parameter labels per vehicle (from
  `mavcmd.xml`), an altitude frame (relative/absolute/terrain), and +Takeoff/RTL/Land shortcuts.
  **Read/Write** use the MAVLink mission protocol with retries. **Fence** (inclusion polygon) and
  **Rally** points work the same way. **Survey** lets you outline an area and generate a lawn-mower
  grid (spacing, angle, overshoot, altitude, camera trigger distance). You can load and save
  Mission Planner `.waypoints` files.
- **Setup screen (Phase 6):** pre-arm messages and sensor health, frame type, accelerometer
  6-position and level calibration (prompts come from the flight controller), onboard compass
  calibration with progress per compass, radio calibration (writes RCn_MIN/MAX/TRIM), flight
  mode switch positions, and motor test (props-off confirmation).
- **TLog replay (Phase 7):** Connect › *Replay a telemetry log* plays any `.tlog` through the HUD and
  map, with play/pause, seek and 0.5–25× speed.
- **ExpressLRS:** on Connect the app reads `http://10.0.0.1/mavlink` and uses the backpack's real
  ports automatically (e.g. send port 14551).

- **More Mission Planner features:**
  - Flight Data tabs: Quick, Actions, Checklist, Status, Servo, Messages.
  - Actions: one-tap modes, guided takeoff, change speed/altitude, restart mission, set home.
  - Long-press the map to **fly here** (Guided).
  - Servo/relay overrides (motor outputs are blocked).
  - Preflight checklist.
  - ESC telemetry and battery cells in Status.
  - Voice alerts (speaker icon in the top bar).
  - Setup: Geofence & max altitude, Battery monitor (with voltage/current calibration), Failsafe,
    Tuning, and **DataFlash logs** (list, download `.bin` over MAVLink, erase).

Not done yet (see `CLAUDE.md`): multiple vehicles at once, terrain-following previews, log analysis
and graphs, and firmware flashing (that needs USB).

### How to change a setting on the drone

1. Connect (for example *ExpressLRS WiFi*), wait for the heartbeat, then open **Parameters** in the top bar.
2. Wait for the download to finish (progress shown top right; about 1 minute over ELRS).
3. **Save** first, so you have a backup in *Files*.
4. Search for the parameter (for example `SR6_` or "battery"), tap it, pick or type the new value, and tap **Write to vehicle**.
   The banner confirms what the flight controller stored.
5. If the banner says a reboot is needed, disarm and tap **Reboot now**.

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
| ExpressLRS (Link Mode = MAVLink, Backpack Telemetry = WiFi), iPad joined to "ExpressLRS TX Backpack …" (password `expresslrs`) | ExpressLRS WiFi → 10.0.0.1, backpack port 14555, iPad port 14550 (check at `http://10.0.0.1/mavlink`) |
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
  fc_params.py            bench tool: dump/set params and reboot a flight controller over USB (pyserial)
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
