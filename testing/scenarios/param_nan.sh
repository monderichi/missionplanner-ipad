#!/usr/bin/env bash
# One-command repro: param_nan (see TESTING_RESULTS.md). Logs: testing/logs/param_nan.*.log
exec python3 "$(dirname "$0")/run.py" "param_nan" "$@"
