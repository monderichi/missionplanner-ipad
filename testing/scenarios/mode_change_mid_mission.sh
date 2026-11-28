#!/usr/bin/env bash
# One-command repro: mode_change_mid_mission (see TESTING_RESULTS.md). Logs: testing/logs/mode_change_mid_mission.*.log
exec python3 "$(dirname "$0")/run.py" "mode_change_mid_mission" "$@"
