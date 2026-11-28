#!/usr/bin/env bash
# One-command repro: probe:survey_huge (see TESTING_RESULTS.md). Logs: testing/logs/probe:survey_huge.*.log
exec python3 "$(dirname "$0")/run.py" "probe:survey_huge" "$@"
