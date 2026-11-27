#!/usr/bin/env bash
# One-command repro: compass_cal_fail (see TESTING_RESULTS.md). Logs: testing/logs/compass_cal_fail.*.log
exec python3 "$(dirname "$0")/run.py" "compass_cal_fail" "$@"
