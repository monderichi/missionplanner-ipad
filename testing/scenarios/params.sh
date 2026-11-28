#!/usr/bin/env bash
# One-command repro: params (see TESTING_RESULTS.md). Logs: testing/logs/params.*.log
exec python3 "$(dirname "$0")/run.py" "params" "$@"
