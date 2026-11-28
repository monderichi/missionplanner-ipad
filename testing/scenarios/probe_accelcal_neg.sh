#!/usr/bin/env bash
# One-command repro: probe:accelcal_neg (see TESTING_RESULTS.md). Logs: testing/logs/probe:accelcal_neg.*.log
exec python3 "$(dirname "$0")/run.py" "probe:accelcal_neg" "$@"
