#!/usr/bin/env bash
# One-command repro: battery_failsafe (see TESTING_RESULTS.md). Logs: testing/logs/battery_failsafe.*.log
exec python3 "$(dirname "$0")/run.py" "battery_failsafe" "$@"
