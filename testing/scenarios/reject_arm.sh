#!/usr/bin/env bash
# One-command repro: reject_arm (see TESTING_RESULTS.md). Logs: testing/logs/reject_arm.*.log
exec python3 "$(dirname "$0")/run.py" "reject_arm" "$@"
