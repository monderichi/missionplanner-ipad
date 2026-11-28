#!/usr/bin/env bash
# One-command repro: probe:param_file_nan (see TESTING_RESULTS.md). Logs: testing/logs/probe:param_file_nan.*.log
exec python3 "$(dirname "$0")/run.py" "probe:param_file_nan" "$@"
