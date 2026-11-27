#!/usr/bin/env bash
# One-command repro: huge_values (see TESTING_RESULTS.md). Logs: testing/logs/huge_values.*.log
exec python3 "$(dirname "$0")/run.py" "huge_values" "$@"
