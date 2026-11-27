#!/usr/bin/env bash
# One-command repro: compass_cal (see TESTING_RESULTS.md). Logs: testing/logs/compass_cal.*.log
exec python3 "$(dirname "$0")/run.py" "compass_cal" "$@"
