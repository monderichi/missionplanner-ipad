#!/usr/bin/env bash
# One-command repro: probe:hud_label_huge (see TESTING_RESULTS.md). Logs: testing/logs/probe:hud_label_huge.*.log
exec python3 "$(dirname "$0")/run.py" "probe:hud_label_huge" "$@"
