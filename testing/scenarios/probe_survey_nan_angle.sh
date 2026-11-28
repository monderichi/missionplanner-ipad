#!/usr/bin/env bash
# One-command repro: probe:survey_nan_angle (see TESTING_RESULTS.md). Logs: testing/logs/probe:survey_nan_angle.*.log
exec python3 "$(dirname "$0")/run.py" "probe:survey_nan_angle" "$@"
