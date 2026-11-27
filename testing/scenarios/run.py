#!/usr/bin/env python3
"""Runs one scenario (or a group) end to end: starts the fake drone / proxy / SITL, runs the headless
app harness against it, saves logs to testing/logs/<scenario>.*.log, prints a one-line verdict.

  python3 testing/scenarios/run.py <scenario> [<scenario> ...]
  python3 testing/scenarios/run.py all          # everything except long/SITL ones
  python3 testing/scenarios/run.py probes       # crash probes only
  python3 testing/scenarios/run.py --list

Verdicts: PASS (all checks passed), FAIL (a check failed), CRASH (harness died on a signal = the app
would crash), ERROR (setup problem). Summary appended to testing/logs/summary.txt.
Build first: testing/harness/build_harness.sh (run.py builds it if the binary is missing).
"""
import os
import re
import signal
import subprocess
import sys
import time

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
LOGS = os.path.join(ROOT, "testing", "logs")
DRONE = [sys.executable, os.path.join(ROOT, "testing", "fake_drone", "fake_drone.py")]
PROXY = [sys.executable, os.path.join(ROOT, "testing", "fake_drone", "fault_proxy.py")]
SITL_BIN = os.path.join(ROOT, "testing", ".sitl", "ardupilot", "build", "sitl", "bin", "arducopter")
TCP = ["--tcp-server", "5799"]
H_TCP = ["--kind", "tcp", "--port", "5799"]

