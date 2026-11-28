#!/usr/bin/env bash
# One-command repro: servo_before_params (see TESTING_RESULTS.md). Logs: testing/logs/servo_before_params.*.log
exec python3 "$(dirname "$0")/run.py" "servo_before_params" "$@"
