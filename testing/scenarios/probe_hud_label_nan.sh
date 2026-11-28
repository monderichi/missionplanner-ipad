#!/usr/bin/env bash
# One-command repro: probe:hud_label_nan (see TESTING_RESULTS.md). Logs: testing/logs/probe:hud_label_nan.*.log
exec python3 "$(dirname "$0")/run.py" "probe:hud_label_nan" "$@"
