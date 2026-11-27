#!/usr/bin/env bash
# One-command repro: connect_udp_connect (see TESTING_RESULTS.md). Logs: testing/logs/connect_udp_connect.*.log
exec python3 "$(dirname "$0")/run.py" "connect_udp_connect" "$@"
