#!/usr/bin/env bash
# One-command repro: fence_breach (see TESTING_RESULTS.md). Logs: testing/logs/fence_breach.*.log
exec python3 "$(dirname "$0")/run.py" "fence_breach" "$@"
