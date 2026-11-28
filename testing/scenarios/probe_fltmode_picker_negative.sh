#!/usr/bin/env bash
# One-command repro: probe:fltmode_picker_negative (see TESTING_RESULTS.md). Logs: testing/logs/probe:fltmode_picker_negative.*.log
exec python3 "$(dirname "$0")/run.py" "probe:fltmode_picker_negative" "$@"
