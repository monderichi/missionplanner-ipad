#!/usr/bin/env python3
"""Scriptable fake ArduCopter for break-testing the app. No dependencies: reuses tools/mavlink_ref.py.

Transports (pick one):
  --tcp-server PORT          like SITL's 5760 (app: TCP 127.0.0.1:PORT)
  --udp-out HOST:PORT        sends to the GCS (app: UDP listen PORT); replies are accepted from anyone
  --udp-bind PORT            UDP server that answers whoever sent last (app: UDP connect 127.0.0.1:PORT)

Faults (--fault NAME[,NAME...] at start, or at runtime: echo "fault NAME on|off" | nc -u 127.0.0.1 CTRL):
  nan_attitude inf_values huge_values bad_latlon gps_loss battery_low battery_critical failsafe_rtl
  reject_arm reject_mode no_ack slow_ack silent hb_only malformed dup reorder disconnect_on_arm
  disconnect_on_takeoff reboot_on_arm second_vehicle other_gcs compid_switch accelcal_nan accelcal_neg
  statustext_flood param_nan fltmode_ch0 mode_change_mid_mission v1_only high_rate wrong_sysid_ack
  ack_wrong_command accelcal_fail magcal_fail no_esc mission_no_space mission_oob param_16char param_count_change

Control port commands (UDP text, default 127.0.0.1:17001): "fault NAME on|off", "silent N" (go silent N s),
"reboot", "status" (prints state to stdout), "quit".
Every event is printed as one line "t=<s> <event>" to stdout (redirect to testing/logs/).
"""
import argparse
import math
import os
import random
import select
import socket
import struct
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "tools"))
import mavlink_ref as mr  # noqa: E402

BY_NAME = {m["name"]: m for m in mr.DEFS}
COPTER_MODES = {0: "STABILIZE", 2: "ALT_HOLD", 3: "AUTO", 4: "GUIDED", 5: "LOITER", 6: "RTL", 9: "LAND", 16: "POSHOLD"}
MAV_RESULT_ACCEPTED, MAV_RESULT_TEMP_REJECTED, MAV_RESULT_DENIED, MAV_RESULT_UNSUPPORTED, MAV_RESULT_FAILED = 0, 1, 2, 3, 4
ALL_FAULTS = __doc__.split("Faults")[1].split("Control port")[0]
T0 = time.time()


def log(msg):
    print(f"t={time.time() - T0:7.2f} {msg}", flush=True)


def payload(name, **vals):
    info = BY_NAME[name]
    full = {}
    for f in info["fields"]:
        v = vals.get(f["name"], 0)
        if f["array"]:
            if isinstance(v, (bytes, str)):
                b = v.encode() if isinstance(v, str) else v
                v = list(b[: f["array"]]) + [0] * (f["array"] - min(len(b), f["array"]))
            elif not isinstance(v, list):
                v = [v] * f["array"]
        full[f["name"]] = v
    return info["id"], mr.encode_payload(info["id"], full)


def default_params():
    """~400 parameters, including the ones the app's Setup pages read."""
    p = {
        "SYSID_THISMAV": 1, "FRAME_CLASS": 1, "FRAME_TYPE": 1, "FLTMODE_CH": 5, "FLTMODE1": 0, "FLTMODE2": 2,
        "FLTMODE3": 5, "FLTMODE4": 6, "FLTMODE5": 9, "FLTMODE6": 3, "ARMING_CHECK": 1, "RCMAP_THROTTLE": 3,
        "FENCE_ENABLE": 0, "FENCE_TYPE": 7, "FENCE_ALT_MAX": 100, "FENCE_ACTION": 1, "BATT_MONITOR": 4,
        "BATT_CAPACITY": 5200, "BATT_LOW_VOLT": 14.0, "BATT_CRT_VOLT": 13.2, "BATT_FS_LOW_ACT": 2,
        "BATT_FS_CRT_ACT": 1, "FS_THR_ENABLE": 1, "FS_GCS_ENABLE": 0, "SERIAL6_PROTOCOL": 2, "SERIAL6_BAUD": 460,
        "SR6_EXTRA1": 1, "SR6_EXT_STAT": 1, "SERVO1_FUNCTION": 33, "SERVO2_FUNCTION": 34, "SERVO3_FUNCTION": 35,
        "SERVO4_FUNCTION": 36, "SERVO5_FUNCTION": 0, "SERVO9_FUNCTION": 0, "WPNAV_SPEED": 1000, "RTL_ALT": 1500,
        "LOG_BITMASK": 176126, "INS_ACCOFFS_X": 0.01, "COMPASS_OFS_X": 12, "BATT_AMP_PERVLT": 17.0,
        "BATT_VOLT_MULT": 10.1, "MOT_SPIN_ARM": 0.1, "ATC_RAT_RLL_P": 0.135,
    }
    for ch in range(1, 17):
        p[f"RC{ch}_MIN"], p[f"RC{ch}_MAX"], p[f"RC{ch}_TRIM"] = 1100, 1900, 1500
    for ch in range(1, 17):
        p.setdefault(f"SERVO{ch}_FUNCTION", 0)
        p[f"SERVO{ch}_MIN"], p[f"SERVO{ch}_MAX"], p[f"SERVO{ch}_TRIM"] = 1000, 2000, 1500
    i = 0
    while len(p) < 400:
        p[f"TEST_P{i:03d}"] = float(i) * 0.5
        i += 1
    return p


