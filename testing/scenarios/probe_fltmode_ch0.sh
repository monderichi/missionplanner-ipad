#!/usr/bin/env bash
# One-command repro: probe:fltmode_ch0 (see TESTING_RESULTS.md). Logs: testing/logs/probe:fltmode_ch0.*.log
exec python3 "$(dirname "$0")/run.py" "probe:fltmode_ch0" "$@"
