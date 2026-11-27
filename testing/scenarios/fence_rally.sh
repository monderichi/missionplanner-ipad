#!/usr/bin/env bash
# One-command repro: fence_rally (see TESTING_RESULTS.md). Logs: testing/logs/fence_rally.*.log
exec python3 "$(dirname "$0")/run.py" "fence_rally" "$@"
