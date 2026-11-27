#!/usr/bin/env bash
# One-command repro: sitl_smoke (see TESTING_RESULTS.md). Logs: testing/logs/sitl_smoke.*.log
exec python3 "$(dirname "$0")/run.py" "sitl_smoke" "$@"
