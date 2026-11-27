#!/usr/bin/env bash
# One-command repro: arm_disarm (see TESTING_RESULTS.md). Logs: testing/logs/arm_disarm.*.log
exec python3 "$(dirname "$0")/run.py" "arm_disarm" "$@"
