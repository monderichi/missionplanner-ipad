"""Generate Packages/MAVLinkKit/Tests/MAVLinkKitTests/Fixtures/sample.bin, a small valid ArduPilot
DataFlash log (FMT/ATT/GPS/MODE/PARM + garbage for resync), and verify it with a reference parser.
Run: python -I tools/make_dataflash_fixture.py
"""
import struct, pathlib, collections

OUT = pathlib.Path(__file__).resolve().parent.parent / "Packages/MAVLinkKit/Tests/MAVLinkKitTests/Fixtures/sample.bin"
HDR = b"\xA3\x95"
SIZES = {'b':1,'B':1,'h':2,'H':2,'i':4,'I':4,'f':4,'d':8,'n':4,'N':16,'Z':64,'c':2,'C':2,'e':4,'E':4,
         'L':4,'M':1,'q':8,'Q':8,'a':64}
STRUCT = {'b':'b','B':'B','h':'h','H':'H','i':'i','I':'I','f':'f','d':'d','c':'h','C':'H','e':'i',
          'E':'I','L':'i','M':'B','q':'q','Q':'Q'}
SCALE = {'c':0.01,'C':0.01,'e':0.01,'E':0.01,'L':1e-7}

FORMATS = {  # type: (name, fmt, columns)
    128: ("FMT", "BBnNZ", "Type,Length,Name,Format,Columns"),
    129: ("ATT", "QccccCCCC", "TimeUS,DesRoll,Roll,DesPitch,Pitch,DesYaw,Yaw,ErrRP,ErrYaw"),
    130: ("GPS", "QBIHBcLLeffffB", "TimeUS,Status,GMS,GWk,NSats,HDop,Lat,Lng,Alt,Spd,GCrs,VZ,Yaw,U"),
    131: ("MODE", "QMBB", "TimeUS,Mode,ModeNum,Rsn"),
    132: ("PARM", "QNf", "TimeUS,Name,Value"),
}

def length(fmt): return 3 + sum(SIZES[c] for c in fmt)
def pad(s, n): return s.encode().ljust(n, b"\0")

for t, (n, f, c) in FORMATS.items():
    assert len(f) == len(c.split(",")), n

def fmt_record(t):
    n, f, c = FORMATS[t]
    return HDR + bytes([128]) + struct.pack("<BB", t, length(f)) + pad(n, 4) + pad(f, 16) + pad(c, 64)

def rec(t, *vals):
    n, f, c = FORMATS[t]
    out = HDR + bytes([t])
    vi = iter(vals)
    for ch in f:
        v = next(vi)
        if ch in ('n', 'N', 'Z'): out += pad(v, SIZES[ch])
        else: out += struct.pack("<" + STRUCT[ch], v)
    return out

def build():
    b = bytearray()
    for t in FORMATS: b += fmt_record(t)
    params = [("RTL_ALT", 1500.0), ("ARMING_CHECK", 1.0), ("WPNAV_SPEED", 500.0),
              ("BATT_CAPACITY", 5200.0), ("FS_BATT_ENABLE", 2.0), ("RTL_ALT", 2000.0)]
    for k, (n, v) in enumerate(params): b += rec(132, 500_000 + k, n, v)
    modes = {0: 0, 20: 5, 50: 6}  # i -> mode number (Stabilize, Loiter, RTL)
    for i in range(100):
        tus = 1_000_000 + i * 100_000
        if i in modes: b += rec(131, tus, modes[i], modes[i], 1)
        b += rec(129, tus, i * 10, i * 20 - 500, 0, -i * 5, i * 100, (i * 360) % 36000, i, 2 * i)
        if i % 5 == 0:
            g = i // 5
            b += rec(130, tus, 3, 1000 * g, 2300, 10, 90, 377749000 + g * 100, -1224194000, 12345,
                     1.5, 90.0, 0.0, 0.0, 1)
        if i == 49:  # garbage: stray bytes, a fake header with an unknown type
            b += b"\x00\x11\xA3\x22\xFF\xA3\x95\x7F\x01\x02"
    return bytes(b)

def parse(data):
    """Reference parser (same resync rules as DataFlash.swift)."""
    plans, out, counts = {}, collections.defaultdict(list), collections.Counter()
    pos, n = 0, len(data)
    while pos + 3 <= n:
        if data[pos] != 0xA3 or data[pos+1] != 0x95: pos += 1; continue
        t = data[pos+2]
        if t == 128:
            if pos + 89 > n: break
            ty, ln = data[pos+3], data[pos+4]
            name = data[pos+5:pos+9].split(b"\0")[0].decode()
            f = data[pos+9:pos+25].split(b"\0")[0].decode()
            cols = data[pos+25:pos+89].split(b"\0")[0].decode().split(",")
            if ln == length(f) and len(cols) == len(f):
                plans[ty] = (name, f, cols, ln)
                counts["FMT"] += 1
            pos += 89; continue
        p = plans.get(t)
        if p is None: pos += 1; continue
        name, f, cols, ln = p
        if pos + ln > n: break
        o = pos + 3; row = []
        for ch in f:
            sz = SIZES[ch]
            raw = data[o:o+sz]; o += sz
            if ch in ('n','N','Z'): row.append(raw.split(b"\0")[0].decode())
            elif ch == 'a': row.append(None)
            else:
                v = struct.unpack("<" + STRUCT[ch], raw)[0]
                row.append(v * SCALE[ch] if ch in SCALE else v)
        out[name].append(row); counts[name] += 1
        pos += ln
    return out, counts, plans

if __name__ == "__main__":
    data = build()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_bytes(data)
    out, counts, plans = parse(data)
    print("wrote", OUT, len(data), "bytes")
    print("counts", dict(counts))
    assert counts == {"FMT": 5, "ATT": 100, "GPS": 20, "MODE": 3, "PARM": 6}, counts
    att = out["ATT"]
    assert abs(att[50][2] - 5.0) < 1e-9, att[50]            # Roll = (50*20-500)*0.01
    assert abs(att[0][2] - (-5.0)) < 1e-9
    assert abs(att[99][4] - (-4.95)) < 1e-9                 # Pitch
    assert out["GPS"][0][6] == 377749000 * 1e-7 and abs(out["GPS"][0][7] + 122.4194) < 1e-9
    assert abs(out["GPS"][0][8] - 123.45) < 1e-9
    assert [r[1] for r in out["MODE"]] == [0, 5, 6]
    assert out["PARM"][-1][1:] == ["RTL_ALT", 2000.0]
    print("python round-trip OK; ATT[50] =", att[50])
