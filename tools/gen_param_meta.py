"""Converts Mission Planner's ParameterMetaDataBackup.xml into compact JSON files bundled with
the iPad app (App/Resources/ParamMeta/<Firmware>.json).

REA Parity Source: Mission Planner ParameterMetaDataBackup.xml, read by
ExtLibs/Utilities/ParameterMetaDataRepository*.cs (DisplayName, Description, Units, Range,
Increment, Values, Bitmask, RebootRequired, ReadOnly, User).

JSON per parameter (keys omitted when absent):
  n  display name        d  description       u  units
  r  [min, max]          i  increment         v  [[code, label], ...]   b  [[bit, label], ...]
  rb reboot required     ro read only         a  1 if User == Advanced

Run:  python -I tools/gen_param_meta.py ["C:/Program Files (x86)/Mission Planner/ParameterMetaDataBackup.xml"]
"""
import json
import os
import sys
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "App", "Resources", "ParamMeta")
DEFAULT_XML = r"C:\Program Files (x86)\Mission Planner\ParameterMetaDataBackup.xml"
FIRMWARE = {"ArduCopter2": "ArduCopter", "ArduPlane": "ArduPlane", "ArduRover": "ArduRover",
            "ArduSub": "ArduSub", "ArduTracker": "AntennaTracker"}


def num(s):
    s = s.strip()
    try:
        f = float(s)
    except ValueError:
        return None
    return int(f) if f.is_integer() and abs(f) < 1e15 else f


def pairs(text):
    """'0:Disabled, 1:Enabled' -> [[0, 'Disabled'], [1, 'Enabled']] (labels may contain ':' or ',')."""
    out = []
    for part in text.split(","):
        if ":" not in part:
            if out:  # a comma inside the previous label
                out[-1][1] += "," + part
            continue
        code, label = part.split(":", 1)
        c = num(code)
        if c is None:
            if out:
                out[-1][1] += "," + part
            continue
        out.append([c, label.strip()])
    return out


def convert(node):
    get = lambda tag: (node.findtext(tag) or "").strip()
    m = {}
    if get("DisplayName"):
        m["n"] = get("DisplayName")
    if get("Description"):
        m["d"] = " ".join(get("Description").split())
    if get("Units"):
        m["u"] = get("Units")
    rng = get("Range").split()
    if len(rng) == 2 and num(rng[0]) is not None and num(rng[1]) is not None:
        m["r"] = [num(rng[0]), num(rng[1])]
    if get("Increment") and num(get("Increment")) is not None:
        m["i"] = num(get("Increment"))
    if get("Values"):
        v = pairs(get("Values"))
        if v:
            m["v"] = v
    if get("Bitmask"):
        b = pairs(get("Bitmask"))
        if b:
            m["b"] = b
    if get("RebootRequired").lower() == "true":
        m["rb"] = 1
    if get("ReadOnly").lower() == "true":
        m["ro"] = 1
    if get("User") == "Advanced":
        m["a"] = 1
    return m


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_XML
    root = ET.parse(src).getroot()
    os.makedirs(OUT, exist_ok=True)
    for child in root:
        name = FIRMWARE.get(child.tag)
        if not name:
            continue
        meta = {p.tag: convert(p) for p in child}
        path = os.path.join(OUT, name + ".json")
        with open(path, "w", encoding="utf-8", newline="\n") as fh:
            json.dump(meta, fh, ensure_ascii=False, separators=(",", ":"), sort_keys=True)
        print(f"{name}: {len(meta)} params, {os.path.getsize(path) // 1024} KB")


if __name__ == "__main__":
    main()
