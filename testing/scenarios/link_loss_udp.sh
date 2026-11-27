#!/usr/bin/env bash
# One-command repro: link_loss_udp (see TESTING_RESULTS.md). Logs: testing/logs/link_loss_udp.*.log
exec python3 "$(dirname "$0")/run.py" "link_loss_udp" "$@"
