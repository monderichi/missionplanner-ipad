#!/usr/bin/env bash
# One-command repro: sitl_arm (see TESTING_RESULTS.md). Logs: testing/logs/sitl_arm.*.log
exec python3 "$(dirname "$0")/run.py" "sitl_arm" "$@"
