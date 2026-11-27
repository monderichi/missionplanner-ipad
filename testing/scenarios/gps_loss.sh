#!/usr/bin/env bash
# One-command repro: gps_loss (see TESTING_RESULTS.md). Logs: testing/logs/gps_loss.*.log
exec python3 "$(dirname "$0")/run.py" "gps_loss" "$@"
