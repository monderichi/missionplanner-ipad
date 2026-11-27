# Mission Planner for iPad: simulator test plan (for Elias)

This round runs entirely on a **Mac with the iPad Simulator**. No iPad, drone or radio is needed. The app
connects to a simulated vehicle on the same Mac over TCP. Tomorrow we fix whatever you find and carry on.

There are two ways to get a vehicle. Use **ArduPilot SITL** where you can, because it really flies, runs
missions and answers every command. The repo's **fake vehicle** script is a quick fallback: it only streams
plausible telemetry and accepts parameter/mission traffic, and it does not fly.

What's new since the last round (please focus here):
- **UGV (ArduRover) and ROV (ArduSub) support.** Setup pages now depend on the firmware, with a new *Rover setup*
  and *ROV setup* page, ROV depth/water temperature/leak warning, and rover/boat map markers.
- **Manual control (Control tab).** MANUAL_CONTROL from on-screen sticks or a game controller, for Rover and Sub only.
- Batch 2: Graph tab, MAVLink Inspector, custom Quick tiles, ADS-B traffic on the map, gimbal/camera, the map
  long-press menu (fly here / ROI / measure), circle/orbit, and DataFlash log review.

---

## 1. Setup (about 15 min)

Needs macOS with **Xcode 15 or newer** (iPadOS 16+ simulator runtime), Homebrew and Python 3.

```bash
git clone https://github.com/monderichi/missionplanner-ipad.git
cd missionplanner-ipad
brew install xcodegen
xcodegen generate
open MissionPlannerPad.xcodeproj
```

In Xcode, choose the scheme **MissionPlannerPad**, pick an iPad simulator (e.g. *iPad Pro 13-inch*) and press
**Run** (⌘R). No signing team is needed for the simulator.

### Vehicle option A: ArduPilot SITL (recommended)

Follow https://ardupilot.org/dev/docs/building-setup-mac.html once, then from the `ardupilot` folder:

```bash
Tools/autotest/sim_vehicle.py -v ArduCopter --console --map     # copter
Tools/autotest/sim_vehicle.py -v Rover --console --map          # UGV
Tools/autotest/sim_vehicle.py -v ArduSub --console --map        # ROV
```

