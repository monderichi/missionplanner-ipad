#!/usr/bin/env bash
# One-command repro: sitl_params (see TESTING_RESULTS.md). Logs: testing/logs/sitl_params.*.log
exec python3 "$(dirname "$0")/run.py" "sitl_params" "$@"
