# Mission Planner for iPad: test plan

Thank you for testing. The app is a native iPad ground station for ArduPilot, modelled on desktop
Mission Planner. It has been compiled and unit-tested on GitHub's Mac, but **it has not yet been used
on a real iPad with a real drone**. That is what this test is for.

Work through the sections in order. Sections Aâ€“F are bench tests (no flying; **propellers off** for
anything that can spin a motor). Only do section G (flight) when Aâ€“F pass and you are at a legal,
safe flying site.

For every test, record **Pass / Fail / Partly / Skipped**, plus a short note. For any failure,
also attach the diagnostics report and the telemetry log (see "How to send feedback").

---

## What you need

- An iPad on iPadOS 16 or newer, a Windows or Mac computer with **Sideloadly**, and an Apple ID.
- The test build `.ipa` (from the GitHub Actions run named in your invitation; the build number
  appears in the app under â“˜ â€º Version).
- An ArduPilot vehicle (tested setup: ArduCopter 4.7.x) and one of these links:
  - **ExpressLRS** with *Link Mode = MAVLink* and *Backpack Telemetry = WiFi* (main target), or
  - a Wi-Fi telemetry bridge (ESP8266/ESP32, DroneBridge), or
  - SITL / MAVProxy on a computer on the same Wi-Fi.
- Optional: desktop Mission Planner, to compare values.

## How to send feedback

1. In the app, tap **â“˜** (top bar) â€º **Share diagnostics report** and **Share latest telemetry log**.
   Send both by email, AirDrop or a cloud drive.
2. Fill in the online feedback page, https://claude.ai/artifact/AJkcibTj4zuqpb5RpnXpPr (the developer shares it
   with you; your answers save automatically), or reply with a list
   like `B3 Fail: HUD frozen, orange banner shown`.
3. Screenshots help a lot: on iPad, press the top button and volume-up together.

---

## A. Install and first launch

| ID | Steps | Expected |
|---|---|---|
| A1 | Install the `.ipa` with Sideloadly. On the iPad, trust the Apple ID (*Settings â€º General â€º VPN & Device Management*); enable Developer Mode if asked. | The app icon appears and the app opens in landscape, showing the Connect sheet. |
| A2 | Tap â“˜ in the top bar. | Diagnostics shows a version like `0.4.0 (build N, abc1234)`. Write the build number in your report. |
| A3 | Open the Files app â€º *On My iPad* â€º *Mission Planner*. | Folders `logs`, `params`, `missions` and `tiles` exist. |

## B. Connection and live data

| ID | Steps | Expected |
|---|---|---|
| B1 | Power the drone **from a battery** and turn on the transmitter. Join the `ExpressLRS TX Backpack â€¦` Wi-Fi (password `expresslrs`). In the app choose **ExpressLRS WiFi** â€º Connect, and allow **Local Network**. | Within ~5 s the top bar shows the firmware (e.g. ArduCopter), the mode and the GPS state. The Connect sheet footer shows "Read from the backpack: â€¦" with the ports. |
| B2 | Tilt and turn the drone by hand. | The **HUD horizon** rolls and pitches and the heading tape turns. No orange "NO ATTITUDE DATA" banner. *(This failed in an earlier build; please test carefully.)* |
| B3 | Check **Quick** and **Status**. | Altitude, speed, battery voltage and GPS look plausible and match desktop Mission Planner if you have it. |
| B4 | Status â€º ESC telemetry (DShot/BLHeli ESCs only). | RPM and temperature per motor are shown (0 RPM when disarmed is fine). |
| B5 | Walk away until the link drops, then come back. | The red "NO HEARTBEAT" banner appears and clears when the link returns. Voice says "Telemetry lost" / "Link restored". |
| B6 | â“˜ â€º look at **Heartbeat sources** and **Messages received**. | Lists the flight controller (e.g. `1/1: quadrotor, autopilot 3`); ATTITUDE is counted. |

## C. Parameters

| ID | Steps | Expected |
|---|---|---|
| C1 | Top bar â€º **Params**. | All parameters download (progress top right; up to ~1 min over ExpressLRS). Count matches desktop Mission Planner. |
| C2 | Tap **Save**. | A `.param` file appears in Files â€º Mission Planner â€º params. |
| C3 | Search `SR6_` (or any group); open one; change it slightly; **Write to vehicle**; then set it back. | The banner confirms the value the flight controller stored. |
| C4 | Open a parameter with a list (e.g. `FRAME_CLASS`) and one with checkboxes (e.g. `ARMING_CHECK`). | Options and bit names are shown with descriptions. **Don't write unless you mean it.** |
| C5 | **Load** the file from C2. | "0 differ" (or only the values you changed). |

## D. Setup (bench, props off)

