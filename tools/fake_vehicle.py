"""Fake ArduCopter for testing the iPad app without a drone (used by CI's simulator job).

TCP server on 127.0.0.1:5760 (like SITL). Speaks MAVLink 2 via tools/mavlink_ref.py and acts like a
disarmed quad near home: heartbeat, attitude that rolls/pitches/turns, moving GPS position, VFR_HUD,
SYS_STATUS (battery + sensor health), GPS_RAW_INT, HOME_POSITION, ESC telemetry, RC_CHANNELS,
STATUSTEXT, a parameter table (from the bundled ArduCopter metadata), a small mission (read and
write), and COMMAND_ACK for every COMMAND_LONG. Logs every message the app sends to stdout.

usage: python -I tools/fake_vehicle.py [--port 5760] [--seconds 600]
"""
import argparse
import json
import math
import os
import socket
import struct
import sys
import threading
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import mavlink_ref as M  # noqa: E402

NAMES = {m["id"]: m["name"] for m in M.DEFS}
HOME = (37.9838, 23.7275, 120.0)  # lat, lon, alt AMSL
SYS, COMP = 1, 1

# --type selects what the fake vehicle pretends to be (MAV_TYPE, metadata file, default mode, extra params)
PROFILES = {
    "copter": dict(mav_type=2, meta="ArduCopter.json", mode=5, extra=[]),
    "rover": dict(mav_type=10, meta="ArduRover.json", mode=4,
                  extra=["MODE_CH", "MODE1", "MODE2", "MODE3", "MODE4", "MODE5", "MODE6", "CRUISE_SPEED",
                         "CRUISE_THROTTLE", "WP_SPEED", "WP_RADIUS", "ATC_STR_RAT_P", "ATC_STR_RAT_I",
                         "ATC_SPEED_P", "FS_ACTION", "FS_TIMEOUT", "MOT_PWM_TYPE", "MOT_THR_MIN", "MOT_THR_MAX",
                         "SERVO1_FUNCTION", "SERVO3_FUNCTION", "TURN_RADIUS"]),
    "boat": dict(mav_type=11, meta="ArduRover.json", mode=4, extra=["FRAME_CLASS", "CRUISE_SPEED", "WP_RADIUS"]),
    "sub": dict(mav_type=12, meta="ArduSub.json", mode=19,
                extra=["FRAME_CONFIG", "JS_GAIN_DEFAULT", "JS_GAIN_MAX", "JS_GAIN_MIN", "JS_GAIN_STEPS",
                       "JS_THR_GAIN", "SURFACE_DEPTH", "FS_LEAK_ENABLE", "FS_PRESS_ENABLE", "FS_PRESS_MAX",
                       "FS_TEMP_ENABLE", "FS_TEMP_MAX", "FS_PILOT_INPUT", "FS_PILOT_TIMEOUT", "LEAK1_PIN",
                       "LEAK1_LOGIC", "BTN0_FUNCTION", "BTN1_FUNCTION", "BTN2_FUNCTION"]),
}
PROFILE = PROFILES["copter"]


