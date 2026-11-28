#!/usr/bin/env bash
# One-command repro: second_vehicle (see TESTING_RESULTS.md). Logs: testing/logs/second_vehicle.*.log
exec python3 "$(dirname "$0")/run.py" "second_vehicle" "$@"
