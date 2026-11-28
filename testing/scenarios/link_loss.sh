#!/usr/bin/env bash
# One-command repro: link_loss (see TESTING_RESULTS.md). Logs: testing/logs/link_loss.*.log
exec python3 "$(dirname "$0")/run.py" "link_loss" "$@"