# name: dict(drone=[fake_drone args] | None, harness=[harness args], proxy=[proxy args], hooks=[(t, action)])
S = {
    "connect": dict(drone=TCP),
    "connect_udp_listen": dict(drone=["--udp-out", "127.0.0.1:14550"], harness=["--kind", "udpListen", "--port", "14550"], name="connect"),
    "connect_udp_connect": dict(drone=["--udp-bind", "14555"], harness=["--kind", "udpConnect", "--port", "14555", "--local-port", "14550"], name="connect"),
    "params": dict(drone=TCP, harness=H_TCP + ["--expect-params", "400"]),
    "params_1500": dict(drone=TCP + ["--params", "1500"], harness=H_TCP + ["--expect-params", "1500"], name="params"),
    "param_set": dict(drone=TCP),
    "param_file_roundtrip": dict(drone=TCP),
    "param_nan": dict(drone=TCP + ["--fault", "param_nan,fltmode_ch0"]),
    "arm_disarm": dict(drone=TCP),
    "reject_arm": dict(drone=TCP + ["--fault", "reject_arm"]),
    "no_ack": dict(drone=TCP + ["--fault", "no_ack"]),
    "mode_change": dict(drone=TCP),
    "guided_takeoff": dict(drone=TCP),
    "mission_roundtrip": dict(drone=TCP),
    "auto_mission": dict(drone=TCP),
    "fence_rally": dict(drone=TCP),
    "mode_change_mid_mission": dict(drone=TCP + ["--fault", "mode_change_mid_mission"]),
    "fly_here": dict(drone=TCP),
    "link_loss": dict(drone=TCP),
    "link_loss_udp": dict(drone=["--udp-out", "127.0.0.1:14550"], harness=["--kind", "udpListen", "--port", "14550"], name="link_loss"),
    "tcp_drop": dict(drone=TCP, hooks=[("restart_drone_after_quit", 3.0)]),
    "stale_after_disconnect": dict(drone=TCP),
    "nan_values": dict(drone=TCP + ["--fault", "nan_attitude"]),
    "inf_values": dict(drone=TCP + ["--fault", "inf_values"], name="nan_values"),
    "huge_values": dict(drone=TCP + ["--fault", "huge_values"], name="nan_values"),
    "bad_latlon": dict(drone=TCP + ["--fault", "bad_latlon"]),
    "gps_loss": dict(drone=TCP),
    "malformed": dict(drone=TCP + ["--fault", "malformed"]),
    "dup_reorder": dict(drone=TCP + ["--fault", "dup"], name="dup_reorder"),
    "reorder": dict(drone=TCP + ["--fault", "reorder"], name="dup_reorder"),
    "second_vehicle": dict(drone=TCP + ["--fault", "second_vehicle"]),
    "other_gcs": dict(drone=TCP + ["--fault", "other_gcs"]),
    "compid_switch": dict(drone=TCP + ["--fault", "compid_switch", "--compid", "1"]),
    "reboot": dict(drone=TCP),
    "disconnect_on_arm": dict(drone=TCP + ["--fault", "disconnect_on_arm"]),
    "battery_failsafe": dict(drone=TCP),
    "statustext_flood": dict(drone=TCP + ["--fault", "statustext_flood"]),
    "high_rate": dict(drone=TCP + ["--fault", "high_rate"], harness=H_TCP + ["--secs", "20"]),
    "large_mission": dict(drone=TCP, harness=H_TCP + ["--items", "700"]),
    "log_download": dict(drone=TCP),
    "replay": dict(drone=TCP),
    "connect_spam": dict(drone=TCP),
    "disconnect_mid_transfer": dict(drone=TCP + ["--params", "3000", "--param-burst", "2"]),
    "accelcal_live_nan": dict(drone=TCP + ["--fault", "accelcal_nan"], name="connect"),
    "lossy_link": dict(drone=["--udp-out", "127.0.0.1:14560"], harness=["--kind", "udpListen", "--port", "14550"],
                       proxy=["--listen", "14560", "--loss", "30", "--latency", "80", "--jitter", "60"]),
    "lossy_link_corrupt": dict(drone=["--udp-out", "127.0.0.1:14560"], harness=["--kind", "udpListen", "--port", "14550"],
                               proxy=["--listen", "14560", "--loss", "10", "--corrupt", "10", "--dup", "10", "--reorder", "10"],
                               name="lossy_link"),
    "blackout": dict(drone=["--udp-out", "127.0.0.1:14560"], harness=["--kind", "udpListen", "--port", "14550"],
                     proxy=["--listen", "14560", "--blackout", "4:8"], name="link_loss_proxy"),
    "servo_before_params": dict(drone=TCP + ["--params", "3000", "--param-burst", "1"]),
    "esc_telemetry": dict(drone=TCP),
    "prearm_check": dict(drone=TCP + ["--fault", "reject_arm"]),
    "accel_cal": dict(drone=TCP),
    "accel_cal_fail": dict(drone=TCP + ["--fault", "accelcal_fail"], harness=H_TCP + ["--expect", "failed"], name="accel_cal"),
    "accel_cal_lossy": dict(drone=["--udp-out", "127.0.0.1:14560"], harness=["--kind", "udpListen", "--port", "14550", "--timeout", "60"],
                            proxy=["--listen", "14560", "--loss", "25", "--seed", "3"], name="accel_cal"),
    "accel_cal_lossy_retap": dict(drone=["--udp-out", "127.0.0.1:14560"], harness=["--kind", "udpListen", "--port", "14550", "--timeout", "90", "--retap", "1"],
                                  proxy=["--listen", "14560", "--loss", "25", "--seed", "3"], name="accel_cal"),
    "compass_cal": dict(drone=TCP),
    "compass_cal_fail": dict(drone=TCP + ["--fault", "magcal_fail"], harness=H_TCP + ["--expect", "failed"], name="compass_cal"),
    "geofence_apply": dict(drone=TCP),
    "fence_breach": dict(drone=TCP),
    "motor_test": dict(drone=TCP),
    "mission_no_space": dict(drone=TCP + ["--fault", "mission_no_space"], harness=H_TCP + ["--expect", "no space"], name="mission_edge"),
    "mission_oob": dict(drone=TCP + ["--fault", "mission_oob"], name="mission_edge"),
    "param_16char": dict(drone=TCP + ["--fault", "param_16char"], harness=H_TCP + ["--name", "ABCDEFGHIJKLMNOP"], name="param_edge"),
    "param_count_change": dict(drone=TCP + ["--fault", "param_count_change"], name="param_edge"),
    "long_session": dict(drone=TCP, harness=H_TCP + ["--secs", "300"], long=True),
    "sitl_smoke": dict(sitl=True, harness=["--kind", "tcp", "--port", "5760"], long=True),
    "sitl_params": dict(sitl=True, harness=["--kind", "tcp", "--port", "5760", "--param-timeout", "90"], name="params", long=True),
    "sitl_arm": dict(sitl=True, harness=["--kind", "tcp", "--port", "5760"], name="sitl_arm", long=True),
}
PROBES = ["probe:accelcal_nan", "probe:accelcal_neg", "probe:accelcal_huge", "probe:waypoint_file_nan",
          "probe:waypoint_file_huge_lat", "probe:waypoint_file_unicode", "probe:waypoint_file_huge",
          "probe:param_file_nan", "probe:mission_item_nan_coord", "probe:survey_nan_angle", "probe:survey_huge",
          "probe:hud_label_nan", "probe:hud_label_huge", "probe:fltmode_ch0", "probe:takeoff_alt_huge",
          "probe:fltmode_picker_negative", "probe:command_overwrite", "probe:waypoint_editor_lat_300",
          "probe:elrs_backpack_json"]
for p in PROBES:
    S[p] = dict(drone=None)
# fuzzing (known crash 76 = COMMAND_LONG/ACCELCAL skipped in the second run so other crashes can surface)
S["probe:fuzz_pipeline"] = dict(drone=None, harness=["--iterations", "300000"])
S["probe:fuzz_pipeline_skip_known"] = dict(drone=None, harness=["--iterations", "300000", "--skip", "76,39"], name="probe:fuzz_pipeline")


def harness_bin():
    out = subprocess.run([os.path.join(ROOT, "testing", "harness", "build_harness.sh")], capture_output=True, text=True)
    path = out.stdout.strip().splitlines()[-1] if out.stdout.strip() else ""
    if out.returncode != 0 or not os.path.exists(path):
        print(out.stdout + out.stderr)
        sys.exit("harness build failed")
    return path


