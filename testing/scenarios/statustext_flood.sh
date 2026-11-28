#!/usr/bin/env bash
# One-command repro: statustext_flood (see TESTING_RESULTS.md). Logs: testing/logs/statustext_flood.*.log
exec python3 "$(dirname "$0")/run.py" "statustext_flood" "$@"
