"""Reference MAVLink v1/v2 codec in Python.

This mirrors the Swift implementation in Packages/MAVLinkKit line-for-line so the
algorithms (X.25 CRC, CRC_EXTRA, framing, v2 zero truncation, resync on bad CRC,
tlog framing) can be verified on Windows, where Swift isn't available, against
packets produced by Mission Planner's own MAVLink.dll (see make_fixtures.ps1).

Run:  python -I tools/mavlink_ref.py
"""
import json
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DEFS = json.load(open(os.path.join(HERE, "mavlink_defs.json"), encoding="utf-8"))
BY_ID = {m["id"]: m for m in DEFS}

STX_V1 = 0xFE
STX_V2 = 0xFD
SIGNED_FLAG = 0x01
FMT = {"Byte": "B", "SByte": "b", "UInt16": "H", "Int16": "h", "UInt32": "I",
       "Int32": "i", "UInt64": "Q", "Int64": "q", "Single": "f", "Double": "d"}


def crc_accumulate(b, crc):
    tmp = (b ^ (crc & 0xFF)) & 0xFF
    tmp = (tmp ^ (tmp << 4)) & 0xFF
    return ((crc >> 8) ^ (tmp << 8) ^ (tmp << 3) ^ (tmp >> 4)) & 0xFFFF


def crc_calc(data, crc=0xFFFF):
    for b in data:
        crc = crc_accumulate(b, crc)
    return crc


class Parser:
    """Streaming parser: feed bytes, get frames. Bad CRC => drop one byte, rescan."""

    def __init__(self):
        self.buf = bytearray()
        self.crc_errors = 0
        self.unknown = 0

    def feed(self, data):
        self.buf.extend(data)
        out = []
        while True:
            # find start byte
            i = 0
            while i < len(self.buf) and self.buf[i] not in (STX_V1, STX_V2):
                i += 1
            del self.buf[:i]
            if len(self.buf) < 2:
                return out
            stx, ln = self.buf[0], self.buf[1]
            if stx == STX_V2:
                if len(self.buf) < 10:
                    return out
                hdr = 10
                sig = 13 if self.buf[2] & SIGNED_FLAG else 0
                msgid = self.buf[7] | (self.buf[8] << 8) | (self.buf[9] << 16)
            else:
                if len(self.buf) < 6:
                    return out
                hdr, sig = 6, 0
                msgid = self.buf[5]
            total = hdr + ln + 2 + sig
            if len(self.buf) < total:
                return out
            frame = bytes(self.buf[:total])
            info = BY_ID.get(msgid)
            if info is None:
                # Unknown ID: the CRC can't be checked, and the table holds every
                # message Mission Planner knows, so this is almost always line noise
                # that happens to contain 0xFD/0xFE. Drop one byte and rescan.
                self.unknown += 1
                del self.buf[:1]
                continue
            crc = crc_calc(frame[1:hdr + ln])
            crc = crc_accumulate(info["crc"], crc)
            got = frame[hdr + ln] | (frame[hdr + ln + 1] << 8)
            if crc != got:
                self.crc_errors += 1
                del self.buf[:1]
                continue
            out.append(dict(raw=frame, msgid=msgid, payload=frame[hdr:hdr + ln], crc_ok=True,
                            version=2 if stx == STX_V2 else 1,
                            seq=frame[4] if stx == STX_V2 else frame[2],
                            sysid=frame[5] if stx == STX_V2 else frame[3],
                            compid=frame[6] if stx == STX_V2 else frame[4]))
            del self.buf[:total]


def decode(msgid, payload):
    info = BY_ID[msgid]
    p = bytes(payload) + bytes(max(0, info["length"] - len(payload)))  # v2 zero-extend
    vals = {}
    for f in info["fields"]:
        fmt = FMT[f["type"]]
        size = struct.calcsize(fmt)
        if f["array"]:
            vals[f["name"]] = [struct.unpack_from("<" + fmt, p, f["offset"] + k * size)[0]
                               for k in range(f["array"])]
        else:
            vals[f["name"]] = struct.unpack_from("<" + fmt, p, f["offset"])[0]
    return vals


