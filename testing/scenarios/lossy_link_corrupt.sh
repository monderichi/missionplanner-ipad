#!/usr/bin/env bash
# One-command repro: lossy_link_corrupt (see TESTING_RESULTS.md). Logs: testing/logs/lossy_link_corrupt.*.log
exec python3 "$(dirname "$0")/run.py" "lossy_link_corrupt" "$@"
