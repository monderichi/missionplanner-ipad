#!/usr/bin/env bash
# One-command repro: probe:mission_item_nan_coord (see TESTING_RESULTS.md). Logs: testing/logs/probe:mission_item_nan_coord.*.log
exec python3 "$(dirname "$0")/run.py" "probe:mission_item_nan_coord" "$@"
