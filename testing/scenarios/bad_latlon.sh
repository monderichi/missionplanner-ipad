#!/usr/bin/env bash
# One-command repro: bad_latlon (see TESTING_RESULTS.md). Logs: testing/logs/bad_latlon.*.log
exec python3 "$(dirname "$0")/run.py" "bad_latlon" "$@"
