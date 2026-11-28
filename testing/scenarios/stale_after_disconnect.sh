#!/usr/bin/env bash
# One-command repro: stale_after_disconnect (see TESTING_RESULTS.md). Logs: testing/logs/stale_after_disconnect.*.log
exec python3 "$(dirname "$0")/run.py" "stale_after_disconnect" "$@"
