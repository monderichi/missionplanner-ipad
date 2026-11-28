#!/usr/bin/env bash
# One-command repro: probe:command_overwrite (see TESTING_RESULTS.md). Logs: testing/logs/probe:command_overwrite.*.log
exec python3 "$(dirname "$0")/run.py" "probe:command_overwrite" "$@"
