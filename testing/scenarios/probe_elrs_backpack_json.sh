#!/usr/bin/env bash
# One-command repro: probe:elrs_backpack_json (see TESTING_RESULTS.md). Logs: testing/logs/probe:elrs_backpack_json.*.log
exec python3 "$(dirname "$0")/run.py" "probe:elrs_backpack_json" "$@"
