#!/usr/bin/env bash
# One-command repro: accel_cal_fail (see TESTING_RESULTS.md). Logs: testing/logs/accel_cal_fail.*.log
exec python3 "$(dirname "$0")/run.py" "accel_cal_fail" "$@"
