#!/usr/bin/env bash
# One-command repro: log_download (see TESTING_RESULTS.md). Logs: testing/logs/log_download.*.log
exec python3 "$(dirname "$0")/run.py" "log_download" "$@"
