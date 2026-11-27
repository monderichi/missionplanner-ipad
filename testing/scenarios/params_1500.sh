#!/usr/bin/env bash
# One-command repro: params_1500 (see TESTING_RESULTS.md). Logs: testing/logs/params_1500.*.log
exec python3 "$(dirname "$0")/run.py" "params_1500" "$@"
