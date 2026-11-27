#!/usr/bin/env bash
# One-command repro: motor_test (see TESTING_RESULTS.md). Logs: testing/logs/motor_test.*.log
exec python3 "$(dirname "$0")/run.py" "motor_test" "$@"
