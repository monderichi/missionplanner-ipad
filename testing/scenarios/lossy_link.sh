#!/usr/bin/env bash
# One-command repro: lossy_link (see TESTING_RESULTS.md). Logs: testing/logs/lossy_link.*.log
exec python3 "$(dirname "$0")/run.py" "lossy_link" "$@"