| ID | Steps | Expected |
|---|---|---|
| D1 | Setup â€º Pre-arm & sensors â€º **Run pre-arm checks now**. | "PreArm: â€¦" messages appear for any problems; sensors show OK/Unhealthy. |
| D2 | Setup â€º Accelerometer â€º **Calibrate accelerometer**. Follow the six positions. | The app asks for each position in turn; ends with "successful". Reboot afterwards. |
| D3 | Setup â€º Compass â€º **Start**, rotate the vehicle in all directions. | Progress bars reach 100%, then report success with fitness and offsets. |
| D4 | Setup â€º Radio calibration. Move the sticks and switches. | Bars follow the sticks. *Calibrate* writes RC*_MIN/MAX/TRIM only if you tap Save. |
| D5 | Setup â€º Flight modes. Flip the mode switch. | The active position is highlighted green. |
| D6 | **PROPS OFF.** Setup â€º Motor test, tick "props removed", tap A, B, C, D at 5 %. | Each motor spins briefly in the expected order. |
| D7 | Setup â€º Geofence & max altitude: set e.g. 60 m, **Apply altitude limit**. | FENCE_ALT_MAX = 60, FENCE_ENABLE = 1, FENCE_TYPE includes bit 0 (check in Params). |
| D8 | Setup â€º Battery monitor. | Voltage/current match a multimeter, or Calibrate voltage fixes it. |
| D9 | Setup â€º DataFlash logs â€º **List**, then download the smallest log. | Progress and speed are shown; the `.bin` appears in Files â€º Mission Planner â€º logs â€º dataflash and opens in desktop Mission Planner. |

## E. Maps and planning (no flight needed)

| ID | Steps | Expected |
|---|---|---|
| E1 | **At home with internet**: Map â€º Offline mapsâ€¦ â€º centre on your flying field, radius 10 km â€º Download. | Finishes in a few minutes; the area appears under "Saved areas". |
| E2 | Turn Wi-Fi/mobile data off (or be on the ExpressLRS hotspot), choose Esri Satellite, pan around the saved area. | The imagery shows without internet; zooming past the saved level shows enlarged (blurry), not blank, imagery. |
| E3 | Top bar â€º **Plan**. Tap the map to add ~5 waypoints, drag one, tap one to edit (try "Loiter Time"), add +Takeoff and +RTL. | Markers, path and list update; the editor shows Mission Planner's parameter names. |
| E4 | **Write**, then **Clear**, then **Read**. | The same mission comes back from the vehicle. |
| E5 | File â€º Save .waypoints; open it in desktop Mission Planner (Load WP File). | Same waypoints in desktop Mission Planner. |
| E6 | Plan â€º Survey: outline 4 corners, Generate. | A lawn-mower grid is appended to the mission. |
| E7 | Plan â€º Fence: tap 4 points, Write. Plan â€º Rally: 1 point, Write. Read both back. | They round-trip, and desktop Mission Planner shows them too. |

## F. Flight Data extras (bench)

| ID | Steps | Expected |
|---|---|---|
| F1 | Flight Data â€º **Checklist**. | GPS, satellites, link, battery, altitude, EKF and pre-arm show green/red correctly. |
| F2 | Flight Data â€º **Actions**: tap a quick mode (e.g. Loiter, or Stabilize on the bench). | The mode changes; voice announces it; the banner says "accepted" or explains the refusal. |
| F3 | Arm and disarm from Actions (**props off**). | Confirmation dialogs; the vehicle arms/disarms; any refusal reason appears in Messages. |
| F4 | Flight Data â€º **Servo**: on a non-motor output (e.g. a servo or camera trigger), tap Low/High. | The output moves; motor outputs are greyed out. |
| F5 | Connect sheet â€º *Replay a telemetry log* â€º pick a log. | The HUD and map replay it; play/pause, scrub and speed work. |

## G. Flight (only after Aâ€“F pass, at a safe legal site, with a pilot ready on the sticks)

| ID | Steps | Expected |
|---|---|---|
| G1 | Fly manually in Loiter/AltHold. | The HUD, altitude, speed and map position follow the vehicle smoothly; the trail is drawn. |
| G2 | Upload a short mission (takeoff 10 m, 2 waypoints, RTL). Switch to **Auto**. | The vehicle flies it; the current waypoint is highlighted green in Plan. |
| G3 | In Guided, **long-press the map** â€º Fly here (low altitude, nearby). | The vehicle flies to the point. |
| G4 | With the altitude fence set low (D7), climb towards it. | The fence triggers the configured action (RTL/Land). |
| G5 | After landing, â“˜ â€º share the report and the latest log. | Both files open on your computer. |

---

## Known limitations (no need to report)

- Firmware flashing, ESC calibration, joystick input and Mission Planner Python scripts aren't
  available on a sideloaded iPad.
- Only one vehicle at a time.
- With a free Apple ID the app must be re-installed (re-signed) every 7 days; your files stay.
- Don't connect desktop Mission Planner and the iPad to the same ExpressLRS backpack Wi-Fi at the
  same time (the backpack talks to only one ground station).
