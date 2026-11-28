#!/usr/bin/env bash
# One-command repro: param_set (see TESTING_RESULTS.md). Logs: testing/logs/param_set.*.log
exec python3 "$(dirname "$0")/run.py" "param_set" "$@"
