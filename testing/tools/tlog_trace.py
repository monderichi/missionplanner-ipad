#!/usr/bin/env python3
"""Print a filtered message trace from a .tlog (both directions, as recorded by the app).
  python3 testing/tools/tlog_trace.py FILE.tlog [--grep MISSION] [--tail 40]
GCS (sys 255) lines are marked '>>', vehicle lines '<<'."""
import argparse, os, struct, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import mavlink_ref as mr
ap = argparse.ArgumentParser(); ap.add_argument("tlog"); ap.add_argument("--grep", default="MISSION"); ap.add_argument("--tail", type=int, default=40)
a = ap.parse_args()
data = open(a.tlog, "rb").read()
p = mr.Parser(); out = []; t0 = None; i = 0
while i + 8 < len(data):
    ts = struct.unpack(">Q", data[i:i + 8])[0] / 1e6
    j = i + 8
    stx = data[j]
    ln = data[j + 1]
    size = (10 + ln + 2 + (13 if data[j + 2] & 1 else 0)) if stx == 0xFD else (6 + ln + 2)
    for pk in p.feed(data[j:j + size]):
        name = mr.BY_ID[pk["msgid"]]["name"]
        if a.grep in name:
            t0 = t0 or ts
            m = mr.decode(pk["msgid"], pk["payload"])
            keep = {k: v for k, v in m.items() if k in ("seq", "count", "type", "mission_type", "current", "command")}
            out.append(f"{ts - t0:8.2f} {'>>' if pk['sysid'] == 255 else '<<'} {name} {keep}")
    i = j + size
print("\n".join(out[-a.tail:]))