class Drone:
    def __init__(self, a):
        self.a = a
        self.sysid, self.compid = a.sysid, a.compid
        self.faults = set(f for f in (a.fault or "").split(",") if f)
        self.seq = 0
        self.params = default_params()
        if a.params:
            while len(self.params) < a.params:
                self.params[f"BULK_{len(self.params):05d}"] = 1.0
        if "param_16char" in self.faults:
            self.params["ABCDEFGHIJKLMNOP"] = 42.0  # exactly 16 chars: no NUL terminator on the wire
        self.param_names = sorted(self.params)
        self.armed = False
        self.mode = 0
        self.lat, self.lon, self.alt = -35.3632621, 149.1652374, 0.0  # SITL default (CMAC)
        self.home = (self.lat, self.lon, 584.0)
        self.vn = self.ve = self.vz = 0.0
        self.target = None
        self.takeoff_alt = None
        self.battery = 16.4
        self.mission = []  # list of dict items (seq 0 = home)
        self.fence, self.rally = [], []
        self.cur_wp = 0
        self.upload = None  # (type, count, items)
        self.rates = {"ATTITUDE": 10, "GLOBAL_POSITION_INT": 3, "VFR_HUD": 4, "SYS_STATUS": 2, "GPS_RAW_INT": 2,
                      "RC_CHANNELS": 2, "MISSION_CURRENT": 1, "BATTERY_STATUS": 1}
        if "high_rate" in self.faults:
            self.rates = {k: 50 for k in self.rates}
        self.last_sent = {}
        self.silent_until = 0
        self.peer = None
        self.reorder_buf = []
        self.stats = {"rx": 0, "tx": 0, "param_list_requests": 0, "param_sets": 0}
        self.pending_ack = []  # (due_time, payload)
        self.flood_until = 0
        self.mid_mission_switched = False
        self.compid_switched = False
        self.accel_step = 0          # 0 = idle, 1..6 = waiting for that position
        self.magcal = None           # dict(start=t, pct={0:..,1:..}) while running
        self.fence_breached = False

    # ---------------- transport ----------------
    def setup(self):
        a = self.a
        self.conn = None
        if a.tcp_server:
            self.srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.srv.bind(("127.0.0.1", a.tcp_server))
            self.srv.listen(1)
            self.mode_kind = "tcp"
            log(f"listening tcp 127.0.0.1:{a.tcp_server}")
        else:
            self.udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.udp.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            if a.udp_bind:
                self.udp.bind(("127.0.0.1", a.udp_bind))
                log(f"udp server 127.0.0.1:{a.udp_bind}")
            else:
                self.udp.bind(("127.0.0.1", a.udp_src_port))
                h, p = a.udp_out.split(":")
                self.peer = (h, int(p))
                log(f"udp out -> {self.peer} from :{a.udp_src_port}")
            self.mode_kind = "udp"
        self.ctrl = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.ctrl.bind(("127.0.0.1", a.control_port))
        self.parser = mr.Parser()

    def write(self, raw):
        if time.time() < self.silent_until or "silent" in self.faults:
            return
        try:
            if self.mode_kind == "tcp":
                if self.conn:
                    self.conn.sendall(raw)
            elif self.peer:
                self.udp.sendto(raw, self.peer)
            self.stats["tx"] += 1
        except OSError as e:
            log(f"send error {e}")
            if self.mode_kind == "tcp":
                self.conn = None

    def send(self, name, sysid=None, compid=None, **vals):
        msgid, pl = payload(name, **vals)
        self.seq = (self.seq + 1) & 0xFF
        s, c = sysid or self.sysid, compid or self.compid
        if "compid_switch" in self.faults and self.compid_switched:
            c = 2 if compid is None else compid
        raw = mr.encode_v1(msgid, pl, self.seq, s, c) if ("v1_only" in self.faults and len(pl) <= 255) \
            else mr.encode_v2(msgid, pl, self.seq, s, c)
        if "reorder" in self.faults:
            self.reorder_buf.append(raw)
            if len(self.reorder_buf) >= 3:
                random.shuffle(self.reorder_buf)
                for r in self.reorder_buf:
                    self.write(r)
                self.reorder_buf = []
            return
        self.write(raw)
        if "dup" in self.faults:
            self.write(raw)

    def statustext(self, sev, text):
        self.send("STATUSTEXT", severity=sev, text=text[:50])
        log(f"STATUSTEXT {sev} {text}")

    # ---------------- periodic output ----------------
    def due(self, name, hz, now):
        if hz <= 0:
            return False
        if now - self.last_sent.get(name, 0) >= 1.0 / hz:
            self.last_sent[name] = now
            return True
        return False

    def telemetry(self, now):
        f = self.faults
        if self.due("HEARTBEAT", 1, now):
            base = 0x01 | 0x10 | 0x08 | (0x80 if self.armed else 0)  # custom mode, stabilize, guided, armed
            self.send("HEARTBEAT", custom_mode=self.mode, type=2, autopilot=3, base_mode=base,
                      system_status=4 if self.armed else 3, mavlink_version=3)
            if "second_vehicle" in f:
                self.send("HEARTBEAT", sysid=2, compid=1, custom_mode=6, type=2, autopilot=3, base_mode=0x81 | 0x80,
                          system_status=4, mavlink_version=3)
                self.send("ATTITUDE", sysid=2, compid=1, roll=1.0, pitch=0.5, yaw=3.0)
            if "other_gcs" in f:
                self.send("HEARTBEAT", sysid=254, compid=190, type=6, autopilot=8, base_mode=0, system_status=4,
                          mavlink_version=3)
            if "accelcal_nan" in f or "accelcal_neg" in f:
                self.send("COMMAND_LONG", command=42429, param1=float("nan") if "accelcal_nan" in f else -1.0,
                          target_system=255, target_component=190)
        if "hb_only" in f:
            return
        if self.due("ATTITUDE", self.rates.get("ATTITUDE", 0), now):
            r, p, y = 0.05 * math.sin(now), 0.03 * math.cos(now), math.atan2(self.ve, self.vn) if self.ve or self.vn else 1.0
            if "nan_attitude" in f:
                r = p = y = float("nan")
            elif "inf_values" in f:
                r, p, y = float("inf"), float("-inf"), float("inf")
            elif "huge_values" in f:
                r, p, y = 3e38, -3e38, 1e30
            self.send("ATTITUDE", time_boot_ms=int((now - T0) * 1000) & 0xFFFFFFFF, roll=r, pitch=p, yaw=y,
                      rollspeed=0, pitchspeed=0, yawspeed=0)
        if self.due("VFR_HUD", self.rates.get("VFR_HUD", 0), now):
            gs = math.hypot(self.vn, self.ve)
            alt = self.home[2] + self.alt
            climb = self.vz
            if "inf_values" in f:
                gs, alt, climb = float("inf"), float("nan"), float("-inf")
            elif "huge_values" in f:
                gs, alt, climb = 3e38, 3e38, -3e38
            self.send("VFR_HUD", airspeed=gs, groundspeed=gs, heading=90, throttle=50 if self.armed else 0, alt=alt,
                      climb=climb)
        if self.due("GLOBAL_POSITION_INT", self.rates.get("GLOBAL_POSITION_INT", 0), now):
            lat, lon = int(self.lat * 1e7), int(self.lon * 1e7)
            if "bad_latlon" in f:
                lat, lon = 2_000_000_000, 2_100_000_000  # 200°, 210°: outside valid ranges
            if "gps_loss" in f:
                lat = lon = 0
            ralt = int(self.alt * 1000)
            if "huge_values" in f:
                ralt = 2_000_000_000
            self.send("GLOBAL_POSITION_INT", time_boot_ms=int((now - T0) * 1000) & 0xFFFFFFFF, lat=lat, lon=lon,
                      alt=int((self.home[2] + self.alt) * 1000), relative_alt=ralt, vx=int(self.vn * 100),
                      vy=int(self.ve * 100), vz=int(-self.vz * 100), hdg=9000)
        if self.due("GPS_RAW_INT", self.rates.get("GPS_RAW_INT", 0), now):
            fix, sats, eph = (0, 0, 65535) if "gps_loss" in f else (3, 12, 80)
            self.send("GPS_RAW_INT", lat=int(self.lat * 1e7), lon=int(self.lon * 1e7), fix_type=fix,
                      satellites_visible=sats, eph=eph, epv=120, alt=int((self.home[2] + self.alt) * 1000))
        if self.due("SYS_STATUS", self.rates.get("SYS_STATUS", 0), now):
            v = self.battery
            rem = max(0, min(100, int((v - 13.2) / (16.8 - 13.2) * 100)))
            if "battery_low" in f:
                v, rem = 13.9, 12
            if "battery_critical" in f:
                v, rem = 13.0, 3
            sensors = 0x0020FC2F
            self.send("SYS_STATUS", onboard_control_sensors_present=sensors, onboard_control_sensors_enabled=sensors,
                      onboard_control_sensors_health=sensors & ~(0x20 if "gps_loss" in f else 0),
                      voltage_battery=int(v * 1000), current_battery=1500 if self.armed else 50, battery_remaining=rem,
                      load=300)
        if self.due("RC_CHANNELS", self.rates.get("RC_CHANNELS", 0), now):
            ch = [1500] * 18
            ch[4] = 1300  # mode switch position 2
            self.send("RC_CHANNELS", chancount=16, **{f"chan{i + 1}_raw": ch[i] for i in range(18)}, rssi=200)
        if "no_esc" not in f and self.due("ESC_TELEMETRY_1_TO_4", 1, now):
            rpm = [9000 + 150 * i if self.armed else 0 for i in range(4)]
            self.send("ESC_TELEMETRY_1_TO_4", rpm=rpm, temperature=[31, 32, 33, 34], voltage=[int(self.battery * 100)] * 4,
                      current=[350 if self.armed else 0] * 4, totalcurrent=[10] * 4, count=[1] * 4)
        if self.accel_step and self.due("ACCELPOS", 1, now):  # ArduPilot re-requests the position every second
            self.send("COMMAND_LONG", command=42429, param1=float(self.accel_step), target_system=255, target_component=190)
        if self.magcal and self.due("MAG_CAL_PROGRESS", 4, now):
            el = now - self.magcal["start"]
            for cid in (0, 1):
                pct = min(100, int(el * (12 if cid == 0 else 10)))
                if "magcal_fail" in f and cid == 1:
                    pct = min(pct, 60)
                self.send("MAG_CAL_PROGRESS", compass_id=cid, cal_mask=3, cal_status=3 if pct < 100 else 4, attempt=1,
                          completion_pct=pct)
                if (pct >= 100 or ("magcal_fail" in f and cid == 1 and el > 9)) and cid not in self.magcal["done"]:
                    self.magcal["done"].add(cid)
                    ok = not ("magcal_fail" in f and cid == 1)
                    self.send("MAG_CAL_REPORT", compass_id=cid, cal_mask=3, cal_status=4 if ok else 5, autosaved=1 if ok else 0,
                              fitness=8.5 + cid, ofs_x=12.0, ofs_y=-30.0, ofs_z=55.0, diag_x=1, diag_y=1, diag_z=1, scale_factor=1)
                    log(f"MAG_CAL_REPORT compass {cid} {'success' if ok else 'FAILED'}")
            if len(self.magcal["done"]) == 2:
                self.magcal = None
        if self.due("MISSION_CURRENT", self.rates.get("MISSION_CURRENT", 0), now):
            self.send("MISSION_CURRENT", seq=self.cur_wp)
        if "statustext_flood" in f and self.due("FLOOD", 10, now):  # 200 STATUSTEXT/s
            for k in range(20):
                self.send("STATUSTEXT", severity=6, text=f"Flood {int(now * 100)}-{k} " + "x" * 20)
        if "malformed" in f and self.due("MALFORMED", 5, now):
            self.inject_malformed()

    def inject_malformed(self):
        """Garbage that a real noisy link produces: random bytes, truncated frames, bad CRC, oversized len."""
        kind = random.choice(["noise", "truncated", "badcrc", "oversized", "unknown_id", "zero_len_attitude"])
        msgid, pl = payload("ATTITUDE", roll=0.1, pitch=0.1, yaw=0.1)
        good = mr.encode_v2(msgid, pl, 0, self.sysid, self.compid)
        if kind == "noise":
            raw = bytes(random.getrandbits(8) for _ in range(random.randint(1, 300)))
        elif kind == "truncated":
            raw = good[: random.randint(2, len(good) - 1)]
        elif kind == "badcrc":
            raw = good[:-1] + bytes([good[-1] ^ 0xFF])
        elif kind == "oversized":
            raw = bytes([0xFD, 255, 0, 0, 0, self.sysid, self.compid, 30, 0, 0]) + bytes(255) + b"\x00\x00"
        elif kind == "unknown_id":
            raw = bytes([0xFD, 4, 0, 0, 0, self.sysid, self.compid, 0xEE, 0xEE, 0x0E, 1, 2, 3, 4, 0, 0])
        else:  # valid CRC, payload truncated to 1 byte (v2 allows it; decoder must zero-extend)
            raw = mr.encode_v2(msgid, b"\x00" * len(pl), 0, self.sysid, self.compid)
        self.write(raw)

    # ---------------- physics ----------------
    def physics(self, dt):
        speed = 5.0
        if self.armed and self.takeoff_alt is not None and self.mode in (4, 3):
            if self.alt < self.takeoff_alt - 0.2:
                self.vz = 2.0
            else:
                self.vz, self.takeoff_alt = 0.0, None
                log(f"reached takeoff alt {self.alt:.1f}")
        elif self.mode == 9 and self.armed:  # LAND
            self.vz = -1.0 if self.alt > 0 else 0
            self.target = None
        elif self.mode == 6 and self.armed:  # RTL
            self.target = (self.home[0], self.home[1], max(self.alt, 15))
        elif self.mode == 3 and self.armed and self.mission:
            if self.cur_wp < 1:
                self.cur_wp = 1
            if self.cur_wp < len(self.mission):
                it = self.mission[self.cur_wp]
                if it["command"] == 22:  # takeoff
                    self.takeoff_alt = it["z"]
                    if self.alt >= it["z"] - 0.3:
                        self.next_wp()
                elif it["command"] == 20:  # RTL
                    self.mode = 6
                    log("mission RTL -> mode RTL")
                else:
                    self.target = (it["x"] / 1e7, it["y"] / 1e7, it["z"])
            if "mode_change_mid_mission" in self.faults and self.cur_wp >= 2 and not self.mid_mission_switched:
                self.mid_mission_switched = True
                self.mode = 5
                self.statustext(4, "Mode change to LOITER (RC switch)")
        if self.target and self.armed:
            dn = (self.target[0] - self.lat) * 111_320
            de = (self.target[1] - self.lon) * 111_320 * math.cos(math.radians(self.lat))
            dz = self.target[2] - self.alt
            d = math.hypot(dn, de)
            if d < 1.0 and abs(dz) < 0.5:
                self.vn = self.ve = self.vz = 0
                if self.mode == 3:
                    self.send("MISSION_ITEM_REACHED", seq=self.cur_wp)
                    self.next_wp()
                elif self.mode == 6:
                    self.mode = 9
                    log("RTL at home -> LAND")
                self.target = None
            else:
                k = min(speed, d / max(dt, 1e-3)) / max(d, 1e-6)
                self.vn, self.ve = dn * k, de * k
                self.vz = max(-2, min(2, dz))
        elif self.takeoff_alt is None and self.mode != 9:
            self.vn = self.ve = 0
            self.vz = 0
        if (self.params.get("FENCE_ENABLE") == 1 and self.armed and not self.fence_breached
                and self.alt > float(self.params.get("FENCE_ALT_MAX", 100)) and int(self.params.get("FENCE_TYPE", 0)) & 1):
            self.fence_breached = True
            self.takeoff_alt = None
            self.target = None
            action = int(self.params.get("FENCE_ACTION", 1))
            self.mode = 9 if action == 2 else 6
            self.statustext(0, "Fence Breach: altitude")  # EMERGENCY, as ArduPilot's breach message
            log(f"FENCE BREACH at {self.alt:.1f} m -> {COPTER_MODES[self.mode]}")
        self.lat += self.vn * dt / 111_320
        self.lon += self.ve * dt / (111_320 * math.cos(math.radians(self.lat)))
        self.alt = max(0.0, self.alt + self.vz * dt)
        if self.armed:
            self.battery = max(12.0, self.battery - 0.002 * dt)
        if self.mode == 9 and self.armed and self.alt <= 0.01:
            self.armed = False
            log("landed, disarmed")

    def next_wp(self):
        self.cur_wp += 1
        if self.cur_wp >= len(self.mission):
            log("mission complete")
            self.mode = 5

    # ---------------- inbound ----------------
    def ack(self, cmd, result, progress=0):
        if "no_ack" in self.faults:
            log(f"(no_ack) dropping ACK for {cmd}")
            return
        if "ack_wrong_command" in self.faults:
            cmd = (cmd + 1) & 0xFFFF
        sysid = 7 if "wrong_sysid_ack" in self.faults else None
        if "slow_ack" in self.faults:
            self.pending_ack.append((time.time() + 5, cmd, result, progress))
            return
        self.send("COMMAND_ACK", sysid=sysid, command=cmd, result=result, progress=progress, target_system=255,
                  target_component=190)

    def param_value(self, name):
        idx = self.param_names.index(name)
        v = float(self.params[name])
        if "param_nan" in self.faults and name == "TEST_P001":
            v = float("nan")
        if "fltmode_ch0" in self.faults and name == "FLTMODE_CH":
            v = 0.0
        count = len(self.param_names)
        if "param_count_change" in self.faults and self.stats.get("pv_sent", 0) > 50:
            count += 10  # vehicle reports a different total mid-download (e.g. a script added params)
        self.stats["pv_sent"] = self.stats.get("pv_sent", 0) + 1
        self.send("PARAM_VALUE", param_id=name, param_value=v, param_type=9, param_count=count, param_index=idx)

    def handle(self, pkt):
        self.stats["rx"] += 1
        mid = pkt["msgid"]
        name = mr.BY_ID[mid]["name"]
        m = mr.decode(mid, pkt["payload"])
        if name == "HEARTBEAT":
            return
        if "target_system" in m and m["target_system"] not in (0, self.sysid):
            return
        f = self.faults
        if name == "PARAM_REQUEST_LIST":
            self.stats["param_list_requests"] += 1
            log(f"PARAM_REQUEST_LIST -> streaming {len(self.param_names)}")
            self.param_stream = list(self.param_names)
        elif name == "PARAM_REQUEST_READ":
            pid = bytes(m["param_id"]).split(b"\0")[0].decode(errors="replace")
            if m["param_index"] >= 0 and m["param_index"] < len(self.param_names):
                self.param_value(self.param_names[m["param_index"]])
            elif pid in self.params:
                self.param_value(pid)
        elif name == "PARAM_SET":
            pid = bytes(m["param_id"]).split(b"\0")[0].decode(errors="replace")
            self.stats["param_sets"] += 1
            log(f"PARAM_SET {pid}={m['param_value']}")
            if pid in self.params:
                v = m["param_value"]
                if not math.isfinite(v):
                    log(f"PARAM_SET {pid} non-finite value rejected")
                else:
                    self.params[pid] = v
                self.param_value(pid)
        elif name == "REQUEST_DATA_STREAM":
            log(f"REQUEST_DATA_STREAM id={m['req_stream_id']} rate={m['req_message_rate']} on={m['start_stop']}")
            groups = {1: ["RAW_IMU"], 2: ["SYS_STATUS", "GPS_RAW_INT", "MISSION_CURRENT", "BATTERY_STATUS"],
                      3: ["RC_CHANNELS"], 6: ["GLOBAL_POSITION_INT"], 10: ["ATTITUDE"], 11: ["VFR_HUD"], 12: []}
            if "high_rate" not in f:
                for msg in groups.get(m["req_stream_id"], []):
                    self.rates[msg] = m["req_message_rate"] if m["start_stop"] else 0
        elif name == "SET_MODE":
            self.set_mode(int(m["custom_mode"]))
        elif name == "COMMAND_LONG":
            self.command(m)
        elif name == "MISSION_REQUEST_LIST":
            items = self.items(m["mission_type"])
            self.send("MISSION_COUNT", count=len(items), target_system=255, target_component=190,
                      mission_type=m["mission_type"])
        elif name in ("MISSION_REQUEST_INT", "MISSION_REQUEST"):
            items = self.items(m["mission_type"])
            s = m["seq"]
            if s < len(items):
                it = dict(items[s])
                it.update(seq=s, target_system=255, target_component=190, mission_type=m["mission_type"])
                if self.upload is None:
                    self.send("MISSION_ITEM_INT", **it)
        elif name == "MISSION_COUNT":
            log(f"MISSION_COUNT {m['count']} type {m['mission_type']}")
            if "mission_no_space" in self.faults and m["count"] > 5:
                self.send("MISSION_ACK", target_system=255, target_component=190, type=4, mission_type=m["mission_type"])
                log("MISSION_ACK NO_SPACE")
                return
            self.upload = (m["mission_type"], m["count"], [None] * m["count"])
            if "mission_oob" in self.faults:
                self.send("MISSION_REQUEST_INT", seq=m["count"] + 5, target_system=255, target_component=190,
                          mission_type=m["mission_type"])
                log("requested out-of-range seq")
            if m["count"] == 0:
                self.set_items(m["mission_type"], [])
                self.upload = None
                self.send("MISSION_ACK", target_system=255, target_component=190, type=0, mission_type=m["mission_type"])
            else:
                self.send("MISSION_REQUEST_INT", seq=0, target_system=255, target_component=190,
                          mission_type=m["mission_type"])
        elif name in ("MISSION_ITEM_INT", "MISSION_ITEM"):
            if m["current"] == 2:  # guided "fly here"
                self.target = ((m["x"] / 1e7) if name == "MISSION_ITEM_INT" else m["x"],
                               (m["y"] / 1e7) if name == "MISSION_ITEM_INT" else m["y"], m["z"])
                log(f"GUIDED goto {self.target}")
                self.send("MISSION_ACK", target_system=255, target_component=190, type=0 if self.mode == 4 else 1,
                          mission_type=0)
                return
            if self.upload is None:
                self.send("MISSION_ACK", target_system=255, target_component=190, type=0, mission_type=m["mission_type"])
                return
            mtype, count, items = self.upload
            s = m["seq"]
            if s < count:
                items[s] = {k: m[k] for k in ("param1", "param2", "param3", "param4", "x", "y", "z", "command", "frame",
                                              "current", "autocontinue")}
            nxt = next((i for i, it in enumerate(items) if it is None), None)
            if nxt is None:
                self.set_items(mtype, items)
                self.upload = None
                log(f"mission type {mtype} stored: {count} items")
                self.send("MISSION_ACK", target_system=255, target_component=190, type=0, mission_type=mtype)
            else:
                self.send("MISSION_REQUEST_INT", seq=nxt, target_system=255, target_component=190, mission_type=mtype)
        elif name == "MISSION_CLEAR_ALL":
            self.set_items(m["mission_type"], [])
            self.send("MISSION_ACK", target_system=255, target_component=190, type=0, mission_type=m["mission_type"])
        elif name == "MISSION_SET_CURRENT":
            self.cur_wp = m["seq"]
            log(f"MISSION_SET_CURRENT {m['seq']}")
            self.send("MISSION_CURRENT", seq=self.cur_wp)
        elif name == "LOG_REQUEST_LIST":
            for i in (1, 2):
                self.send("LOG_ENTRY", id=i, num_logs=2, last_log_num=2, size=1000 * i, time_utc=1_700_000_000)
        elif name == "LOG_REQUEST_DATA":
            size = 1000 * m["id"]
            ofs, end = m["ofs"], min(size, m["ofs"] + m["count"])
            while ofs < end:
                n = min(90, end - ofs)
                self.send("LOG_DATA", id=m["id"], ofs=ofs, count=n, data=bytes((ofs + k) & 0xFF for k in range(n)))
                ofs += n
            if m["ofs"] >= size:
                self.send("LOG_DATA", id=m["id"], ofs=size, count=0, data=b"")

    def items(self, t):
        return {0: self.mission, 1: self.fence, 2: self.rally}.get(t, [])

    def set_items(self, t, items):
        if t == 0:
            self.mission = items
        elif t == 1:
            self.fence = items
        elif t == 2:
            self.rally = items

    def set_mode(self, mode):
        if "reject_mode" in self.faults:
            self.statustext(3, "Flight mode change failed")
            return False
        if mode not in COPTER_MODES:
            self.statustext(3, f"Unknown mode {mode}")
            return False
        self.mode = mode
        log(f"mode -> {COPTER_MODES[mode]}")
        if mode == 3:
            self.cur_wp = max(self.cur_wp, 1)
        return True

    def command(self, m):
        cmd = m["command"]
        log(f"COMMAND_LONG {cmd} p1={m['param1']} p2={m['param2']} p7={m['param7']} conf={m['confirmation']}")
        f = self.faults
        if cmd == 400:  # arm/disarm
            if m["param1"] == 1:
                if "disconnect_on_arm" in f:
                    self.armed = True
                    self.silent_until = time.time() + 1e9
                    log("disconnect_on_arm: armed, going silent forever")
                    return
                if "reboot_on_arm" in f:
                    self.reboot()
                    return
                if "reject_arm" in f:
                    self.statustext(2, "PreArm: Battery below minimum arming voltage")
                    return self.ack(cmd, MAV_RESULT_FAILED)
                self.armed = True
                log("ARMED")
            else:
                if self.alt > 0.5 and m["param2"] != 21196:
                    self.statustext(3, "Disarm: vehicle is flying")
                    return self.ack(cmd, MAV_RESULT_FAILED)
                self.armed = False
                log("DISARMED" + (" (FORCE)" if m["param2"] == 21196 else ""))
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        if cmd == 176:  # DO_SET_MODE
            ok = self.set_mode(int(m["param2"]))
            return self.ack(cmd, MAV_RESULT_ACCEPTED if ok else MAV_RESULT_FAILED)
        if cmd == 22:  # NAV_TAKEOFF
            if not self.armed or self.mode != 4:
                return self.ack(cmd, MAV_RESULT_FAILED)
            if "disconnect_on_takeoff" in f:
                self.takeoff_alt = m["param7"]
                self.silent_until = time.time() + 1e9
                log("disconnect_on_takeoff: climbing, going silent")
                return
            self.takeoff_alt = m["param7"]
            log(f"TAKEOFF to {m['param7']}")
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        if cmd == 246:
            self.ack(cmd, MAV_RESULT_ACCEPTED)
            return self.reboot()
        if cmd in (511, 512):
            if cmd == 512 and int(m["param1"]) == 242:
                self.send("HOME_POSITION", latitude=int(self.home[0] * 1e7), longitude=int(self.home[1] * 1e7),
                          altitude=int(self.home[2] * 1000), q=[1, 0, 0, 0])
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        if cmd == 179:
            self.home = (self.lat, self.lon, self.home[2])
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        if cmd == 241 and m["param5"] == 1:  # 6-position accel cal
            self.accel_step = 1
            self.ack(cmd, MAV_RESULT_ACCEPTED)
            self.statustext(6, "Place vehicle level and press any key.")
            self.send("COMMAND_LONG", command=42429, param1=1.0, target_system=255, target_component=190)
            return
        if cmd == 42429:  # GCS confirms a position
            if self.accel_step and int(m["param1"]) == self.accel_step:
                if "accelcal_fail" in f and self.accel_step == 3:
                    self.accel_step = 0
                    self.statustext(2, "Calibration FAILED")
                    self.send("COMMAND_LONG", command=42429, param1=16777216.0, target_system=255, target_component=190)
                elif self.accel_step == 6:
                    self.accel_step = 0
                    self.statustext(6, "Calibration successful")
                    self.send("COMMAND_LONG", command=42429, param1=16777215.0, target_system=255, target_component=190)
                else:
                    self.accel_step += 1
                    self.send("COMMAND_LONG", command=42429, param1=float(self.accel_step), target_system=255,
                              target_component=190)
                log(f"accel cal -> step {self.accel_step}")
            else:
                log(f"accel cal: ignored position {m['param1']} (waiting for {self.accel_step})")
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        if cmd == 42424:
            self.magcal = dict(start=time.time(), done=set())
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        if cmd == 42425:
            self.statustext(6, "Compass calibration accepted")
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        if cmd == 42426:
            self.magcal = None
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        if cmd == 401:
            if "reject_arm" in f or "gps_loss" in f:
                self.statustext(2, "PreArm: GPS: Bad fix" if "gps_loss" in f else "PreArm: Battery below minimum arming voltage")
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        if cmd == 209:
            if self.armed:
                return self.ack(cmd, MAV_RESULT_DENIED)
            log(f"MOTOR TEST motor={int(m['param1'])} type={int(m['param2'])} thr={m['param3']} dur={m['param4']} count={int(m['param5'])}")
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        if cmd in (178, 183, 241, 181):
            return self.ack(cmd, MAV_RESULT_ACCEPTED)
        return self.ack(cmd, MAV_RESULT_UNSUPPORTED)

    def reboot(self):
        log("REBOOT: silent 3 s, then fresh boot")
        self.silent_until = time.time() + 3
        self.armed = False
        self.mode = 0
        self.seq = 0

    def control(self, text):
        parts = text.strip().split()
        if not parts:
            return
        if parts[0] == "fault" and len(parts) >= 3:
            (self.faults.add if parts[2] == "on" else self.faults.discard)(parts[1])
            if parts[1] == "compid_switch":
                self.compid_switched = parts[2] == "on"
            log(f"CONTROL fault {parts[1]} {parts[2]} -> {sorted(self.faults)}")
        elif parts[0] == "silent":
            self.silent_until = time.time() + float(parts[1])
            log(f"CONTROL silent {parts[1]} s")
        elif parts[0] == "reboot":
            self.reboot()
        elif parts[0] == "status":
            log(f"STATUS armed={self.armed} mode={COPTER_MODES.get(self.mode)} alt={self.alt:.1f} wp={self.cur_wp} "
                f"mission={len(self.mission)} fence={len(self.fence)} rally={len(self.rally)} stats={self.stats}")
        elif parts[0] == "quit":
            log("CONTROL quit")
            raise SystemExit(0)

    # ---------------- main loop ----------------
    def run(self):
        self.setup()
        self.param_stream = []
        last = time.time()
        if "compid_switch" in self.faults:
            self.compid_switched = True
        if self.a.duration:
            end = time.time() + self.a.duration
        else:
            end = float("inf")
        while time.time() < end:
            socks = [self.ctrl]
            if self.mode_kind == "tcp":
                socks.append(self.conn or self.srv)
            else:
                socks.append(self.udp)
            r, _, _ = select.select(socks, [], [], 0.01)
            for s in r:
                if s is self.ctrl:
                    self.control(self.ctrl.recv(1024).decode(errors="replace"))
                elif self.mode_kind == "tcp" and s is self.srv:
                    self.conn, addr = self.srv.accept()
                    self.conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
                    log(f"tcp client {addr}")
                    self.parser = mr.Parser()
                else:
                    try:
                        if self.mode_kind == "tcp":
                            data = self.conn.recv(65536)
                            if not data:
                                log("tcp client closed")
                                self.conn = None
                                continue
                        else:
                            data, addr = self.udp.recvfrom(65536)
                            if self.a.udp_bind or self.peer is None:
                                self.peer = addr
                    except OSError as e:
                        log(f"recv error {e}")
                        self.conn = None
                        continue
                    if time.time() < self.silent_until:
                        continue
                    for pkt in self.parser.feed(data):
                        self.handle(pkt)
            now = time.time()
            dt, last = now - last, now
            self.physics(dt)
            for (due, cmd, res, prog) in [x for x in self.pending_ack if x[0] <= now]:
                self.pending_ack.remove((due, cmd, res, prog))
                self.send("COMMAND_ACK", command=cmd, result=res, progress=prog, target_system=255, target_component=190)
            if self.param_stream and time.time() >= self.silent_until:
                for _ in range(min(self.a.param_burst, len(self.param_stream))):
                    self.param_value(self.param_stream.pop(0))
            if (self.mode_kind == "udp" and self.peer) or (self.mode_kind == "tcp" and self.conn):
                self.telemetry(now)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--tcp-server", type=int)
    ap.add_argument("--udp-out")
    ap.add_argument("--udp-src-port", type=int, default=14590)
    ap.add_argument("--udp-bind", type=int)
    ap.add_argument("--sysid", type=int, default=1)
    ap.add_argument("--compid", type=int, default=1)
    ap.add_argument("--fault", default="")
    ap.add_argument("--params", type=int, default=0, help="total parameter count (default ~400)")
    ap.add_argument("--param-burst", type=int, default=20, help="PARAM_VALUEs per 10 ms loop")
    ap.add_argument("--control-port", type=int, default=17001)
    ap.add_argument("--duration", type=float, default=0)
    ap.add_argument("--seed", type=int, default=1)
    a = ap.parse_args()
    random.seed(a.seed)
    unknown = [f for f in a.fault.split(",") if f and f not in ALL_FAULTS.split()]
    if unknown:
        ap.error(f"unknown fault(s) {unknown}")
    if not (a.tcp_server or a.udp_out or a.udp_bind):
        ap.error("pick --tcp-server, --udp-out or --udp-bind")
    try:
        Drone(a).run()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
