#!/usr/bin/env bash
# One-command repro: guided_takeoff (see TESTING_RESULTS.md). Logs: testing/logs/guided_takeoff.*.log
exec python3 "$(dirname "$0")/run.py" "guided_takeoff" "$@"
