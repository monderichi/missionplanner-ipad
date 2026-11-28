#!/usr/bin/env bash
# One-command repro: auto_mission (see TESTING_RESULTS.md). Logs: testing/logs/auto_mission.*.log
exec python3 "$(dirname "$0")/run.py" "auto_mission" "$@"
