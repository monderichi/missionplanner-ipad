# Claude Opus & Sonnet Prompt Pack: ArduPilot Mission Planner for iPadOS (via REA & Sideloadly)

This document contains a two-stage prompt workflow designed to split architectural planning (**Claude Opus**) and code execution (**Claude Sonnet**):

1. **Stage 1 — Claude Opus Prompt (Architecture, REA Analysis & Task Decomposition)**
2. **Stage 2 — Claude Sonnet Prompt (Module Execution, REA Verification & `.ipa` Packaging for Sideloadly)**

---

## Prerequisite: Enable REA (`morluto/rea`) in Your Claude Environment
Before running these prompts in Claude Code (or your MCP-enabled client), ensure REA is installed and registered:
```bash
npx rea-agents@latest setup
npx -y rea-agents@latest doctor
```

---

## Stage 1: Prompt for Claude Opus (Overview, REA Deconstruction & Master Blueprint)

Copy and paste the following prompt to **Claude Opus**:

```markdown
# ROLE & OBJECTIVE
You are the Lead Systems Architect and Reverse-Engineering Director. Your job is to design a complete, evidence-backed technical blueprint and phased task backlog to recreate **ArduPilot Mission Planner** (`https://github.com/ardupilot/MissionPlanner`) as a native, touch-first **iPadOS Ground Control Station (GCS)** deployed via **Sideloadly** (`.ipa`), using **REA (`https://github.com/morluto/rea`)** skills to inspect and extract the exact behavior, protocols, and subsystems from Mission Planner.

**IMPORTANT:** You (Opus) are responsible for the **System Overview, REA Reverse-Engineering Audit, iPadOS/Sideloadly Constraint Mapping, and Granular Task Specifications**. **Claude Sonnet** will execute the actual coding tasks from your specification. Do NOT write boilerplate application code—write the definitive architectural spec, REA evidence ledger, data models, state machines, and step-by-step execution prompts that Sonnet will follow without ambiguity.

---

