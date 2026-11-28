#!/usr/bin/env bash
# One-command repro: prearm_check (see TESTING_RESULTS.md). Logs: testing/logs/prearm_check.*.log
exec python3 "$(dirname "$0")/run.py" "prearm_check" "$@"
