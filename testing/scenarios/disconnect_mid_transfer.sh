#!/usr/bin/env bash
# One-command repro: disconnect_mid_transfer (see TESTING_RESULTS.md). Logs: testing/logs/disconnect_mid_transfer.*.log
exec python3 "$(dirname "$0")/run.py" "disconnect_mid_transfer" "$@"
