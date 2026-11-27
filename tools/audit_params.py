"""Audit: every ArduPilot parameter name used in App/UI and App/Vehicle against the bundled metadata.

Usage: python -I tools/audit_params.py [--missing]   (prints name -> present in Copter/Plane/Rover/Sub)
Looks at quoted ALL-CAPS literals and expands interpolated names (SERVOn_, RCn_, SERIALn_, FLTMODEn, MODEn, SRn_).
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
META = {
    "Copter": "ArduCopter", "Plane": "ArduPlane", "Rover": "ArduRover", "Sub": "ArduSub", "Tracker": "AntennaTracker",
}
meta = {k: set(json.load(open(ROOT / "App/Resources/ParamMeta" / f"{v}.json", encoding="utf-8"))) for k, v in META.items()}

LIT = re.compile(r'"([A-Z][A-Z0-9_]{2,15})"')
BS = chr(92)  # backslash: Swift string interpolation starts with backslash-paren
INTERP = re.compile('"([A-Z][A-Z0-9_]*)' + re.escape(BS + "(") + r'[^)]*\)([A-Z0-9_]*)"')
# Prefixes that are parameter families when interpolated.
RANGES = {"SERVO": range(1, 17), "RC": range(1, 17), "SERIAL": range(0, 9), "FLTMODE": range(1, 7),
          "MODE": range(1, 7), "SR": range(0, 4)}

# Literals that are not parameters (modes, enum-ish strings, keys).
IGNORE = {"YES", "NO", "ALL", "OK", "WARNING", "ERROR", "INFO", "DEBUG", "NOTICE", "ALERT", "CRITICAL", "EMERGENCY",
          "GPS", "RTL", "LAND", "AUTO", "GUIDED", "LOITER", "HOLD", "MANUAL", "ACRO", "STEERING", "SMART_RTL"}

names = {}
for folder in ("App/UI", "App/Vehicle"):
    for p in sorted((ROOT / folder).rglob("*.swift")):
        text = p.read_text(encoding="utf-8")
        for m in LIT.finditer(text):
            n = m.group(1)
            if "_" in n or n.isalpha() is False or n in ("FRAME_CLASS",):
                names.setdefault(n, set()).add(p.name)
        for m in INTERP.finditer(text):
            pre, suf = m.group(1), m.group(2)
            if pre in RANGES:
                for i in RANGES[pre]:
                    names.setdefault(f"{pre}{i}{suf}", set()).add(p.name)

union = set().union(*meta.values())
rows = []
for n in sorted(names):
    if n in IGNORE:
        continue
    present = {k: n in v for k, v in meta.items()}
    # Skip things that exist nowhere and look like plain words (not params): keep only if has digit/underscore.
    if not any(present.values()) and "_" not in n:
        continue
    rows.append((n, present, sorted(names[n])))

only_missing = "--missing" in sys.argv
print(f"{'PARAM':28} {'Copter':7} {'Plane':7} {'Rover':7} {'Sub':7} files")
for n, pr, files in rows:
    if only_missing and pr["Copter"]:
        continue
    f = lambda b: "yes" if b else "-"
    print(f"{n:28} {f(pr['Copter']):7} {f(pr['Plane']):7} {f(pr['Rover']):7} {f(pr['Sub']):7} {','.join(files)}")
bad = [n for n, pr, _ in rows if not any(pr.values())]
print(f"\n{len(rows)} names, {sum(1 for _, pr, _ in rows if not pr['Copter'])} missing on Copter, {len(bad)} in no firmware: {bad}")
