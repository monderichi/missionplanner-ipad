# Agent notes: Mission Planner for iPad

Read `README.md` (what works, build, install) and `CLAUDE_PROMPTS.md` (the phase 1–7 plan) first.
This file is the running handoff log: what's in flight, what was learned on the bench, and what to
do next. Update it when you finish a piece of work.

## Ground rules

- No Mac. Swift can't compile on this Windows PC; **GitHub Actions is the only compiler**
  (`.github/workflows/build-sideloadly-ipa.yml`, runs on every push to `main`). Read Swift diffs
  carefully before pushing, and check the Actions run afterwards.
- Deployment target is iOS 16 (`project.yml`), so APIs up to iOS 16 only (`LabeledContent` is fine).
- Sideloaded with a free Apple ID: no restricted entitlements. In particular **no UDP
  broadcast/multicast receive** (needs `com.apple.developer.networking.multicast`) and no USB serial.
  Every network link must be unicast.
- Protocol code mirrors Mission Planner; keep the `// REA Parity Source:` header comments.
- `tools/mavlink_ref.py` is the Python twin of the Swift codec and works on Windows. Use it to test
  protocol ideas against real hardware before writing Swift.

## Status (2026-11-21)

Phases 1–2 are done and building on CI (commit `071924d`): links, MAVLink v1/v2, heartbeat,
stream requests, tlog, HUD, map, status.

