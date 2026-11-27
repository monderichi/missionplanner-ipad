#!/usr/bin/env bash
# One-command repro: probe:waypoint_editor_lat_300 (see TESTING_RESULTS.md). Logs: testing/logs/probe:waypoint_editor_lat_300.*.log
exec python3 "$(dirname "$0")/run.py" "probe:waypoint_editor_lat_300" "$@"
