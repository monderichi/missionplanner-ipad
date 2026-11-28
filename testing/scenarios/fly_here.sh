#!/usr/bin/env bash
# One-command repro: fly_here (see TESTING_RESULTS.md). Logs: testing/logs/fly_here.*.log
exec python3 "$(dirname "$0")/run.py" "fly_here" "$@"
