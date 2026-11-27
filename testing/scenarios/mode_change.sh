#!/usr/bin/env bash
# One-command repro: mode_change (see TESTING_RESULTS.md). Logs: testing/logs/mode_change.*.log
exec python3 "$(dirname "$0")/run.py" "mode_change" "$@"
