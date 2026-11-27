#!/usr/bin/env bash
# One-command repro: high_rate (see TESTING_RESULTS.md). Logs: testing/logs/high_rate.*.log
exec python3 "$(dirname "$0")/run.py" "high_rate" "$@"
