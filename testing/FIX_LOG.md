# Fix log (branch `bug_fixes`)

One entry per fix: bug id → cause → change → proof (test). Bug details and repros: `TESTING_RESULTS.md`.
Code comments at each change are tagged `// BUG-0xx:`.

## MAVLinkKit (unit-tested with `testing/unit/run_unit_tests.sh`)

| Bug | Change | Proof |
|---|---|---|
| BUG-002 | `CommandSession` queues a second command with the same id until the first one is resolved (COMMAND_ACK has no request id), then sends and retries it on its own; force-disarm is never queued. `pendingCommands` includes queued ones. | `test_BUG002_disarmNotCompletedByEarlierArmAck`, `test_BUG002_secondModeChangeRetriedAfterFirstAck`, `test_BUG002_forceDisarmGoesOutImmediately`, `probe_command_overwrite.sh` |
| BUG-007 | `MissionItem.e7()` converts degrees without trapping (non-finite → 0, clamp); `isValidCoordinate`; legacy `MISSION_ITEM` scales x/y only for location commands (others are param5/6); `WaypointFile.parse` rejects non-finite values and impossible positions (`badLine`). | `test_BUG007_*`, `probe_waypoint_file_nan/_huge_lat.sh`, `probe_mission_item_nan_coord.sh`, `probe_fuzz_pipeline.sh` |
| BUG-010 | `WaypointFile.parse` stops at `maxItems` (10 000) with `tooManyItems`. (App side: see below.) | `probe_waypoint_file_huge.sh` |
| BUG-016 | Loss estimate: late/duplicate packets no longer move the sequence baseline; a late packet that had been counted missing is un-counted. | `test_BUG016_reorderedPacketsAreNotLoss`, `test_cov_duplicatesDoNotCountAsLoss`, `reorder.sh` |
| BUG-020 | `ParamFile.parse` skips nan/inf. | `test_BUG020_paramFileRejectsNonFinite`, `probe_param_file_nan.sh` |
| BUG-033 | Mission upload: MISSION_ACK INVALID_SEQUENCE (13) is not fatal (ArduPilot keeps the upload open); after the last item, MISSION_ACK ERROR (1) or exhausted retries start a read-back (`uploadVerify`: MISSION_REQUEST_LIST → MISSION_COUNT must equal the uploaded count). The unit tests' simulated vehicle gained an `arduPilotLike` mode that behaves like SITL 4.7.3. | `testUploadToArduPilotLikeVehicleSurvivesLoss` (60 runs at 30 % loss), `sitl_lossy*.sh` |
