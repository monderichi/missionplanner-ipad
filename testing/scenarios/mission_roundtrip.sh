#!/usr/bin/env bash
# One-command repro: mission_roundtrip (see TESTING_RESULTS.md). Logs: testing/logs/mission_roundtrip.*.log
exec python3 "$(dirname "$0")/run.py" "mission_roundtrip" "$@"
