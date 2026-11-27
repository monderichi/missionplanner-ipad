#!/usr/bin/env bash
# One-command repro: large_mission (see TESTING_RESULTS.md). Logs: testing/logs/large_mission.*.log
exec python3 "$(dirname "$0")/run.py" "large_mission" "$@"
