#!/usr/bin/env bash
# One-command repro: param_file_roundtrip (see TESTING_RESULTS.md). Logs: testing/logs/param_file_roundtrip.*.log
exec python3 "$(dirname "$0")/run.py" "param_file_roundtrip" "$@"
