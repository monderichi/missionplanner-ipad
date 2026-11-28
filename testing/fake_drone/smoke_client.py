#!/usr/bin/env python3
"""Tiny GCS used to smoke-test fake_drone.py / SITL: connects over TCP, sends heartbeats, prints message counts."""
import socket, sys, time, os, collections
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import mavlink_ref as mr
from fake_drone import payload
port = int(sys.argv[1]) if len(sys.argv) > 1 else 5799
secs = float(sys.argv[2]) if len(sys.argv) > 2 else 4
s = socket.create_connection(("127.0.0.1", port)); s.settimeout(0.1)
p = mr.Parser(); counts = collections.Counter(); seq = 0
def send(name, **kw):
    global seq; seq = (seq + 1) & 255; mid, pl = payload(name, **kw); s.sendall(mr.encode_v2(mid, pl, seq, 255, 190))
end = time.time() + secs; last = 0; asked = False
while time.time() < end:
    if time.time() - last > 1:
        send("HEARTBEAT", type=6, autopilot=8, system_status=4, mavlink_version=3); last = time.time()
        if not asked: send("PARAM_REQUEST_LIST", target_system=1, target_component=1); asked = True
    try: data = s.recv(65536)
    except socket.timeout: continue
    for pk in p.feed(data): counts[mr.BY_ID[pk["msgid"]]["name"]] += 1
print(dict(counts), "crc_errors", p.crc_errors)