def build_params():
    meta_path = os.path.join(HERE, "..", "App", "Resources", "ParamMeta", PROFILE["meta"])
    meta = json.load(open(meta_path, encoding="utf-8"))
    wanted = ["FRAME_CLASS", "FRAME_TYPE", "ARMING_CHECK", "SERIAL6_PROTOCOL", "SERIAL6_BAUD", "SR6_EXTRA1",
              "SR6_EXTRA2", "SR6_POSITION", "FENCE_ENABLE", "FENCE_TYPE", "FENCE_ALT_MAX", "FENCE_ACTION",
              "FENCE_RADIUS", "FENCE_MARGIN", "BATT_MONITOR", "BATT_CAPACITY", "BATT_VOLT_MULT",
              "BATT_AMP_PERVLT", "BATT_LOW_VOLT", "BATT_ARM_VOLT", "FS_THR_ENABLE", "FS_THR_VALUE",
              "FS_GCS_ENABLE", "FLTMODE_CH", "FLTMODE1", "FLTMODE2", "FLTMODE3", "FLTMODE4", "FLTMODE5",
              "FLTMODE6", "ATC_RAT_RLL_P", "ATC_RAT_RLL_I", "ATC_RAT_RLL_D", "ATC_RAT_PIT_P", "ANGLE_MAX",
              "WPNAV_SPEED", "RTL_ALT", "INS_GYRO_FILTER", "MOT_SPIN_ARM", "MOT_SPIN_MIN", "RCMAP_THROTTLE"]
    defaults = {"FRAME_CLASS": 1, "FRAME_TYPE": 1, "ARMING_CHECK": 1, "SERIAL6_PROTOCOL": 2, "SERIAL6_BAUD": 460,
                "SR6_EXTRA1": 1, "FENCE_ALT_MAX": 100, "FENCE_TYPE": 7, "FENCE_ACTION": 1, "FENCE_RADIUS": 300,
                "FENCE_MARGIN": 2, "BATT_MONITOR": 4, "BATT_CAPACITY": 3300, "BATT_VOLT_MULT": 10.1,
                "BATT_AMP_PERVLT": 17, "BATT_LOW_VOLT": 14.0, "BATT_ARM_VOLT": 15.2, "FS_THR_ENABLE": 1,
                "FS_THR_VALUE": 975, "FLTMODE_CH": 5, "FLTMODE1": 0, "FLTMODE2": 2, "FLTMODE3": 5,
                "FLTMODE4": 16, "FLTMODE5": 6, "FLTMODE6": 9, "ATC_RAT_RLL_P": 0.135, "ATC_RAT_RLL_I": 0.135,
                "ATC_RAT_RLL_D": 0.0036, "ATC_RAT_PIT_P": 0.135, "ANGLE_MAX": 3000, "WPNAV_SPEED": 1000,
                "RTL_ALT": 1500, "INS_GYRO_FILTER": 20, "MOT_SPIN_ARM": 0.1, "MOT_SPIN_MIN": 0.15,
                "RCMAP_THROTTLE": 3}
    defaults.update({"FRAME_CLASS": 1 if PROFILE["mav_type"] in (2, 10) else (2 if PROFILE["mav_type"] == 11 else 1),
                     "SERVO1_FUNCTION": 26, "SERVO3_FUNCTION": 70, "MODE_CH": 8, "MODE1": 0, "MODE2": 4, "MODE3": 10,
                     "MODE4": 11, "MODE5": 15, "MODE6": 5, "CRUISE_SPEED": 3, "JS_GAIN_DEFAULT": 0.5})
    names = [n for n in wanted + PROFILE["extra"] if n in meta]
    names = list(dict.fromkeys(names))
    # pad with more real names so the list looks like a real vehicle (but stays quick to download)
    for n in sorted(meta):
        if len(names) >= 220:
            break
        if n not in names and len(n) <= 16:
            names.append(n)
    params = []
    for n in names:
        m = meta[n]
        v = defaults.get(n)
        if v is None:
            r = m.get("r")
            v = r[0] if r and r[0] > 0 else (m["v"][0][0] if m.get("v") else 0)
        params.append([n, float(v)])
    return params


def mission_items():
    lat, lon, alt = HOME
    pts = [(0, 3, 22, 0, 0, 20)]  # placeholder for takeoff (seq, frame, cmd, lat, lon, alt)
    items = [dict(seq=0, frame=0, command=16, lat=lat, lon=lon, alt=alt)]  # home
    items.append(dict(seq=1, frame=3, command=22, lat=0, lon=0, alt=20))
    for i, (dn, de) in enumerate([(80, 0), (80, 120), (-40, 160), (-60, 40)]):
        items.append(dict(seq=2 + i, frame=3, command=16, lat=lat + dn / 111320,
                          lon=lon + de / (111320 * math.cos(math.radians(lat))), alt=30 + 5 * i))
    items.append(dict(seq=6, frame=3, command=20, lat=0, lon=0, alt=0))
    del pts
    return items