SITL serves MAVLink on **TCP 5760**. Start SITL first, then connect the app. If MAVProxy is holding 5760,
add `--no-mavproxy`, or connect the app to `127.0.0.1:5762` (SITL's second TCP port).

### Vehicle option B: fake vehicle (no flying)

```bash
python3 tools/fake_vehicle.py --type copter     # or: rover | boat | sub
```

### Connect the app

Top-left **Link** › type **TCP** › host `127.0.0.1`, port `5760` (or `5762`) › **Connect**.
The top bar should show the firmware (ArduCopter / ArduRover / ArduSub), the mode and *Disarmed*.

---

## 2. How to report

For each test ID write **Pass / Fail / Partly / Skip** and a short note, for example:

```
S-C3 Fail: HUD pitch moves but the heading tape is stuck at 0
S-R5 Pass
```

Attach screenshots (simulator: ⌘S saves one to the Desktop). For anything strange also attach:
- the **diagnostics report**: ⓘ in the top bar › *Share diagnostics report*;
- the **telemetry log** (.tlog): ⓘ › *Share latest telemetry log*.

In the simulator, *Share* opens a share sheet. Use *Save to Files* and then drag the file out of
`~/Library/Developer/CoreSimulator/...`, or just paste the text of the report.

Send everything in one file (e.g. `feedback_elias.md`) or as a GitHub issue in the repo. You can also use
the feedback page https://claude.ai/artifact/AJkcibTj4zuqpb5RpnXpPr (put "simulator" in the *ipad* field).

---

## 3. Copter (SITL ArduCopter)

| ID | Steps | Expected |
|----|-------|----------|
| S-C1 | Connect over TCP | Link turns green. ⓘ shows the version/build, and the heartbeat source is sysid 1 compid 1. |
| S-C2 | Wait 30 s on **Data** | Parameters download, the progress bar ends (≈ 1000+ params on SITL). |
| S-C3 | Watch the HUD while SITL is idle, then tilt it with `rc 1 1700` in MAVProxy (or fly, below) | Roll/pitch/heading move smoothly. No *NO ATTITUDE DATA* banner. |
| S-C4 | Data › **Actions**: set mode GUIDED, **Arm**, **Takeoff** 10 m | Arms, climbs to about 10 m. Altitude, vertical speed and the trail on the map update. |
| S-C5 | Long-press the map › **Fly here** | The vehicle flies to the point. |
| S-C6 | Long-press › **Measure** between two points | The distance/bearing shown look right. |
| S-C7 | Actions › **RTL**, then **Land** | Mode changes are spoken (speaker icon on) and shown in the top bar. |
| S-C8 | **Plan**: add 4 waypoints, a survey grid, **Write**, then **Read** back | The read-back matches. Switching to AUTO flies the mission. |
| S-C9 | Plan: draw a fence polygon and a rally point, write and read | Both survive the round trip. |
| S-C10 | **Setup › Geofence & max altitude**: set FENCE_ALT_MAX = 50, enable the fence | The value is written (confirmed), and the vehicle stops at 50 m in a climb. |
| S-C11 | **Params**: search `RTL_ALT`, change it, write; then save the .param file and load it back | Write is confirmed. Compare shows the difference. |
| S-C12 | Data › **Graph**: plot altitude and roll | Live lines. |
| S-C13 | ⓘ › **MAVLink Inspector** | Message list with rates (ATTITUDE about 4–10 Hz), and the fields update. |
| S-C14 | Data › **Quick**: long-press a tile and change its value | The tile shows the new value and is kept after an app restart. |
| S-C15 | **Setup › DataFlash logs**: list, download one, **Review** | It downloads with progress. The review shows the messages and a plot, with mode bands. |
| S-C16 | Setup pages: open every page in the list | None crashes or stays empty. Note any page that looks wrong for a copter. |
| S-C17 | Stop SITL for 10 s, then start it again | *Telemetry lost* banner and speech, then it reconnects by itself and the parameters re-download after the reboot. |

## 4. UGV (SITL Rover; boat = `-v Rover --frame motorboat`)

| ID | Steps | Expected |
|----|-------|----------|
| S-R1 | Connect | Top bar shows *ArduRover*, mode *Hold* or *Manual*. Map marker = rover arrow (boat: boat arrow). |
| S-R2 | **Setup** list | Copter-only pages (Frame type, copter tuning) are hidden. **Rover setup** is shown. |
| S-R3 | Setup › **Rover setup** | Cruise speed/throttle, steering and turn rates, and failsafe actions show the SITL values. Change CRUISE_SPEED and write. |
| S-R4 | Setup › **Failsafe** and **Tuning** | Rover-specific parameters (FS_ACTION, FS_THR_*, ATC_STR_RAT_*, …), not copter ones. |
| S-R5 | Data › **Control**: enable manual control (mode MANUAL, armed), drag the on-screen sticks | Left stick up = forward (*Z throttle* bar), right stick left/right = steering (*Y steering* bar). The rover drives in SITL. |
| S-R6 | With manual control on, stop SITL or disconnect | Manual control switches itself off. |
| S-R7 | Plan a 4-waypoint mission, AUTO | Drives it. *Restart mission* works. |
| S-R8 | Setup › **Motor test** | Throttle/steering test entries (not quad motors A–D). Read the warning first. In SITL, no damage is possible. |

## 5. ROV (SITL ArduSub)

| ID | Steps | Expected |
|----|-------|----------|
| S-S1 | Connect | Top bar shows *ArduSub*, mode *Manual*. Altitude is shown as negative depth. |
| S-S2 | Setup › **ROV setup** | Live depth and water temperature. FRAME_CONFIG (BlueROV1/vectored/…) and the JS_GAIN_* values. |
| S-S3 | Data › **Control**: arm, enable, move the sticks | Right stick = forward/lateral (X/Y), left stick = heave/yaw (Z around 500 / R). The ROV moves in SITL. |
| S-S4 | Change **Gain** in the Control tab | The bar values scale. |
| S-S5 | Leak: fake vehicle `--type sub` sends *Leak Detected* after about 6 s | Red **LEAK DETECTED** banner plus speech. *Clear* on the ROV setup page removes it. |
| S-S6 | Optional: pair any game controller with the Mac (Xbox/PS via Bluetooth) | The Control tab offers *Use game controller (name)*. The sticks drive the frame and the buttons light up 0–15. Switching it off brings back the on-screen sticks. |
| S-S7 | Setup list | Copter/rover-only pages are hidden. Note anything that should not be there for a sub. |

## 6. General UI checks (any vehicle)

| ID | Steps | Expected |
|----|-------|----------|
| S-G1 | Rotate the simulator (⌘← / ⌘→) | The layout works in portrait and landscape. |
| S-G2 | Setup › **Planner settings**: change units, map type | Kept after a relaunch. Note screens that ignore the units (known gap). |
| S-G3 | Map › offline area download (Esri, small radius) | Tiles download, then the map works with the Mac's Wi-Fi off. |
| S-G4 | ADS-B (fake vehicle only): aircraft *TEST123* near home | A plane icon with callsign, altitude and distance on the map. |
| S-G5 | Disconnect, then Link › **Replay a telemetry log** from an earlier session | The HUD and map play back. Pause/seek work. |
| S-G6 | Anything that crashes, freezes or looks unlike desktop Mission Planner | Describe it with a screenshot. |

---

## Known limits (no need to report)

- Firmware flashing, ESC calibration, MP scripts and USB serial are not possible on a sideloaded iPad.
- On a real iPad the link is UDP/TCP/ExpressLRS Wi-Fi only (no UDP broadcast receive).
- The fake vehicle does not fly or execute missions. Use SITL for S-C4…S-C10, S-R5…S-R7 and S-S3.

Thanks! Send the results back and we'll fix everything you find tomorrow.
