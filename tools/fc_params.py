"""Read / set ArduPilot params over USB serial (Windows bench tool) using mavlink_ref.py.
Needs pyserial. Close/disconnect Mission Planner first: it holds the COM port.

usage: python -I tools/fc_params.py COM12 dump <out.json>
       python -I tools/fc_params.py COM12 set NAME=VAL [NAME=VAL ...]
       python -I tools/fc_params.py COM12 reboot
"""
import json, os, struct, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mavlink_ref as M
import serial

port, mode, args = sys.argv[1], sys.argv[2], sys.argv[3:]
ser = serial.Serial(port, 115200, timeout=0.05)
parser = M.Parser()
seq = 0
target = None


def send(msgid, vals):
    global seq
    ser.write(M.encode_v2(msgid, M.encode_payload(msgid, vals), seq & 0xFF, 255, 190))
    seq += 1


def frames(timeout):
    end = time.time() + timeout
    while time.time() < end:
        data = ser.read(4096)
        for f in parser.feed(data):
            yield f


def pid(name):
    b = name.encode()[:16]
    return list(b + bytes(16 - len(b)))


def pname(v):
    return bytes(v["param_id"]).split(b"\0")[0].decode()


# wait for autopilot heartbeat
for f in frames(5):
    if f["msgid"] == 0 and f["compid"] == 1:
        target = f["sysid"]
        break
if target is None:
    sys.exit("No heartbeat on " + port + " (is Mission Planner still connected?)")
hb = lambda: send(0, dict(custom_mode=0, type=6, autopilot=8, base_mode=0, system_status=4, mavlink_version=3))
hb()

if mode == "dump":
    params, count, last = {}, None, time.time()
    send(21, dict(target_system=target, target_component=1))
    while True:
        got = False
        for f in frames(0.5):
            if f["msgid"] == 22:
                v = M.decode(22, f["payload"])
                params[pname(v)] = v["param_value"]
                count = v["param_count"]
                got = True
        if count and len(params) >= count:
            break
        if not got:
            if time.time() - last > 20:
                break
            # re-request missing by index
            send(21, dict(target_system=target, target_component=1)) if count is None else None
        else:
            last = time.time()
    json.dump(params, open(args[0], "w"), indent=1, sort_keys=True)
    print(f"sysid {target}: {len(params)}/{count} params -> {args[0]}")

elif mode == "set":
    for a in args:
        name, val = a.split("=")
        val = float(val)
        ok = False
        for attempt in range(3):
            send(23, dict(param_value=val, target_system=target, target_component=1,
                          param_id=pid(name), param_type=9))
            for f in frames(1.5):
                if f["msgid"] == 22:
                    v = M.decode(22, f["payload"])
                    if pname(v) == name:
                        print(f"{name} = {v['param_value']:g}")
                        ok = abs(v["param_value"] - val) < 1e-3
                        break
            if ok:
                break
        if not ok:
            print(f"!! {name} not confirmed")

elif mode == "reboot":
    send(76, dict(param1=1, param2=0, param3=0, param4=0, param5=0, param6=0, param7=0,
                  command=246, target_system=target, target_component=1, confirmation=0))
    for f in frames(2):
        if f["msgid"] == 77:
            print("reboot ack", M.decode(77, f["payload"]))
            break
ser.close()
