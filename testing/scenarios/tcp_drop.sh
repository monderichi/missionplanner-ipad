#!/usr/bin/env bash
# One-command repro: tcp_drop (see TESTING_RESULTS.md). Logs: testing/logs/tcp_drop.*.log
exec python3 "$(dirname "$0")/run.py" "tcp_drop" "$@"
