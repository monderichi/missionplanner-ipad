"""Builds App/Resources/ParamMeta/<Firmware>.json from ArduPilot's own parameter metadata (apm.pdef.json).

BUG-034: the bundled metadata came from an older Mission Planner ParameterMetaDataBackup.xml and missed 42 % of the
parameters of ArduCopter 4.7.3 (incl. all MAVn_* stream rates, renamed from SRn_* in 4.7). This script uses the
metadata generated from the exact firmware source instead.

1. In an ArduPilot checkout at the release tag (e.g. testing/.sitl/ardupilot at Copter-4.7.3; needs `pip install lxml`):
     python Tools/autotest/param_metadata/param_parse.py --vehicle ArduCopter --format json   # → apm.pdef.json
   (repeat for Rover, ArduSub, ArduPlane, AntennaTracker in separate folders)
2. python3 -I tools/gen_param_meta_ardupilot.py <dir with ArduCopter/ Rover/ ArduSub/ ArduPlane/ AntennaTracker/> [<dir of previous JSON>]
   The optional second folder keeps names that only older firmware has (ARMING_CHECK, SRn_*, …).

Output keys (same as tools/gen_param_meta.py, read by App/Vehicle/ParamMetadata.swift):
  n display name, d description, u units, r [min, max], i increment, v [[code, label]], b [[bit, label]],
  rb reboot required, ro read only, a 1 if User == Advanced
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "App", "Resources", "ParamMeta")
VEHICLES = {"ArduCopter": "ArduCopter", "Rover": "ArduRover", "ArduSub": "ArduSub", "ArduPlane": "ArduPlane",
            "AntennaTracker": "AntennaTracker"}


def num(s):
    try:
        f = float(s)
    except (TypeError, ValueError):
        return None
    return int(f) if f.is_integer() else f


def pairs(d):
    out = []
    for k, v in d.items():
        n = num(k)
        if n is not None:
            out.append([n, str(v).strip()])
    return sorted(out, key=lambda p: p[0])


def convert(p):
    m = {}
    if p.get("DisplayName"):
        m["n"] = p["DisplayName"].strip()
    if p.get("Description"):
        m["d"] = " ".join(p["Description"].split())
    if p.get("Units"):
        m["u"] = p["Units"]
    r = p.get("Range")
    if isinstance(r, dict) and num(r.get("low")) is not None and num(r.get("high")) is not None:
        m["r"] = [num(r["low"]), num(r["high"])]
    if num(p.get("Increment")) is not None:
        m["i"] = num(p["Increment"])
    if isinstance(p.get("Values"), dict) and p["Values"]:
        m["v"] = pairs(p["Values"])
    if isinstance(p.get("Bitmask"), dict) and p["Bitmask"]:
        m["b"] = pairs(p["Bitmask"])
    if str(p.get("RebootRequired", "")).lower() == "true":
        m["rb"] = 1
    if str(p.get("ReadOnly", "")).lower() == "true":
        m["ro"] = 1
    if p.get("User") == "Advanced":
        m["a"] = 1
    return m


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "..", "testing", ".sitl", "pdef")
    for folder, firmware in VEHICLES.items():
        src = os.path.join(root, folder, "apm.pdef.json")
        if not os.path.exists(src):
            print(f"skip {folder}: {src} missing")
            continue
        groups = json.load(open(src, encoding="utf-8"))
        out = {}
        for params in groups.values():
            if not isinstance(params, dict):  # e.g. {"json": {"version": 1}}
                continue
            for name, p in params.items():
                if not isinstance(p, dict):
                    continue
                name = name.split(":")[-1]  # some generators prefix the vehicle ("ArduCopter:NAME")
                out[name] = convert(p)
        dst = os.path.join(OUT, f"{firmware}.json")
        # Keep entries of the previous metadata for names this release no longer has (older firmware still uses them,
        # e.g. ARMING_CHECK before 4.7's ARMING_SKIPCHK, SRn_* before MAVn_*). New release data wins for shared names.
        legacy = sys.argv[2] if len(sys.argv) > 2 else None
        if legacy:
            old_path = os.path.join(legacy, f"{firmware}.json")
            if os.path.exists(old_path):
                old = json.load(open(old_path, encoding="utf-8"))
                kept = {k: v for k, v in old.items() if k not in out}
                out.update(kept)
                print(f"  kept {len(kept)} legacy names from {os.path.relpath(old_path)}")
        with open(dst, "w", encoding="utf-8") as f:
            json.dump(dict(sorted(out.items())), f, ensure_ascii=False, separators=(",", ":"))
        print(f"{firmware}: {len(out)} parameters -> {os.path.relpath(dst)}")


if __name__ == "__main__":
    main()
