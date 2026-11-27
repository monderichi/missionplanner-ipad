#!/usr/bin/env bash
# One-command repro: inf_values (see TESTING_RESULTS.md). Logs: testing/logs/inf_values.*.log
exec python3 "$(dirname "$0")/run.py" "inf_values" "$@"