# 1. INPUT REPOSITORIES & TOOLING
- **Source Reference & Target to Analyze:** `https://github.com/ardupilot/MissionPlanner` (C# / .NET / WinForms / MAVLink assemblies & source)
- **Analysis Methodology:** **REA (`morluto/rea` / `rea-agents`)** — Use REA MCP/CLI capabilities to inspect Mission Planner's `.NET` projects, compiled DLLs/assemblies (e.g., `MissionPlanner.Core`, `MAVLink`, `MissionPlanner.ArduPilot`, `MissionPlanner.Comms`, `MissionPlanner.Controls`, `GMap.NET`), decompile or trace critical logic, and document **evidence-backed findings** (file paths, class hierarchies, packet framing, state transitions, and known limitations).
- **Deployment Target:** iPadOS via **Sideloadly** (Windows/macOS sideloading using a standard/free or paid Apple Developer account).

---

# 2. MANDATORY SIDELOADLY & iPadOS CONSTRAINTS TO ARCHITECT FOR
Your architecture MUST explicitly account for Sideloadly sideloading limits on iPadOS:
1. **Entitlement Restrictions (Free Apple ID via Sideloadly):**
   - No restricted Apple entitlements (`com.apple.developer.networking.multipath`, CarPlay, Critical Alerts, External Accessory MFi without hardware cert, or custom kernel drivers).
   - **USB Serial Caveat:** iPadOS blocks raw USB CDC/ACM serial drivers for sideloaded apps without DriverKit/MFi entitlements. You must architect **UDP (Wi-Fi telemetry / ESP8266 / DroneBridge / MAVLink-Router)**, **TCP**, and **CoreBluetooth (BLE UART / HM-10 / Nordic NUS)** as primary transports, plus optional WebSocket/companion-computer bridging.
2. **7-Day Re-signing & App ID Limits:**
   - Sideloadly re-signs every 7 days (or via Wi-Fi auto-refresh). All mission waypoints, tile caches, parameter backups (`.param`), and TLogs (`.tlog`) MUST reside in user-accessible `Documents/` with `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` enabled in `Info.plist` so user data survives re-installs and is visible in the iPad Files app / iTunes File Sharing.
3. **Zero-Mac Build Pipeline Option:**
   - Specify how Sonnet will configure an automated **GitHub Actions `macos-latest` workflow** (or cross-platform build script) that compiles and packages an unsigned `.ipa` artifact (`Payload/App.app` -> `.ipa`) ready to drag-and-drop directly into **Sideloadly**.

---

# 3. REA (`morluto/rea`) REVERSE-ENGINEERING WORKFLOW
Use REA skills/tools on the `MissionPlanner` repository or binaries to extract and document evidence for the following 6 core pillars:

1. **Comms & MAVLink Transport Layer (`ExtLibs/Comms`, `ExtLibs/MAVLink`):**
   - How `MAVLinkInterface`, `MAVState`, and `MAVList` multiplex multiple vehicles/sysids/compids.
   - Packet framing for MAVLink v1 and v2, CRC_EXTRA validation, message signing, heartbeat watchdogs, and link-loss detection.
2. **Flight Data & HUD (`GCSViews/FlightData.cs`, `ExtLibs/Controls/HUD.cs`):**
   - Exact telemetry message subscriptions (`ATTITUDE`, `VFR_HUD`, `GLOBAL_POSITION_INT`, `SYS_STATUS`, `GPS_RAW_INT`, `EKF_STATUS_REPORT`, `VIBRATION`, `STATUSTEXT`) and update frequencies (`SRx_*` stream rates).
   - HUD artificial horizon geometry, pitch ladder, roll arc, compass tape, failsafe banners, and Quick Telemetry tabs.
3. **Flight Planner & Waypoint Engine (`GCSViews/FlightPlanner.cs`, `ExtLibs/ArduPilot/Mavlink/MAVLinkMission`):**
   - The MAVLink Mission Protocol state machine (`MISSION_COUNT`, `MISSION_REQUEST_INT`, `MISSION_ITEM_INT`, `MISSION_ACK`, partial uploads, rally points, and geofences `FENCE_POINT`).
   - Auto-grid / Survey / Corridor polygon generation math (`ExtLibs/Grid`).
4. **Configuration, Tuning & Parameters (`GCSViews/ConfigurationView`):**
   - The Parameter Protocol state machine (`PARAM_REQUEST_LIST`, `PARAM_VALUE`, `PARAM_SET`, `PARAM_REQUEST_READ` retries for dropped packets).
   - How `ParameterMetaDataBackup.xml` / `apm.pdef.xml` is parsed to render human-readable parameter ranges, bitmasks,enums, and reboot warnings.
   - Calibration state machines (Accelerometer 6-axis handshake via `MAV_CMD_PREFLIGHT_CALIBRATION` & `STATUSTEXT`/command ack prompts, Compass Onboard MagCal `MAG_CAL_PROGRESS` / `MAG_CAL_REPORT`, Radio/ESC/Flight Modes).
5. **TLog Recording, Playback & DataFlash Logs (`ExtLibs/ArduPilot/Log`):**
   - Binary `.tlog` timestamped packet framing (`[uint64_be_unix_usec][raw_mavlink_packet]`) for 100% compatibility with desktop Mission Planner.
6. **Map Engine & Offline Caching (`ExtLibs/GMap.NET`):**
   - Tile provider URL templates, offline region pre-fetching, vehicle trail rendering, heading/COG vectors, and touch-friendly waypoint drag/insert on iPad.

---

# 4. REQUIRED DELIVERABLES FROM YOU (OPUS)
Produce a comprehensive **Master Architectural & Execution Document** structured into the following sections:

1. **Tech Stack Decision Matrix (iPadOS + Sideloadly Optimized):**
   - Recommend and lock in the single best stack for Sonnet to execute cleanly (e.g., **SwiftUI + Metal + MapKit/MapLibre** for 100% native iPadOS performance, OR **.NET 8/9 MAUI / Avalonia iOS** to directly reuse MissionPlanner's `ExtLibs/MAVLink` and `ExtLibs/ArduPilot` C# libraries, OR **Flutter iOS**). Justify based on code reuse from MissionPlanner vs. iPad UI/UX quality and `.ipa` build reliability.
2. **REA Evidence Report:**
   - For each of the 6 core pillars above, list the exact source classes, methods, data structures, and protocol edge-cases discovered in `ardupilot/MissionPlanner`, including explicit limitations.
3. **iPadOS Touch UX & Split-Screen Architecture:**
   - How Mission Planner's dense WinForms layout translates to a 10"–13" iPad landscape layout (Floating HUD overlay, interactive Map canvas, collapsible Right Drawer for Waypoints/Params, top Telemetry Status Bar, Pre-Arm Checklist modal, and safe Two-Step Arm/Disarm slider).
4. **Phased Implementation Backlog for Claude Sonnet (Phases 1 to 7):**
   - Break the entire development down into **7 self-contained, sequential implementation tickets** for Claude Sonnet:
     - **Phase 1:** Project Scaffold, `Info.plist` (Sideloadly File Sharing + Local Network permissions), & GitHub Actions Unsigned `.ipa` Builder.
     - **Phase 2:** MAVLink v2 Core Parser, CRC_EXTRA Registry, `.tlog` Logger, & UDP/TCP/BLE Transports.
     - **Phase 3:** `MAVState` Store, Vehicle Multiplexer, Heartbeat Manager, & Parameter Engine (`PARAM_REQUEST_LIST` + XML metadata parser).
     - **Phase 4:** iPadOS Flight Data View — Map Canvas (Offline Tiles, Vehicle Markers, Flight Path) + 60fps Artificial Horizon HUD.
     - **Phase 5:** Flight Planner View — Interactive Touch Waypoint Editor, `MISSION_ITEM_INT` Upload/Download State Machine, Geofence/Rally, & Survey Grid Generator.
     - **Phase 6:** Setup & Tuning View — Full Parameter Tree Search/Edit, Flight Modes, 6-Axis Accel & Onboard Compass Calibration Wizards, Motor Test, & Pre-Arm Status Inspector.
     - **Phase 7:** `.tlog` Replay Engine, Sideloadly Packaging Verification, & Regression Test Suite.
   - For **every phase**, specify:
     - Exact file tree to create.
     - Interfaces/types and method signatures.
     - Acceptance criteria & unit tests Sonnet must run.
```

---

## Stage 2: Prompt for Claude Sonnet (Task Execution, Coding & `.ipa` Build)

Once **Claude Opus** generates the Master Blueprint and Phased Backlog, feed Opus's output along with the prompt below to **Claude Sonnet**:

```markdown
# ROLE & OBJECTIVE
You are the Lead Implementation Engineer (Claude Sonnet). You are executing the **ArduPilot Mission Planner for iPadOS (Sideloadly Edition)** based on the **Master Architectural Blueprint created by Claude Opus** (attached below) and verified against **`https://github.com/ardupilot/MissionPlanner`** using **REA (`https://github.com/morluto/rea`)** skills.

---

# EXECUTION RULES & REA STANDARDS
1. **No Stubs, Placeholders, or `// TODO`s:**
   - Every MAVLink state machine (Heartbeat, Stream Rate negotiation, Parameter Fetch/Retry, Mission `MISSION_ITEM_INT` Upload/Download, Accel/Compass Calibration, and `.tlog` binary recording) MUST be implemented completely with real byte-level parsing, timeouts, and retry logic matching `ardupilot/MissionPlanner`.
2. **Evidence-Driven Parity via REA (`morluto/rea`):**
   - Whenever you implement a subsystem (e.g., `MAVLinkInterface`, `HUD`, `MAVLinkMission`, `Grid`, `.tlog` format, or `ParameterMetaDataParser`), use REA skills/tools or inspect the corresponding C# classes in `ardupilot/MissionPlanner` first.
   - Document the source evidence at the top of each core module file in a concise header comment (`// REA Parity Source: MissionPlanner/...`).
3. **Strict Sideloadly & iPadOS Compliance:**
   - **Bundle & Entitlements:** Do NOT include restricted entitlements that fail Sideloadly free-account signing.
   - **`Info.plist` Requirements:**
     - `UIFileSharingEnabled = true` and `LSSupportsOpeningDocumentsInPlace = true` (so `.tlog`, `.waypoints`, `.param`, and offline map tiles in `Documents/` persist across 7-day Sideloadly re-signs and appear in the iPad Files app).
     - `NSLocalNetworkUsageDescription` and `NSBonjourServices` (required by iPadOS 14+ to allow UDP broadcast/unicast MAVLink sockets on port `14550` / `14555` and TCP `5760`).
     - `NSBluetoothAlwaysUsageDescription` (for BLE telemetry radios).
     - `UISupportedInterfaceOrientations~ipad` locked primarily to Landscape Left / Landscape Right for GCS ergonomics.
4. **Binary Compatibility with Desktop Mission Planner:**
   - `.tlog` files written on the iPad must use the exact 8-byte big-endian microsecond Unix timestamp prefix followed by the raw MAVLink packet so they open directly in desktop Mission Planner.
   - `.waypoints` files must support export/import in standard `QGC WPL 110` text format.
   - `.param` files must export/import in standard Mission Planner `PARAM_NAME,VALUE` format.
5. **Automated Sideloadly `.ipa` Build Pipeline:**
   - Include a working `.github/workflows/build-sideloadly-ipa.yml` (and local `scripts/package_ipa.sh`) that builds the app with `CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`, packages `Payload/<AppName>.app`, zips it into `MissionPlanner-iPad-Sideloadly.ipa`, and uploads it as a downloadable artifact ready for Sideloadly.

---

# HOW TO WORK THROUGH THE PHASES
We will execute Opus's blueprint phase-by-phase:
- Start now with **Phase 1** and **Phase 2** from Opus's specification.
- Before writing code for each phase:
  1. Run any needed REA inspections on `MissionPlanner` to verify exact byte layouts, constants, and state transitions.
  2. Create all files in the specified directory structure.
  3. Run builds/tests to verify zero compile errors and 100% protocol test pass rate.
  4. Summarize what was completed, show the verification output, and ask to proceed to the next phase.

---

# OPUS ARCHITECTURAL BLUEPRINT
<PASTE_CLAUDE_OPUS_OUTPUT_HERE>
```
