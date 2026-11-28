#!/usr/bin/env bash
# One-command repro: accelcal_live_nan (see TESTING_RESULTS.md). Logs: testing/logs/accelcal_live_nan.*.log
exec python3 "$(dirname "$0")/run.py" "accelcal_live_nan" "$@"
