#!/usr/bin/env bash
# One-command repro: nan_values (see TESTING_RESULTS.md). Logs: testing/logs/nan_values.*.log
exec python3 "$(dirname "$0")/run.py" "nan_values" "$@"
