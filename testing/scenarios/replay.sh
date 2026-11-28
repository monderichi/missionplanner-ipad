#!/usr/bin/env bash
# One-command repro: replay (see TESTING_RESULTS.md). Logs: testing/logs/replay.*.log
exec python3 "$(dirname "$0")/run.py" "replay" "$@"
