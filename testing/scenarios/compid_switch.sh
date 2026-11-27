#!/usr/bin/env bash
# One-command repro: compid_switch (see TESTING_RESULTS.md). Logs: testing/logs/compid_switch.*.log
exec python3 "$(dirname "$0")/run.py" "compid_switch" "$@"