def start(cmd, logname):
    f = open(os.path.join(LOGS, logname), "w")
    return subprocess.Popen(cmd, stdout=f, stderr=subprocess.STDOUT, cwd=ROOT, start_new_session=True)


def stop(p):
    if p and p.poll() is None:
        try:
            os.killpg(p.pid, signal.SIGTERM)
            p.wait(timeout=5)
        except Exception:
            os.killpg(p.pid, signal.SIGKILL)


def start_sitl(name):
    if not os.path.exists(SITL_BIN):
        return None, "SITL not built (testing/sitl/build_sitl.sh)"
    wd = os.path.join(ROOT, "testing", ".build", "sitl_run")
    os.makedirs(wd, exist_ok=True)
    defaults = os.path.join(ROOT, "testing", ".sitl", "ardupilot", "Tools", "autotest", "default_params", "copter.parm")
    cmd = [SITL_BIN, "--model", "quad", "--speedup", "1", "--home", "-35.363262,149.165237,584,353",
           "--defaults", defaults, "--wipe", "--sim-address", "127.0.0.1"]
    f = open(os.path.join(LOGS, f"{name}.sitl.log"), "w")
    p = subprocess.Popen(cmd, stdout=f, stderr=subprocess.STDOUT, cwd=wd, start_new_session=True)
    time.sleep(3)
    return p, None


def run(key, hb):
    spec = S[key]
    os.makedirs(LOGS, exist_ok=True)
    home = os.path.join(ROOT, "testing", ".build", "home")
    os.makedirs(os.path.join(home, "Documents"), exist_ok=True)
    env = dict(os.environ, CFFIXED_USER_HOME=home)
    drone = proxy = sitl = None
    try:
        if spec.get("sitl"):
            sitl, err = start_sitl(key)
            if err:
                return "SKIP", err
        if spec.get("proxy"):
            proxy = start(PROXY + spec["proxy"], f"{key}.proxy.log")
        dargs = spec.get("drone")
        if dargs is not None:
            drone = start(DRONE + dargs, f"{key}.drone.log")
            time.sleep(0.6)
        hargs = spec.get("harness", H_TCP if dargs is not None else [])
        cmd = [hb, spec.get("name", key)] + hargs + ["-speech.enabled", "<false/>"]
        hlog = open(os.path.join(LOGS, f"{key}.harness.log"), "w")
        h = subprocess.Popen(cmd, stdout=hlog, stderr=subprocess.STDOUT, cwd=ROOT, env=env)
        for hook, t in spec.get("hooks", []):
            if hook == "restart_drone_after_quit":
                drone.wait(timeout=30)
                time.sleep(t)
                drone = start(DRONE + dargs, f"{key}.drone2.log")
        try:
            rc = h.wait(timeout=900)
        except subprocess.TimeoutExpired:
            h.kill()
            rc = "timeout"
        hlog.close()
    finally:
        stop(drone)
        stop(proxy)
        stop(sitl)
    text = open(os.path.join(LOGS, f"{key}.harness.log")).read()
    fails = [l[11:] for l in text.splitlines() if l.startswith("CHECK FAIL")]
    fatal = re.findall(r"(Fatal error.*|.*error: .*Index out of range.*)", text)
    if rc == "timeout":
        return "ERROR", "harness timeout (hang?)"
    if isinstance(rc, int) and rc < 0:
        return "CRASH", f"signal {-rc}: {fatal[0].strip() if fatal else 'no message'}"
    if rc == 0:
        return "PASS", ""
    if rc == 1:
        return "FAIL", "; ".join(fails)[:600]
    return "ERROR", f"exit {rc}"


def main():
    args = sys.argv[1:]
    if not args or args == ["--list"]:
        print("\n".join(sorted(S)))
        return
    if args == ["all"]:
        args = [k for k in S if not k.startswith("probe:") and not S[k].get("long")] + PROBES
    elif args == ["probes"]:
        args = PROBES
    elif args == ["sitl"]:
        args = [k for k in S if S[k].get("sitl")]
    hb = harness_bin()
    results = []
    with open(os.path.join(LOGS, "summary.txt"), "a") as summary:
        summary.write(f"\n=== {time.strftime('%Y-%m-%d %H:%M:%S')} {' '.join(args)}\n")
        for k in args:
            if k not in S:
                print(f"unknown scenario {k}")
                continue
            t0 = time.time()
            verdict, detail = run(k, hb)
            line = f"{verdict:5} {k:28} {time.time() - t0:5.1f}s {detail}"
            print(line, flush=True)
            summary.write(line + "\n")
            results.append(verdict)
    print(f"TOTAL {len(results)}: " + ", ".join(f"{v}={results.count(v)}" for v in ("PASS", "FAIL", "CRASH", "ERROR", "SKIP")))
    sys.exit(0 if all(r in ("PASS", "SKIP") for r in results) else 1)


if __name__ == "__main__":
    main()
