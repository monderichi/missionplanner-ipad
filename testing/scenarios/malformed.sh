#!/usr/bin/env bash
# One-command repro: malformed (see TESTING_RESULTS.md). Logs: testing/logs/malformed.*.log
exec python3 "$(dirname "$0")/run.py" "malformed" "$@"
