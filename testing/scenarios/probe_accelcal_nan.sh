#!/usr/bin/env bash
# One-command repro: probe:accelcal_nan (see TESTING_RESULTS.md). Logs: testing/logs/probe:accelcal_nan.*.log
exec python3 "$(dirname "$0")/run.py" "probe:accelcal_nan" "$@"
