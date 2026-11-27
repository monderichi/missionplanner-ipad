#!/usr/bin/env bash
# One-command repro: probe:waypoint_file_huge (see TESTING_RESULTS.md). Logs: testing/logs/probe:waypoint_file_huge.*.log
exec python3 "$(dirname "$0")/run.py" "probe:waypoint_file_huge" "$@"