class Vehicle:
    def __init__(self, conn, log):
        self.conn = conn
        self.log = log
        self.seq = 0
        self.lock = threading.Lock()
        self.params = build_params()
        self.mission = mission_items()
        self.upload = None
        self.t0 = time.time()
        self.mode = PROFILE["mode"]  # Loiter / Hold / Manual
        self.armed = False
        self.alive = True

    def send(self, msgid, **vals):
        info = M.BY_ID[msgid]
        full = {}
        for f in info["fields"]:
            v = vals.get(f["name"], 0)
            full[f["name"]] = ([0] * f["array"] if v == 0 else v) if f["array"] else v
        frame = M.encode_v2(msgid, M.encode_payload(msgid, full), self.seq & 0xFF, SYS, COMP)
        self.seq += 1
        with self.lock:
            try:
                self.conn.sendall(frame)
            except OSError:
                self.alive = False

    def param_value(self, i):
        n, v = self.params[i]
        pid = list(n.encode()[:16].ljust(16, b"\0"))
        ptype = 9 if (v != int(v) or n.startswith(("ATC_", "MOT_", "BATT_VOLT", "BATT_AMP"))) else 4
        self.send(22, param_id=pid, param_value=v, param_type=ptype, param_count=len(self.params), param_index=i)

    def item(self, it, mission_type=0):
        self.send(73, target_system=255, target_component=190, seq=it["seq"], frame=it["frame"],
                  command=it["command"], current=1 if it["seq"] == 0 else 0, autocontinue=1,
                  x=int(round(it["lat"] * 1e7)), y=int(round(it["lon"] * 1e7)), z=float(it["alt"]),
                  mission_type=mission_type)

    # ---- periodic telemetry
    def telemetry(self):
        n = 0
        while self.alive:
            t = time.time() - self.t0
            roll = math.radians(25 * math.sin(t * 0.8))
            pitch = math.radians(12 * math.sin(t * 0.5))
            yaw = (t * 0.3) % (2 * math.pi)
            self.send(30, time_boot_ms=int(t * 1000) & 0xFFFFFFFF, roll=roll, pitch=pitch, yaw=yaw)
            if n % 2 == 0:
                lat = HOME[0] + 0.0004 * math.sin(t * 0.1)
                lon = HOME[1] + 0.0006 * math.cos(t * 0.1)
                rel = {2: 12 + 3 * math.sin(t * 0.2), 12: -(4 + 1.5 * math.sin(t * 0.2))}.get(PROFILE["mav_type"], 0.0)
                self.send(74, airspeed=4.2, groundspeed=4.0, heading=int(math.degrees(yaw)) % 360, throttle=38,
                          alt=HOME[2] + rel, climb=0.6 * math.cos(t * 0.2))
                self.send(33, time_boot_ms=int(t * 1000) & 0xFFFFFFFF, lat=int(lat * 1e7), lon=int(lon * 1e7),
                          alt=int((HOME[2] + rel) * 1000), relative_alt=int(rel * 1000), vx=300, vy=100, vz=0,
                          hdg=int(math.degrees(yaw) * 100) % 36000)
            if n % 10 == 0:
                base = 81 | (128 if self.armed else 0)
                self.send(0, type=PROFILE["mav_type"], autopilot=3, base_mode=base, custom_mode=self.mode, system_status=3,
                          mavlink_version=3)
                sensors = 0x3020FC2F | (1 << 28)
                self.send(1, onboard_control_sensors_present=sensors, onboard_control_sensors_enabled=sensors,
                          onboard_control_sensors_health=sensors, load=310, voltage_battery=16420,
                          current_battery=1250, battery_remaining=76, drop_rate_comm=0)
                self.send(24, time_usec=int(time.time() * 1e6), fix_type=3, lat=int(HOME[0] * 1e7),
                          lon=int(HOME[1] * 1e7), alt=int(HOME[2] * 1000), eph=78, epv=120, vel=400, cog=9000,
                          satellites_visible=14)
                if PROFILE["mav_type"] == 12:  # external depth sensor: pressure (hPa) + water temperature (cdegC)
                    self.send(137, time_boot_ms=int(t * 1000) & 0xFFFFFFFF, press_abs=1013.25 + 98.1 * 4,
                              press_diff=0.0, temperature=1450)
                self.send(193, flags=0x1FF, velocity_variance=0.12, pos_horiz_variance=0.08,
                          pos_vert_variance=0.10, compass_variance=0.05, terrain_alt_variance=0.0)
                self.send(241, time_usec=int(time.time() * 1e6), vibration_x=8.5, vibration_y=9.1, vibration_z=12.4)
                self.send(242, latitude=int(HOME[0] * 1e7), longitude=int(HOME[1] * 1e7), altitude=int(HOME[2] * 1000))
                self.send(11030, rpm=[0, 0, 0, 0], temperature=[31, 32, 30, 33], voltage=[1640] * 4,
                          current=[0, 0, 0, 0], totalcurrent=[0] * 4, count=[n] * 4)
                self.send(147, id=0, current_consumed=412, energy_consumed=-1, temperature=32767,
                          voltages=[4105, 4102, 4108, 4105] + [65535] * 6, current_battery=1250, battery_remaining=76)
                self.send(65, time_boot_ms=int(t * 1000) & 0xFFFFFFFF, chancount=16,
                          **{f"chan{i}_raw": v for i, v in enumerate([1500, 1500, 1000, 1500, 1495, 1100, 1900, 1500], 1)},
                          rssi=210)
                self.send(36, time_usec=int(t * 1e6) & 0xFFFFFFFF, port=0,
                          **{f"servo{i}_raw": v for i, v in enumerate([1000, 1000, 1000, 1000, 1500, 1100, 0, 0], 1)})
                self.send(42, seq=2, total=len(self.mission) - 1)
            if n % 10 == 5:
                # two fake aircraft circling HOME (ADSB_VEHICLE)
                for icao, call, radius, alt_m, speed, phase in (
                        (0xABC123, b"TEST123", 180.0, 300.0, 15.0, 0.0),  # close enough to appear on the default map zoom
                        (0x4CA1F2, b"SKY42", 1500.0, 900.0, 120.0, 2.0)):
                    omega = speed / radius  # rad/s, counter-clockwise
                    ang = phase + omega * t
                    dn = radius * math.sin(ang)
                    de = radius * math.cos(ang)
                    alat = HOME[0] + dn / 111320.0
                    alon = HOME[1] + de / (111320.0 * math.cos(math.radians(HOME[0])))
                    # velocity direction for CCW motion: d(east)/dt = -sin, d(north)/dt = cos -> bearing atan2(E, N)
                    hdg = math.degrees(math.atan2(-math.sin(ang), math.cos(ang))) % 360
                    self.send(246, ICAO_address=icao, lat=int(alat * 1e7), lon=int(alon * 1e7),
                              altitude=int(alt_m * 1000), heading=int(hdg * 100) % 36000,
                              hor_velocity=int(speed * 100), ver_velocity=0, flags=0x1FF, squawk=1200,
                              altitude_type=0, callsign=list(call.ljust(9, b"\0")), emitter_type=1, tslc=1)
            if n == 30:
                self.send(253, severity=6, text=list(b"ArduCopter V4.7.3 (fake for CI)".ljust(50, b"\0")))
            if n == 60 and PROFILE["mav_type"] == 12:  # ArduSub announces water ingress like this
                self.send(253, severity=2, text=list(b"Leak Detected".ljust(50, b"\0")))
            if n % 300 == 20 and not self.armed:  # like ArduPilot: repeat PreArm failures every 30 s while disarmed
                self.send(253, severity=4, text=list(b"PreArm: RC not calibrated (fake)".ljust(50, b"\0")))
            n += 1
            time.sleep(0.1)

    # ---- requests from the app
    def handle(self, f):
        mid = f["msgid"]
        name = NAMES.get(mid, str(mid))
        v = M.decode(mid, f["payload"]) if mid in M.BY_ID else {}
        if mid != 0:
            short = {k: x for k, x in v.items() if not isinstance(x, list)}
            self.log(f"APP -> {name} {short}")
        if mid == 21:  # PARAM_REQUEST_LIST
            def stream():
                for i in range(len(self.params)):
                    self.param_value(i)
                    time.sleep(0.004)
            threading.Thread(target=stream, daemon=True).start()
        elif mid == 20:  # PARAM_REQUEST_READ
            if v["param_index"] >= 0:
                if v["param_index"] < len(self.params):
                    self.param_value(v["param_index"])
            else:
                n = bytes(v["param_id"]).split(b"\0")[0].decode()
                for i, (pn, _) in enumerate(self.params):
                    if pn == n:
                        self.param_value(i)
        elif mid == 23:  # PARAM_SET
            n = bytes(v["param_id"]).split(b"\0")[0].decode()
            for i, (pn, _) in enumerate(self.params):
                if pn == n:
                    self.params[i][1] = v["param_value"]
                    self.param_value(i)
        elif mid == 43:  # MISSION_REQUEST_LIST
            mt = v["mission_type"]
            count = len(self.mission) if mt == 0 else 0
            self.send(44, count=count, target_system=255, target_component=190, mission_type=mt)
        elif mid in (51, 40):  # MISSION_REQUEST_INT / MISSION_REQUEST
            if v["mission_type"] == 0 and v["seq"] < len(self.mission):
                self.item(self.mission[v["seq"]])
        elif mid == 47:  # MISSION_ACK from the app after a download
            pass
        elif mid == 44:  # MISSION_COUNT: upload starts
            self.upload = {"type": v["mission_type"], "count": v["count"], "items": {}}
            if v["count"] == 0:
                self.send(47, target_system=255, target_component=190, type=0, mission_type=v["mission_type"])
            else:
                self.send(51, seq=0, target_system=255, target_component=190, mission_type=v["mission_type"])
        elif mid == 73 and self.upload:
            u = self.upload
            u["items"][v["seq"]] = v
            missing = [i for i in range(u["count"]) if i not in u["items"]]
            if missing:
                self.send(51, seq=missing[0], target_system=255, target_component=190, mission_type=u["type"])
            else:
                if u["type"] == 0:
                    self.mission = [dict(seq=i, frame=u["items"][i]["frame"], command=u["items"][i]["command"],
                                         lat=u["items"][i]["x"] / 1e7, lon=u["items"][i]["y"] / 1e7,
                                         alt=u["items"][i]["z"]) for i in range(u["count"])]
                self.send(47, target_system=255, target_component=190, type=0, mission_type=u["type"])
                self.upload = None
        elif mid == 76:  # COMMAND_LONG
            cmd = v["command"]
            if cmd == 176:
                self.mode = int(v["param2"])
            if cmd == 400:
                self.armed = v["param1"] == 1
            if cmd == 512 and int(v["param1"]) == 242:
                self.send(242, latitude=int(HOME[0] * 1e7), longitude=int(HOME[1] * 1e7), altitude=int(HOME[2] * 1000))
            self.send(77, command=cmd, result=0, target_system=255, target_component=190)
        elif mid == 117:  # LOG_REQUEST_LIST
            self.send(118, id=1, num_logs=1, last_log_num=1, time_utc=1764000000, size=9000)


