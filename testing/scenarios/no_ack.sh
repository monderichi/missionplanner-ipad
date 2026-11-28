#!/usr/bin/env bash
# One-command repro: no_ack (see TESTING_RESULTS.md). Logs: testing/logs/no_ack.*.log
exec python3 "$(dirname "$0")/run.py" "no_ack" "$@"