Commit `813dc59` (CI run #4) builds green: 26/26 MAVLinkKit tests, 1.44 MB IPA. It contains the
items below. NOT yet tested on a real iPad / vehicle:
- The ExpressLRS WiFi link (below).
- **Phase 3: parameters and commands.**
  - `MAVLinkKit/ParameterProtocol.swift`: `ParameterSession`, a pure state machine for download,
    gap-fill by index and set with confirm/retry; plus `ParamFile` (.param save/parse, MP and QGC formats).
  - `MAVLinkKit/CommandProtocol.swift`: `CommandSession` for COMMAND_LONG retry/ACK (arm,
    DO_SET_MODE, reboot), plus `MAVLinkSender.pack(any:)`.
  - Tests in `ParameterTests.swift`, including a simulated vehicle with 30% loss each way.
  - The gap-fill algorithm was simulated in Python over 200 runs: about 58 s median for 900 params
    at 30% loss with `.narrowLink`, and about 2 s on a clean link.
  - App side: `ParameterStore` / `CommandCenter`, owned by `LinkManager`. They attach on the first
    heartbeat of a sysid, survive short dropouts, and re-download after a reboot. Bulk writes are
    queued, 3 in flight on narrow links.
  - UI: the *Parameters* screen (top-bar switch), `ParamEditViews.swift` (editor/load/compare),
    and `ActionsView` (an Actions tab in Flight Data).
  - Metadata: `tools/gen_param_meta.py` turns MP's `ParameterMetaDataBackup.xml` into
    `App/Resources/ParamMeta/*.json` (bundled resources, loaded by `ParamMetadataRepository`).

### In progress: ExpressLRS WiFi link (written, NOT yet committed or built)

The user flies with **ExpressLRS in MAVLink mode**. The iPad connects to the radio's TX Backpack
Wi-Fi hotspot directly. No PC is in the path.

```
FC SERIAL6 (MAVLink2 @ 460800) -> ELRS RX -> RF -> ELRS TX module -> TX Backpack Wi-Fi AP -> iPad
```

ExpressLRS TX Backpack behaviour (from `ExpressLRS/Backpack` source, `lib/WIFI/devWIFI.cpp`):
- AP SSID `ExpressLRS TX Backpack XXXXXX`, password `expresslrs`, IP `10.0.0.1/24`.
- MAVLink UDP: the backpack listens on its *listen port* and sends to the GCS on its *send port*
  (both configurable via `http://10.0.0.1/mavlink`, which also shows the current values).
  Defaults are listen **14555**, send **14550**. Confirmed from source: `TxBackpackConfig::SetDefaults()`
  in `lib/config/config.cpp`. The backpack uses one `WiFiUDP mavlinkUDP` bound to the listen port for
  both receive and send, so its replies come *from* 10.0.0.1:14555. That matches our connected socket.
  MAVLink over Wi-Fi is only active when the backpack is in `WIFI_SERVICE_MAVLINK_TX` (set via the ELRS
  Lua "Backpack Telemetry = WiFi", or `/setmavlink`) and the firmware is built with `MAVLINK_ENABLED`.
- Until it receives a UDP packet it sends to the **broadcast** address. After the first packet it
  stores the sender's IP (`gcsIP`) and unicasts to `gcsIP:<send port>`. Note: it uses the IP only,
  not the sender's source port.

Why the existing link types fail, and the fix:
- *UDP listen* never sends, so it only gets broadcasts, which iOS blocks for us.
- *UDP connect* sends from an ephemeral port, but the replies go to port 14550.
- New `LinkKind.elrs` ("ExpressLRS WiFi") = `NWClientTransport(..., proto: .udp, localPort: 14550)`.
  It binds local port 14550 (`requiredLocalEndpoint` + `allowLocalEndpointReuse`) and connects to
  `10.0.0.1:14555`. The 1 Hz GCS heartbeat in `LinkManager.startHeartbeat()` is the packet that makes
  the backpack learn the iPad's IP. The connected UDP socket accepts the replies because the backpack
  sends them from its listen port.
- Files changed: `App/Link/NetworkTransports.swift` (`localPort`), `App/Link/Transport.swift`
  (`.elrs` case, help, default port 14555), `App/Link/LinkManager.swift` (`connect(... localPort:)`),
  `App/UI/ConnectView.swift` (ELRS section: backpack IP / backpack port / iPad port, stored under
  `link.localPort`).

- `NWClientTransport` hardening: a fresh `NWParameters` per connection; `.elrs` is pinned to
  Wi-Fi (`requiredInterfaceType`); `.waiting` is restarted every 2 s (no Wi-Fi yet, Local Network
  prompt pending); UDP `.failed` reopens; UDP receive errors (ICMP port unreachable) don't stop the
  receive loop; and errors are explained in plain words. *UDP connect* now also binds the iPad
  port (14550), so MAVESP8266-style bridges work as well.
- Loopback test on Windows (scratch script, not in the repo): a fake backpack built exactly per
  devWIFI.cpp plus a fake FC. Bind 14550 + connect 14555 got 6 heartbeats and 300/300 params. An
  ephemeral source port got 0, which confirms the design.
- `LinkManager` uses `narrowLinkStreamRates` for `.elrs`/`.ble` (HUD 4 Hz, RAW_SENSORS off), because
  REQUEST_DATA_STREAM overrides the FC's SR6_* rates and the 10 Hz defaults would swamp ELRS.

**Next steps for this feature**
1. Commit and push. Fix any CI compile errors (the code has never been compiled).
2. The user installs the new IPA with Sideloadly and tests: join the backpack Wi-Fi, choose
   *ExpressLRS WiFi*, connect, and allow Local Network.
3. If it stays silent: read the real ports at `http://10.0.0.1/mavlink`. If the connected-socket
   assumption is wrong (the replies come from a different source port), switch `.elrs` to an
   `NWListener` on 14550 plus a separate send connection to `10.0.0.1:14555`.
4. Once it works, confirm the defaults and update this file and the README.

### Vehicle bench state (the user's copter)

- **ArduCopter V4.7.3** (d9c5097c) on a **MicoAir743v2**, Frame QUAD/X, sysid 1; `RCOut: DS600:1-4 PWM:5-11`
  (DShot600 ESCs on outputs 1–4, so the ESCs report ESC_TELEMETRY/RPM). This was confirmed 2026-11-25 from Mission
  Planner's tlogs in `Documents\Mission Planner\logs\QUADROTOR\1\`. The earlier "4.6.3" note was wrong. On the PC
  it appears as USB **COM12** ("ArduPilot").
- On Mission Planner's link only (1,1) and the GCS (255,190) send heartbeats; ATTITUDE arrives at about 3.9 Hz.
  The frozen-HUD cause over ELRS is NOT proven. Ask the user for an iPad `.tlog` (Files › Mission Planner › logs)
  and analyse it (heartbeat sources, ATTITUDE rate). The scratch script `analyze_tlog.py` does exactly that and
  is quick to rewrite.
- "PreArm: RC not found" appeared in Mission Planner's 13-16 log (RC not received at that time).
- ELRS receiver on **SERIAL6**: `SERIAL6_PROTOCOL=2`, `SERIAL6_BAUD=460`, `RSSI_TYPE=5`, `RC_PROTOCOLS=1`.
- 2026-11-21: set `SR6_EXT_STAT/EXTRA1/EXTRA2/EXTRA3/POSITION/RAW_SENS/RC_CHAN = 1` (they were 0)
  and left `SR6_ADSB/PARAMS/RAW_CTRL = 0`. The controller confirmed every set before a reboot. The
  read-back after the reboot didn't run (COM12 hadn't re-enumerated yet).
