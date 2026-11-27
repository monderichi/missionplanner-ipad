#!/usr/bin/env bash
# One-command repro: blackout (see TESTING_RESULTS.md). Logs: testing/logs/blackout.*.log
exec python3 "$(dirname "$0")/run.py" "blackout" "$@"