def serve(port, seconds):
    start = time.time()
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("127.0.0.1", port))
    srv.listen(4)
    srv.settimeout(1.0)
    log = lambda s: print(f"[{time.time() - start:7.2f}] {s}", flush=True)
    log(f"fake ArduCopter listening on tcp 127.0.0.1:{port}")
    while time.time() - start < seconds:
        try:
            conn, addr = srv.accept()
        except socket.timeout:
            continue
        log(f"app connected from {addr}")
        conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        veh = Vehicle(conn, log)
        threading.Thread(target=veh.telemetry, daemon=True).start()

        def reader(c=conn, vv=veh):
            p = M.Parser()
            c.settimeout(1.0)
            while vv.alive and time.time() - start < seconds:
                try:
                    data = c.recv(4096)
                except socket.timeout:
                    continue
                except OSError:
                    break
                if not data:
                    break
                for f in p.feed(data):
                    vv.handle(f)
            vv.alive = False
            log("app disconnected")
            c.close()
        threading.Thread(target=reader, daemon=True).start()
    log("fake vehicle stopping")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=5760)
    ap.add_argument("--seconds", type=int, default=600)
    ap.add_argument("--type", choices=sorted(PROFILES), default="copter")
    a = ap.parse_args()
    PROFILE = PROFILES[a.type]
    serve(a.port, a.seconds)
