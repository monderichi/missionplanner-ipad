#!/usr/bin/env bash
# One-command repro: connect (see TESTING_RESULTS.md). Logs: testing/logs/connect.*.log
exec python3 "$(dirname "$0")/run.py" "connect" "$@"
