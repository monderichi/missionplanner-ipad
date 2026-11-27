#!/usr/bin/env bash
# One-command repro: probe:accelcal_huge (see TESTING_RESULTS.md). Logs: testing/logs/probe:accelcal_huge.*.log
exec python3 "$(dirname "$0")/run.py" "probe:accelcal_huge" "$@"
