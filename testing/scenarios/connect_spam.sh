#!/usr/bin/env bash
# One-command repro: connect_spam (see TESTING_RESULTS.md). Logs: testing/logs/connect_spam.*.log
exec python3 "$(dirname "$0")/run.py" "connect_spam" "$@"
