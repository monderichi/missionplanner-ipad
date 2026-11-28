#!/usr/bin/env bash
# One-command repro: long_session (see TESTING_RESULTS.md). Logs: testing/logs/long_session.*.log
exec python3 "$(dirname "$0")/run.py" "long_session" "$@"
