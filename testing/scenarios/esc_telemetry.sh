#!/usr/bin/env bash
# One-command repro: esc_telemetry (see TESTING_RESULTS.md). Logs: testing/logs/esc_telemetry.*.log
exec python3 "$(dirname "$0")/run.py" "esc_telemetry" "$@"
