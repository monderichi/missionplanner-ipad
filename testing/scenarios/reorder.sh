#!/usr/bin/env bash
# One-command repro: reorder (see TESTING_RESULTS.md). Logs: testing/logs/reorder.*.log
exec python3 "$(dirname "$0")/run.py" "reorder" "$@"
