#!/usr/bin/env bash
# One-command repro: probe:takeoff_alt_huge (see TESTING_RESULTS.md). Logs: testing/logs/probe:takeoff_alt_huge.*.log
exec python3 "$(dirname "$0")/run.py" "probe:takeoff_alt_huge" "$@"
