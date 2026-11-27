#!/usr/bin/env python3
"""UDP fault proxy between a vehicle (fake drone or SITL) and the app.

  vehicle --udp--> 127.0.0.1:LISTEN [proxy] --udp--> APP_HOST:APP_PORT (app in "UDP listen")
  app replies to the proxy socket, the proxy forwards them back to the vehicle's address.

Faults are per datagram (one MAVLink frame for the fake drone; SITL may batch frames):
  --loss PCT  --latency MS  --jitter MS  --dup PCT  --reorder PCT  --corrupt PCT
  --blackout START:DURATION[,START:DURATION...]  (seconds after start; nothing passes either way)
  --up-loss PCT  (app->vehicle only; defaults to --loss)
Prints one summary line per 5 s: "t=.. down=.. up=.. dropped=.. dup=.. corrupted=..".
"""
import argparse
import heapq
import random
import select
import socket
import time


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--listen", type=int, default=14560)
    ap.add_argument("--app", default="127.0.0.1:14550")
    ap.add_argument("--loss", type=float, default=0)
    ap.add_argument("--up-loss", type=float)
    ap.add_argument("--latency", type=float, default=0)
    ap.add_argument("--jitter", type=float, default=0)
    ap.add_argument("--dup", type=float, default=0)
    ap.add_argument("--reorder", type=float, default=0)
    ap.add_argument("--corrupt", type=float, default=0)
    ap.add_argument("--blackout", default="")
    ap.add_argument("--duration", type=float, default=0)
    ap.add_argument("--seed", type=int, default=1)
    a = ap.parse_args()
    random.seed(a.seed)
    up_loss = a.loss if a.up_loss is None else a.up_loss
    blackouts = [tuple(map(float, b.split(":"))) for b in a.blackout.split(",") if b]
    vs = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  # vehicle side
    vs.bind(("127.0.0.1", a.listen))
    asock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  # app side (ephemeral source port)
    asock.bind(("127.0.0.1", 0))
    h, p = a.app.split(":")
    app = (h, int(p))
    vehicle = None
    q = []  # (due, seq, sock, data, addr)
    n = 0
    st = dict(down=0, up=0, dropped=0, dup=0, corrupted=0, reordered=0)
    t0 = time.time()
    last_report = t0

    def blacked(now):
        t = now - t0
        return any(s <= t < s + d for s, d in blackouts)

    def enqueue(sock, data, addr, loss):
        nonlocal n
        now = time.time()
        if blacked(now) or random.random() * 100 < loss:
            st["dropped"] += 1
            return
        if random.random() * 100 < a.corrupt and data:
            b = bytearray(data)
            b[random.randrange(len(b))] ^= 1 << random.randrange(8)
            data = bytes(b)
            st["corrupted"] += 1
        delay = (a.latency + random.uniform(-a.jitter, a.jitter)) / 1000
        if random.random() * 100 < a.reorder:
            delay += 0.05 + random.random() * 0.1
            st["reordered"] += 1
        copies = 2 if random.random() * 100 < a.dup else 1
        st["dup"] += copies - 1
        for _ in range(copies):
            n += 1
            heapq.heappush(q, (now + max(0, delay), n, sock, data, addr))

    while not a.duration or time.time() - t0 < a.duration:
        timeout = max(0, min(0.01, (q[0][0] - time.time()) if q else 0.01))
        r, _, _ = select.select([vs, asock], [], [], timeout)
        for s in r:
            data, addr = s.recvfrom(65536)
            if s is vs:
                vehicle = addr
                st["down"] += 1
                enqueue(asock, data, app, a.loss)
            elif vehicle:
                st["up"] += 1
                enqueue(vs, data, vehicle, up_loss)
        now = time.time()
        while q and q[0][0] <= now:
            _, _, s, data, addr = heapq.heappop(q)
            try:
                s.sendto(data, addr)
            except OSError:
                pass
        if now - last_report > 5:
            last_report = now
            print(f"t={now - t0:6.1f} " + " ".join(f"{k}={v}" for k, v in st.items()), flush=True)


if __name__ == "__main__":
    main()
