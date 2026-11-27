#!/usr/bin/env bash
# One-command repro: reboot (see TESTING_RESULTS.md). Logs: testing/logs/reboot.*.log
exec python3 "$(dirname "$0")/run.py" "reboot" "$@"
