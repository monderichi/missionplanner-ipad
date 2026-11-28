#!/usr/bin/env bash
# One-command repro: dup_reorder (see TESTING_RESULTS.md). Logs: testing/logs/dup_reorder.*.log
exec python3 "$(dirname "$0")/run.py" "dup_reorder" "$@"
