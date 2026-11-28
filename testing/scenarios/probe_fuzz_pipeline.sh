#!/usr/bin/env bash
# One-command repro: probe:fuzz_pipeline (see TESTING_RESULTS.md). Logs: testing/logs/probe:fuzz_pipeline.*.log
exec python3 "$(dirname "$0")/run.py" "probe:fuzz_pipeline" "$@"