def encode_payload(msgid, vals):
    info = BY_ID[msgid]
    p = bytearray(info["length"])
    for f in info["fields"]:
        fmt = FMT[f["type"]]
        size = struct.calcsize(fmt)
        v = vals[f["name"]]
        if f["array"]:
            for k in range(f["array"]):
                struct.pack_into("<" + fmt, p, f["offset"] + k * size, v[k])
        else:
            struct.pack_into("<" + fmt, p, f["offset"], v)
    return bytes(p)


def encode_v2(msgid, payload, seq, sysid, compid):
    info = BY_ID[msgid]
    n = len(payload)
    while n > 1 and payload[n - 1] == 0:  # v2 payload truncation
        n -= 1
    payload = payload[:n]
    hdr = bytes([STX_V2, n, 0, 0, seq, sysid, compid, msgid & 0xFF, (msgid >> 8) & 0xFF, (msgid >> 16) & 0xFF])
    crc = crc_accumulate(info["crc"], crc_calc(hdr[1:] + payload))
    return hdr + payload + bytes([crc & 0xFF, crc >> 8])


def encode_v1(msgid, payload, seq, sysid, compid):
    info = BY_ID[msgid]
    # Mission Planner (MavlinkParse.GenerateMAVLinkPacket10) sends the full struct,
    # extension fields included, with no truncation. Match it byte-for-byte.
    hdr = bytes([STX_V1, len(payload), seq, sysid, compid, msgid])
    crc = crc_accumulate(info["crc"], crc_calc(hdr[1:] + payload))
    return hdr + payload + bytes([crc & 0xFF, crc >> 8])


def tlog_record(usec, packet):
    return struct.pack(">Q", usec) + packet


def parse_value(f, s):
    return float(s) if f["type"] in ("Single", "Double") else int(s)


def main():
    fx = json.load(open(os.path.join(HERE, "..", "Packages", "MAVLinkKit", "Tests", "MAVLinkKitTests",
                                     "Fixtures", "mp_packets.json"), encoding="utf-8"))
    assert crc_calc(b"123456789") == 0x6F91, "X.25/MCRF4XX check value"
    fails = 0
    checked = 0
    stream = bytearray()
    for e in fx:
        info = BY_ID[e["id"]]
        expected = {}
        for f in info["fields"]:
            s = e["fields"][f["name"]]
            expected[f["name"]] = [parse_value(f, x) for x in s] if f["array"] else parse_value(f, s)
        for ver in ("v2", "v1"):
            if ver not in e:
                continue
            raw = bytes.fromhex(e[ver])
            stream += b"\x00\x55\xfd\x07\x00" + raw  # junk (incl. a fake STX) exercises resync
            p = Parser()
            frames = p.feed(raw)
            if len(frames) != 1 or not frames[0]["crc_ok"]:
                print("PARSE FAIL", ver, e["name"], e["variant"]); fails += 1; continue
            got = decode(e["id"], frames[0]["payload"])
            want = dict(expected)
            if got != want:
                print("DECODE FAIL", ver, e["name"], e["variant"]); fails += 1
            enc = encode_payload(e["id"], expected)
            fn = encode_v2 if ver == "v2" else encode_v1
            mine = fn(e["id"], enc, e["seq"], e["sysid"], e["compid"])
            if mine != raw:
                print("ENCODE MISMATCH", ver, e["name"], e["variant"], mine.hex(), raw.hex()); fails += 1
            checked += 1
    # whole stream with junk, plus one corrupted copy of a frame up front
    corrupted = bytearray(bytes.fromhex(fx[0]["v2"])); corrupted[12] ^= 0xFF
    p = Parser()
    frames = []
    data = bytes(corrupted) + bytes(stream)
    for k in range(0, len(data), 37):  # odd chunking like a UDP/BLE link
        frames += p.feed(data[k:k + 37])
    ok = sum(1 for f in frames if f["crc_ok"])
    print(f"checked {checked} packets individually; stream: {ok}/{checked} frames recovered, "
          f"{p.crc_errors} crc rejects; failures: {fails}")
    if ok != checked:
        fails += 1
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
