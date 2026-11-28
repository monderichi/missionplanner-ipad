#!/usr/bin/env bash
# One-command repro: geofence_apply (see TESTING_RESULTS.md). Logs: testing/logs/geofence_apply.*.log
exec python3 "$(dirname "$0")/run.py" "geofence_apply" "$@"
