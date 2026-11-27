#!/usr/bin/env python3
"""Share of a vehicle's parameters that have bundled metadata.
  python3 testing/tools/param_meta_coverage.py [FILE.param] [--firmware ArduCopter]
Default FILE = newest .param saved by the harness (testing/.build/home/Documents/params)."""
import glob, json, os, sys
root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
args = [a for a in sys.argv[1:] if not a.startswith("--")]
fw = sys.argv[sys.argv.index("--firmware") + 1] if "--firmware" in sys.argv else "ArduCopter"
f = args[0] if args else max(glob.glob(os.path.join(root, "testing/.build/home*/Documents/params/*.param")), key=os.path.getmtime)
meta = json.load(open(os.path.join(root, "App/Resources/ParamMeta", fw + ".json")))
names = [l.split(",")[0].strip() for l in open(f) if "," in l and not l.startswith("#")]
miss = [n for n in names if n not in meta]
print(f"{f}: {len(names)} params, {len(names) - len(miss)} with metadata ({100 * (len(names) - len(miss)) / max(1, len(names)):.1f} %)")
print("missing (first 20):", ", ".join(miss[:20]))
