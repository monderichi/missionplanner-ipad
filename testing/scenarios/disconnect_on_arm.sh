#!/usr/bin/env bash
# One-command repro: disconnect_on_arm (see TESTING_RESULTS.md). Logs: testing/logs/disconnect_on_arm.*.log
exec python3 "$(dirname "$0")/run.py" "disconnect_on_arm" "$@"
