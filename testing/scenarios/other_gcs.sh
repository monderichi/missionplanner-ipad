#!/usr/bin/env bash
# One-command repro: other_gcs (see TESTING_RESULTS.md). Logs: testing/logs/other_gcs.*.log
exec python3 "$(dirname "$0")/run.py" "other_gcs" "$@"