- On USB power only the controller reported `RC_CHANNELS.chancount = 0` and RSSI 254 (no RC). The
  receiver was probably unpowered. Still to check: with a battery in and the radio on, RC and RSSI
  show up in Mission Planner.
- The ELRS Lua is set up (Link Mode = MAVLink, Backpack Telemetry = WiFi), according to the user.
- Other serial ports: SERIAL0 USB MAVLink, SERIAL2 protocol 42, SERIAL3 GPS (5), SERIAL4 MAVLink @ 230400,
  SERIAL7 protocol 16, SERIAL8 MAVLink.
- Bench tool: `python -I tools/fc_params.py COM12 dump|set NAME=VAL ...|reboot` (needs pyserial,
  and Mission Planner must be disconnected because it holds the port). Back up with `dump` before any `set`.

### Not this approach

- Bridging through desktop Mission Planner (Ctrl+F → MAVLink Mirror, TCP inbound 14550) works for a
  PC-tethered setup, but the user explicitly does **not** want it. They want the ELRS Wi-Fi.

## Phases 4–7 (2026-11-21, see README "What works now")

Commit `a90a9a5` (CI run 44944471283) builds green on the first try: 32/32 tests. Not yet
tried on the iPad: the map editing, calibrations, motor test and replay need a real check.

- The user confirmed the iPad connects over ExpressLRS Wi-Fi. Their backpack sends to **14551** (not
  14550). `ELRSBackpack.swift` now reads `/mavlink` on connect and uses `ports.listen`/`ports.send`.
  ATS allows it via `NSAllowsLocalNetworking`; if the read fails, the typed ports are used.
- MAVLinkKit `MissionProtocol.swift`: `MissionSession` (download/upload for mission/fence/rally,
  retries, MISSION_REQUEST legacy), `WaypointFile` (QGC WPL 110), `Geo`, `SurveyGrid`. Tests are in
  `MissionTests.swift`; the simulated vehicle re-ACKs a duplicate final item, as ArduPilot does.
- App: `MissionStore` (home = item 0, fence groups get param1 = vertex count), `Map/MapCanvas.swift`
  (MKMapView: markers, drag, overlays), `Map/TileCache.swift` (Esri/OSM cache + Esri area download,
  capped at 6000 tiles; OSM area download is disabled per their tile policy), `PlanView`,
  `CalibrationStore` + `SetupView`, `ReplayTransport` + `ReplayBar`.
- `App/Resources/MissionCommands.json` comes from `tools/gen_mission_cmds.ps1` (mavcmd.xml + MAV_CMD enum).
- Calibration commands use `CommandCenter.sendOnce`, because resending PREFLIGHT_CALIBRATION would
  restart it. The vehicle drives the accel cal with COMMAND_LONG 42429, which `LinkManager` routes
  to `CalibrationStore`.

## Mission Planner feature parity batch (2026-11-25)

- HUD: vehicle lock only on real autopilot heartbeats, preferring compid 1; sessions re-attach on a compid
  change; attitude watchdog (REQUEST_DATA_STREAM + SET_MESSAGE_INTERVAL); NO ATTITUDE DATA banner.
- Setup pages: Geofence & max altitude (quick FENCE_ALT_MAX preset), Battery monitor (+ voltage/current
  calibration), Failsafe, Tuning (generic `ParamListPage` + `ParamAutoRow`), DataFlash logs.
- Flight Data: scrollable tabs Quick/Actions/Checklist/Status/Servo/Messages; Actions has quick modes,
  guided takeoff, change speed/alt, restart mission and set home; long-press the map to fly there (MISSION_ITEM_INT
  current=2); Servo/relay overrides (motor outputs are blocked); preflight checklist (MP
  checklistDefault.xml); ESC telemetry + battery cells in Status; speech alerts (toggle in the top bar).
- MAVLinkKit `LogProtocol.swift`: `LogListSession` and `LogDownloadSession` (gap re-requests, EOF via a short
  chunk, LOG_REQUEST_END) with `LogTests`.
- Not feasible on a sideloaded iPad: firmware flashing, ESC calibration (power cycle), joystick, MP scripts.

## Backlog after the ELRS link works

Phases 4–7 from `CLAUDE_PROMPTS.md`: map upgrades (trail, offline tiles), the mission editor
(MISSION_ITEM_INT up/download), setup/calibration wizards, and tlog replay. Multi-vehicle (MAVList)
is still single-vehicle. With ELRS, keep in mind the link is narrow (1:2 telemetry ratio): use
`.narrowLink` configs, and don't raise the stream rates much.
