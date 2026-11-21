// GENERATED FILE - do not edit. Regenerate with: python -I tools/gen_swift.py
//
// REA Parity Source: Mission Planner MAVLink.dll (MAVLink.MAVLINK_MESSAGE_INFOS and the
// mavlink_*_t structs), dumped by tools/dump_mavlink_defs.ps1. Field order is wire order
// (sorted by size), offsets and CRC_EXTRA bytes are taken verbatim from that assembly.
// 349 messages.

// swiftlint:disable all

/// Namespace for all generated MAVLink message types, e.g. `MAV.Heartbeat`.
public enum MAV {}

public enum MAVLinkMessages {
    /// Message table lookup (CRC_EXTRA, lengths). `nil` for IDs Mission Planner doesn't know.
    public static func info(for id: UInt32) -> MAVMessageInfo? {
        switch id {
        case 0: return MAV.Heartbeat.mavInfo
        case 1: return MAV.SysStatus.mavInfo
        case 2: return MAV.SystemTime.mavInfo
        case 4: return MAV.Ping.mavInfo
        case 5: return MAV.ChangeOperatorControl.mavInfo
        case 6: return MAV.ChangeOperatorControlAck.mavInfo
        case 7: return MAV.AuthKey.mavInfo
        case 11: return MAV.SetMode.mavInfo
        case 20: return MAV.ParamRequestRead.mavInfo
        case 21: return MAV.ParamRequestList.mavInfo
        case 22: return MAV.ParamValue.mavInfo
        case 23: return MAV.ParamSet.mavInfo
        case 24: return MAV.GpsRawInt.mavInfo
        case 25: return MAV.GpsStatus.mavInfo
        case 26: return MAV.ScaledImu.mavInfo
        case 27: return MAV.RawImu.mavInfo
        case 28: return MAV.RawPressure.mavInfo
        case 29: return MAV.ScaledPressure.mavInfo
        case 30: return MAV.Attitude.mavInfo
        case 31: return MAV.AttitudeQuaternion.mavInfo
        case 32: return MAV.LocalPositionNed.mavInfo
        case 33: return MAV.GlobalPositionInt.mavInfo
        case 34: return MAV.RcChannelsScaled.mavInfo
        case 35: return MAV.RcChannelsRaw.mavInfo
        case 36: return MAV.ServoOutputRaw.mavInfo
        case 37: return MAV.MissionRequestPartialList.mavInfo
        case 38: return MAV.MissionWritePartialList.mavInfo
        case 39: return MAV.MissionItem.mavInfo
        case 40: return MAV.MissionRequest.mavInfo
        case 41: return MAV.MissionSetCurrent.mavInfo
        case 42: return MAV.MissionCurrent.mavInfo
        case 43: return MAV.MissionRequestList.mavInfo
        case 44: return MAV.MissionCount.mavInfo
        case 45: return MAV.MissionClearAll.mavInfo
        case 46: return MAV.MissionItemReached.mavInfo
        case 47: return MAV.MissionAck.mavInfo
        case 48: return MAV.SetGpsGlobalOrigin.mavInfo
        case 49: return MAV.GpsGlobalOrigin.mavInfo
        case 50: return MAV.ParamMapRc.mavInfo
        case 51: return MAV.MissionRequestInt.mavInfo
        case 53: return MAV.MissionChecksum.mavInfo
        case 54: return MAV.SafetySetAllowedArea.mavInfo
        case 55: return MAV.SafetyAllowedArea.mavInfo
        case 61: return MAV.AttitudeQuaternionCov.mavInfo
        case 62: return MAV.NavControllerOutput.mavInfo
        case 63: return MAV.GlobalPositionIntCov.mavInfo
        case 64: return MAV.LocalPositionNedCov.mavInfo
        case 65: return MAV.RcChannels.mavInfo
        case 66: return MAV.RequestDataStream.mavInfo
        case 67: return MAV.DataStream.mavInfo
        case 69: return MAV.ManualControl.mavInfo
        case 70: return MAV.RcChannelsOverride.mavInfo
        case 73: return MAV.MissionItemInt.mavInfo
        case 74: return MAV.VfrHud.mavInfo
        case 75: return MAV.CommandInt.mavInfo
        case 76: return MAV.CommandLong.mavInfo
        case 77: return MAV.CommandAck.mavInfo
        case 81: return MAV.ManualSetpoint.mavInfo
        case 82: return MAV.SetAttitudeTarget.mavInfo
        case 83: return MAV.AttitudeTarget.mavInfo
        case 84: return MAV.SetPositionTargetLocalNed.mavInfo
        case 85: return MAV.PositionTargetLocalNed.mavInfo
        case 86: return MAV.SetPositionTargetGlobalInt.mavInfo
        case 87: return MAV.PositionTargetGlobalInt.mavInfo
        case 89: return MAV.LocalPositionNedSystemGlobalOffset.mavInfo
        case 90: return MAV.HilState.mavInfo
        case 91: return MAV.HilControls.mavInfo
        case 92: return MAV.HilRcInputsRaw.mavInfo
        case 93: return MAV.HilActuatorControls.mavInfo
        case 100: return MAV.OpticalFlow.mavInfo
        case 101: return MAV.GlobalVisionPositionEstimate.mavInfo
        case 102: return MAV.VisionPositionEstimate.mavInfo
        case 103: return MAV.VisionSpeedEstimate.mavInfo
        case 104: return MAV.ViconPositionEstimate.mavInfo
        case 105: return MAV.HighresImu.mavInfo
        case 106: return MAV.OpticalFlowRad.mavInfo
        case 107: return MAV.HilSensor.mavInfo
        case 108: return MAV.SimState.mavInfo
        case 109: return MAV.RadioStatus.mavInfo
        case 110: return MAV.FileTransferProtocol.mavInfo
        case 111: return MAV.Timesync.mavInfo
        case 112: return MAV.CameraTrigger.mavInfo
        case 113: return MAV.HilGps.mavInfo
        case 114: return MAV.HilOpticalFlow.mavInfo
        case 115: return MAV.HilStateQuaternion.mavInfo
        case 116: return MAV.ScaledImu2.mavInfo
        case 117: return MAV.LogRequestList.mavInfo
        case 118: return MAV.LogEntry.mavInfo
        case 119: return MAV.LogRequestData.mavInfo
        case 120: return MAV.LogData.mavInfo
        case 121: return MAV.LogErase.mavInfo
        case 122: return MAV.LogRequestEnd.mavInfo
        case 123: return MAV.GpsInjectData.mavInfo
        case 124: return MAV.Gps2Raw.mavInfo
        case 125: return MAV.PowerStatus.mavInfo
        case 126: return MAV.SerialControl.mavInfo
        case 127: return MAV.GpsRtk.mavInfo
        case 128: return MAV.Gps2Rtk.mavInfo
        case 129: return MAV.ScaledImu3.mavInfo
        case 130: return MAV.DataTransmissionHandshake.mavInfo
        case 131: return MAV.EncapsulatedData.mavInfo
        case 132: return MAV.DistanceSensor.mavInfo
        case 133: return MAV.TerrainRequest.mavInfo
        case 134: return MAV.TerrainData.mavInfo
        case 135: return MAV.TerrainCheck.mavInfo
        case 136: return MAV.TerrainReport.mavInfo
        case 137: return MAV.ScaledPressure2.mavInfo
        case 138: return MAV.AttPosMocap.mavInfo
        case 139: return MAV.SetActuatorControlTarget.mavInfo
        case 140: return MAV.ActuatorControlTarget.mavInfo
        case 141: return MAV.Altitude.mavInfo
        case 142: return MAV.ResourceRequest.mavInfo
        case 143: return MAV.ScaledPressure3.mavInfo
        case 144: return MAV.FollowTarget.mavInfo
        case 146: return MAV.ControlSystemState.mavInfo
        case 147: return MAV.BatteryStatus.mavInfo
        case 148: return MAV.AutopilotVersion.mavInfo
        case 149: return MAV.LandingTarget.mavInfo
        case 150: return MAV.SensorOffsets.mavInfo
        case 151: return MAV.SetMagOffsets.mavInfo
        case 152: return MAV.Meminfo.mavInfo
        case 153: return MAV.ApAdc.mavInfo
        case 154: return MAV.DigicamConfigure.mavInfo
        case 155: return MAV.DigicamControl.mavInfo
        case 156: return MAV.MountConfigure.mavInfo
        case 157: return MAV.MountControl.mavInfo
        case 158: return MAV.MountStatus.mavInfo
        case 160: return MAV.FencePoint.mavInfo
        case 161: return MAV.FenceFetchPoint.mavInfo
        case 162: return MAV.FenceStatus.mavInfo
        case 163: return MAV.Ahrs.mavInfo
        case 164: return MAV.Simstate.mavInfo
        case 165: return MAV.Hwstatus.mavInfo
        case 166: return MAV.Radio.mavInfo
        case 167: return MAV.LimitsStatus.mavInfo
        case 168: return MAV.Wind.mavInfo
        case 169: return MAV.Data16.mavInfo
        case 170: return MAV.Data32.mavInfo
        case 171: return MAV.Data64.mavInfo
        case 172: return MAV.Data96.mavInfo
        case 173: return MAV.Rangefinder.mavInfo
        case 174: return MAV.AirspeedAutocal.mavInfo
        case 175: return MAV.RallyPoint.mavInfo
        case 176: return MAV.RallyFetchPoint.mavInfo
        case 177: return MAV.CompassmotStatus.mavInfo
        case 178: return MAV.Ahrs2.mavInfo
        case 179: return MAV.CameraStatus.mavInfo
        case 180: return MAV.CameraFeedback.mavInfo
        case 181: return MAV.Battery2.mavInfo
        case 182: return MAV.Ahrs3.mavInfo
        case 183: return MAV.AutopilotVersionRequest.mavInfo
        case 184: return MAV.RemoteLogDataBlock.mavInfo
        case 185: return MAV.RemoteLogBlockStatus.mavInfo
        case 186: return MAV.LedControl.mavInfo
        case 191: return MAV.MagCalProgress.mavInfo
        case 192: return MAV.MagCalReport.mavInfo
        case 193: return MAV.EkfStatusReport.mavInfo
        case 194: return MAV.PidTuning.mavInfo
        case 195: return MAV.Deepstall.mavInfo
        case 200: return MAV.GimbalReport.mavInfo
        case 201: return MAV.GimbalControl.mavInfo
        case 214: return MAV.GimbalTorqueCmdReport.mavInfo
        case 215: return MAV.GoproHeartbeat.mavInfo
        case 216: return MAV.GoproGetRequest.mavInfo
        case 217: return MAV.GoproGetResponse.mavInfo
        case 218: return MAV.GoproSetRequest.mavInfo
        case 219: return MAV.GoproSetResponse.mavInfo
        case 220: return MAV.NavFilterBias.mavInfo
        case 221: return MAV.RadioCalibration.mavInfo
        case 222: return MAV.UalbertaSysStatus.mavInfo
        case 223: return MAV.CommandIntStamped.mavInfo
        case 224: return MAV.CommandLongStamped.mavInfo
        case 225: return MAV.EfiStatus.mavInfo
        case 226: return MAV.Rpm.mavInfo
        case 230: return MAV.EstimatorStatus.mavInfo
        case 231: return MAV.WindCov.mavInfo
        case 232: return MAV.GpsInput.mavInfo
        case 233: return MAV.GpsRtcmData.mavInfo
        case 234: return MAV.HighLatency.mavInfo
        case 235: return MAV.HighLatency2.mavInfo
        case 241: return MAV.Vibration.mavInfo
        case 242: return MAV.HomePosition.mavInfo
        case 243: return MAV.SetHomePosition.mavInfo
        case 244: return MAV.MessageInterval.mavInfo
        case 245: return MAV.ExtendedSysState.mavInfo
        case 246: return MAV.AdsbVehicle.mavInfo
        case 247: return MAV.Collision.mavInfo
        case 248: return MAV.V2Extension.mavInfo
        case 249: return MAV.MemoryVect.mavInfo
        case 250: return MAV.DebugVect.mavInfo
        case 251: return MAV.NamedValueFloat.mavInfo
        case 252: return MAV.NamedValueInt.mavInfo
        case 253: return MAV.Statustext.mavInfo
        case 254: return MAV.Debug.mavInfo
        case 256: return MAV.SetupSigning.mavInfo
        case 257: return MAV.ButtonChange.mavInfo
        case 258: return MAV.PlayTune.mavInfo
        case 259: return MAV.CameraInformation.mavInfo
        case 260: return MAV.CameraSettings.mavInfo
        case 261: return MAV.StorageInformation.mavInfo
        case 262: return MAV.CameraCaptureStatus.mavInfo
        case 263: return MAV.CameraImageCaptured.mavInfo
        case 264: return MAV.FlightInformation.mavInfo
        case 265: return MAV.MountOrientation.mavInfo
        case 266: return MAV.LoggingData.mavInfo
        case 267: return MAV.LoggingDataAcked.mavInfo
        case 268: return MAV.LoggingAck.mavInfo
        case 269: return MAV.VideoStreamInformation.mavInfo
        case 270: return MAV.VideoStreamStatus.mavInfo
        case 271: return MAV.CameraFovStatus.mavInfo
        case 275: return MAV.CameraTrackingImageStatus.mavInfo
        case 276: return MAV.CameraTrackingGeoStatus.mavInfo
        case 277: return MAV.CameraThermalRange.mavInfo
        case 280: return MAV.GimbalManagerInformation.mavInfo
        case 281: return MAV.GimbalManagerStatus.mavInfo
        case 282: return MAV.GimbalManagerSetAttitude.mavInfo
        case 283: return MAV.GimbalDeviceInformation.mavInfo
        case 284: return MAV.GimbalDeviceSetAttitude.mavInfo
        case 285: return MAV.GimbalDeviceAttitudeStatus.mavInfo
        case 286: return MAV.AutopilotStateForGimbalDevice.mavInfo
        case 287: return MAV.GimbalManagerSetPitchyaw.mavInfo
        case 288: return MAV.GimbalManagerSetManualControl.mavInfo
        case 295: return MAV.Airspeed.mavInfo
        case 299: return MAV.WifiConfigAp.mavInfo
        case 301: return MAV.AisVessel.mavInfo
        case 310: return MAV.UavcanNodeStatus.mavInfo
        case 311: return MAV.UavcanNodeInfo.mavInfo
        case 320: return MAV.ParamExtRequestRead.mavInfo
        case 321: return MAV.ParamExtRequestList.mavInfo
        case 322: return MAV.ParamExtValue.mavInfo
        case 323: return MAV.ParamExtSet.mavInfo
        case 324: return MAV.ParamExtAck.mavInfo
        case 330: return MAV.ObstacleDistance.mavInfo
        case 331: return MAV.Odometry.mavInfo
        case 332: return MAV.TrajectoryRepresentationWaypoints.mavInfo
        case 333: return MAV.TrajectoryRepresentationBezier.mavInfo
        case 335: return MAV.IsbdLinkStatus.mavInfo
        case 339: return MAV.RawRpm.mavInfo
        case 340: return MAV.UtmGlobalPosition.mavInfo
        case 350: return MAV.DebugFloatArray.mavInfo
        case 370: return MAV.SmartBatteryInfo.mavInfo
        case 373: return MAV.GeneratorStatus.mavInfo
        case 375: return MAV.ActuatorOutputStatus.mavInfo
        case 376: return MAV.RelayStatus.mavInfo
        case 385: return MAV.Tunnel.mavInfo
        case 386: return MAV.CanFrame.mavInfo
        case 387: return MAV.CanfdFrame.mavInfo
        case 388: return MAV.CanFilterModify.mavInfo
        case 420: return MAV.RadioRcChannels.mavInfo
        case 435: return MAV.AvailableModes.mavInfo
        case 436: return MAV.CurrentMode.mavInfo
        case 437: return MAV.AvailableModesMonitor.mavInfo
        case 441: return MAV.GnssIntegrity.mavInfo
        case 8002: return MAV.SensPower.mavInfo
        case 8003: return MAV.SensMppt.mavInfo
        case 8004: return MAV.AslctrlData.mavInfo
        case 8005: return MAV.AslctrlDebug.mavInfo
        case 8006: return MAV.AsluavStatus.mavInfo
        case 8007: return MAV.EkfExt.mavInfo
        case 8008: return MAV.AslObctrl.mavInfo
        case 8009: return MAV.SensAtmos.mavInfo
        case 8010: return MAV.SensBatmon.mavInfo
        case 8011: return MAV.FwSoaringData.mavInfo
        case 8012: return MAV.SensorpodStatus.mavInfo
        case 8013: return MAV.SensPowerBoard.mavInfo
        case 8014: return MAV.GsmLinkStatus.mavInfo
        case 8015: return MAV.SatcomLinkStatus.mavInfo
        case 8016: return MAV.SensorAirflowAngles.mavInfo
        case 9000: return MAV.WheelDistance.mavInfo
        case 9005: return MAV.WinchStatus.mavInfo
        case 10001: return MAV.UavionixAdsbOutCfg.mavInfo
        case 10002: return MAV.UavionixAdsbOutDynamic.mavInfo
        case 10003: return MAV.UavionixAdsbTransceiverHealthReport.mavInfo
        case 10004: return MAV.UavionixAdsbOutCfgRegistration.mavInfo
        case 10005: return MAV.UavionixAdsbOutCfgFlightid.mavInfo
        case 10006: return MAV.UavionixAdsbGet.mavInfo
        case 10007: return MAV.UavionixAdsbOutControl.mavInfo
        case 10008: return MAV.UavionixAdsbOutStatus.mavInfo
        case 10151: return MAV.LoweheiserGovEfi.mavInfo
        case 11000: return MAV.DeviceOpRead.mavInfo
        case 11001: return MAV.DeviceOpReadReply.mavInfo
        case 11002: return MAV.DeviceOpWrite.mavInfo
        case 11003: return MAV.DeviceOpWriteReply.mavInfo
        case 11004: return MAV.SecureCommand.mavInfo
        case 11005: return MAV.SecureCommandReply.mavInfo
        case 11010: return MAV.AdapTuning.mavInfo
        case 11011: return MAV.VisionPositionDelta.mavInfo
        case 11020: return MAV.AoaSsa.mavInfo
        case 11030: return MAV.EscTelemetry1To4.mavInfo
        case 11031: return MAV.EscTelemetry5To8.mavInfo
        case 11032: return MAV.EscTelemetry9To12.mavInfo
        case 11033: return MAV.OsdParamConfig.mavInfo
        case 11034: return MAV.OsdParamConfigReply.mavInfo
        case 11035: return MAV.OsdParamShowConfig.mavInfo
        case 11036: return MAV.OsdParamShowConfigReply.mavInfo
        case 11037: return MAV.ObstacleDistance3d.mavInfo
        case 11038: return MAV.WaterDepth.mavInfo
        case 11039: return MAV.McuStatus.mavInfo
        case 11040: return MAV.EscTelemetry13To16.mavInfo
        case 11041: return MAV.EscTelemetry17To20.mavInfo
        case 11042: return MAV.EscTelemetry21To24.mavInfo
        case 11043: return MAV.EscTelemetry25To28.mavInfo
        case 11044: return MAV.EscTelemetry29To32.mavInfo
        case 11060: return MAV.NamedValueString.mavInfo
        case 12900: return MAV.OpenDroneIdBasicId.mavInfo
        case 12901: return MAV.OpenDroneIdLocation.mavInfo
        case 12902: return MAV.OpenDroneIdAuthentication.mavInfo
        case 12903: return MAV.OpenDroneIdSelfId.mavInfo
        case 12904: return MAV.OpenDroneIdSystem.mavInfo
        case 12905: return MAV.OpenDroneIdOperatorId.mavInfo
        case 12915: return MAV.OpenDroneIdMessagePack.mavInfo
        case 12918: return MAV.OpenDroneIdArmStatus.mavInfo
        case 12919: return MAV.OpenDroneIdSystemUpdate.mavInfo
        case 12920: return MAV.HygrometerSensor.mavInfo
        case 17000: return MAV.TestTypes.mavInfo
        case 17150: return MAV.ArrayTest0.mavInfo
        case 17151: return MAV.ArrayTest1.mavInfo
        case 17153: return MAV.ArrayTest3.mavInfo
        case 17154: return MAV.ArrayTest4.mavInfo
        case 17155: return MAV.ArrayTest5.mavInfo
        case 17156: return MAV.ArrayTest6.mavInfo
        case 17157: return MAV.ArrayTest7.mavInfo
        case 17158: return MAV.ArrayTest8.mavInfo
        case 26900: return MAV.ZvideoStreamInformation.mavInfo
        case 42000: return MAV.IcarousHeartbeat.mavInfo
        case 42001: return MAV.IcarousKinematicBands.mavInfo
        case 50001: return MAV.CubepilotRawRc.mavInfo
        case 50002: return MAV.HerelinkVideoStreamInformation.mavInfo
        case 50003: return MAV.HerelinkTelem.mavInfo
        case 50004: return MAV.CubepilotFirmwareUpdateStart.mavInfo
        case 50005: return MAV.CubepilotFirmwareUpdateResp.mavInfo
        case 52000: return MAV.AirlinkAuth.mavInfo
        case 52001: return MAV.AirlinkAuthResponse.mavInfo
        case 60000: return MAV.AutopilotStateForGimbalDeviceExt.mavInfo
        case 60010: return MAV.Storm32GimbalManagerInformation.mavInfo
        case 60011: return MAV.Storm32GimbalManagerStatus.mavInfo
        case 60012: return MAV.Storm32GimbalManagerControl.mavInfo
        case 60013: return MAV.Storm32GimbalManagerControlPitchyaw.mavInfo
        case 60014: return MAV.Storm32GimbalManagerCorrectRoll.mavInfo
        case 60020: return MAV.QshotStatus.mavInfo
        case 60040: return MAV.FrskyPassthroughArray.mavInfo
        case 60041: return MAV.ParamValueArray.mavInfo
        case 60045: return MAV.MlrsRadioLinkStats.mavInfo
        case 60046: return MAV.MlrsRadioLinkInformation.mavInfo
        case 60047: return MAV.MlrsRadioLinkFlowControl.mavInfo
        case 60050: return MAV.AvssPrsSysStatus.mavInfo
        case 60051: return MAV.AvssDronePosition.mavInfo
        case 60052: return MAV.AvssDroneImu.mavInfo
        case 60053: return MAV.AvssDroneOperationMode.mavInfo
        default: return nil
        }
    }

    /// Decodes a payload into its typed message struct. Short (v2-truncated) payloads are zero-extended.
    public static func decode(id: UInt32, payload: [UInt8]) -> MAVLinkMessage? {
        switch id {
        case 0: return MAV.Heartbeat(payload: MAVLinkPayloadReader(payload, length: 9))
        case 1: return MAV.SysStatus(payload: MAVLinkPayloadReader(payload, length: 31))
        case 2: return MAV.SystemTime(payload: MAVLinkPayloadReader(payload, length: 12))
        case 4: return MAV.Ping(payload: MAVLinkPayloadReader(payload, length: 14))
        case 5: return MAV.ChangeOperatorControl(payload: MAVLinkPayloadReader(payload, length: 28))
        case 6: return MAV.ChangeOperatorControlAck(payload: MAVLinkPayloadReader(payload, length: 3))
        case 7: return MAV.AuthKey(payload: MAVLinkPayloadReader(payload, length: 32))
        case 11: return MAV.SetMode(payload: MAVLinkPayloadReader(payload, length: 6))
        case 20: return MAV.ParamRequestRead(payload: MAVLinkPayloadReader(payload, length: 20))
        case 21: return MAV.ParamRequestList(payload: MAVLinkPayloadReader(payload, length: 2))
        case 22: return MAV.ParamValue(payload: MAVLinkPayloadReader(payload, length: 25))
        case 23: return MAV.ParamSet(payload: MAVLinkPayloadReader(payload, length: 23))
        case 24: return MAV.GpsRawInt(payload: MAVLinkPayloadReader(payload, length: 52))
        case 25: return MAV.GpsStatus(payload: MAVLinkPayloadReader(payload, length: 101))
        case 26: return MAV.ScaledImu(payload: MAVLinkPayloadReader(payload, length: 24))
        case 27: return MAV.RawImu(payload: MAVLinkPayloadReader(payload, length: 29))
        case 28: return MAV.RawPressure(payload: MAVLinkPayloadReader(payload, length: 16))
        case 29: return MAV.ScaledPressure(payload: MAVLinkPayloadReader(payload, length: 16))
        case 30: return MAV.Attitude(payload: MAVLinkPayloadReader(payload, length: 28))
        case 31: return MAV.AttitudeQuaternion(payload: MAVLinkPayloadReader(payload, length: 48))
        case 32: return MAV.LocalPositionNed(payload: MAVLinkPayloadReader(payload, length: 28))
        case 33: return MAV.GlobalPositionInt(payload: MAVLinkPayloadReader(payload, length: 28))
        case 34: return MAV.RcChannelsScaled(payload: MAVLinkPayloadReader(payload, length: 22))
        case 35: return MAV.RcChannelsRaw(payload: MAVLinkPayloadReader(payload, length: 22))
        case 36: return MAV.ServoOutputRaw(payload: MAVLinkPayloadReader(payload, length: 37))
        case 37: return MAV.MissionRequestPartialList(payload: MAVLinkPayloadReader(payload, length: 7))
        case 38: return MAV.MissionWritePartialList(payload: MAVLinkPayloadReader(payload, length: 7))
        case 39: return MAV.MissionItem(payload: MAVLinkPayloadReader(payload, length: 38))
        case 40: return MAV.MissionRequest(payload: MAVLinkPayloadReader(payload, length: 5))
        case 41: return MAV.MissionSetCurrent(payload: MAVLinkPayloadReader(payload, length: 4))
        case 42: return MAV.MissionCurrent(payload: MAVLinkPayloadReader(payload, length: 6))
        case 43: return MAV.MissionRequestList(payload: MAVLinkPayloadReader(payload, length: 3))
        case 44: return MAV.MissionCount(payload: MAVLinkPayloadReader(payload, length: 5))
        case 45: return MAV.MissionClearAll(payload: MAVLinkPayloadReader(payload, length: 3))
        case 46: return MAV.MissionItemReached(payload: MAVLinkPayloadReader(payload, length: 2))
        case 47: return MAV.MissionAck(payload: MAVLinkPayloadReader(payload, length: 4))
        case 48: return MAV.SetGpsGlobalOrigin(payload: MAVLinkPayloadReader(payload, length: 21))
        case 49: return MAV.GpsGlobalOrigin(payload: MAVLinkPayloadReader(payload, length: 20))
        case 50: return MAV.ParamMapRc(payload: MAVLinkPayloadReader(payload, length: 37))
        case 51: return MAV.MissionRequestInt(payload: MAVLinkPayloadReader(payload, length: 5))
        case 53: return MAV.MissionChecksum(payload: MAVLinkPayloadReader(payload, length: 5))
        case 54: return MAV.SafetySetAllowedArea(payload: MAVLinkPayloadReader(payload, length: 27))
        case 55: return MAV.SafetyAllowedArea(payload: MAVLinkPayloadReader(payload, length: 25))
        case 61: return MAV.AttitudeQuaternionCov(payload: MAVLinkPayloadReader(payload, length: 72))
        case 62: return MAV.NavControllerOutput(payload: MAVLinkPayloadReader(payload, length: 26))
        case 63: return MAV.GlobalPositionIntCov(payload: MAVLinkPayloadReader(payload, length: 181))
        case 64: return MAV.LocalPositionNedCov(payload: MAVLinkPayloadReader(payload, length: 225))
        case 65: return MAV.RcChannels(payload: MAVLinkPayloadReader(payload, length: 42))
        case 66: return MAV.RequestDataStream(payload: MAVLinkPayloadReader(payload, length: 6))
        case 67: return MAV.DataStream(payload: MAVLinkPayloadReader(payload, length: 4))
        case 69: return MAV.ManualControl(payload: MAVLinkPayloadReader(payload, length: 30))
        case 70: return MAV.RcChannelsOverride(payload: MAVLinkPayloadReader(payload, length: 38))
        case 73: return MAV.MissionItemInt(payload: MAVLinkPayloadReader(payload, length: 38))
        case 74: return MAV.VfrHud(payload: MAVLinkPayloadReader(payload, length: 20))
        case 75: return MAV.CommandInt(payload: MAVLinkPayloadReader(payload, length: 35))
        case 76: return MAV.CommandLong(payload: MAVLinkPayloadReader(payload, length: 33))
        case 77: return MAV.CommandAck(payload: MAVLinkPayloadReader(payload, length: 10))
        case 81: return MAV.ManualSetpoint(payload: MAVLinkPayloadReader(payload, length: 22))
        case 82: return MAV.SetAttitudeTarget(payload: MAVLinkPayloadReader(payload, length: 39))
        case 83: return MAV.AttitudeTarget(payload: MAVLinkPayloadReader(payload, length: 37))
        case 84: return MAV.SetPositionTargetLocalNed(payload: MAVLinkPayloadReader(payload, length: 53))
        case 85: return MAV.PositionTargetLocalNed(payload: MAVLinkPayloadReader(payload, length: 51))
        case 86: return MAV.SetPositionTargetGlobalInt(payload: MAVLinkPayloadReader(payload, length: 53))
        case 87: return MAV.PositionTargetGlobalInt(payload: MAVLinkPayloadReader(payload, length: 51))
        case 89: return MAV.LocalPositionNedSystemGlobalOffset(payload: MAVLinkPayloadReader(payload, length: 28))
        case 90: return MAV.HilState(payload: MAVLinkPayloadReader(payload, length: 56))
        case 91: return MAV.HilControls(payload: MAVLinkPayloadReader(payload, length: 42))
        case 92: return MAV.HilRcInputsRaw(payload: MAVLinkPayloadReader(payload, length: 33))
        case 93: return MAV.HilActuatorControls(payload: MAVLinkPayloadReader(payload, length: 81))
        case 100: return MAV.OpticalFlow(payload: MAVLinkPayloadReader(payload, length: 34))
        case 101: return MAV.GlobalVisionPositionEstimate(payload: MAVLinkPayloadReader(payload, length: 117))
        case 102: return MAV.VisionPositionEstimate(payload: MAVLinkPayloadReader(payload, length: 117))
        case 103: return MAV.VisionSpeedEstimate(payload: MAVLinkPayloadReader(payload, length: 57))
        case 104: return MAV.ViconPositionEstimate(payload: MAVLinkPayloadReader(payload, length: 116))
        case 105: return MAV.HighresImu(payload: MAVLinkPayloadReader(payload, length: 63))
        case 106: return MAV.OpticalFlowRad(payload: MAVLinkPayloadReader(payload, length: 44))
        case 107: return MAV.HilSensor(payload: MAVLinkPayloadReader(payload, length: 65))
        case 108: return MAV.SimState(payload: MAVLinkPayloadReader(payload, length: 92))
        case 109: return MAV.RadioStatus(payload: MAVLinkPayloadReader(payload, length: 9))
        case 110: return MAV.FileTransferProtocol(payload: MAVLinkPayloadReader(payload, length: 254))
        case 111: return MAV.Timesync(payload: MAVLinkPayloadReader(payload, length: 16))
        case 112: return MAV.CameraTrigger(payload: MAVLinkPayloadReader(payload, length: 12))
        case 113: return MAV.HilGps(payload: MAVLinkPayloadReader(payload, length: 39))
        case 114: return MAV.HilOpticalFlow(payload: MAVLinkPayloadReader(payload, length: 44))
        case 115: return MAV.HilStateQuaternion(payload: MAVLinkPayloadReader(payload, length: 64))
        case 116: return MAV.ScaledImu2(payload: MAVLinkPayloadReader(payload, length: 24))
        case 117: return MAV.LogRequestList(payload: MAVLinkPayloadReader(payload, length: 6))
        case 118: return MAV.LogEntry(payload: MAVLinkPayloadReader(payload, length: 14))
        case 119: return MAV.LogRequestData(payload: MAVLinkPayloadReader(payload, length: 12))
        case 120: return MAV.LogData(payload: MAVLinkPayloadReader(payload, length: 97))
        case 121: return MAV.LogErase(payload: MAVLinkPayloadReader(payload, length: 2))
        case 122: return MAV.LogRequestEnd(payload: MAVLinkPayloadReader(payload, length: 2))
        case 123: return MAV.GpsInjectData(payload: MAVLinkPayloadReader(payload, length: 113))
        case 124: return MAV.Gps2Raw(payload: MAVLinkPayloadReader(payload, length: 57))
        case 125: return MAV.PowerStatus(payload: MAVLinkPayloadReader(payload, length: 6))
        case 126: return MAV.SerialControl(payload: MAVLinkPayloadReader(payload, length: 79))
        case 127: return MAV.GpsRtk(payload: MAVLinkPayloadReader(payload, length: 35))
        case 128: return MAV.Gps2Rtk(payload: MAVLinkPayloadReader(payload, length: 35))
        case 129: return MAV.ScaledImu3(payload: MAVLinkPayloadReader(payload, length: 24))
        case 130: return MAV.DataTransmissionHandshake(payload: MAVLinkPayloadReader(payload, length: 13))
        case 131: return MAV.EncapsulatedData(payload: MAVLinkPayloadReader(payload, length: 255))
        case 132: return MAV.DistanceSensor(payload: MAVLinkPayloadReader(payload, length: 39))
        case 133: return MAV.TerrainRequest(payload: MAVLinkPayloadReader(payload, length: 18))
        case 134: return MAV.TerrainData(payload: MAVLinkPayloadReader(payload, length: 43))
        case 135: return MAV.TerrainCheck(payload: MAVLinkPayloadReader(payload, length: 8))
        case 136: return MAV.TerrainReport(payload: MAVLinkPayloadReader(payload, length: 22))
        case 137: return MAV.ScaledPressure2(payload: MAVLinkPayloadReader(payload, length: 16))
        case 138: return MAV.AttPosMocap(payload: MAVLinkPayloadReader(payload, length: 120))
        case 139: return MAV.SetActuatorControlTarget(payload: MAVLinkPayloadReader(payload, length: 43))
        case 140: return MAV.ActuatorControlTarget(payload: MAVLinkPayloadReader(payload, length: 41))
        case 141: return MAV.Altitude(payload: MAVLinkPayloadReader(payload, length: 32))
        case 142: return MAV.ResourceRequest(payload: MAVLinkPayloadReader(payload, length: 243))
        case 143: return MAV.ScaledPressure3(payload: MAVLinkPayloadReader(payload, length: 16))
        case 144: return MAV.FollowTarget(payload: MAVLinkPayloadReader(payload, length: 93))
        case 146: return MAV.ControlSystemState(payload: MAVLinkPayloadReader(payload, length: 100))
        case 147: return MAV.BatteryStatus(payload: MAVLinkPayloadReader(payload, length: 54))
        case 148: return MAV.AutopilotVersion(payload: MAVLinkPayloadReader(payload, length: 78))
        case 149: return MAV.LandingTarget(payload: MAVLinkPayloadReader(payload, length: 60))
        case 150: return MAV.SensorOffsets(payload: MAVLinkPayloadReader(payload, length: 42))
        case 151: return MAV.SetMagOffsets(payload: MAVLinkPayloadReader(payload, length: 8))
        case 152: return MAV.Meminfo(payload: MAVLinkPayloadReader(payload, length: 8))
        case 153: return MAV.ApAdc(payload: MAVLinkPayloadReader(payload, length: 12))
        case 154: return MAV.DigicamConfigure(payload: MAVLinkPayloadReader(payload, length: 15))
        case 155: return MAV.DigicamControl(payload: MAVLinkPayloadReader(payload, length: 13))
        case 156: return MAV.MountConfigure(payload: MAVLinkPayloadReader(payload, length: 6))
        case 157: return MAV.MountControl(payload: MAVLinkPayloadReader(payload, length: 15))
        case 158: return MAV.MountStatus(payload: MAVLinkPayloadReader(payload, length: 15))
        case 160: return MAV.FencePoint(payload: MAVLinkPayloadReader(payload, length: 12))
        case 161: return MAV.FenceFetchPoint(payload: MAVLinkPayloadReader(payload, length: 3))
        case 162: return MAV.FenceStatus(payload: MAVLinkPayloadReader(payload, length: 9))
        case 163: return MAV.Ahrs(payload: MAVLinkPayloadReader(payload, length: 28))
        case 164: return MAV.Simstate(payload: MAVLinkPayloadReader(payload, length: 44))
        case 165: return MAV.Hwstatus(payload: MAVLinkPayloadReader(payload, length: 3))
        case 166: return MAV.Radio(payload: MAVLinkPayloadReader(payload, length: 9))
        case 167: return MAV.LimitsStatus(payload: MAVLinkPayloadReader(payload, length: 22))
        case 168: return MAV.Wind(payload: MAVLinkPayloadReader(payload, length: 12))
        case 169: return MAV.Data16(payload: MAVLinkPayloadReader(payload, length: 18))
        case 170: return MAV.Data32(payload: MAVLinkPayloadReader(payload, length: 34))
        case 171: return MAV.Data64(payload: MAVLinkPayloadReader(payload, length: 66))
        case 172: return MAV.Data96(payload: MAVLinkPayloadReader(payload, length: 98))
        case 173: return MAV.Rangefinder(payload: MAVLinkPayloadReader(payload, length: 8))
        case 174: return MAV.AirspeedAutocal(payload: MAVLinkPayloadReader(payload, length: 48))
        case 175: return MAV.RallyPoint(payload: MAVLinkPayloadReader(payload, length: 19))
        case 176: return MAV.RallyFetchPoint(payload: MAVLinkPayloadReader(payload, length: 3))
        case 177: return MAV.CompassmotStatus(payload: MAVLinkPayloadReader(payload, length: 20))
        case 178: return MAV.Ahrs2(payload: MAVLinkPayloadReader(payload, length: 24))
        case 179: return MAV.CameraStatus(payload: MAVLinkPayloadReader(payload, length: 29))
        case 180: return MAV.CameraFeedback(payload: MAVLinkPayloadReader(payload, length: 47))
        case 181: return MAV.Battery2(payload: MAVLinkPayloadReader(payload, length: 4))
        case 182: return MAV.Ahrs3(payload: MAVLinkPayloadReader(payload, length: 40))
        case 183: return MAV.AutopilotVersionRequest(payload: MAVLinkPayloadReader(payload, length: 2))
        case 184: return MAV.RemoteLogDataBlock(payload: MAVLinkPayloadReader(payload, length: 206))
        case 185: return MAV.RemoteLogBlockStatus(payload: MAVLinkPayloadReader(payload, length: 7))
        case 186: return MAV.LedControl(payload: MAVLinkPayloadReader(payload, length: 29))
        case 191: return MAV.MagCalProgress(payload: MAVLinkPayloadReader(payload, length: 27))
        case 192: return MAV.MagCalReport(payload: MAVLinkPayloadReader(payload, length: 54))
        case 193: return MAV.EkfStatusReport(payload: MAVLinkPayloadReader(payload, length: 26))
        case 194: return MAV.PidTuning(payload: MAVLinkPayloadReader(payload, length: 33))
        case 195: return MAV.Deepstall(payload: MAVLinkPayloadReader(payload, length: 37))
        case 200: return MAV.GimbalReport(payload: MAVLinkPayloadReader(payload, length: 42))
        case 201: return MAV.GimbalControl(payload: MAVLinkPayloadReader(payload, length: 14))
        case 214: return MAV.GimbalTorqueCmdReport(payload: MAVLinkPayloadReader(payload, length: 8))
        case 215: return MAV.GoproHeartbeat(payload: MAVLinkPayloadReader(payload, length: 3))
        case 216: return MAV.GoproGetRequest(payload: MAVLinkPayloadReader(payload, length: 3))
        case 217: return MAV.GoproGetResponse(payload: MAVLinkPayloadReader(payload, length: 6))
        case 218: return MAV.GoproSetRequest(payload: MAVLinkPayloadReader(payload, length: 7))
        case 219: return MAV.GoproSetResponse(payload: MAVLinkPayloadReader(payload, length: 2))
        case 220: return MAV.NavFilterBias(payload: MAVLinkPayloadReader(payload, length: 32))
        case 221: return MAV.RadioCalibration(payload: MAVLinkPayloadReader(payload, length: 42))
        case 222: return MAV.UalbertaSysStatus(payload: MAVLinkPayloadReader(payload, length: 3))
        case 223: return MAV.CommandIntStamped(payload: MAVLinkPayloadReader(payload, length: 47))
        case 224: return MAV.CommandLongStamped(payload: MAVLinkPayloadReader(payload, length: 45))
        case 225: return MAV.EfiStatus(payload: MAVLinkPayloadReader(payload, length: 73))
        case 226: return MAV.Rpm(payload: MAVLinkPayloadReader(payload, length: 8))
        case 230: return MAV.EstimatorStatus(payload: MAVLinkPayloadReader(payload, length: 42))
        case 231: return MAV.WindCov(payload: MAVLinkPayloadReader(payload, length: 40))
        case 232: return MAV.GpsInput(payload: MAVLinkPayloadReader(payload, length: 65))
        case 233: return MAV.GpsRtcmData(payload: MAVLinkPayloadReader(payload, length: 182))
        case 234: return MAV.HighLatency(payload: MAVLinkPayloadReader(payload, length: 40))
        case 235: return MAV.HighLatency2(payload: MAVLinkPayloadReader(payload, length: 42))
        case 241: return MAV.Vibration(payload: MAVLinkPayloadReader(payload, length: 32))
        case 242: return MAV.HomePosition(payload: MAVLinkPayloadReader(payload, length: 60))
        case 243: return MAV.SetHomePosition(payload: MAVLinkPayloadReader(payload, length: 61))
        case 244: return MAV.MessageInterval(payload: MAVLinkPayloadReader(payload, length: 6))
        case 245: return MAV.ExtendedSysState(payload: MAVLinkPayloadReader(payload, length: 2))
        case 246: return MAV.AdsbVehicle(payload: MAVLinkPayloadReader(payload, length: 38))
        case 247: return MAV.Collision(payload: MAVLinkPayloadReader(payload, length: 19))
        case 248: return MAV.V2Extension(payload: MAVLinkPayloadReader(payload, length: 254))
        case 249: return MAV.MemoryVect(payload: MAVLinkPayloadReader(payload, length: 36))
        case 250: return MAV.DebugVect(payload: MAVLinkPayloadReader(payload, length: 30))
        case 251: return MAV.NamedValueFloat(payload: MAVLinkPayloadReader(payload, length: 18))
        case 252: return MAV.NamedValueInt(payload: MAVLinkPayloadReader(payload, length: 18))
        case 253: return MAV.Statustext(payload: MAVLinkPayloadReader(payload, length: 54))
        case 254: return MAV.Debug(payload: MAVLinkPayloadReader(payload, length: 9))
        case 256: return MAV.SetupSigning(payload: MAVLinkPayloadReader(payload, length: 42))
        case 257: return MAV.ButtonChange(payload: MAVLinkPayloadReader(payload, length: 9))
        case 258: return MAV.PlayTune(payload: MAVLinkPayloadReader(payload, length: 232))
        case 259: return MAV.CameraInformation(payload: MAVLinkPayloadReader(payload, length: 236))
        case 260: return MAV.CameraSettings(payload: MAVLinkPayloadReader(payload, length: 13))
        case 261: return MAV.StorageInformation(payload: MAVLinkPayloadReader(payload, length: 60))
        case 262: return MAV.CameraCaptureStatus(payload: MAVLinkPayloadReader(payload, length: 22))
        case 263: return MAV.CameraImageCaptured(payload: MAVLinkPayloadReader(payload, length: 255))
        case 264: return MAV.FlightInformation(payload: MAVLinkPayloadReader(payload, length: 28))
        case 265: return MAV.MountOrientation(payload: MAVLinkPayloadReader(payload, length: 20))
        case 266: return MAV.LoggingData(payload: MAVLinkPayloadReader(payload, length: 255))
        case 267: return MAV.LoggingDataAcked(payload: MAVLinkPayloadReader(payload, length: 255))
        case 268: return MAV.LoggingAck(payload: MAVLinkPayloadReader(payload, length: 4))
        case 269: return MAV.VideoStreamInformation(payload: MAVLinkPayloadReader(payload, length: 214))
        case 270: return MAV.VideoStreamStatus(payload: MAVLinkPayloadReader(payload, length: 19))
        case 271: return MAV.CameraFovStatus(payload: MAVLinkPayloadReader(payload, length: 52))
        case 275: return MAV.CameraTrackingImageStatus(payload: MAVLinkPayloadReader(payload, length: 31))
        case 276: return MAV.CameraTrackingGeoStatus(payload: MAVLinkPayloadReader(payload, length: 49))
        case 277: return MAV.CameraThermalRange(payload: MAVLinkPayloadReader(payload, length: 30))
        case 280: return MAV.GimbalManagerInformation(payload: MAVLinkPayloadReader(payload, length: 33))
        case 281: return MAV.GimbalManagerStatus(payload: MAVLinkPayloadReader(payload, length: 13))
        case 282: return MAV.GimbalManagerSetAttitude(payload: MAVLinkPayloadReader(payload, length: 35))
        case 283: return MAV.GimbalDeviceInformation(payload: MAVLinkPayloadReader(payload, length: 145))
        case 284: return MAV.GimbalDeviceSetAttitude(payload: MAVLinkPayloadReader(payload, length: 32))
        case 285: return MAV.GimbalDeviceAttitudeStatus(payload: MAVLinkPayloadReader(payload, length: 49))
        case 286: return MAV.AutopilotStateForGimbalDevice(payload: MAVLinkPayloadReader(payload, length: 57))
        case 287: return MAV.GimbalManagerSetPitchyaw(payload: MAVLinkPayloadReader(payload, length: 23))
        case 288: return MAV.GimbalManagerSetManualControl(payload: MAVLinkPayloadReader(payload, length: 23))
        case 295: return MAV.Airspeed(payload: MAVLinkPayloadReader(payload, length: 12))
        case 299: return MAV.WifiConfigAp(payload: MAVLinkPayloadReader(payload, length: 96))
        case 301: return MAV.AisVessel(payload: MAVLinkPayloadReader(payload, length: 58))
        case 310: return MAV.UavcanNodeStatus(payload: MAVLinkPayloadReader(payload, length: 17))
        case 311: return MAV.UavcanNodeInfo(payload: MAVLinkPayloadReader(payload, length: 116))
        case 320: return MAV.ParamExtRequestRead(payload: MAVLinkPayloadReader(payload, length: 20))
        case 321: return MAV.ParamExtRequestList(payload: MAVLinkPayloadReader(payload, length: 2))
        case 322: return MAV.ParamExtValue(payload: MAVLinkPayloadReader(payload, length: 149))
        case 323: return MAV.ParamExtSet(payload: MAVLinkPayloadReader(payload, length: 147))
        case 324: return MAV.ParamExtAck(payload: MAVLinkPayloadReader(payload, length: 146))
        case 330: return MAV.ObstacleDistance(payload: MAVLinkPayloadReader(payload, length: 167))
        case 331: return MAV.Odometry(payload: MAVLinkPayloadReader(payload, length: 233))
        case 332: return MAV.TrajectoryRepresentationWaypoints(payload: MAVLinkPayloadReader(payload, length: 239))
        case 333: return MAV.TrajectoryRepresentationBezier(payload: MAVLinkPayloadReader(payload, length: 109))
        case 335: return MAV.IsbdLinkStatus(payload: MAVLinkPayloadReader(payload, length: 24))
        case 339: return MAV.RawRpm(payload: MAVLinkPayloadReader(payload, length: 5))
        case 340: return MAV.UtmGlobalPosition(payload: MAVLinkPayloadReader(payload, length: 70))
        case 350: return MAV.DebugFloatArray(payload: MAVLinkPayloadReader(payload, length: 252))
        case 370: return MAV.SmartBatteryInfo(payload: MAVLinkPayloadReader(payload, length: 109))
        case 373: return MAV.GeneratorStatus(payload: MAVLinkPayloadReader(payload, length: 42))
        case 375: return MAV.ActuatorOutputStatus(payload: MAVLinkPayloadReader(payload, length: 140))
        case 376: return MAV.RelayStatus(payload: MAVLinkPayloadReader(payload, length: 8))
        case 385: return MAV.Tunnel(payload: MAVLinkPayloadReader(payload, length: 133))
        case 386: return MAV.CanFrame(payload: MAVLinkPayloadReader(payload, length: 16))
        case 387: return MAV.CanfdFrame(payload: MAVLinkPayloadReader(payload, length: 72))
        case 388: return MAV.CanFilterModify(payload: MAVLinkPayloadReader(payload, length: 37))
        case 420: return MAV.RadioRcChannels(payload: MAVLinkPayloadReader(payload, length: 73))
        case 435: return MAV.AvailableModes(payload: MAVLinkPayloadReader(payload, length: 46))
        case 436: return MAV.CurrentMode(payload: MAVLinkPayloadReader(payload, length: 9))
        case 437: return MAV.AvailableModesMonitor(payload: MAVLinkPayloadReader(payload, length: 1))
        case 441: return MAV.GnssIntegrity(payload: MAVLinkPayloadReader(payload, length: 17))
        case 8002: return MAV.SensPower(payload: MAVLinkPayloadReader(payload, length: 16))
        case 8003: return MAV.SensMppt(payload: MAVLinkPayloadReader(payload, length: 41))
        case 8004: return MAV.AslctrlData(payload: MAVLinkPayloadReader(payload, length: 98))
        case 8005: return MAV.AslctrlDebug(payload: MAVLinkPayloadReader(payload, length: 38))
        case 8006: return MAV.AsluavStatus(payload: MAVLinkPayloadReader(payload, length: 14))
        case 8007: return MAV.EkfExt(payload: MAVLinkPayloadReader(payload, length: 32))
        case 8008: return MAV.AslObctrl(payload: MAVLinkPayloadReader(payload, length: 33))
        case 8009: return MAV.SensAtmos(payload: MAVLinkPayloadReader(payload, length: 16))
        case 8010: return MAV.SensBatmon(payload: MAVLinkPayloadReader(payload, length: 41))
        case 8011: return MAV.FwSoaringData(payload: MAVLinkPayloadReader(payload, length: 102))
        case 8012: return MAV.SensorpodStatus(payload: MAVLinkPayloadReader(payload, length: 16))
        case 8013: return MAV.SensPowerBoard(payload: MAVLinkPayloadReader(payload, length: 46))
        case 8014: return MAV.GsmLinkStatus(payload: MAVLinkPayloadReader(payload, length: 14))
        case 8015: return MAV.SatcomLinkStatus(payload: MAVLinkPayloadReader(payload, length: 24))
        case 8016: return MAV.SensorAirflowAngles(payload: MAVLinkPayloadReader(payload, length: 18))
        case 9000: return MAV.WheelDistance(payload: MAVLinkPayloadReader(payload, length: 137))
        case 9005: return MAV.WinchStatus(payload: MAVLinkPayloadReader(payload, length: 34))
        case 10001: return MAV.UavionixAdsbOutCfg(payload: MAVLinkPayloadReader(payload, length: 20))
        case 10002: return MAV.UavionixAdsbOutDynamic(payload: MAVLinkPayloadReader(payload, length: 41))
        case 10003: return MAV.UavionixAdsbTransceiverHealthReport(payload: MAVLinkPayloadReader(payload, length: 1))
        case 10004: return MAV.UavionixAdsbOutCfgRegistration(payload: MAVLinkPayloadReader(payload, length: 9))
        case 10005: return MAV.UavionixAdsbOutCfgFlightid(payload: MAVLinkPayloadReader(payload, length: 9))
        case 10006: return MAV.UavionixAdsbGet(payload: MAVLinkPayloadReader(payload, length: 4))
        case 10007: return MAV.UavionixAdsbOutControl(payload: MAVLinkPayloadReader(payload, length: 17))
        case 10008: return MAV.UavionixAdsbOutStatus(payload: MAVLinkPayloadReader(payload, length: 14))
        case 10151: return MAV.LoweheiserGovEfi(payload: MAVLinkPayloadReader(payload, length: 85))
        case 11000: return MAV.DeviceOpRead(payload: MAVLinkPayloadReader(payload, length: 52))
        case 11001: return MAV.DeviceOpReadReply(payload: MAVLinkPayloadReader(payload, length: 136))
        case 11002: return MAV.DeviceOpWrite(payload: MAVLinkPayloadReader(payload, length: 180))
        case 11003: return MAV.DeviceOpWriteReply(payload: MAVLinkPayloadReader(payload, length: 5))
        case 11004: return MAV.SecureCommand(payload: MAVLinkPayloadReader(payload, length: 232))
        case 11005: return MAV.SecureCommandReply(payload: MAVLinkPayloadReader(payload, length: 230))
        case 11010: return MAV.AdapTuning(payload: MAVLinkPayloadReader(payload, length: 49))
        case 11011: return MAV.VisionPositionDelta(payload: MAVLinkPayloadReader(payload, length: 44))
        case 11020: return MAV.AoaSsa(payload: MAVLinkPayloadReader(payload, length: 16))
        case 11030: return MAV.EscTelemetry1To4(payload: MAVLinkPayloadReader(payload, length: 44))
        case 11031: return MAV.EscTelemetry5To8(payload: MAVLinkPayloadReader(payload, length: 44))
        case 11032: return MAV.EscTelemetry9To12(payload: MAVLinkPayloadReader(payload, length: 44))
        case 11033: return MAV.OsdParamConfig(payload: MAVLinkPayloadReader(payload, length: 37))
        case 11034: return MAV.OsdParamConfigReply(payload: MAVLinkPayloadReader(payload, length: 5))
        case 11035: return MAV.OsdParamShowConfig(payload: MAVLinkPayloadReader(payload, length: 8))
        case 11036: return MAV.OsdParamShowConfigReply(payload: MAVLinkPayloadReader(payload, length: 34))
        case 11037: return MAV.ObstacleDistance3d(payload: MAVLinkPayloadReader(payload, length: 28))
        case 11038: return MAV.WaterDepth(payload: MAVLinkPayloadReader(payload, length: 38))
        case 11039: return MAV.McuStatus(payload: MAVLinkPayloadReader(payload, length: 9))
        case 11040: return MAV.EscTelemetry13To16(payload: MAVLinkPayloadReader(payload, length: 44))
        case 11041: return MAV.EscTelemetry17To20(payload: MAVLinkPayloadReader(payload, length: 44))
        case 11042: return MAV.EscTelemetry21To24(payload: MAVLinkPayloadReader(payload, length: 44))
        case 11043: return MAV.EscTelemetry25To28(payload: MAVLinkPayloadReader(payload, length: 44))
        case 11044: return MAV.EscTelemetry29To32(payload: MAVLinkPayloadReader(payload, length: 44))
        case 11060: return MAV.NamedValueString(payload: MAVLinkPayloadReader(payload, length: 78))
        case 12900: return MAV.OpenDroneIdBasicId(payload: MAVLinkPayloadReader(payload, length: 44))
        case 12901: return MAV.OpenDroneIdLocation(payload: MAVLinkPayloadReader(payload, length: 59))
        case 12902: return MAV.OpenDroneIdAuthentication(payload: MAVLinkPayloadReader(payload, length: 53))
        case 12903: return MAV.OpenDroneIdSelfId(payload: MAVLinkPayloadReader(payload, length: 46))
        case 12904: return MAV.OpenDroneIdSystem(payload: MAVLinkPayloadReader(payload, length: 54))
        case 12905: return MAV.OpenDroneIdOperatorId(payload: MAVLinkPayloadReader(payload, length: 43))
        case 12915: return MAV.OpenDroneIdMessagePack(payload: MAVLinkPayloadReader(payload, length: 249))
        case 12918: return MAV.OpenDroneIdArmStatus(payload: MAVLinkPayloadReader(payload, length: 51))
        case 12919: return MAV.OpenDroneIdSystemUpdate(payload: MAVLinkPayloadReader(payload, length: 18))
        case 12920: return MAV.HygrometerSensor(payload: MAVLinkPayloadReader(payload, length: 5))
        case 17000: return MAV.TestTypes(payload: MAVLinkPayloadReader(payload, length: 179))
        case 17150: return MAV.ArrayTest0(payload: MAVLinkPayloadReader(payload, length: 33))
        case 17151: return MAV.ArrayTest1(payload: MAVLinkPayloadReader(payload, length: 16))
        case 17153: return MAV.ArrayTest3(payload: MAVLinkPayloadReader(payload, length: 17))
        case 17154: return MAV.ArrayTest4(payload: MAVLinkPayloadReader(payload, length: 17))
        case 17155: return MAV.ArrayTest5(payload: MAVLinkPayloadReader(payload, length: 10))
        case 17156: return MAV.ArrayTest6(payload: MAVLinkPayloadReader(payload, length: 91))
        case 17157: return MAV.ArrayTest7(payload: MAVLinkPayloadReader(payload, length: 84))
        case 17158: return MAV.ArrayTest8(payload: MAVLinkPayloadReader(payload, length: 24))
        case 26900: return MAV.ZvideoStreamInformation(payload: MAVLinkPayloadReader(payload, length: 246))
        case 42000: return MAV.IcarousHeartbeat(payload: MAVLinkPayloadReader(payload, length: 1))
        case 42001: return MAV.IcarousKinematicBands(payload: MAVLinkPayloadReader(payload, length: 46))
        case 50001: return MAV.CubepilotRawRc(payload: MAVLinkPayloadReader(payload, length: 32))
        case 50002: return MAV.HerelinkVideoStreamInformation(payload: MAVLinkPayloadReader(payload, length: 246))
        case 50003: return MAV.HerelinkTelem(payload: MAVLinkPayloadReader(payload, length: 19))
        case 50004: return MAV.CubepilotFirmwareUpdateStart(payload: MAVLinkPayloadReader(payload, length: 10))
        case 50005: return MAV.CubepilotFirmwareUpdateResp(payload: MAVLinkPayloadReader(payload, length: 6))
        case 52000: return MAV.AirlinkAuth(payload: MAVLinkPayloadReader(payload, length: 100))
        case 52001: return MAV.AirlinkAuthResponse(payload: MAVLinkPayloadReader(payload, length: 1))
        case 60000: return MAV.AutopilotStateForGimbalDeviceExt(payload: MAVLinkPayloadReader(payload, length: 22))
        case 60010: return MAV.Storm32GimbalManagerInformation(payload: MAVLinkPayloadReader(payload, length: 33))
        case 60011: return MAV.Storm32GimbalManagerStatus(payload: MAVLinkPayloadReader(payload, length: 7))
        case 60012: return MAV.Storm32GimbalManagerControl(payload: MAVLinkPayloadReader(payload, length: 36))
        case 60013: return MAV.Storm32GimbalManagerControlPitchyaw(payload: MAVLinkPayloadReader(payload, length: 24))
        case 60014: return MAV.Storm32GimbalManagerCorrectRoll(payload: MAVLinkPayloadReader(payload, length: 8))
        case 60020: return MAV.QshotStatus(payload: MAVLinkPayloadReader(payload, length: 4))
        case 60040: return MAV.FrskyPassthroughArray(payload: MAVLinkPayloadReader(payload, length: 245))
        case 60041: return MAV.ParamValueArray(payload: MAVLinkPayloadReader(payload, length: 255))
        case 60045: return MAV.MlrsRadioLinkStats(payload: MAVLinkPayloadReader(payload, length: 23))
        case 60046: return MAV.MlrsRadioLinkInformation(payload: MAVLinkPayloadReader(payload, length: 28))
        case 60047: return MAV.MlrsRadioLinkFlowControl(payload: MAVLinkPayloadReader(payload, length: 7))
        case 60050: return MAV.AvssPrsSysStatus(payload: MAVLinkPayloadReader(payload, length: 14))
        case 60051: return MAV.AvssDronePosition(payload: MAVLinkPayloadReader(payload, length: 24))
        case 60052: return MAV.AvssDroneImu(payload: MAVLinkPayloadReader(payload, length: 44))
        case 60053: return MAV.AvssDroneOperationMode(payload: MAVLinkPayloadReader(payload, length: 6))
        default: return nil
        }
    }
}

/// HEARTBEAT (#0)
extension MAV {
    public struct Heartbeat: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 0, name: "HEARTBEAT", crcExtra: 50, minLength: 9, length: 9)
        public var customMode: UInt32
        public var type: UInt8
        public var autopilot: UInt8
        public var baseMode: UInt8
        public var systemStatus: UInt8
        public var mavlinkVersion: UInt8

        public init(customMode: UInt32 = 0, type: UInt8 = 0, autopilot: UInt8 = 0, baseMode: UInt8 = 0, systemStatus: UInt8 = 0, mavlinkVersion: UInt8 = 0) {
            self.customMode = customMode
            self.type = type
            self.autopilot = autopilot
            self.baseMode = baseMode
            self.systemStatus = systemStatus
            self.mavlinkVersion = mavlinkVersion
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.customMode = p.uint32(0)
            self.type = p.uint8(4)
            self.autopilot = p.uint8(5)
            self.baseMode = p.uint8(6)
            self.systemStatus = p.uint8(7)
            self.mavlinkVersion = p.uint8(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.customMode, 0)
            w.put(self.type, 4)
            w.put(self.autopilot, 5)
            w.put(self.baseMode, 6)
            w.put(self.systemStatus, 7)
            w.put(self.mavlinkVersion, 8)
        }
    }
}

/// SYS_STATUS (#1)
extension MAV {
    public struct SysStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 1, name: "SYS_STATUS", crcExtra: 124, minLength: 31, length: 31)
        public var onboardControlSensorsPresent: UInt32
        public var onboardControlSensorsEnabled: UInt32
        public var onboardControlSensorsHealth: UInt32
        public var load: UInt16
        public var voltageBattery: UInt16
        public var currentBattery: Int16
        public var dropRateComm: UInt16
        public var errorsComm: UInt16
        public var errorsCount1: UInt16
        public var errorsCount2: UInt16
        public var errorsCount3: UInt16
        public var errorsCount4: UInt16
        public var batteryRemaining: Int8

        public init(onboardControlSensorsPresent: UInt32 = 0, onboardControlSensorsEnabled: UInt32 = 0, onboardControlSensorsHealth: UInt32 = 0, load: UInt16 = 0, voltageBattery: UInt16 = 0, currentBattery: Int16 = 0, dropRateComm: UInt16 = 0, errorsComm: UInt16 = 0, errorsCount1: UInt16 = 0, errorsCount2: UInt16 = 0, errorsCount3: UInt16 = 0, errorsCount4: UInt16 = 0, batteryRemaining: Int8 = 0) {
            self.onboardControlSensorsPresent = onboardControlSensorsPresent
            self.onboardControlSensorsEnabled = onboardControlSensorsEnabled
            self.onboardControlSensorsHealth = onboardControlSensorsHealth
            self.load = load
            self.voltageBattery = voltageBattery
            self.currentBattery = currentBattery
            self.dropRateComm = dropRateComm
            self.errorsComm = errorsComm
            self.errorsCount1 = errorsCount1
            self.errorsCount2 = errorsCount2
            self.errorsCount3 = errorsCount3
            self.errorsCount4 = errorsCount4
            self.batteryRemaining = batteryRemaining
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.onboardControlSensorsPresent = p.uint32(0)
            self.onboardControlSensorsEnabled = p.uint32(4)
            self.onboardControlSensorsHealth = p.uint32(8)
            self.load = p.uint16(12)
            self.voltageBattery = p.uint16(14)
            self.currentBattery = p.int16(16)
            self.dropRateComm = p.uint16(18)
            self.errorsComm = p.uint16(20)
            self.errorsCount1 = p.uint16(22)
            self.errorsCount2 = p.uint16(24)
            self.errorsCount3 = p.uint16(26)
            self.errorsCount4 = p.uint16(28)
            self.batteryRemaining = p.int8(30)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.onboardControlSensorsPresent, 0)
            w.put(self.onboardControlSensorsEnabled, 4)
            w.put(self.onboardControlSensorsHealth, 8)
            w.put(self.load, 12)
            w.put(self.voltageBattery, 14)
            w.put(self.currentBattery, 16)
            w.put(self.dropRateComm, 18)
            w.put(self.errorsComm, 20)
            w.put(self.errorsCount1, 22)
            w.put(self.errorsCount2, 24)
            w.put(self.errorsCount3, 26)
            w.put(self.errorsCount4, 28)
            w.put(self.batteryRemaining, 30)
        }
    }
}

/// SYSTEM_TIME (#2)
extension MAV {
    public struct SystemTime: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 2, name: "SYSTEM_TIME", crcExtra: 137, minLength: 12, length: 12)
        public var timeUnixUsec: UInt64
        public var timeBootMs: UInt32

        public init(timeUnixUsec: UInt64 = 0, timeBootMs: UInt32 = 0) {
            self.timeUnixUsec = timeUnixUsec
            self.timeBootMs = timeBootMs
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUnixUsec = p.uint64(0)
            self.timeBootMs = p.uint32(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUnixUsec, 0)
            w.put(self.timeBootMs, 8)
        }
    }
}

/// PING (#4)
extension MAV {
    public struct Ping: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 4, name: "PING", crcExtra: 237, minLength: 14, length: 14)
        public var timeUsec: UInt64
        public var seq: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(timeUsec: UInt64 = 0, seq: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.seq = seq
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.seq = p.uint32(8)
            self.targetSystem = p.uint8(12)
            self.targetComponent = p.uint8(13)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.seq, 8)
            w.put(self.targetSystem, 12)
            w.put(self.targetComponent, 13)
        }
    }
}

/// CHANGE_OPERATOR_CONTROL (#5)
extension MAV {
    public struct ChangeOperatorControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 5, name: "CHANGE_OPERATOR_CONTROL", crcExtra: 217, minLength: 28, length: 28)
        public var targetSystem: UInt8
        public var controlRequest: UInt8
        public var version: UInt8
        public var passkey: [UInt8]

        public init(targetSystem: UInt8 = 0, controlRequest: UInt8 = 0, version: UInt8 = 0, passkey: [UInt8] = [UInt8](repeating: 0, count: 25)) {
            self.targetSystem = targetSystem
            self.controlRequest = controlRequest
            self.version = version
            self.passkey = passkey
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.controlRequest = p.uint8(1)
            self.version = p.uint8(2)
            self.passkey = (0..<25).map { p.uint8(3 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.controlRequest, 1)
            w.put(self.version, 2)
            for k in 0..<Swift.min(25, self.passkey.count) { w.put(self.passkey[k], 3 + k * 1) }
        }
    }
}

/// CHANGE_OPERATOR_CONTROL_ACK (#6)
extension MAV {
    public struct ChangeOperatorControlAck: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 6, name: "CHANGE_OPERATOR_CONTROL_ACK", crcExtra: 104, minLength: 3, length: 3)
        public var gcsSystemId: UInt8
        public var controlRequest: UInt8
        public var ack: UInt8

        public init(gcsSystemId: UInt8 = 0, controlRequest: UInt8 = 0, ack: UInt8 = 0) {
            self.gcsSystemId = gcsSystemId
            self.controlRequest = controlRequest
            self.ack = ack
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.gcsSystemId = p.uint8(0)
            self.controlRequest = p.uint8(1)
            self.ack = p.uint8(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.gcsSystemId, 0)
            w.put(self.controlRequest, 1)
            w.put(self.ack, 2)
        }
    }
}

/// AUTH_KEY (#7)
extension MAV {
    public struct AuthKey: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 7, name: "AUTH_KEY", crcExtra: 119, minLength: 32, length: 32)
        public var key: [UInt8]

        public init(key: [UInt8] = [UInt8](repeating: 0, count: 32)) {
            self.key = key
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.key = (0..<32).map { p.uint8(0 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(32, self.key.count) { w.put(self.key[k], 0 + k * 1) }
        }
    }
}

/// SET_MODE (#11)
extension MAV {
    public struct SetMode: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11, name: "SET_MODE", crcExtra: 89, minLength: 6, length: 6)
        public var customMode: UInt32
        public var targetSystem: UInt8
        public var baseMode: UInt8

        public init(customMode: UInt32 = 0, targetSystem: UInt8 = 0, baseMode: UInt8 = 0) {
            self.customMode = customMode
            self.targetSystem = targetSystem
            self.baseMode = baseMode
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.customMode = p.uint32(0)
            self.targetSystem = p.uint8(4)
            self.baseMode = p.uint8(5)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.customMode, 0)
            w.put(self.targetSystem, 4)
            w.put(self.baseMode, 5)
        }
    }
}

/// PARAM_REQUEST_READ (#20)
extension MAV {
    public struct ParamRequestRead: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 20, name: "PARAM_REQUEST_READ", crcExtra: 214, minLength: 20, length: 20)
        public var paramIndex: Int16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var paramId: [UInt8]

        public init(paramIndex: Int16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, paramId: [UInt8] = [UInt8](repeating: 0, count: 16)) {
            self.paramIndex = paramIndex
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.paramId = paramId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.paramIndex = p.int16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
            self.paramId = (0..<16).map { p.uint8(4 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.paramIndex, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
            for k in 0..<Swift.min(16, self.paramId.count) { w.put(self.paramId[k], 4 + k * 1) }
        }
    }
}

/// PARAM_REQUEST_LIST (#21)
extension MAV {
    public struct ParamRequestList: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 21, name: "PARAM_REQUEST_LIST", crcExtra: 159, minLength: 2, length: 2)
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
        }
    }
}

/// PARAM_VALUE (#22)
extension MAV {
    public struct ParamValue: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 22, name: "PARAM_VALUE", crcExtra: 220, minLength: 25, length: 25)
        public var paramValue: Float
        public var paramCount: UInt16
        public var paramIndex: UInt16
        public var paramId: [UInt8]
        public var paramType: UInt8

        public init(paramValue: Float = 0, paramCount: UInt16 = 0, paramIndex: UInt16 = 0, paramId: [UInt8] = [UInt8](repeating: 0, count: 16), paramType: UInt8 = 0) {
            self.paramValue = paramValue
            self.paramCount = paramCount
            self.paramIndex = paramIndex
            self.paramId = paramId
            self.paramType = paramType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.paramValue = p.float(0)
            self.paramCount = p.uint16(4)
            self.paramIndex = p.uint16(6)
            self.paramId = (0..<16).map { p.uint8(8 + $0 * 1) }
            self.paramType = p.uint8(24)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.paramValue, 0)
            w.put(self.paramCount, 4)
            w.put(self.paramIndex, 6)
            for k in 0..<Swift.min(16, self.paramId.count) { w.put(self.paramId[k], 8 + k * 1) }
            w.put(self.paramType, 24)
        }
    }
}

/// PARAM_SET (#23)
extension MAV {
    public struct ParamSet: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 23, name: "PARAM_SET", crcExtra: 168, minLength: 23, length: 23)
        public var paramValue: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var paramId: [UInt8]
        public var paramType: UInt8

        public init(paramValue: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, paramId: [UInt8] = [UInt8](repeating: 0, count: 16), paramType: UInt8 = 0) {
            self.paramValue = paramValue
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.paramId = paramId
            self.paramType = paramType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.paramValue = p.float(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.paramId = (0..<16).map { p.uint8(6 + $0 * 1) }
            self.paramType = p.uint8(22)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.paramValue, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            for k in 0..<Swift.min(16, self.paramId.count) { w.put(self.paramId[k], 6 + k * 1) }
            w.put(self.paramType, 22)
        }
    }
}

/// GPS_RAW_INT (#24)
extension MAV {
    public struct GpsRawInt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 24, name: "GPS_RAW_INT", crcExtra: 24, minLength: 30, length: 52)
        public var timeUsec: UInt64
        public var lat: Int32
        public var lon: Int32
        public var alt: Int32
        public var eph: UInt16
        public var epv: UInt16
        public var vel: UInt16
        public var cog: UInt16
        public var fixType: UInt8
        public var satellitesVisible: UInt8
        public var altEllipsoid: Int32  // extension field
        public var hAcc: UInt32  // extension field
        public var vAcc: UInt32  // extension field
        public var velAcc: UInt32  // extension field
        public var hdgAcc: UInt32  // extension field
        public var yaw: UInt16  // extension field

        public init(timeUsec: UInt64 = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Int32 = 0, eph: UInt16 = 0, epv: UInt16 = 0, vel: UInt16 = 0, cog: UInt16 = 0, fixType: UInt8 = 0, satellitesVisible: UInt8 = 0, altEllipsoid: Int32 = 0, hAcc: UInt32 = 0, vAcc: UInt32 = 0, velAcc: UInt32 = 0, hdgAcc: UInt32 = 0, yaw: UInt16 = 0) {
            self.timeUsec = timeUsec
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.eph = eph
            self.epv = epv
            self.vel = vel
            self.cog = cog
            self.fixType = fixType
            self.satellitesVisible = satellitesVisible
            self.altEllipsoid = altEllipsoid
            self.hAcc = hAcc
            self.vAcc = vAcc
            self.velAcc = velAcc
            self.hdgAcc = hdgAcc
            self.yaw = yaw
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.lat = p.int32(8)
            self.lon = p.int32(12)
            self.alt = p.int32(16)
            self.eph = p.uint16(20)
            self.epv = p.uint16(22)
            self.vel = p.uint16(24)
            self.cog = p.uint16(26)
            self.fixType = p.uint8(28)
            self.satellitesVisible = p.uint8(29)
            self.altEllipsoid = p.int32(30)
            self.hAcc = p.uint32(34)
            self.vAcc = p.uint32(38)
            self.velAcc = p.uint32(42)
            self.hdgAcc = p.uint32(46)
            self.yaw = p.uint16(50)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.lat, 8)
            w.put(self.lon, 12)
            w.put(self.alt, 16)
            w.put(self.eph, 20)
            w.put(self.epv, 22)
            w.put(self.vel, 24)
            w.put(self.cog, 26)
            w.put(self.fixType, 28)
            w.put(self.satellitesVisible, 29)
            w.put(self.altEllipsoid, 30)
            w.put(self.hAcc, 34)
            w.put(self.vAcc, 38)
            w.put(self.velAcc, 42)
            w.put(self.hdgAcc, 46)
            w.put(self.yaw, 50)
        }
    }
}

/// GPS_STATUS (#25)
extension MAV {
    public struct GpsStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 25, name: "GPS_STATUS", crcExtra: 23, minLength: 101, length: 101)
        public var satellitesVisible: UInt8
        public var satellitePrn: [UInt8]
        public var satelliteUsed: [UInt8]
        public var satelliteElevation: [UInt8]
        public var satelliteAzimuth: [UInt8]
        public var satelliteSnr: [UInt8]

        public init(satellitesVisible: UInt8 = 0, satellitePrn: [UInt8] = [UInt8](repeating: 0, count: 20), satelliteUsed: [UInt8] = [UInt8](repeating: 0, count: 20), satelliteElevation: [UInt8] = [UInt8](repeating: 0, count: 20), satelliteAzimuth: [UInt8] = [UInt8](repeating: 0, count: 20), satelliteSnr: [UInt8] = [UInt8](repeating: 0, count: 20)) {
            self.satellitesVisible = satellitesVisible
            self.satellitePrn = satellitePrn
            self.satelliteUsed = satelliteUsed
            self.satelliteElevation = satelliteElevation
            self.satelliteAzimuth = satelliteAzimuth
            self.satelliteSnr = satelliteSnr
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.satellitesVisible = p.uint8(0)
            self.satellitePrn = (0..<20).map { p.uint8(1 + $0 * 1) }
            self.satelliteUsed = (0..<20).map { p.uint8(21 + $0 * 1) }
            self.satelliteElevation = (0..<20).map { p.uint8(41 + $0 * 1) }
            self.satelliteAzimuth = (0..<20).map { p.uint8(61 + $0 * 1) }
            self.satelliteSnr = (0..<20).map { p.uint8(81 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.satellitesVisible, 0)
            for k in 0..<Swift.min(20, self.satellitePrn.count) { w.put(self.satellitePrn[k], 1 + k * 1) }
            for k in 0..<Swift.min(20, self.satelliteUsed.count) { w.put(self.satelliteUsed[k], 21 + k * 1) }
            for k in 0..<Swift.min(20, self.satelliteElevation.count) { w.put(self.satelliteElevation[k], 41 + k * 1) }
            for k in 0..<Swift.min(20, self.satelliteAzimuth.count) { w.put(self.satelliteAzimuth[k], 61 + k * 1) }
            for k in 0..<Swift.min(20, self.satelliteSnr.count) { w.put(self.satelliteSnr[k], 81 + k * 1) }
        }
    }
}

/// SCALED_IMU (#26)
extension MAV {
    public struct ScaledImu: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 26, name: "SCALED_IMU", crcExtra: 170, minLength: 22, length: 24)
        public var timeBootMs: UInt32
        public var xacc: Int16
        public var yacc: Int16
        public var zacc: Int16
        public var xgyro: Int16
        public var ygyro: Int16
        public var zgyro: Int16
        public var xmag: Int16
        public var ymag: Int16
        public var zmag: Int16
        public var temperature: Int16  // extension field

        public init(timeBootMs: UInt32 = 0, xacc: Int16 = 0, yacc: Int16 = 0, zacc: Int16 = 0, xgyro: Int16 = 0, ygyro: Int16 = 0, zgyro: Int16 = 0, xmag: Int16 = 0, ymag: Int16 = 0, zmag: Int16 = 0, temperature: Int16 = 0) {
            self.timeBootMs = timeBootMs
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
            self.xgyro = xgyro
            self.ygyro = ygyro
            self.zgyro = zgyro
            self.xmag = xmag
            self.ymag = ymag
            self.zmag = zmag
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.xacc = p.int16(4)
            self.yacc = p.int16(6)
            self.zacc = p.int16(8)
            self.xgyro = p.int16(10)
            self.ygyro = p.int16(12)
            self.zgyro = p.int16(14)
            self.xmag = p.int16(16)
            self.ymag = p.int16(18)
            self.zmag = p.int16(20)
            self.temperature = p.int16(22)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.xacc, 4)
            w.put(self.yacc, 6)
            w.put(self.zacc, 8)
            w.put(self.xgyro, 10)
            w.put(self.ygyro, 12)
            w.put(self.zgyro, 14)
            w.put(self.xmag, 16)
            w.put(self.ymag, 18)
            w.put(self.zmag, 20)
            w.put(self.temperature, 22)
        }
    }
}

/// RAW_IMU (#27)
extension MAV {
    public struct RawImu: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 27, name: "RAW_IMU", crcExtra: 144, minLength: 26, length: 29)
        public var timeUsec: UInt64
        public var xacc: Int16
        public var yacc: Int16
        public var zacc: Int16
        public var xgyro: Int16
        public var ygyro: Int16
        public var zgyro: Int16
        public var xmag: Int16
        public var ymag: Int16
        public var zmag: Int16
        public var id: UInt8  // extension field
        public var temperature: Int16  // extension field

        public init(timeUsec: UInt64 = 0, xacc: Int16 = 0, yacc: Int16 = 0, zacc: Int16 = 0, xgyro: Int16 = 0, ygyro: Int16 = 0, zgyro: Int16 = 0, xmag: Int16 = 0, ymag: Int16 = 0, zmag: Int16 = 0, id: UInt8 = 0, temperature: Int16 = 0) {
            self.timeUsec = timeUsec
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
            self.xgyro = xgyro
            self.ygyro = ygyro
            self.zgyro = zgyro
            self.xmag = xmag
            self.ymag = ymag
            self.zmag = zmag
            self.id = id
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.xacc = p.int16(8)
            self.yacc = p.int16(10)
            self.zacc = p.int16(12)
            self.xgyro = p.int16(14)
            self.ygyro = p.int16(16)
            self.zgyro = p.int16(18)
            self.xmag = p.int16(20)
            self.ymag = p.int16(22)
            self.zmag = p.int16(24)
            self.id = p.uint8(26)
            self.temperature = p.int16(27)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.xacc, 8)
            w.put(self.yacc, 10)
            w.put(self.zacc, 12)
            w.put(self.xgyro, 14)
            w.put(self.ygyro, 16)
            w.put(self.zgyro, 18)
            w.put(self.xmag, 20)
            w.put(self.ymag, 22)
            w.put(self.zmag, 24)
            w.put(self.id, 26)
            w.put(self.temperature, 27)
        }
    }
}

/// RAW_PRESSURE (#28)
extension MAV {
    public struct RawPressure: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 28, name: "RAW_PRESSURE", crcExtra: 67, minLength: 16, length: 16)
        public var timeUsec: UInt64
        public var pressAbs: Int16
        public var pressDiff1: Int16
        public var pressDiff2: Int16
        public var temperature: Int16

        public init(timeUsec: UInt64 = 0, pressAbs: Int16 = 0, pressDiff1: Int16 = 0, pressDiff2: Int16 = 0, temperature: Int16 = 0) {
            self.timeUsec = timeUsec
            self.pressAbs = pressAbs
            self.pressDiff1 = pressDiff1
            self.pressDiff2 = pressDiff2
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.pressAbs = p.int16(8)
            self.pressDiff1 = p.int16(10)
            self.pressDiff2 = p.int16(12)
            self.temperature = p.int16(14)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.pressAbs, 8)
            w.put(self.pressDiff1, 10)
            w.put(self.pressDiff2, 12)
            w.put(self.temperature, 14)
        }
    }
}

/// SCALED_PRESSURE (#29)
extension MAV {
    public struct ScaledPressure: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 29, name: "SCALED_PRESSURE", crcExtra: 115, minLength: 14, length: 16)
        public var timeBootMs: UInt32
        public var pressAbs: Float
        public var pressDiff: Float
        public var temperature: Int16
        public var temperaturePressDiff: Int16  // extension field

        public init(timeBootMs: UInt32 = 0, pressAbs: Float = 0, pressDiff: Float = 0, temperature: Int16 = 0, temperaturePressDiff: Int16 = 0) {
            self.timeBootMs = timeBootMs
            self.pressAbs = pressAbs
            self.pressDiff = pressDiff
            self.temperature = temperature
            self.temperaturePressDiff = temperaturePressDiff
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.pressAbs = p.float(4)
            self.pressDiff = p.float(8)
            self.temperature = p.int16(12)
            self.temperaturePressDiff = p.int16(14)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.pressAbs, 4)
            w.put(self.pressDiff, 8)
            w.put(self.temperature, 12)
            w.put(self.temperaturePressDiff, 14)
        }
    }
}

/// ATTITUDE (#30)
extension MAV {
    public struct Attitude: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 30, name: "ATTITUDE", crcExtra: 39, minLength: 28, length: 28)
        public var timeBootMs: UInt32
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var rollspeed: Float
        public var pitchspeed: Float
        public var yawspeed: Float

        public init(timeBootMs: UInt32 = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0, rollspeed: Float = 0, pitchspeed: Float = 0, yawspeed: Float = 0) {
            self.timeBootMs = timeBootMs
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.rollspeed = rollspeed
            self.pitchspeed = pitchspeed
            self.yawspeed = yawspeed
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.roll = p.float(4)
            self.pitch = p.float(8)
            self.yaw = p.float(12)
            self.rollspeed = p.float(16)
            self.pitchspeed = p.float(20)
            self.yawspeed = p.float(24)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.roll, 4)
            w.put(self.pitch, 8)
            w.put(self.yaw, 12)
            w.put(self.rollspeed, 16)
            w.put(self.pitchspeed, 20)
            w.put(self.yawspeed, 24)
        }
    }
}

/// ATTITUDE_QUATERNION (#31)
extension MAV {
    public struct AttitudeQuaternion: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 31, name: "ATTITUDE_QUATERNION", crcExtra: 246, minLength: 32, length: 48)
        public var timeBootMs: UInt32
        public var q1: Float
        public var q2: Float
        public var q3: Float
        public var q4: Float
        public var rollspeed: Float
        public var pitchspeed: Float
        public var yawspeed: Float
        public var reprOffsetQ: [Float]  // extension field

        public init(timeBootMs: UInt32 = 0, q1: Float = 0, q2: Float = 0, q3: Float = 0, q4: Float = 0, rollspeed: Float = 0, pitchspeed: Float = 0, yawspeed: Float = 0, reprOffsetQ: [Float] = [Float](repeating: 0, count: 4)) {
            self.timeBootMs = timeBootMs
            self.q1 = q1
            self.q2 = q2
            self.q3 = q3
            self.q4 = q4
            self.rollspeed = rollspeed
            self.pitchspeed = pitchspeed
            self.yawspeed = yawspeed
            self.reprOffsetQ = reprOffsetQ
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.q1 = p.float(4)
            self.q2 = p.float(8)
            self.q3 = p.float(12)
            self.q4 = p.float(16)
            self.rollspeed = p.float(20)
            self.pitchspeed = p.float(24)
            self.yawspeed = p.float(28)
            self.reprOffsetQ = (0..<4).map { p.float(32 + $0 * 4) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.q1, 4)
            w.put(self.q2, 8)
            w.put(self.q3, 12)
            w.put(self.q4, 16)
            w.put(self.rollspeed, 20)
            w.put(self.pitchspeed, 24)
            w.put(self.yawspeed, 28)
            for k in 0..<Swift.min(4, self.reprOffsetQ.count) { w.put(self.reprOffsetQ[k], 32 + k * 4) }
        }
    }
}

/// LOCAL_POSITION_NED (#32)
extension MAV {
    public struct LocalPositionNed: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 32, name: "LOCAL_POSITION_NED", crcExtra: 185, minLength: 28, length: 28)
        public var timeBootMs: UInt32
        public var x: Float
        public var y: Float
        public var z: Float
        public var vx: Float
        public var vy: Float
        public var vz: Float

        public init(timeBootMs: UInt32 = 0, x: Float = 0, y: Float = 0, z: Float = 0, vx: Float = 0, vy: Float = 0, vz: Float = 0) {
            self.timeBootMs = timeBootMs
            self.x = x
            self.y = y
            self.z = z
            self.vx = vx
            self.vy = vy
            self.vz = vz
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.x = p.float(4)
            self.y = p.float(8)
            self.z = p.float(12)
            self.vx = p.float(16)
            self.vy = p.float(20)
            self.vz = p.float(24)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.x, 4)
            w.put(self.y, 8)
            w.put(self.z, 12)
            w.put(self.vx, 16)
            w.put(self.vy, 20)
            w.put(self.vz, 24)
        }
    }
}

/// GLOBAL_POSITION_INT (#33)
extension MAV {
    public struct GlobalPositionInt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 33, name: "GLOBAL_POSITION_INT", crcExtra: 104, minLength: 28, length: 28)
        public var timeBootMs: UInt32
        public var lat: Int32
        public var lon: Int32
        public var alt: Int32
        public var relativeAlt: Int32
        public var vx: Int16
        public var vy: Int16
        public var vz: Int16
        public var hdg: UInt16

        public init(timeBootMs: UInt32 = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Int32 = 0, relativeAlt: Int32 = 0, vx: Int16 = 0, vy: Int16 = 0, vz: Int16 = 0, hdg: UInt16 = 0) {
            self.timeBootMs = timeBootMs
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.relativeAlt = relativeAlt
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.hdg = hdg
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.lat = p.int32(4)
            self.lon = p.int32(8)
            self.alt = p.int32(12)
            self.relativeAlt = p.int32(16)
            self.vx = p.int16(20)
            self.vy = p.int16(22)
            self.vz = p.int16(24)
            self.hdg = p.uint16(26)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.lat, 4)
            w.put(self.lon, 8)
            w.put(self.alt, 12)
            w.put(self.relativeAlt, 16)
            w.put(self.vx, 20)
            w.put(self.vy, 22)
            w.put(self.vz, 24)
            w.put(self.hdg, 26)
        }
    }
}

/// RC_CHANNELS_SCALED (#34)
extension MAV {
    public struct RcChannelsScaled: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 34, name: "RC_CHANNELS_SCALED", crcExtra: 237, minLength: 22, length: 22)
        public var timeBootMs: UInt32
        public var chan1Scaled: Int16
        public var chan2Scaled: Int16
        public var chan3Scaled: Int16
        public var chan4Scaled: Int16
        public var chan5Scaled: Int16
        public var chan6Scaled: Int16
        public var chan7Scaled: Int16
        public var chan8Scaled: Int16
        public var port: UInt8
        public var rssi: UInt8

        public init(timeBootMs: UInt32 = 0, chan1Scaled: Int16 = 0, chan2Scaled: Int16 = 0, chan3Scaled: Int16 = 0, chan4Scaled: Int16 = 0, chan5Scaled: Int16 = 0, chan6Scaled: Int16 = 0, chan7Scaled: Int16 = 0, chan8Scaled: Int16 = 0, port: UInt8 = 0, rssi: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.chan1Scaled = chan1Scaled
            self.chan2Scaled = chan2Scaled
            self.chan3Scaled = chan3Scaled
            self.chan4Scaled = chan4Scaled
            self.chan5Scaled = chan5Scaled
            self.chan6Scaled = chan6Scaled
            self.chan7Scaled = chan7Scaled
            self.chan8Scaled = chan8Scaled
            self.port = port
            self.rssi = rssi
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.chan1Scaled = p.int16(4)
            self.chan2Scaled = p.int16(6)
            self.chan3Scaled = p.int16(8)
            self.chan4Scaled = p.int16(10)
            self.chan5Scaled = p.int16(12)
            self.chan6Scaled = p.int16(14)
            self.chan7Scaled = p.int16(16)
            self.chan8Scaled = p.int16(18)
            self.port = p.uint8(20)
            self.rssi = p.uint8(21)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.chan1Scaled, 4)
            w.put(self.chan2Scaled, 6)
            w.put(self.chan3Scaled, 8)
            w.put(self.chan4Scaled, 10)
            w.put(self.chan5Scaled, 12)
            w.put(self.chan6Scaled, 14)
            w.put(self.chan7Scaled, 16)
            w.put(self.chan8Scaled, 18)
            w.put(self.port, 20)
            w.put(self.rssi, 21)
        }
    }
}

/// RC_CHANNELS_RAW (#35)
extension MAV {
    public struct RcChannelsRaw: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 35, name: "RC_CHANNELS_RAW", crcExtra: 244, minLength: 22, length: 22)
        public var timeBootMs: UInt32
        public var chan1Raw: UInt16
        public var chan2Raw: UInt16
        public var chan3Raw: UInt16
        public var chan4Raw: UInt16
        public var chan5Raw: UInt16
        public var chan6Raw: UInt16
        public var chan7Raw: UInt16
        public var chan8Raw: UInt16
        public var port: UInt8
        public var rssi: UInt8

        public init(timeBootMs: UInt32 = 0, chan1Raw: UInt16 = 0, chan2Raw: UInt16 = 0, chan3Raw: UInt16 = 0, chan4Raw: UInt16 = 0, chan5Raw: UInt16 = 0, chan6Raw: UInt16 = 0, chan7Raw: UInt16 = 0, chan8Raw: UInt16 = 0, port: UInt8 = 0, rssi: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.chan1Raw = chan1Raw
            self.chan2Raw = chan2Raw
            self.chan3Raw = chan3Raw
            self.chan4Raw = chan4Raw
            self.chan5Raw = chan5Raw
            self.chan6Raw = chan6Raw
            self.chan7Raw = chan7Raw
            self.chan8Raw = chan8Raw
            self.port = port
            self.rssi = rssi
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.chan1Raw = p.uint16(4)
            self.chan2Raw = p.uint16(6)
            self.chan3Raw = p.uint16(8)
            self.chan4Raw = p.uint16(10)
            self.chan5Raw = p.uint16(12)
            self.chan6Raw = p.uint16(14)
            self.chan7Raw = p.uint16(16)
            self.chan8Raw = p.uint16(18)
            self.port = p.uint8(20)
            self.rssi = p.uint8(21)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.chan1Raw, 4)
            w.put(self.chan2Raw, 6)
            w.put(self.chan3Raw, 8)
            w.put(self.chan4Raw, 10)
            w.put(self.chan5Raw, 12)
            w.put(self.chan6Raw, 14)
            w.put(self.chan7Raw, 16)
            w.put(self.chan8Raw, 18)
            w.put(self.port, 20)
            w.put(self.rssi, 21)
        }
    }
}

/// SERVO_OUTPUT_RAW (#36)
extension MAV {
    public struct ServoOutputRaw: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 36, name: "SERVO_OUTPUT_RAW", crcExtra: 222, minLength: 21, length: 37)
        public var timeUsec: UInt32
        public var servo1Raw: UInt16
        public var servo2Raw: UInt16
        public var servo3Raw: UInt16
        public var servo4Raw: UInt16
        public var servo5Raw: UInt16
        public var servo6Raw: UInt16
        public var servo7Raw: UInt16
        public var servo8Raw: UInt16
        public var port: UInt8
        public var servo9Raw: UInt16  // extension field
        public var servo10Raw: UInt16  // extension field
        public var servo11Raw: UInt16  // extension field
        public var servo12Raw: UInt16  // extension field
        public var servo13Raw: UInt16  // extension field
        public var servo14Raw: UInt16  // extension field
        public var servo15Raw: UInt16  // extension field
        public var servo16Raw: UInt16  // extension field

        public init(timeUsec: UInt32 = 0, servo1Raw: UInt16 = 0, servo2Raw: UInt16 = 0, servo3Raw: UInt16 = 0, servo4Raw: UInt16 = 0, servo5Raw: UInt16 = 0, servo6Raw: UInt16 = 0, servo7Raw: UInt16 = 0, servo8Raw: UInt16 = 0, port: UInt8 = 0, servo9Raw: UInt16 = 0, servo10Raw: UInt16 = 0, servo11Raw: UInt16 = 0, servo12Raw: UInt16 = 0, servo13Raw: UInt16 = 0, servo14Raw: UInt16 = 0, servo15Raw: UInt16 = 0, servo16Raw: UInt16 = 0) {
            self.timeUsec = timeUsec
            self.servo1Raw = servo1Raw
            self.servo2Raw = servo2Raw
            self.servo3Raw = servo3Raw
            self.servo4Raw = servo4Raw
            self.servo5Raw = servo5Raw
            self.servo6Raw = servo6Raw
            self.servo7Raw = servo7Raw
            self.servo8Raw = servo8Raw
            self.port = port
            self.servo9Raw = servo9Raw
            self.servo10Raw = servo10Raw
            self.servo11Raw = servo11Raw
            self.servo12Raw = servo12Raw
            self.servo13Raw = servo13Raw
            self.servo14Raw = servo14Raw
            self.servo15Raw = servo15Raw
            self.servo16Raw = servo16Raw
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint32(0)
            self.servo1Raw = p.uint16(4)
            self.servo2Raw = p.uint16(6)
            self.servo3Raw = p.uint16(8)
            self.servo4Raw = p.uint16(10)
            self.servo5Raw = p.uint16(12)
            self.servo6Raw = p.uint16(14)
            self.servo7Raw = p.uint16(16)
            self.servo8Raw = p.uint16(18)
            self.port = p.uint8(20)
            self.servo9Raw = p.uint16(21)
            self.servo10Raw = p.uint16(23)
            self.servo11Raw = p.uint16(25)
            self.servo12Raw = p.uint16(27)
            self.servo13Raw = p.uint16(29)
            self.servo14Raw = p.uint16(31)
            self.servo15Raw = p.uint16(33)
            self.servo16Raw = p.uint16(35)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.servo1Raw, 4)
            w.put(self.servo2Raw, 6)
            w.put(self.servo3Raw, 8)
            w.put(self.servo4Raw, 10)
            w.put(self.servo5Raw, 12)
            w.put(self.servo6Raw, 14)
            w.put(self.servo7Raw, 16)
            w.put(self.servo8Raw, 18)
            w.put(self.port, 20)
            w.put(self.servo9Raw, 21)
            w.put(self.servo10Raw, 23)
            w.put(self.servo11Raw, 25)
            w.put(self.servo12Raw, 27)
            w.put(self.servo13Raw, 29)
            w.put(self.servo14Raw, 31)
            w.put(self.servo15Raw, 33)
            w.put(self.servo16Raw, 35)
        }
    }
}

/// MISSION_REQUEST_PARTIAL_LIST (#37)
extension MAV {
    public struct MissionRequestPartialList: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 37, name: "MISSION_REQUEST_PARTIAL_LIST", crcExtra: 212, minLength: 6, length: 7)
        public var startIndex: Int16
        public var endIndex: Int16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var missionType: UInt8  // extension field

        public init(startIndex: Int16 = 0, endIndex: Int16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, missionType: UInt8 = 0) {
            self.startIndex = startIndex
            self.endIndex = endIndex
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.startIndex = p.int16(0)
            self.endIndex = p.int16(2)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.missionType = p.uint8(6)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.startIndex, 0)
            w.put(self.endIndex, 2)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            w.put(self.missionType, 6)
        }
    }
}

/// MISSION_WRITE_PARTIAL_LIST (#38)
extension MAV {
    public struct MissionWritePartialList: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 38, name: "MISSION_WRITE_PARTIAL_LIST", crcExtra: 9, minLength: 6, length: 7)
        public var startIndex: Int16
        public var endIndex: Int16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var missionType: UInt8  // extension field

        public init(startIndex: Int16 = 0, endIndex: Int16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, missionType: UInt8 = 0) {
            self.startIndex = startIndex
            self.endIndex = endIndex
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.startIndex = p.int16(0)
            self.endIndex = p.int16(2)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.missionType = p.uint8(6)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.startIndex, 0)
            w.put(self.endIndex, 2)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            w.put(self.missionType, 6)
        }
    }
}

/// MISSION_ITEM (#39)
extension MAV {
    public struct MissionItem: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 39, name: "MISSION_ITEM", crcExtra: 254, minLength: 37, length: 38)
        public var param1: Float
        public var param2: Float
        public var param3: Float
        public var param4: Float
        public var x: Float
        public var y: Float
        public var z: Float
        public var seq: UInt16
        public var command: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var frame: UInt8
        public var current: UInt8
        public var autocontinue: UInt8
        public var missionType: UInt8  // extension field

        public init(param1: Float = 0, param2: Float = 0, param3: Float = 0, param4: Float = 0, x: Float = 0, y: Float = 0, z: Float = 0, seq: UInt16 = 0, command: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, frame: UInt8 = 0, current: UInt8 = 0, autocontinue: UInt8 = 0, missionType: UInt8 = 0) {
            self.param1 = param1
            self.param2 = param2
            self.param3 = param3
            self.param4 = param4
            self.x = x
            self.y = y
            self.z = z
            self.seq = seq
            self.command = command
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.frame = frame
            self.current = current
            self.autocontinue = autocontinue
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.param1 = p.float(0)
            self.param2 = p.float(4)
            self.param3 = p.float(8)
            self.param4 = p.float(12)
            self.x = p.float(16)
            self.y = p.float(20)
            self.z = p.float(24)
            self.seq = p.uint16(28)
            self.command = p.uint16(30)
            self.targetSystem = p.uint8(32)
            self.targetComponent = p.uint8(33)
            self.frame = p.uint8(34)
            self.current = p.uint8(35)
            self.autocontinue = p.uint8(36)
            self.missionType = p.uint8(37)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.param1, 0)
            w.put(self.param2, 4)
            w.put(self.param3, 8)
            w.put(self.param4, 12)
            w.put(self.x, 16)
            w.put(self.y, 20)
            w.put(self.z, 24)
            w.put(self.seq, 28)
            w.put(self.command, 30)
            w.put(self.targetSystem, 32)
            w.put(self.targetComponent, 33)
            w.put(self.frame, 34)
            w.put(self.current, 35)
            w.put(self.autocontinue, 36)
            w.put(self.missionType, 37)
        }
    }
}

/// MISSION_REQUEST (#40)
extension MAV {
    public struct MissionRequest: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 40, name: "MISSION_REQUEST", crcExtra: 230, minLength: 4, length: 5)
        public var seq: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var missionType: UInt8  // extension field

        public init(seq: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, missionType: UInt8 = 0) {
            self.seq = seq
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.seq = p.uint16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
            self.missionType = p.uint8(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.seq, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
            w.put(self.missionType, 4)
        }
    }
}

/// MISSION_SET_CURRENT (#41)
extension MAV {
    public struct MissionSetCurrent: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 41, name: "MISSION_SET_CURRENT", crcExtra: 28, minLength: 4, length: 4)
        public var seq: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(seq: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.seq = seq
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.seq = p.uint16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.seq, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
        }
    }
}

/// MISSION_CURRENT (#42)
extension MAV {
    public struct MissionCurrent: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 42, name: "MISSION_CURRENT", crcExtra: 28, minLength: 2, length: 6)
        public var seq: UInt16
        public var total: UInt16  // extension field
        public var missionState: UInt8  // extension field
        public var missionMode: UInt8  // extension field

        public init(seq: UInt16 = 0, total: UInt16 = 0, missionState: UInt8 = 0, missionMode: UInt8 = 0) {
            self.seq = seq
            self.total = total
            self.missionState = missionState
            self.missionMode = missionMode
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.seq = p.uint16(0)
            self.total = p.uint16(2)
            self.missionState = p.uint8(4)
            self.missionMode = p.uint8(5)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.seq, 0)
            w.put(self.total, 2)
            w.put(self.missionState, 4)
            w.put(self.missionMode, 5)
        }
    }
}

/// MISSION_REQUEST_LIST (#43)
extension MAV {
    public struct MissionRequestList: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 43, name: "MISSION_REQUEST_LIST", crcExtra: 132, minLength: 2, length: 3)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var missionType: UInt8  // extension field

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, missionType: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.missionType = p.uint8(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            w.put(self.missionType, 2)
        }
    }
}

/// MISSION_COUNT (#44)
extension MAV {
    public struct MissionCount: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 44, name: "MISSION_COUNT", crcExtra: 221, minLength: 4, length: 5)
        public var count: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var missionType: UInt8  // extension field

        public init(count: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, missionType: UInt8 = 0) {
            self.count = count
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.count = p.uint16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
            self.missionType = p.uint8(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.count, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
            w.put(self.missionType, 4)
        }
    }
}

/// MISSION_CLEAR_ALL (#45)
extension MAV {
    public struct MissionClearAll: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 45, name: "MISSION_CLEAR_ALL", crcExtra: 232, minLength: 2, length: 3)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var missionType: UInt8  // extension field

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, missionType: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.missionType = p.uint8(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            w.put(self.missionType, 2)
        }
    }
}

/// MISSION_ITEM_REACHED (#46)
extension MAV {
    public struct MissionItemReached: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 46, name: "MISSION_ITEM_REACHED", crcExtra: 11, minLength: 2, length: 2)
        public var seq: UInt16

        public init(seq: UInt16 = 0) {
            self.seq = seq
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.seq = p.uint16(0)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.seq, 0)
        }
    }
}

/// MISSION_ACK (#47)
extension MAV {
    public struct MissionAck: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 47, name: "MISSION_ACK", crcExtra: 153, minLength: 3, length: 4)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var type: UInt8
        public var missionType: UInt8  // extension field

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, type: UInt8 = 0, missionType: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.type = type
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.type = p.uint8(2)
            self.missionType = p.uint8(3)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            w.put(self.type, 2)
            w.put(self.missionType, 3)
        }
    }
}

/// SET_GPS_GLOBAL_ORIGIN (#48)
extension MAV {
    public struct SetGpsGlobalOrigin: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 48, name: "SET_GPS_GLOBAL_ORIGIN", crcExtra: 41, minLength: 13, length: 21)
        public var latitude: Int32
        public var longitude: Int32
        public var altitude: Int32
        public var targetSystem: UInt8
        public var timeUsec: UInt64  // extension field

        public init(latitude: Int32 = 0, longitude: Int32 = 0, altitude: Int32 = 0, targetSystem: UInt8 = 0, timeUsec: UInt64 = 0) {
            self.latitude = latitude
            self.longitude = longitude
            self.altitude = altitude
            self.targetSystem = targetSystem
            self.timeUsec = timeUsec
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.latitude = p.int32(0)
            self.longitude = p.int32(4)
            self.altitude = p.int32(8)
            self.targetSystem = p.uint8(12)
            self.timeUsec = p.uint64(13)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.latitude, 0)
            w.put(self.longitude, 4)
            w.put(self.altitude, 8)
            w.put(self.targetSystem, 12)
            w.put(self.timeUsec, 13)
        }
    }
}

/// GPS_GLOBAL_ORIGIN (#49)
extension MAV {
    public struct GpsGlobalOrigin: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 49, name: "GPS_GLOBAL_ORIGIN", crcExtra: 39, minLength: 12, length: 20)
        public var latitude: Int32
        public var longitude: Int32
        public var altitude: Int32
        public var timeUsec: UInt64  // extension field

        public init(latitude: Int32 = 0, longitude: Int32 = 0, altitude: Int32 = 0, timeUsec: UInt64 = 0) {
            self.latitude = latitude
            self.longitude = longitude
            self.altitude = altitude
            self.timeUsec = timeUsec
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.latitude = p.int32(0)
            self.longitude = p.int32(4)
            self.altitude = p.int32(8)
            self.timeUsec = p.uint64(12)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.latitude, 0)
            w.put(self.longitude, 4)
            w.put(self.altitude, 8)
            w.put(self.timeUsec, 12)
        }
    }
}

/// PARAM_MAP_RC (#50)
extension MAV {
    public struct ParamMapRc: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 50, name: "PARAM_MAP_RC", crcExtra: 78, minLength: 37, length: 37)
        public var paramValue0: Float
        public var scale: Float
        public var paramValueMin: Float
        public var paramValueMax: Float
        public var paramIndex: Int16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var paramId: [UInt8]
        public var parameterRcChannelIndex: UInt8

        public init(paramValue0: Float = 0, scale: Float = 0, paramValueMin: Float = 0, paramValueMax: Float = 0, paramIndex: Int16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, paramId: [UInt8] = [UInt8](repeating: 0, count: 16), parameterRcChannelIndex: UInt8 = 0) {
            self.paramValue0 = paramValue0
            self.scale = scale
            self.paramValueMin = paramValueMin
            self.paramValueMax = paramValueMax
            self.paramIndex = paramIndex
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.paramId = paramId
            self.parameterRcChannelIndex = parameterRcChannelIndex
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.paramValue0 = p.float(0)
            self.scale = p.float(4)
            self.paramValueMin = p.float(8)
            self.paramValueMax = p.float(12)
            self.paramIndex = p.int16(16)
            self.targetSystem = p.uint8(18)
            self.targetComponent = p.uint8(19)
            self.paramId = (0..<16).map { p.uint8(20 + $0 * 1) }
            self.parameterRcChannelIndex = p.uint8(36)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.paramValue0, 0)
            w.put(self.scale, 4)
            w.put(self.paramValueMin, 8)
            w.put(self.paramValueMax, 12)
            w.put(self.paramIndex, 16)
            w.put(self.targetSystem, 18)
            w.put(self.targetComponent, 19)
            for k in 0..<Swift.min(16, self.paramId.count) { w.put(self.paramId[k], 20 + k * 1) }
            w.put(self.parameterRcChannelIndex, 36)
        }
    }
}

/// MISSION_REQUEST_INT (#51)
extension MAV {
    public struct MissionRequestInt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 51, name: "MISSION_REQUEST_INT", crcExtra: 196, minLength: 4, length: 5)
        public var seq: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var missionType: UInt8  // extension field

        public init(seq: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, missionType: UInt8 = 0) {
            self.seq = seq
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.seq = p.uint16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
            self.missionType = p.uint8(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.seq, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
            w.put(self.missionType, 4)
        }
    }
}

/// MISSION_CHECKSUM (#53)
extension MAV {
    public struct MissionChecksum: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 53, name: "MISSION_CHECKSUM", crcExtra: 3, minLength: 5, length: 5)
        public var checksum: UInt32
        public var missionType: UInt8

        public init(checksum: UInt32 = 0, missionType: UInt8 = 0) {
            self.checksum = checksum
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.checksum = p.uint32(0)
            self.missionType = p.uint8(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.checksum, 0)
            w.put(self.missionType, 4)
        }
    }
}

/// SAFETY_SET_ALLOWED_AREA (#54)
extension MAV {
    public struct SafetySetAllowedArea: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 54, name: "SAFETY_SET_ALLOWED_AREA", crcExtra: 15, minLength: 27, length: 27)
        public var p1x: Float
        public var p1y: Float
        public var p1z: Float
        public var p2x: Float
        public var p2y: Float
        public var p2z: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var frame: UInt8

        public init(p1x: Float = 0, p1y: Float = 0, p1z: Float = 0, p2x: Float = 0, p2y: Float = 0, p2z: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, frame: UInt8 = 0) {
            self.p1x = p1x
            self.p1y = p1y
            self.p1z = p1z
            self.p2x = p2x
            self.p2y = p2y
            self.p2z = p2z
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.frame = frame
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.p1x = p.float(0)
            self.p1y = p.float(4)
            self.p1z = p.float(8)
            self.p2x = p.float(12)
            self.p2y = p.float(16)
            self.p2z = p.float(20)
            self.targetSystem = p.uint8(24)
            self.targetComponent = p.uint8(25)
            self.frame = p.uint8(26)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.p1x, 0)
            w.put(self.p1y, 4)
            w.put(self.p1z, 8)
            w.put(self.p2x, 12)
            w.put(self.p2y, 16)
            w.put(self.p2z, 20)
            w.put(self.targetSystem, 24)
            w.put(self.targetComponent, 25)
            w.put(self.frame, 26)
        }
    }
}

/// SAFETY_ALLOWED_AREA (#55)
extension MAV {
    public struct SafetyAllowedArea: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 55, name: "SAFETY_ALLOWED_AREA", crcExtra: 3, minLength: 25, length: 25)
        public var p1x: Float
        public var p1y: Float
        public var p1z: Float
        public var p2x: Float
        public var p2y: Float
        public var p2z: Float
        public var frame: UInt8

        public init(p1x: Float = 0, p1y: Float = 0, p1z: Float = 0, p2x: Float = 0, p2y: Float = 0, p2z: Float = 0, frame: UInt8 = 0) {
            self.p1x = p1x
            self.p1y = p1y
            self.p1z = p1z
            self.p2x = p2x
            self.p2y = p2y
            self.p2z = p2z
            self.frame = frame
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.p1x = p.float(0)
            self.p1y = p.float(4)
            self.p1z = p.float(8)
            self.p2x = p.float(12)
            self.p2y = p.float(16)
            self.p2z = p.float(20)
            self.frame = p.uint8(24)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.p1x, 0)
            w.put(self.p1y, 4)
            w.put(self.p1z, 8)
            w.put(self.p2x, 12)
            w.put(self.p2y, 16)
            w.put(self.p2z, 20)
            w.put(self.frame, 24)
        }
    }
}

/// ATTITUDE_QUATERNION_COV (#61)
extension MAV {
    public struct AttitudeQuaternionCov: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 61, name: "ATTITUDE_QUATERNION_COV", crcExtra: 167, minLength: 72, length: 72)
        public var timeUsec: UInt64
        public var q: [Float]
        public var rollspeed: Float
        public var pitchspeed: Float
        public var yawspeed: Float
        public var covariance: [Float]

        public init(timeUsec: UInt64 = 0, q: [Float] = [Float](repeating: 0, count: 4), rollspeed: Float = 0, pitchspeed: Float = 0, yawspeed: Float = 0, covariance: [Float] = [Float](repeating: 0, count: 9)) {
            self.timeUsec = timeUsec
            self.q = q
            self.rollspeed = rollspeed
            self.pitchspeed = pitchspeed
            self.yawspeed = yawspeed
            self.covariance = covariance
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.q = (0..<4).map { p.float(8 + $0 * 4) }
            self.rollspeed = p.float(24)
            self.pitchspeed = p.float(28)
            self.yawspeed = p.float(32)
            self.covariance = (0..<9).map { p.float(36 + $0 * 4) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 8 + k * 4) }
            w.put(self.rollspeed, 24)
            w.put(self.pitchspeed, 28)
            w.put(self.yawspeed, 32)
            for k in 0..<Swift.min(9, self.covariance.count) { w.put(self.covariance[k], 36 + k * 4) }
        }
    }
}

/// NAV_CONTROLLER_OUTPUT (#62)
extension MAV {
    public struct NavControllerOutput: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 62, name: "NAV_CONTROLLER_OUTPUT", crcExtra: 183, minLength: 26, length: 26)
        public var navRoll: Float
        public var navPitch: Float
        public var altError: Float
        public var aspdError: Float
        public var xtrackError: Float
        public var navBearing: Int16
        public var targetBearing: Int16
        public var wpDist: UInt16

        public init(navRoll: Float = 0, navPitch: Float = 0, altError: Float = 0, aspdError: Float = 0, xtrackError: Float = 0, navBearing: Int16 = 0, targetBearing: Int16 = 0, wpDist: UInt16 = 0) {
            self.navRoll = navRoll
            self.navPitch = navPitch
            self.altError = altError
            self.aspdError = aspdError
            self.xtrackError = xtrackError
            self.navBearing = navBearing
            self.targetBearing = targetBearing
            self.wpDist = wpDist
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.navRoll = p.float(0)
            self.navPitch = p.float(4)
            self.altError = p.float(8)
            self.aspdError = p.float(12)
            self.xtrackError = p.float(16)
            self.navBearing = p.int16(20)
            self.targetBearing = p.int16(22)
            self.wpDist = p.uint16(24)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.navRoll, 0)
            w.put(self.navPitch, 4)
            w.put(self.altError, 8)
            w.put(self.aspdError, 12)
            w.put(self.xtrackError, 16)
            w.put(self.navBearing, 20)
            w.put(self.targetBearing, 22)
            w.put(self.wpDist, 24)
        }
    }
}

/// GLOBAL_POSITION_INT_COV (#63)
extension MAV {
    public struct GlobalPositionIntCov: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 63, name: "GLOBAL_POSITION_INT_COV", crcExtra: 119, minLength: 181, length: 181)
        public var timeUsec: UInt64
        public var lat: Int32
        public var lon: Int32
        public var alt: Int32
        public var relativeAlt: Int32
        public var vx: Float
        public var vy: Float
        public var vz: Float
        public var covariance: [Float]
        public var estimatorType: UInt8

        public init(timeUsec: UInt64 = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Int32 = 0, relativeAlt: Int32 = 0, vx: Float = 0, vy: Float = 0, vz: Float = 0, covariance: [Float] = [Float](repeating: 0, count: 36), estimatorType: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.relativeAlt = relativeAlt
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.covariance = covariance
            self.estimatorType = estimatorType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.lat = p.int32(8)
            self.lon = p.int32(12)
            self.alt = p.int32(16)
            self.relativeAlt = p.int32(20)
            self.vx = p.float(24)
            self.vy = p.float(28)
            self.vz = p.float(32)
            self.covariance = (0..<36).map { p.float(36 + $0 * 4) }
            self.estimatorType = p.uint8(180)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.lat, 8)
            w.put(self.lon, 12)
            w.put(self.alt, 16)
            w.put(self.relativeAlt, 20)
            w.put(self.vx, 24)
            w.put(self.vy, 28)
            w.put(self.vz, 32)
            for k in 0..<Swift.min(36, self.covariance.count) { w.put(self.covariance[k], 36 + k * 4) }
            w.put(self.estimatorType, 180)
        }
    }
}

/// LOCAL_POSITION_NED_COV (#64)
extension MAV {
    public struct LocalPositionNedCov: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 64, name: "LOCAL_POSITION_NED_COV", crcExtra: 191, minLength: 225, length: 225)
        public var timeUsec: UInt64
        public var x: Float
        public var y: Float
        public var z: Float
        public var vx: Float
        public var vy: Float
        public var vz: Float
        public var ax: Float
        public var ay: Float
        public var az: Float
        public var covariance: [Float]
        public var estimatorType: UInt8

        public init(timeUsec: UInt64 = 0, x: Float = 0, y: Float = 0, z: Float = 0, vx: Float = 0, vy: Float = 0, vz: Float = 0, ax: Float = 0, ay: Float = 0, az: Float = 0, covariance: [Float] = [Float](repeating: 0, count: 45), estimatorType: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.x = x
            self.y = y
            self.z = z
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.ax = ax
            self.ay = ay
            self.az = az
            self.covariance = covariance
            self.estimatorType = estimatorType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.x = p.float(8)
            self.y = p.float(12)
            self.z = p.float(16)
            self.vx = p.float(20)
            self.vy = p.float(24)
            self.vz = p.float(28)
            self.ax = p.float(32)
            self.ay = p.float(36)
            self.az = p.float(40)
            self.covariance = (0..<45).map { p.float(44 + $0 * 4) }
            self.estimatorType = p.uint8(224)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.x, 8)
            w.put(self.y, 12)
            w.put(self.z, 16)
            w.put(self.vx, 20)
            w.put(self.vy, 24)
            w.put(self.vz, 28)
            w.put(self.ax, 32)
            w.put(self.ay, 36)
            w.put(self.az, 40)
            for k in 0..<Swift.min(45, self.covariance.count) { w.put(self.covariance[k], 44 + k * 4) }
            w.put(self.estimatorType, 224)
        }
    }
}

/// RC_CHANNELS (#65)
extension MAV {
    public struct RcChannels: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 65, name: "RC_CHANNELS", crcExtra: 118, minLength: 42, length: 42)
        public var timeBootMs: UInt32
        public var chan1Raw: UInt16
        public var chan2Raw: UInt16
        public var chan3Raw: UInt16
        public var chan4Raw: UInt16
        public var chan5Raw: UInt16
        public var chan6Raw: UInt16
        public var chan7Raw: UInt16
        public var chan8Raw: UInt16
        public var chan9Raw: UInt16
        public var chan10Raw: UInt16
        public var chan11Raw: UInt16
        public var chan12Raw: UInt16
        public var chan13Raw: UInt16
        public var chan14Raw: UInt16
        public var chan15Raw: UInt16
        public var chan16Raw: UInt16
        public var chan17Raw: UInt16
        public var chan18Raw: UInt16
        public var chancount: UInt8
        public var rssi: UInt8

        public init(timeBootMs: UInt32 = 0, chan1Raw: UInt16 = 0, chan2Raw: UInt16 = 0, chan3Raw: UInt16 = 0, chan4Raw: UInt16 = 0, chan5Raw: UInt16 = 0, chan6Raw: UInt16 = 0, chan7Raw: UInt16 = 0, chan8Raw: UInt16 = 0, chan9Raw: UInt16 = 0, chan10Raw: UInt16 = 0, chan11Raw: UInt16 = 0, chan12Raw: UInt16 = 0, chan13Raw: UInt16 = 0, chan14Raw: UInt16 = 0, chan15Raw: UInt16 = 0, chan16Raw: UInt16 = 0, chan17Raw: UInt16 = 0, chan18Raw: UInt16 = 0, chancount: UInt8 = 0, rssi: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.chan1Raw = chan1Raw
            self.chan2Raw = chan2Raw
            self.chan3Raw = chan3Raw
            self.chan4Raw = chan4Raw
            self.chan5Raw = chan5Raw
            self.chan6Raw = chan6Raw
            self.chan7Raw = chan7Raw
            self.chan8Raw = chan8Raw
            self.chan9Raw = chan9Raw
            self.chan10Raw = chan10Raw
            self.chan11Raw = chan11Raw
            self.chan12Raw = chan12Raw
            self.chan13Raw = chan13Raw
            self.chan14Raw = chan14Raw
            self.chan15Raw = chan15Raw
            self.chan16Raw = chan16Raw
            self.chan17Raw = chan17Raw
            self.chan18Raw = chan18Raw
            self.chancount = chancount
            self.rssi = rssi
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.chan1Raw = p.uint16(4)
            self.chan2Raw = p.uint16(6)
            self.chan3Raw = p.uint16(8)
            self.chan4Raw = p.uint16(10)
            self.chan5Raw = p.uint16(12)
            self.chan6Raw = p.uint16(14)
            self.chan7Raw = p.uint16(16)
            self.chan8Raw = p.uint16(18)
            self.chan9Raw = p.uint16(20)
            self.chan10Raw = p.uint16(22)
            self.chan11Raw = p.uint16(24)
            self.chan12Raw = p.uint16(26)
            self.chan13Raw = p.uint16(28)
            self.chan14Raw = p.uint16(30)
            self.chan15Raw = p.uint16(32)
            self.chan16Raw = p.uint16(34)
            self.chan17Raw = p.uint16(36)
            self.chan18Raw = p.uint16(38)
            self.chancount = p.uint8(40)
            self.rssi = p.uint8(41)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.chan1Raw, 4)
            w.put(self.chan2Raw, 6)
            w.put(self.chan3Raw, 8)
            w.put(self.chan4Raw, 10)
            w.put(self.chan5Raw, 12)
            w.put(self.chan6Raw, 14)
            w.put(self.chan7Raw, 16)
            w.put(self.chan8Raw, 18)
            w.put(self.chan9Raw, 20)
            w.put(self.chan10Raw, 22)
            w.put(self.chan11Raw, 24)
            w.put(self.chan12Raw, 26)
            w.put(self.chan13Raw, 28)
            w.put(self.chan14Raw, 30)
            w.put(self.chan15Raw, 32)
            w.put(self.chan16Raw, 34)
            w.put(self.chan17Raw, 36)
            w.put(self.chan18Raw, 38)
            w.put(self.chancount, 40)
            w.put(self.rssi, 41)
        }
    }
}

/// REQUEST_DATA_STREAM (#66)
extension MAV {
    public struct RequestDataStream: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 66, name: "REQUEST_DATA_STREAM", crcExtra: 148, minLength: 6, length: 6)
        public var reqMessageRate: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var reqStreamId: UInt8
        public var startStop: UInt8

        public init(reqMessageRate: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, reqStreamId: UInt8 = 0, startStop: UInt8 = 0) {
            self.reqMessageRate = reqMessageRate
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.reqStreamId = reqStreamId
            self.startStop = startStop
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.reqMessageRate = p.uint16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
            self.reqStreamId = p.uint8(4)
            self.startStop = p.uint8(5)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.reqMessageRate, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
            w.put(self.reqStreamId, 4)
            w.put(self.startStop, 5)
        }
    }
}

/// DATA_STREAM (#67)
extension MAV {
    public struct DataStream: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 67, name: "DATA_STREAM", crcExtra: 21, minLength: 4, length: 4)
        public var messageRate: UInt16
        public var streamId: UInt8
        public var onOff: UInt8

        public init(messageRate: UInt16 = 0, streamId: UInt8 = 0, onOff: UInt8 = 0) {
            self.messageRate = messageRate
            self.streamId = streamId
            self.onOff = onOff
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.messageRate = p.uint16(0)
            self.streamId = p.uint8(2)
            self.onOff = p.uint8(3)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.messageRate, 0)
            w.put(self.streamId, 2)
            w.put(self.onOff, 3)
        }
    }
}

/// MANUAL_CONTROL (#69)
extension MAV {
    public struct ManualControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 69, name: "MANUAL_CONTROL", crcExtra: 243, minLength: 11, length: 30)
        public var x: Int16
        public var y: Int16
        public var z: Int16
        public var r: Int16
        public var buttons: UInt16
        public var target: UInt8
        public var buttons2: UInt16  // extension field
        public var enabledExtensions: UInt8  // extension field
        public var s: Int16  // extension field
        public var t: Int16  // extension field
        public var aux1: Int16  // extension field
        public var aux2: Int16  // extension field
        public var aux3: Int16  // extension field
        public var aux4: Int16  // extension field
        public var aux5: Int16  // extension field
        public var aux6: Int16  // extension field

        public init(x: Int16 = 0, y: Int16 = 0, z: Int16 = 0, r: Int16 = 0, buttons: UInt16 = 0, target: UInt8 = 0, buttons2: UInt16 = 0, enabledExtensions: UInt8 = 0, s: Int16 = 0, t: Int16 = 0, aux1: Int16 = 0, aux2: Int16 = 0, aux3: Int16 = 0, aux4: Int16 = 0, aux5: Int16 = 0, aux6: Int16 = 0) {
            self.x = x
            self.y = y
            self.z = z
            self.r = r
            self.buttons = buttons
            self.target = target
            self.buttons2 = buttons2
            self.enabledExtensions = enabledExtensions
            self.s = s
            self.t = t
            self.aux1 = aux1
            self.aux2 = aux2
            self.aux3 = aux3
            self.aux4 = aux4
            self.aux5 = aux5
            self.aux6 = aux6
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.x = p.int16(0)
            self.y = p.int16(2)
            self.z = p.int16(4)
            self.r = p.int16(6)
            self.buttons = p.uint16(8)
            self.target = p.uint8(10)
            self.buttons2 = p.uint16(11)
            self.enabledExtensions = p.uint8(13)
            self.s = p.int16(14)
            self.t = p.int16(16)
            self.aux1 = p.int16(18)
            self.aux2 = p.int16(20)
            self.aux3 = p.int16(22)
            self.aux4 = p.int16(24)
            self.aux5 = p.int16(26)
            self.aux6 = p.int16(28)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.x, 0)
            w.put(self.y, 2)
            w.put(self.z, 4)
            w.put(self.r, 6)
            w.put(self.buttons, 8)
            w.put(self.target, 10)
            w.put(self.buttons2, 11)
            w.put(self.enabledExtensions, 13)
            w.put(self.s, 14)
            w.put(self.t, 16)
            w.put(self.aux1, 18)
            w.put(self.aux2, 20)
            w.put(self.aux3, 22)
            w.put(self.aux4, 24)
            w.put(self.aux5, 26)
            w.put(self.aux6, 28)
        }
    }
}

/// RC_CHANNELS_OVERRIDE (#70)
extension MAV {
    public struct RcChannelsOverride: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 70, name: "RC_CHANNELS_OVERRIDE", crcExtra: 124, minLength: 18, length: 38)
        public var chan1Raw: UInt16
        public var chan2Raw: UInt16
        public var chan3Raw: UInt16
        public var chan4Raw: UInt16
        public var chan5Raw: UInt16
        public var chan6Raw: UInt16
        public var chan7Raw: UInt16
        public var chan8Raw: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var chan9Raw: UInt16  // extension field
        public var chan10Raw: UInt16  // extension field
        public var chan11Raw: UInt16  // extension field
        public var chan12Raw: UInt16  // extension field
        public var chan13Raw: UInt16  // extension field
        public var chan14Raw: UInt16  // extension field
        public var chan15Raw: UInt16  // extension field
        public var chan16Raw: UInt16  // extension field
        public var chan17Raw: UInt16  // extension field
        public var chan18Raw: UInt16  // extension field

        public init(chan1Raw: UInt16 = 0, chan2Raw: UInt16 = 0, chan3Raw: UInt16 = 0, chan4Raw: UInt16 = 0, chan5Raw: UInt16 = 0, chan6Raw: UInt16 = 0, chan7Raw: UInt16 = 0, chan8Raw: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, chan9Raw: UInt16 = 0, chan10Raw: UInt16 = 0, chan11Raw: UInt16 = 0, chan12Raw: UInt16 = 0, chan13Raw: UInt16 = 0, chan14Raw: UInt16 = 0, chan15Raw: UInt16 = 0, chan16Raw: UInt16 = 0, chan17Raw: UInt16 = 0, chan18Raw: UInt16 = 0) {
            self.chan1Raw = chan1Raw
            self.chan2Raw = chan2Raw
            self.chan3Raw = chan3Raw
            self.chan4Raw = chan4Raw
            self.chan5Raw = chan5Raw
            self.chan6Raw = chan6Raw
            self.chan7Raw = chan7Raw
            self.chan8Raw = chan8Raw
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.chan9Raw = chan9Raw
            self.chan10Raw = chan10Raw
            self.chan11Raw = chan11Raw
            self.chan12Raw = chan12Raw
            self.chan13Raw = chan13Raw
            self.chan14Raw = chan14Raw
            self.chan15Raw = chan15Raw
            self.chan16Raw = chan16Raw
            self.chan17Raw = chan17Raw
            self.chan18Raw = chan18Raw
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.chan1Raw = p.uint16(0)
            self.chan2Raw = p.uint16(2)
            self.chan3Raw = p.uint16(4)
            self.chan4Raw = p.uint16(6)
            self.chan5Raw = p.uint16(8)
            self.chan6Raw = p.uint16(10)
            self.chan7Raw = p.uint16(12)
            self.chan8Raw = p.uint16(14)
            self.targetSystem = p.uint8(16)
            self.targetComponent = p.uint8(17)
            self.chan9Raw = p.uint16(18)
            self.chan10Raw = p.uint16(20)
            self.chan11Raw = p.uint16(22)
            self.chan12Raw = p.uint16(24)
            self.chan13Raw = p.uint16(26)
            self.chan14Raw = p.uint16(28)
            self.chan15Raw = p.uint16(30)
            self.chan16Raw = p.uint16(32)
            self.chan17Raw = p.uint16(34)
            self.chan18Raw = p.uint16(36)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.chan1Raw, 0)
            w.put(self.chan2Raw, 2)
            w.put(self.chan3Raw, 4)
            w.put(self.chan4Raw, 6)
            w.put(self.chan5Raw, 8)
            w.put(self.chan6Raw, 10)
            w.put(self.chan7Raw, 12)
            w.put(self.chan8Raw, 14)
            w.put(self.targetSystem, 16)
            w.put(self.targetComponent, 17)
            w.put(self.chan9Raw, 18)
            w.put(self.chan10Raw, 20)
            w.put(self.chan11Raw, 22)
            w.put(self.chan12Raw, 24)
            w.put(self.chan13Raw, 26)
            w.put(self.chan14Raw, 28)
            w.put(self.chan15Raw, 30)
            w.put(self.chan16Raw, 32)
            w.put(self.chan17Raw, 34)
            w.put(self.chan18Raw, 36)
        }
    }
}

/// MISSION_ITEM_INT (#73)
extension MAV {
    public struct MissionItemInt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 73, name: "MISSION_ITEM_INT", crcExtra: 38, minLength: 37, length: 38)
        public var param1: Float
        public var param2: Float
        public var param3: Float
        public var param4: Float
        public var x: Int32
        public var y: Int32
        public var z: Float
        public var seq: UInt16
        public var command: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var frame: UInt8
        public var current: UInt8
        public var autocontinue: UInt8
        public var missionType: UInt8  // extension field

        public init(param1: Float = 0, param2: Float = 0, param3: Float = 0, param4: Float = 0, x: Int32 = 0, y: Int32 = 0, z: Float = 0, seq: UInt16 = 0, command: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, frame: UInt8 = 0, current: UInt8 = 0, autocontinue: UInt8 = 0, missionType: UInt8 = 0) {
            self.param1 = param1
            self.param2 = param2
            self.param3 = param3
            self.param4 = param4
            self.x = x
            self.y = y
            self.z = z
            self.seq = seq
            self.command = command
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.frame = frame
            self.current = current
            self.autocontinue = autocontinue
            self.missionType = missionType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.param1 = p.float(0)
            self.param2 = p.float(4)
            self.param3 = p.float(8)
            self.param4 = p.float(12)
            self.x = p.int32(16)
            self.y = p.int32(20)
            self.z = p.float(24)
            self.seq = p.uint16(28)
            self.command = p.uint16(30)
            self.targetSystem = p.uint8(32)
            self.targetComponent = p.uint8(33)
            self.frame = p.uint8(34)
            self.current = p.uint8(35)
            self.autocontinue = p.uint8(36)
            self.missionType = p.uint8(37)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.param1, 0)
            w.put(self.param2, 4)
            w.put(self.param3, 8)
            w.put(self.param4, 12)
            w.put(self.x, 16)
            w.put(self.y, 20)
            w.put(self.z, 24)
            w.put(self.seq, 28)
            w.put(self.command, 30)
            w.put(self.targetSystem, 32)
            w.put(self.targetComponent, 33)
            w.put(self.frame, 34)
            w.put(self.current, 35)
            w.put(self.autocontinue, 36)
            w.put(self.missionType, 37)
        }
    }
}

/// VFR_HUD (#74)
extension MAV {
    public struct VfrHud: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 74, name: "VFR_HUD", crcExtra: 20, minLength: 20, length: 20)
        public var airspeed: Float
        public var groundspeed: Float
        public var alt: Float
        public var climb: Float
        public var heading: Int16
        public var throttle: UInt16

        public init(airspeed: Float = 0, groundspeed: Float = 0, alt: Float = 0, climb: Float = 0, heading: Int16 = 0, throttle: UInt16 = 0) {
            self.airspeed = airspeed
            self.groundspeed = groundspeed
            self.alt = alt
            self.climb = climb
            self.heading = heading
            self.throttle = throttle
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.airspeed = p.float(0)
            self.groundspeed = p.float(4)
            self.alt = p.float(8)
            self.climb = p.float(12)
            self.heading = p.int16(16)
            self.throttle = p.uint16(18)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.airspeed, 0)
            w.put(self.groundspeed, 4)
            w.put(self.alt, 8)
            w.put(self.climb, 12)
            w.put(self.heading, 16)
            w.put(self.throttle, 18)
        }
    }
}

/// COMMAND_INT (#75)
extension MAV {
    public struct CommandInt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 75, name: "COMMAND_INT", crcExtra: 158, minLength: 35, length: 35)
        public var param1: Float
        public var param2: Float
        public var param3: Float
        public var param4: Float
        public var x: Int32
        public var y: Int32
        public var z: Float
        public var command: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var frame: UInt8
        public var current: UInt8
        public var autocontinue: UInt8

        public init(param1: Float = 0, param2: Float = 0, param3: Float = 0, param4: Float = 0, x: Int32 = 0, y: Int32 = 0, z: Float = 0, command: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, frame: UInt8 = 0, current: UInt8 = 0, autocontinue: UInt8 = 0) {
            self.param1 = param1
            self.param2 = param2
            self.param3 = param3
            self.param4 = param4
            self.x = x
            self.y = y
            self.z = z
            self.command = command
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.frame = frame
            self.current = current
            self.autocontinue = autocontinue
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.param1 = p.float(0)
            self.param2 = p.float(4)
            self.param3 = p.float(8)
            self.param4 = p.float(12)
            self.x = p.int32(16)
            self.y = p.int32(20)
            self.z = p.float(24)
            self.command = p.uint16(28)
            self.targetSystem = p.uint8(30)
            self.targetComponent = p.uint8(31)
            self.frame = p.uint8(32)
            self.current = p.uint8(33)
            self.autocontinue = p.uint8(34)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.param1, 0)
            w.put(self.param2, 4)
            w.put(self.param3, 8)
            w.put(self.param4, 12)
            w.put(self.x, 16)
            w.put(self.y, 20)
            w.put(self.z, 24)
            w.put(self.command, 28)
            w.put(self.targetSystem, 30)
            w.put(self.targetComponent, 31)
            w.put(self.frame, 32)
            w.put(self.current, 33)
            w.put(self.autocontinue, 34)
        }
    }
}

/// COMMAND_LONG (#76)
extension MAV {
    public struct CommandLong: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 76, name: "COMMAND_LONG", crcExtra: 152, minLength: 33, length: 33)
        public var param1: Float
        public var param2: Float
        public var param3: Float
        public var param4: Float
        public var param5: Float
        public var param6: Float
        public var param7: Float
        public var command: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var confirmation: UInt8

        public init(param1: Float = 0, param2: Float = 0, param3: Float = 0, param4: Float = 0, param5: Float = 0, param6: Float = 0, param7: Float = 0, command: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, confirmation: UInt8 = 0) {
            self.param1 = param1
            self.param2 = param2
            self.param3 = param3
            self.param4 = param4
            self.param5 = param5
            self.param6 = param6
            self.param7 = param7
            self.command = command
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.confirmation = confirmation
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.param1 = p.float(0)
            self.param2 = p.float(4)
            self.param3 = p.float(8)
            self.param4 = p.float(12)
            self.param5 = p.float(16)
            self.param6 = p.float(20)
            self.param7 = p.float(24)
            self.command = p.uint16(28)
            self.targetSystem = p.uint8(30)
            self.targetComponent = p.uint8(31)
            self.confirmation = p.uint8(32)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.param1, 0)
            w.put(self.param2, 4)
            w.put(self.param3, 8)
            w.put(self.param4, 12)
            w.put(self.param5, 16)
            w.put(self.param6, 20)
            w.put(self.param7, 24)
            w.put(self.command, 28)
            w.put(self.targetSystem, 30)
            w.put(self.targetComponent, 31)
            w.put(self.confirmation, 32)
        }
    }
}

/// COMMAND_ACK (#77)
extension MAV {
    public struct CommandAck: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 77, name: "COMMAND_ACK", crcExtra: 143, minLength: 3, length: 10)
        public var command: UInt16
        public var result: UInt8
        public var progress: UInt8  // extension field
        public var resultParam2: Int32  // extension field
        public var targetSystem: UInt8  // extension field
        public var targetComponent: UInt8  // extension field

        public init(command: UInt16 = 0, result: UInt8 = 0, progress: UInt8 = 0, resultParam2: Int32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.command = command
            self.result = result
            self.progress = progress
            self.resultParam2 = resultParam2
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.command = p.uint16(0)
            self.result = p.uint8(2)
            self.progress = p.uint8(3)
            self.resultParam2 = p.int32(4)
            self.targetSystem = p.uint8(8)
            self.targetComponent = p.uint8(9)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.command, 0)
            w.put(self.result, 2)
            w.put(self.progress, 3)
            w.put(self.resultParam2, 4)
            w.put(self.targetSystem, 8)
            w.put(self.targetComponent, 9)
        }
    }
}

/// MANUAL_SETPOINT (#81)
extension MAV {
    public struct ManualSetpoint: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 81, name: "MANUAL_SETPOINT", crcExtra: 106, minLength: 22, length: 22)
        public var timeBootMs: UInt32
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var thrust: Float
        public var modeSwitch: UInt8
        public var manualOverrideSwitch: UInt8

        public init(timeBootMs: UInt32 = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0, thrust: Float = 0, modeSwitch: UInt8 = 0, manualOverrideSwitch: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.thrust = thrust
            self.modeSwitch = modeSwitch
            self.manualOverrideSwitch = manualOverrideSwitch
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.roll = p.float(4)
            self.pitch = p.float(8)
            self.yaw = p.float(12)
            self.thrust = p.float(16)
            self.modeSwitch = p.uint8(20)
            self.manualOverrideSwitch = p.uint8(21)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.roll, 4)
            w.put(self.pitch, 8)
            w.put(self.yaw, 12)
            w.put(self.thrust, 16)
            w.put(self.modeSwitch, 20)
            w.put(self.manualOverrideSwitch, 21)
        }
    }
}

/// SET_ATTITUDE_TARGET (#82)
extension MAV {
    public struct SetAttitudeTarget: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 82, name: "SET_ATTITUDE_TARGET", crcExtra: 49, minLength: 39, length: 39)
        public var timeBootMs: UInt32
        public var q: [Float]
        public var bodyRollRate: Float
        public var bodyPitchRate: Float
        public var bodyYawRate: Float
        public var thrust: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var typeMask: UInt8

        public init(timeBootMs: UInt32 = 0, q: [Float] = [Float](repeating: 0, count: 4), bodyRollRate: Float = 0, bodyPitchRate: Float = 0, bodyYawRate: Float = 0, thrust: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, typeMask: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.q = q
            self.bodyRollRate = bodyRollRate
            self.bodyPitchRate = bodyPitchRate
            self.bodyYawRate = bodyYawRate
            self.thrust = thrust
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.typeMask = typeMask
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.q = (0..<4).map { p.float(4 + $0 * 4) }
            self.bodyRollRate = p.float(20)
            self.bodyPitchRate = p.float(24)
            self.bodyYawRate = p.float(28)
            self.thrust = p.float(32)
            self.targetSystem = p.uint8(36)
            self.targetComponent = p.uint8(37)
            self.typeMask = p.uint8(38)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 4 + k * 4) }
            w.put(self.bodyRollRate, 20)
            w.put(self.bodyPitchRate, 24)
            w.put(self.bodyYawRate, 28)
            w.put(self.thrust, 32)
            w.put(self.targetSystem, 36)
            w.put(self.targetComponent, 37)
            w.put(self.typeMask, 38)
        }
    }
}

/// ATTITUDE_TARGET (#83)
extension MAV {
    public struct AttitudeTarget: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 83, name: "ATTITUDE_TARGET", crcExtra: 22, minLength: 37, length: 37)
        public var timeBootMs: UInt32
        public var q: [Float]
        public var bodyRollRate: Float
        public var bodyPitchRate: Float
        public var bodyYawRate: Float
        public var thrust: Float
        public var typeMask: UInt8

        public init(timeBootMs: UInt32 = 0, q: [Float] = [Float](repeating: 0, count: 4), bodyRollRate: Float = 0, bodyPitchRate: Float = 0, bodyYawRate: Float = 0, thrust: Float = 0, typeMask: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.q = q
            self.bodyRollRate = bodyRollRate
            self.bodyPitchRate = bodyPitchRate
            self.bodyYawRate = bodyYawRate
            self.thrust = thrust
            self.typeMask = typeMask
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.q = (0..<4).map { p.float(4 + $0 * 4) }
            self.bodyRollRate = p.float(20)
            self.bodyPitchRate = p.float(24)
            self.bodyYawRate = p.float(28)
            self.thrust = p.float(32)
            self.typeMask = p.uint8(36)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 4 + k * 4) }
            w.put(self.bodyRollRate, 20)
            w.put(self.bodyPitchRate, 24)
            w.put(self.bodyYawRate, 28)
            w.put(self.thrust, 32)
            w.put(self.typeMask, 36)
        }
    }
}

/// SET_POSITION_TARGET_LOCAL_NED (#84)
extension MAV {
    public struct SetPositionTargetLocalNed: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 84, name: "SET_POSITION_TARGET_LOCAL_NED", crcExtra: 143, minLength: 53, length: 53)
        public var timeBootMs: UInt32
        public var x: Float
        public var y: Float
        public var z: Float
        public var vx: Float
        public var vy: Float
        public var vz: Float
        public var afx: Float
        public var afy: Float
        public var afz: Float
        public var yaw: Float
        public var yawRate: Float
        public var typeMask: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var coordinateFrame: UInt8

        public init(timeBootMs: UInt32 = 0, x: Float = 0, y: Float = 0, z: Float = 0, vx: Float = 0, vy: Float = 0, vz: Float = 0, afx: Float = 0, afy: Float = 0, afz: Float = 0, yaw: Float = 0, yawRate: Float = 0, typeMask: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, coordinateFrame: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.x = x
            self.y = y
            self.z = z
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.afx = afx
            self.afy = afy
            self.afz = afz
            self.yaw = yaw
            self.yawRate = yawRate
            self.typeMask = typeMask
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.coordinateFrame = coordinateFrame
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.x = p.float(4)
            self.y = p.float(8)
            self.z = p.float(12)
            self.vx = p.float(16)
            self.vy = p.float(20)
            self.vz = p.float(24)
            self.afx = p.float(28)
            self.afy = p.float(32)
            self.afz = p.float(36)
            self.yaw = p.float(40)
            self.yawRate = p.float(44)
            self.typeMask = p.uint16(48)
            self.targetSystem = p.uint8(50)
            self.targetComponent = p.uint8(51)
            self.coordinateFrame = p.uint8(52)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.x, 4)
            w.put(self.y, 8)
            w.put(self.z, 12)
            w.put(self.vx, 16)
            w.put(self.vy, 20)
            w.put(self.vz, 24)
            w.put(self.afx, 28)
            w.put(self.afy, 32)
            w.put(self.afz, 36)
            w.put(self.yaw, 40)
            w.put(self.yawRate, 44)
            w.put(self.typeMask, 48)
            w.put(self.targetSystem, 50)
            w.put(self.targetComponent, 51)
            w.put(self.coordinateFrame, 52)
        }
    }
}

/// POSITION_TARGET_LOCAL_NED (#85)
extension MAV {
    public struct PositionTargetLocalNed: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 85, name: "POSITION_TARGET_LOCAL_NED", crcExtra: 140, minLength: 51, length: 51)
        public var timeBootMs: UInt32
        public var x: Float
        public var y: Float
        public var z: Float
        public var vx: Float
        public var vy: Float
        public var vz: Float
        public var afx: Float
        public var afy: Float
        public var afz: Float
        public var yaw: Float
        public var yawRate: Float
        public var typeMask: UInt16
        public var coordinateFrame: UInt8

        public init(timeBootMs: UInt32 = 0, x: Float = 0, y: Float = 0, z: Float = 0, vx: Float = 0, vy: Float = 0, vz: Float = 0, afx: Float = 0, afy: Float = 0, afz: Float = 0, yaw: Float = 0, yawRate: Float = 0, typeMask: UInt16 = 0, coordinateFrame: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.x = x
            self.y = y
            self.z = z
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.afx = afx
            self.afy = afy
            self.afz = afz
            self.yaw = yaw
            self.yawRate = yawRate
            self.typeMask = typeMask
            self.coordinateFrame = coordinateFrame
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.x = p.float(4)
            self.y = p.float(8)
            self.z = p.float(12)
            self.vx = p.float(16)
            self.vy = p.float(20)
            self.vz = p.float(24)
            self.afx = p.float(28)
            self.afy = p.float(32)
            self.afz = p.float(36)
            self.yaw = p.float(40)
            self.yawRate = p.float(44)
            self.typeMask = p.uint16(48)
            self.coordinateFrame = p.uint8(50)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.x, 4)
            w.put(self.y, 8)
            w.put(self.z, 12)
            w.put(self.vx, 16)
            w.put(self.vy, 20)
            w.put(self.vz, 24)
            w.put(self.afx, 28)
            w.put(self.afy, 32)
            w.put(self.afz, 36)
            w.put(self.yaw, 40)
            w.put(self.yawRate, 44)
            w.put(self.typeMask, 48)
            w.put(self.coordinateFrame, 50)
        }
    }
}

/// SET_POSITION_TARGET_GLOBAL_INT (#86)
extension MAV {
    public struct SetPositionTargetGlobalInt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 86, name: "SET_POSITION_TARGET_GLOBAL_INT", crcExtra: 5, minLength: 53, length: 53)
        public var timeBootMs: UInt32
        public var latInt: Int32
        public var lonInt: Int32
        public var alt: Float
        public var vx: Float
        public var vy: Float
        public var vz: Float
        public var afx: Float
        public var afy: Float
        public var afz: Float
        public var yaw: Float
        public var yawRate: Float
        public var typeMask: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var coordinateFrame: UInt8

        public init(timeBootMs: UInt32 = 0, latInt: Int32 = 0, lonInt: Int32 = 0, alt: Float = 0, vx: Float = 0, vy: Float = 0, vz: Float = 0, afx: Float = 0, afy: Float = 0, afz: Float = 0, yaw: Float = 0, yawRate: Float = 0, typeMask: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, coordinateFrame: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.latInt = latInt
            self.lonInt = lonInt
            self.alt = alt
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.afx = afx
            self.afy = afy
            self.afz = afz
            self.yaw = yaw
            self.yawRate = yawRate
            self.typeMask = typeMask
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.coordinateFrame = coordinateFrame
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.latInt = p.int32(4)
            self.lonInt = p.int32(8)
            self.alt = p.float(12)
            self.vx = p.float(16)
            self.vy = p.float(20)
            self.vz = p.float(24)
            self.afx = p.float(28)
            self.afy = p.float(32)
            self.afz = p.float(36)
            self.yaw = p.float(40)
            self.yawRate = p.float(44)
            self.typeMask = p.uint16(48)
            self.targetSystem = p.uint8(50)
            self.targetComponent = p.uint8(51)
            self.coordinateFrame = p.uint8(52)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.latInt, 4)
            w.put(self.lonInt, 8)
            w.put(self.alt, 12)
            w.put(self.vx, 16)
            w.put(self.vy, 20)
            w.put(self.vz, 24)
            w.put(self.afx, 28)
            w.put(self.afy, 32)
            w.put(self.afz, 36)
            w.put(self.yaw, 40)
            w.put(self.yawRate, 44)
            w.put(self.typeMask, 48)
            w.put(self.targetSystem, 50)
            w.put(self.targetComponent, 51)
            w.put(self.coordinateFrame, 52)
        }
    }
}

/// POSITION_TARGET_GLOBAL_INT (#87)
extension MAV {
    public struct PositionTargetGlobalInt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 87, name: "POSITION_TARGET_GLOBAL_INT", crcExtra: 150, minLength: 51, length: 51)
        public var timeBootMs: UInt32
        public var latInt: Int32
        public var lonInt: Int32
        public var alt: Float
        public var vx: Float
        public var vy: Float
        public var vz: Float
        public var afx: Float
        public var afy: Float
        public var afz: Float
        public var yaw: Float
        public var yawRate: Float
        public var typeMask: UInt16
        public var coordinateFrame: UInt8

        public init(timeBootMs: UInt32 = 0, latInt: Int32 = 0, lonInt: Int32 = 0, alt: Float = 0, vx: Float = 0, vy: Float = 0, vz: Float = 0, afx: Float = 0, afy: Float = 0, afz: Float = 0, yaw: Float = 0, yawRate: Float = 0, typeMask: UInt16 = 0, coordinateFrame: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.latInt = latInt
            self.lonInt = lonInt
            self.alt = alt
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.afx = afx
            self.afy = afy
            self.afz = afz
            self.yaw = yaw
            self.yawRate = yawRate
            self.typeMask = typeMask
            self.coordinateFrame = coordinateFrame
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.latInt = p.int32(4)
            self.lonInt = p.int32(8)
            self.alt = p.float(12)
            self.vx = p.float(16)
            self.vy = p.float(20)
            self.vz = p.float(24)
            self.afx = p.float(28)
            self.afy = p.float(32)
            self.afz = p.float(36)
            self.yaw = p.float(40)
            self.yawRate = p.float(44)
            self.typeMask = p.uint16(48)
            self.coordinateFrame = p.uint8(50)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.latInt, 4)
            w.put(self.lonInt, 8)
            w.put(self.alt, 12)
            w.put(self.vx, 16)
            w.put(self.vy, 20)
            w.put(self.vz, 24)
            w.put(self.afx, 28)
            w.put(self.afy, 32)
            w.put(self.afz, 36)
            w.put(self.yaw, 40)
            w.put(self.yawRate, 44)
            w.put(self.typeMask, 48)
            w.put(self.coordinateFrame, 50)
        }
    }
}

/// LOCAL_POSITION_NED_SYSTEM_GLOBAL_OFFSET (#89)
extension MAV {
    public struct LocalPositionNedSystemGlobalOffset: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 89, name: "LOCAL_POSITION_NED_SYSTEM_GLOBAL_OFFSET", crcExtra: 231, minLength: 28, length: 28)
        public var timeBootMs: UInt32
        public var x: Float
        public var y: Float
        public var z: Float
        public var roll: Float
        public var pitch: Float
        public var yaw: Float

        public init(timeBootMs: UInt32 = 0, x: Float = 0, y: Float = 0, z: Float = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0) {
            self.timeBootMs = timeBootMs
            self.x = x
            self.y = y
            self.z = z
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.x = p.float(4)
            self.y = p.float(8)
            self.z = p.float(12)
            self.roll = p.float(16)
            self.pitch = p.float(20)
            self.yaw = p.float(24)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.x, 4)
            w.put(self.y, 8)
            w.put(self.z, 12)
            w.put(self.roll, 16)
            w.put(self.pitch, 20)
            w.put(self.yaw, 24)
        }
    }
}

/// HIL_STATE (#90)
extension MAV {
    public struct HilState: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 90, name: "HIL_STATE", crcExtra: 183, minLength: 56, length: 56)
        public var timeUsec: UInt64
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var rollspeed: Float
        public var pitchspeed: Float
        public var yawspeed: Float
        public var lat: Int32
        public var lon: Int32
        public var alt: Int32
        public var vx: Int16
        public var vy: Int16
        public var vz: Int16
        public var xacc: Int16
        public var yacc: Int16
        public var zacc: Int16

        public init(timeUsec: UInt64 = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0, rollspeed: Float = 0, pitchspeed: Float = 0, yawspeed: Float = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Int32 = 0, vx: Int16 = 0, vy: Int16 = 0, vz: Int16 = 0, xacc: Int16 = 0, yacc: Int16 = 0, zacc: Int16 = 0) {
            self.timeUsec = timeUsec
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.rollspeed = rollspeed
            self.pitchspeed = pitchspeed
            self.yawspeed = yawspeed
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.roll = p.float(8)
            self.pitch = p.float(12)
            self.yaw = p.float(16)
            self.rollspeed = p.float(20)
            self.pitchspeed = p.float(24)
            self.yawspeed = p.float(28)
            self.lat = p.int32(32)
            self.lon = p.int32(36)
            self.alt = p.int32(40)
            self.vx = p.int16(44)
            self.vy = p.int16(46)
            self.vz = p.int16(48)
            self.xacc = p.int16(50)
            self.yacc = p.int16(52)
            self.zacc = p.int16(54)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.roll, 8)
            w.put(self.pitch, 12)
            w.put(self.yaw, 16)
            w.put(self.rollspeed, 20)
            w.put(self.pitchspeed, 24)
            w.put(self.yawspeed, 28)
            w.put(self.lat, 32)
            w.put(self.lon, 36)
            w.put(self.alt, 40)
            w.put(self.vx, 44)
            w.put(self.vy, 46)
            w.put(self.vz, 48)
            w.put(self.xacc, 50)
            w.put(self.yacc, 52)
            w.put(self.zacc, 54)
        }
    }
}

/// HIL_CONTROLS (#91)
extension MAV {
    public struct HilControls: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 91, name: "HIL_CONTROLS", crcExtra: 63, minLength: 42, length: 42)
        public var timeUsec: UInt64
        public var rollAilerons: Float
        public var pitchElevator: Float
        public var yawRudder: Float
        public var throttle: Float
        public var aux1: Float
        public var aux2: Float
        public var aux3: Float
        public var aux4: Float
        public var mode: UInt8
        public var navMode: UInt8

        public init(timeUsec: UInt64 = 0, rollAilerons: Float = 0, pitchElevator: Float = 0, yawRudder: Float = 0, throttle: Float = 0, aux1: Float = 0, aux2: Float = 0, aux3: Float = 0, aux4: Float = 0, mode: UInt8 = 0, navMode: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.rollAilerons = rollAilerons
            self.pitchElevator = pitchElevator
            self.yawRudder = yawRudder
            self.throttle = throttle
            self.aux1 = aux1
            self.aux2 = aux2
            self.aux3 = aux3
            self.aux4 = aux4
            self.mode = mode
            self.navMode = navMode
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.rollAilerons = p.float(8)
            self.pitchElevator = p.float(12)
            self.yawRudder = p.float(16)
            self.throttle = p.float(20)
            self.aux1 = p.float(24)
            self.aux2 = p.float(28)
            self.aux3 = p.float(32)
            self.aux4 = p.float(36)
            self.mode = p.uint8(40)
            self.navMode = p.uint8(41)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.rollAilerons, 8)
            w.put(self.pitchElevator, 12)
            w.put(self.yawRudder, 16)
            w.put(self.throttle, 20)
            w.put(self.aux1, 24)
            w.put(self.aux2, 28)
            w.put(self.aux3, 32)
            w.put(self.aux4, 36)
            w.put(self.mode, 40)
            w.put(self.navMode, 41)
        }
    }
}

/// HIL_RC_INPUTS_RAW (#92)
extension MAV {
    public struct HilRcInputsRaw: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 92, name: "HIL_RC_INPUTS_RAW", crcExtra: 54, minLength: 33, length: 33)
        public var timeUsec: UInt64
        public var chan1Raw: UInt16
        public var chan2Raw: UInt16
        public var chan3Raw: UInt16
        public var chan4Raw: UInt16
        public var chan5Raw: UInt16
        public var chan6Raw: UInt16
        public var chan7Raw: UInt16
        public var chan8Raw: UInt16
        public var chan9Raw: UInt16
        public var chan10Raw: UInt16
        public var chan11Raw: UInt16
        public var chan12Raw: UInt16
        public var rssi: UInt8

        public init(timeUsec: UInt64 = 0, chan1Raw: UInt16 = 0, chan2Raw: UInt16 = 0, chan3Raw: UInt16 = 0, chan4Raw: UInt16 = 0, chan5Raw: UInt16 = 0, chan6Raw: UInt16 = 0, chan7Raw: UInt16 = 0, chan8Raw: UInt16 = 0, chan9Raw: UInt16 = 0, chan10Raw: UInt16 = 0, chan11Raw: UInt16 = 0, chan12Raw: UInt16 = 0, rssi: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.chan1Raw = chan1Raw
            self.chan2Raw = chan2Raw
            self.chan3Raw = chan3Raw
            self.chan4Raw = chan4Raw
            self.chan5Raw = chan5Raw
            self.chan6Raw = chan6Raw
            self.chan7Raw = chan7Raw
            self.chan8Raw = chan8Raw
            self.chan9Raw = chan9Raw
            self.chan10Raw = chan10Raw
            self.chan11Raw = chan11Raw
            self.chan12Raw = chan12Raw
            self.rssi = rssi
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.chan1Raw = p.uint16(8)
            self.chan2Raw = p.uint16(10)
            self.chan3Raw = p.uint16(12)
            self.chan4Raw = p.uint16(14)
            self.chan5Raw = p.uint16(16)
            self.chan6Raw = p.uint16(18)
            self.chan7Raw = p.uint16(20)
            self.chan8Raw = p.uint16(22)
            self.chan9Raw = p.uint16(24)
            self.chan10Raw = p.uint16(26)
            self.chan11Raw = p.uint16(28)
            self.chan12Raw = p.uint16(30)
            self.rssi = p.uint8(32)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.chan1Raw, 8)
            w.put(self.chan2Raw, 10)
            w.put(self.chan3Raw, 12)
            w.put(self.chan4Raw, 14)
            w.put(self.chan5Raw, 16)
            w.put(self.chan6Raw, 18)
            w.put(self.chan7Raw, 20)
            w.put(self.chan8Raw, 22)
            w.put(self.chan9Raw, 24)
            w.put(self.chan10Raw, 26)
            w.put(self.chan11Raw, 28)
            w.put(self.chan12Raw, 30)
            w.put(self.rssi, 32)
        }
    }
}

/// HIL_ACTUATOR_CONTROLS (#93)
extension MAV {
    public struct HilActuatorControls: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 93, name: "HIL_ACTUATOR_CONTROLS", crcExtra: 47, minLength: 81, length: 81)
        public var timeUsec: UInt64
        public var flags: UInt64
        public var controls: [Float]
        public var mode: UInt8

        public init(timeUsec: UInt64 = 0, flags: UInt64 = 0, controls: [Float] = [Float](repeating: 0, count: 16), mode: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.flags = flags
            self.controls = controls
            self.mode = mode
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.flags = p.uint64(8)
            self.controls = (0..<16).map { p.float(16 + $0 * 4) }
            self.mode = p.uint8(80)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.flags, 8)
            for k in 0..<Swift.min(16, self.controls.count) { w.put(self.controls[k], 16 + k * 4) }
            w.put(self.mode, 80)
        }
    }
}

/// OPTICAL_FLOW (#100)
extension MAV {
    public struct OpticalFlow: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 100, name: "OPTICAL_FLOW", crcExtra: 175, minLength: 26, length: 34)
        public var timeUsec: UInt64
        public var flowCompMX: Float
        public var flowCompMY: Float
        public var groundDistance: Float
        public var flowX: Int16
        public var flowY: Int16
        public var sensorId: UInt8
        public var quality: UInt8
        public var flowRateX: Float  // extension field
        public var flowRateY: Float  // extension field

        public init(timeUsec: UInt64 = 0, flowCompMX: Float = 0, flowCompMY: Float = 0, groundDistance: Float = 0, flowX: Int16 = 0, flowY: Int16 = 0, sensorId: UInt8 = 0, quality: UInt8 = 0, flowRateX: Float = 0, flowRateY: Float = 0) {
            self.timeUsec = timeUsec
            self.flowCompMX = flowCompMX
            self.flowCompMY = flowCompMY
            self.groundDistance = groundDistance
            self.flowX = flowX
            self.flowY = flowY
            self.sensorId = sensorId
            self.quality = quality
            self.flowRateX = flowRateX
            self.flowRateY = flowRateY
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.flowCompMX = p.float(8)
            self.flowCompMY = p.float(12)
            self.groundDistance = p.float(16)
            self.flowX = p.int16(20)
            self.flowY = p.int16(22)
            self.sensorId = p.uint8(24)
            self.quality = p.uint8(25)
            self.flowRateX = p.float(26)
            self.flowRateY = p.float(30)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.flowCompMX, 8)
            w.put(self.flowCompMY, 12)
            w.put(self.groundDistance, 16)
            w.put(self.flowX, 20)
            w.put(self.flowY, 22)
            w.put(self.sensorId, 24)
            w.put(self.quality, 25)
            w.put(self.flowRateX, 26)
            w.put(self.flowRateY, 30)
        }
    }
}

/// GLOBAL_VISION_POSITION_ESTIMATE (#101)
extension MAV {
    public struct GlobalVisionPositionEstimate: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 101, name: "GLOBAL_VISION_POSITION_ESTIMATE", crcExtra: 102, minLength: 32, length: 117)
        public var usec: UInt64
        public var x: Float
        public var y: Float
        public var z: Float
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var covariance: [Float]  // extension field
        public var resetCounter: UInt8  // extension field

        public init(usec: UInt64 = 0, x: Float = 0, y: Float = 0, z: Float = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0, covariance: [Float] = [Float](repeating: 0, count: 21), resetCounter: UInt8 = 0) {
            self.usec = usec
            self.x = x
            self.y = y
            self.z = z
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.covariance = covariance
            self.resetCounter = resetCounter
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.usec = p.uint64(0)
            self.x = p.float(8)
            self.y = p.float(12)
            self.z = p.float(16)
            self.roll = p.float(20)
            self.pitch = p.float(24)
            self.yaw = p.float(28)
            self.covariance = (0..<21).map { p.float(32 + $0 * 4) }
            self.resetCounter = p.uint8(116)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.usec, 0)
            w.put(self.x, 8)
            w.put(self.y, 12)
            w.put(self.z, 16)
            w.put(self.roll, 20)
            w.put(self.pitch, 24)
            w.put(self.yaw, 28)
            for k in 0..<Swift.min(21, self.covariance.count) { w.put(self.covariance[k], 32 + k * 4) }
            w.put(self.resetCounter, 116)
        }
    }
}

/// VISION_POSITION_ESTIMATE (#102)
extension MAV {
    public struct VisionPositionEstimate: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 102, name: "VISION_POSITION_ESTIMATE", crcExtra: 158, minLength: 32, length: 117)
        public var usec: UInt64
        public var x: Float
        public var y: Float
        public var z: Float
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var covariance: [Float]  // extension field
        public var resetCounter: UInt8  // extension field

        public init(usec: UInt64 = 0, x: Float = 0, y: Float = 0, z: Float = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0, covariance: [Float] = [Float](repeating: 0, count: 21), resetCounter: UInt8 = 0) {
            self.usec = usec
            self.x = x
            self.y = y
            self.z = z
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.covariance = covariance
            self.resetCounter = resetCounter
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.usec = p.uint64(0)
            self.x = p.float(8)
            self.y = p.float(12)
            self.z = p.float(16)
            self.roll = p.float(20)
            self.pitch = p.float(24)
            self.yaw = p.float(28)
            self.covariance = (0..<21).map { p.float(32 + $0 * 4) }
            self.resetCounter = p.uint8(116)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.usec, 0)
            w.put(self.x, 8)
            w.put(self.y, 12)
            w.put(self.z, 16)
            w.put(self.roll, 20)
            w.put(self.pitch, 24)
            w.put(self.yaw, 28)
            for k in 0..<Swift.min(21, self.covariance.count) { w.put(self.covariance[k], 32 + k * 4) }
            w.put(self.resetCounter, 116)
        }
    }
}

/// VISION_SPEED_ESTIMATE (#103)
extension MAV {
    public struct VisionSpeedEstimate: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 103, name: "VISION_SPEED_ESTIMATE", crcExtra: 208, minLength: 20, length: 57)
        public var usec: UInt64
        public var x: Float
        public var y: Float
        public var z: Float
        public var covariance: [Float]  // extension field
        public var resetCounter: UInt8  // extension field

        public init(usec: UInt64 = 0, x: Float = 0, y: Float = 0, z: Float = 0, covariance: [Float] = [Float](repeating: 0, count: 9), resetCounter: UInt8 = 0) {
            self.usec = usec
            self.x = x
            self.y = y
            self.z = z
            self.covariance = covariance
            self.resetCounter = resetCounter
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.usec = p.uint64(0)
            self.x = p.float(8)
            self.y = p.float(12)
            self.z = p.float(16)
            self.covariance = (0..<9).map { p.float(20 + $0 * 4) }
            self.resetCounter = p.uint8(56)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.usec, 0)
            w.put(self.x, 8)
            w.put(self.y, 12)
            w.put(self.z, 16)
            for k in 0..<Swift.min(9, self.covariance.count) { w.put(self.covariance[k], 20 + k * 4) }
            w.put(self.resetCounter, 56)
        }
    }
}

/// VICON_POSITION_ESTIMATE (#104)
extension MAV {
    public struct ViconPositionEstimate: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 104, name: "VICON_POSITION_ESTIMATE", crcExtra: 56, minLength: 32, length: 116)
        public var usec: UInt64
        public var x: Float
        public var y: Float
        public var z: Float
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var covariance: [Float]  // extension field

        public init(usec: UInt64 = 0, x: Float = 0, y: Float = 0, z: Float = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0, covariance: [Float] = [Float](repeating: 0, count: 21)) {
            self.usec = usec
            self.x = x
            self.y = y
            self.z = z
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.covariance = covariance
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.usec = p.uint64(0)
            self.x = p.float(8)
            self.y = p.float(12)
            self.z = p.float(16)
            self.roll = p.float(20)
            self.pitch = p.float(24)
            self.yaw = p.float(28)
            self.covariance = (0..<21).map { p.float(32 + $0 * 4) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.usec, 0)
            w.put(self.x, 8)
            w.put(self.y, 12)
            w.put(self.z, 16)
            w.put(self.roll, 20)
            w.put(self.pitch, 24)
            w.put(self.yaw, 28)
            for k in 0..<Swift.min(21, self.covariance.count) { w.put(self.covariance[k], 32 + k * 4) }
        }
    }
}

/// HIGHRES_IMU (#105)
extension MAV {
    public struct HighresImu: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 105, name: "HIGHRES_IMU", crcExtra: 93, minLength: 62, length: 63)
        public var timeUsec: UInt64
        public var xacc: Float
        public var yacc: Float
        public var zacc: Float
        public var xgyro: Float
        public var ygyro: Float
        public var zgyro: Float
        public var xmag: Float
        public var ymag: Float
        public var zmag: Float
        public var absPressure: Float
        public var diffPressure: Float
        public var pressureAlt: Float
        public var temperature: Float
        public var fieldsUpdated: UInt16
        public var id: UInt8  // extension field

        public init(timeUsec: UInt64 = 0, xacc: Float = 0, yacc: Float = 0, zacc: Float = 0, xgyro: Float = 0, ygyro: Float = 0, zgyro: Float = 0, xmag: Float = 0, ymag: Float = 0, zmag: Float = 0, absPressure: Float = 0, diffPressure: Float = 0, pressureAlt: Float = 0, temperature: Float = 0, fieldsUpdated: UInt16 = 0, id: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
            self.xgyro = xgyro
            self.ygyro = ygyro
            self.zgyro = zgyro
            self.xmag = xmag
            self.ymag = ymag
            self.zmag = zmag
            self.absPressure = absPressure
            self.diffPressure = diffPressure
            self.pressureAlt = pressureAlt
            self.temperature = temperature
            self.fieldsUpdated = fieldsUpdated
            self.id = id
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.xacc = p.float(8)
            self.yacc = p.float(12)
            self.zacc = p.float(16)
            self.xgyro = p.float(20)
            self.ygyro = p.float(24)
            self.zgyro = p.float(28)
            self.xmag = p.float(32)
            self.ymag = p.float(36)
            self.zmag = p.float(40)
            self.absPressure = p.float(44)
            self.diffPressure = p.float(48)
            self.pressureAlt = p.float(52)
            self.temperature = p.float(56)
            self.fieldsUpdated = p.uint16(60)
            self.id = p.uint8(62)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.xacc, 8)
            w.put(self.yacc, 12)
            w.put(self.zacc, 16)
            w.put(self.xgyro, 20)
            w.put(self.ygyro, 24)
            w.put(self.zgyro, 28)
            w.put(self.xmag, 32)
            w.put(self.ymag, 36)
            w.put(self.zmag, 40)
            w.put(self.absPressure, 44)
            w.put(self.diffPressure, 48)
            w.put(self.pressureAlt, 52)
            w.put(self.temperature, 56)
            w.put(self.fieldsUpdated, 60)
            w.put(self.id, 62)
        }
    }
}

/// OPTICAL_FLOW_RAD (#106)
extension MAV {
    public struct OpticalFlowRad: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 106, name: "OPTICAL_FLOW_RAD", crcExtra: 138, minLength: 44, length: 44)
        public var timeUsec: UInt64
        public var integrationTimeUs: UInt32
        public var integratedX: Float
        public var integratedY: Float
        public var integratedXgyro: Float
        public var integratedYgyro: Float
        public var integratedZgyro: Float
        public var timeDeltaDistanceUs: UInt32
        public var distance: Float
        public var temperature: Int16
        public var sensorId: UInt8
        public var quality: UInt8

        public init(timeUsec: UInt64 = 0, integrationTimeUs: UInt32 = 0, integratedX: Float = 0, integratedY: Float = 0, integratedXgyro: Float = 0, integratedYgyro: Float = 0, integratedZgyro: Float = 0, timeDeltaDistanceUs: UInt32 = 0, distance: Float = 0, temperature: Int16 = 0, sensorId: UInt8 = 0, quality: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.integrationTimeUs = integrationTimeUs
            self.integratedX = integratedX
            self.integratedY = integratedY
            self.integratedXgyro = integratedXgyro
            self.integratedYgyro = integratedYgyro
            self.integratedZgyro = integratedZgyro
            self.timeDeltaDistanceUs = timeDeltaDistanceUs
            self.distance = distance
            self.temperature = temperature
            self.sensorId = sensorId
            self.quality = quality
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.integrationTimeUs = p.uint32(8)
            self.integratedX = p.float(12)
            self.integratedY = p.float(16)
            self.integratedXgyro = p.float(20)
            self.integratedYgyro = p.float(24)
            self.integratedZgyro = p.float(28)
            self.timeDeltaDistanceUs = p.uint32(32)
            self.distance = p.float(36)
            self.temperature = p.int16(40)
            self.sensorId = p.uint8(42)
            self.quality = p.uint8(43)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.integrationTimeUs, 8)
            w.put(self.integratedX, 12)
            w.put(self.integratedY, 16)
            w.put(self.integratedXgyro, 20)
            w.put(self.integratedYgyro, 24)
            w.put(self.integratedZgyro, 28)
            w.put(self.timeDeltaDistanceUs, 32)
            w.put(self.distance, 36)
            w.put(self.temperature, 40)
            w.put(self.sensorId, 42)
            w.put(self.quality, 43)
        }
    }
}

/// HIL_SENSOR (#107)
extension MAV {
    public struct HilSensor: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 107, name: "HIL_SENSOR", crcExtra: 108, minLength: 64, length: 65)
        public var timeUsec: UInt64
        public var xacc: Float
        public var yacc: Float
        public var zacc: Float
        public var xgyro: Float
        public var ygyro: Float
        public var zgyro: Float
        public var xmag: Float
        public var ymag: Float
        public var zmag: Float
        public var absPressure: Float
        public var diffPressure: Float
        public var pressureAlt: Float
        public var temperature: Float
        public var fieldsUpdated: UInt32
        public var id: UInt8  // extension field

        public init(timeUsec: UInt64 = 0, xacc: Float = 0, yacc: Float = 0, zacc: Float = 0, xgyro: Float = 0, ygyro: Float = 0, zgyro: Float = 0, xmag: Float = 0, ymag: Float = 0, zmag: Float = 0, absPressure: Float = 0, diffPressure: Float = 0, pressureAlt: Float = 0, temperature: Float = 0, fieldsUpdated: UInt32 = 0, id: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
            self.xgyro = xgyro
            self.ygyro = ygyro
            self.zgyro = zgyro
            self.xmag = xmag
            self.ymag = ymag
            self.zmag = zmag
            self.absPressure = absPressure
            self.diffPressure = diffPressure
            self.pressureAlt = pressureAlt
            self.temperature = temperature
            self.fieldsUpdated = fieldsUpdated
            self.id = id
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.xacc = p.float(8)
            self.yacc = p.float(12)
            self.zacc = p.float(16)
            self.xgyro = p.float(20)
            self.ygyro = p.float(24)
            self.zgyro = p.float(28)
            self.xmag = p.float(32)
            self.ymag = p.float(36)
            self.zmag = p.float(40)
            self.absPressure = p.float(44)
            self.diffPressure = p.float(48)
            self.pressureAlt = p.float(52)
            self.temperature = p.float(56)
            self.fieldsUpdated = p.uint32(60)
            self.id = p.uint8(64)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.xacc, 8)
            w.put(self.yacc, 12)
            w.put(self.zacc, 16)
            w.put(self.xgyro, 20)
            w.put(self.ygyro, 24)
            w.put(self.zgyro, 28)
            w.put(self.xmag, 32)
            w.put(self.ymag, 36)
            w.put(self.zmag, 40)
            w.put(self.absPressure, 44)
            w.put(self.diffPressure, 48)
            w.put(self.pressureAlt, 52)
            w.put(self.temperature, 56)
            w.put(self.fieldsUpdated, 60)
            w.put(self.id, 64)
        }
    }
}

/// SIM_STATE (#108)
extension MAV {
    public struct SimState: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 108, name: "SIM_STATE", crcExtra: 32, minLength: 84, length: 92)
        public var q1: Float
        public var q2: Float
        public var q3: Float
        public var q4: Float
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var xacc: Float
        public var yacc: Float
        public var zacc: Float
        public var xgyro: Float
        public var ygyro: Float
        public var zgyro: Float
        public var lat: Float
        public var lon: Float
        public var alt: Float
        public var stdDevHorz: Float
        public var stdDevVert: Float
        public var vn: Float
        public var ve: Float
        public var vd: Float
        public var latInt: Int32  // extension field
        public var lonInt: Int32  // extension field

        public init(q1: Float = 0, q2: Float = 0, q3: Float = 0, q4: Float = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0, xacc: Float = 0, yacc: Float = 0, zacc: Float = 0, xgyro: Float = 0, ygyro: Float = 0, zgyro: Float = 0, lat: Float = 0, lon: Float = 0, alt: Float = 0, stdDevHorz: Float = 0, stdDevVert: Float = 0, vn: Float = 0, ve: Float = 0, vd: Float = 0, latInt: Int32 = 0, lonInt: Int32 = 0) {
            self.q1 = q1
            self.q2 = q2
            self.q3 = q3
            self.q4 = q4
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
            self.xgyro = xgyro
            self.ygyro = ygyro
            self.zgyro = zgyro
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.stdDevHorz = stdDevHorz
            self.stdDevVert = stdDevVert
            self.vn = vn
            self.ve = ve
            self.vd = vd
            self.latInt = latInt
            self.lonInt = lonInt
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.q1 = p.float(0)
            self.q2 = p.float(4)
            self.q3 = p.float(8)
            self.q4 = p.float(12)
            self.roll = p.float(16)
            self.pitch = p.float(20)
            self.yaw = p.float(24)
            self.xacc = p.float(28)
            self.yacc = p.float(32)
            self.zacc = p.float(36)
            self.xgyro = p.float(40)
            self.ygyro = p.float(44)
            self.zgyro = p.float(48)
            self.lat = p.float(52)
            self.lon = p.float(56)
            self.alt = p.float(60)
            self.stdDevHorz = p.float(64)
            self.stdDevVert = p.float(68)
            self.vn = p.float(72)
            self.ve = p.float(76)
            self.vd = p.float(80)
            self.latInt = p.int32(84)
            self.lonInt = p.int32(88)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.q1, 0)
            w.put(self.q2, 4)
            w.put(self.q3, 8)
            w.put(self.q4, 12)
            w.put(self.roll, 16)
            w.put(self.pitch, 20)
            w.put(self.yaw, 24)
            w.put(self.xacc, 28)
            w.put(self.yacc, 32)
            w.put(self.zacc, 36)
            w.put(self.xgyro, 40)
            w.put(self.ygyro, 44)
            w.put(self.zgyro, 48)
            w.put(self.lat, 52)
            w.put(self.lon, 56)
            w.put(self.alt, 60)
            w.put(self.stdDevHorz, 64)
            w.put(self.stdDevVert, 68)
            w.put(self.vn, 72)
            w.put(self.ve, 76)
            w.put(self.vd, 80)
            w.put(self.latInt, 84)
            w.put(self.lonInt, 88)
        }
    }
}

/// RADIO_STATUS (#109)
extension MAV {
    public struct RadioStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 109, name: "RADIO_STATUS", crcExtra: 185, minLength: 9, length: 9)
        public var rxerrors: UInt16
        public var fixed: UInt16
        public var rssi: UInt8
        public var remrssi: UInt8
        public var txbuf: UInt8
        public var noise: UInt8
        public var remnoise: UInt8

        public init(rxerrors: UInt16 = 0, fixed: UInt16 = 0, rssi: UInt8 = 0, remrssi: UInt8 = 0, txbuf: UInt8 = 0, noise: UInt8 = 0, remnoise: UInt8 = 0) {
            self.rxerrors = rxerrors
            self.fixed = fixed
            self.rssi = rssi
            self.remrssi = remrssi
            self.txbuf = txbuf
            self.noise = noise
            self.remnoise = remnoise
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.rxerrors = p.uint16(0)
            self.fixed = p.uint16(2)
            self.rssi = p.uint8(4)
            self.remrssi = p.uint8(5)
            self.txbuf = p.uint8(6)
            self.noise = p.uint8(7)
            self.remnoise = p.uint8(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.rxerrors, 0)
            w.put(self.fixed, 2)
            w.put(self.rssi, 4)
            w.put(self.remrssi, 5)
            w.put(self.txbuf, 6)
            w.put(self.noise, 7)
            w.put(self.remnoise, 8)
        }
    }
}

/// FILE_TRANSFER_PROTOCOL (#110)
extension MAV {
    public struct FileTransferProtocol: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 110, name: "FILE_TRANSFER_PROTOCOL", crcExtra: 84, minLength: 254, length: 254)
        public var targetNetwork: UInt8
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var payload: [UInt8]

        public init(targetNetwork: UInt8 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, payload: [UInt8] = [UInt8](repeating: 0, count: 251)) {
            self.targetNetwork = targetNetwork
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.payload = payload
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetNetwork = p.uint8(0)
            self.targetSystem = p.uint8(1)
            self.targetComponent = p.uint8(2)
            self.payload = (0..<251).map { p.uint8(3 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetNetwork, 0)
            w.put(self.targetSystem, 1)
            w.put(self.targetComponent, 2)
            for k in 0..<Swift.min(251, self.payload.count) { w.put(self.payload[k], 3 + k * 1) }
        }
    }
}

/// TIMESYNC (#111)
extension MAV {
    public struct Timesync: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 111, name: "TIMESYNC", crcExtra: 34, minLength: 16, length: 16)
        public var tc1: Int64
        public var ts1: Int64

        public init(tc1: Int64 = 0, ts1: Int64 = 0) {
            self.tc1 = tc1
            self.ts1 = ts1
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.tc1 = p.int64(0)
            self.ts1 = p.int64(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.tc1, 0)
            w.put(self.ts1, 8)
        }
    }
}

/// CAMERA_TRIGGER (#112)
extension MAV {
    public struct CameraTrigger: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 112, name: "CAMERA_TRIGGER", crcExtra: 174, minLength: 12, length: 12)
        public var timeUsec: UInt64
        public var seq: UInt32

        public init(timeUsec: UInt64 = 0, seq: UInt32 = 0) {
            self.timeUsec = timeUsec
            self.seq = seq
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.seq = p.uint32(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.seq, 8)
        }
    }
}

/// HIL_GPS (#113)
extension MAV {
    public struct HilGps: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 113, name: "HIL_GPS", crcExtra: 124, minLength: 36, length: 39)
        public var timeUsec: UInt64
        public var lat: Int32
        public var lon: Int32
        public var alt: Int32
        public var eph: UInt16
        public var epv: UInt16
        public var vel: UInt16
        public var vn: Int16
        public var ve: Int16
        public var vd: Int16
        public var cog: UInt16
        public var fixType: UInt8
        public var satellitesVisible: UInt8
        public var id: UInt8  // extension field
        public var yaw: UInt16  // extension field

        public init(timeUsec: UInt64 = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Int32 = 0, eph: UInt16 = 0, epv: UInt16 = 0, vel: UInt16 = 0, vn: Int16 = 0, ve: Int16 = 0, vd: Int16 = 0, cog: UInt16 = 0, fixType: UInt8 = 0, satellitesVisible: UInt8 = 0, id: UInt8 = 0, yaw: UInt16 = 0) {
            self.timeUsec = timeUsec
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.eph = eph
            self.epv = epv
            self.vel = vel
            self.vn = vn
            self.ve = ve
            self.vd = vd
            self.cog = cog
            self.fixType = fixType
            self.satellitesVisible = satellitesVisible
            self.id = id
            self.yaw = yaw
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.lat = p.int32(8)
            self.lon = p.int32(12)
            self.alt = p.int32(16)
            self.eph = p.uint16(20)
            self.epv = p.uint16(22)
            self.vel = p.uint16(24)
            self.vn = p.int16(26)
            self.ve = p.int16(28)
            self.vd = p.int16(30)
            self.cog = p.uint16(32)
            self.fixType = p.uint8(34)
            self.satellitesVisible = p.uint8(35)
            self.id = p.uint8(36)
            self.yaw = p.uint16(37)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.lat, 8)
            w.put(self.lon, 12)
            w.put(self.alt, 16)
            w.put(self.eph, 20)
            w.put(self.epv, 22)
            w.put(self.vel, 24)
            w.put(self.vn, 26)
            w.put(self.ve, 28)
            w.put(self.vd, 30)
            w.put(self.cog, 32)
            w.put(self.fixType, 34)
            w.put(self.satellitesVisible, 35)
            w.put(self.id, 36)
            w.put(self.yaw, 37)
        }
    }
}

/// HIL_OPTICAL_FLOW (#114)
extension MAV {
    public struct HilOpticalFlow: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 114, name: "HIL_OPTICAL_FLOW", crcExtra: 237, minLength: 44, length: 44)
        public var timeUsec: UInt64
        public var integrationTimeUs: UInt32
        public var integratedX: Float
        public var integratedY: Float
        public var integratedXgyro: Float
        public var integratedYgyro: Float
        public var integratedZgyro: Float
        public var timeDeltaDistanceUs: UInt32
        public var distance: Float
        public var temperature: Int16
        public var sensorId: UInt8
        public var quality: UInt8

        public init(timeUsec: UInt64 = 0, integrationTimeUs: UInt32 = 0, integratedX: Float = 0, integratedY: Float = 0, integratedXgyro: Float = 0, integratedYgyro: Float = 0, integratedZgyro: Float = 0, timeDeltaDistanceUs: UInt32 = 0, distance: Float = 0, temperature: Int16 = 0, sensorId: UInt8 = 0, quality: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.integrationTimeUs = integrationTimeUs
            self.integratedX = integratedX
            self.integratedY = integratedY
            self.integratedXgyro = integratedXgyro
            self.integratedYgyro = integratedYgyro
            self.integratedZgyro = integratedZgyro
            self.timeDeltaDistanceUs = timeDeltaDistanceUs
            self.distance = distance
            self.temperature = temperature
            self.sensorId = sensorId
            self.quality = quality
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.integrationTimeUs = p.uint32(8)
            self.integratedX = p.float(12)
            self.integratedY = p.float(16)
            self.integratedXgyro = p.float(20)
            self.integratedYgyro = p.float(24)
            self.integratedZgyro = p.float(28)
            self.timeDeltaDistanceUs = p.uint32(32)
            self.distance = p.float(36)
            self.temperature = p.int16(40)
            self.sensorId = p.uint8(42)
            self.quality = p.uint8(43)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.integrationTimeUs, 8)
            w.put(self.integratedX, 12)
            w.put(self.integratedY, 16)
            w.put(self.integratedXgyro, 20)
            w.put(self.integratedYgyro, 24)
            w.put(self.integratedZgyro, 28)
            w.put(self.timeDeltaDistanceUs, 32)
            w.put(self.distance, 36)
            w.put(self.temperature, 40)
            w.put(self.sensorId, 42)
            w.put(self.quality, 43)
        }
    }
}

/// HIL_STATE_QUATERNION (#115)
extension MAV {
    public struct HilStateQuaternion: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 115, name: "HIL_STATE_QUATERNION", crcExtra: 4, minLength: 64, length: 64)
        public var timeUsec: UInt64
        public var attitudeQuaternion: [Float]
        public var rollspeed: Float
        public var pitchspeed: Float
        public var yawspeed: Float
        public var lat: Int32
        public var lon: Int32
        public var alt: Int32
        public var vx: Int16
        public var vy: Int16
        public var vz: Int16
        public var indAirspeed: UInt16
        public var trueAirspeed: UInt16
        public var xacc: Int16
        public var yacc: Int16
        public var zacc: Int16

        public init(timeUsec: UInt64 = 0, attitudeQuaternion: [Float] = [Float](repeating: 0, count: 4), rollspeed: Float = 0, pitchspeed: Float = 0, yawspeed: Float = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Int32 = 0, vx: Int16 = 0, vy: Int16 = 0, vz: Int16 = 0, indAirspeed: UInt16 = 0, trueAirspeed: UInt16 = 0, xacc: Int16 = 0, yacc: Int16 = 0, zacc: Int16 = 0) {
            self.timeUsec = timeUsec
            self.attitudeQuaternion = attitudeQuaternion
            self.rollspeed = rollspeed
            self.pitchspeed = pitchspeed
            self.yawspeed = yawspeed
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.indAirspeed = indAirspeed
            self.trueAirspeed = trueAirspeed
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.attitudeQuaternion = (0..<4).map { p.float(8 + $0 * 4) }
            self.rollspeed = p.float(24)
            self.pitchspeed = p.float(28)
            self.yawspeed = p.float(32)
            self.lat = p.int32(36)
            self.lon = p.int32(40)
            self.alt = p.int32(44)
            self.vx = p.int16(48)
            self.vy = p.int16(50)
            self.vz = p.int16(52)
            self.indAirspeed = p.uint16(54)
            self.trueAirspeed = p.uint16(56)
            self.xacc = p.int16(58)
            self.yacc = p.int16(60)
            self.zacc = p.int16(62)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            for k in 0..<Swift.min(4, self.attitudeQuaternion.count) { w.put(self.attitudeQuaternion[k], 8 + k * 4) }
            w.put(self.rollspeed, 24)
            w.put(self.pitchspeed, 28)
            w.put(self.yawspeed, 32)
            w.put(self.lat, 36)
            w.put(self.lon, 40)
            w.put(self.alt, 44)
            w.put(self.vx, 48)
            w.put(self.vy, 50)
            w.put(self.vz, 52)
            w.put(self.indAirspeed, 54)
            w.put(self.trueAirspeed, 56)
            w.put(self.xacc, 58)
            w.put(self.yacc, 60)
            w.put(self.zacc, 62)
        }
    }
}

/// SCALED_IMU2 (#116)
extension MAV {
    public struct ScaledImu2: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 116, name: "SCALED_IMU2", crcExtra: 76, minLength: 22, length: 24)
        public var timeBootMs: UInt32
        public var xacc: Int16
        public var yacc: Int16
        public var zacc: Int16
        public var xgyro: Int16
        public var ygyro: Int16
        public var zgyro: Int16
        public var xmag: Int16
        public var ymag: Int16
        public var zmag: Int16
        public var temperature: Int16  // extension field

        public init(timeBootMs: UInt32 = 0, xacc: Int16 = 0, yacc: Int16 = 0, zacc: Int16 = 0, xgyro: Int16 = 0, ygyro: Int16 = 0, zgyro: Int16 = 0, xmag: Int16 = 0, ymag: Int16 = 0, zmag: Int16 = 0, temperature: Int16 = 0) {
            self.timeBootMs = timeBootMs
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
            self.xgyro = xgyro
            self.ygyro = ygyro
            self.zgyro = zgyro
            self.xmag = xmag
            self.ymag = ymag
            self.zmag = zmag
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.xacc = p.int16(4)
            self.yacc = p.int16(6)
            self.zacc = p.int16(8)
            self.xgyro = p.int16(10)
            self.ygyro = p.int16(12)
            self.zgyro = p.int16(14)
            self.xmag = p.int16(16)
            self.ymag = p.int16(18)
            self.zmag = p.int16(20)
            self.temperature = p.int16(22)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.xacc, 4)
            w.put(self.yacc, 6)
            w.put(self.zacc, 8)
            w.put(self.xgyro, 10)
            w.put(self.ygyro, 12)
            w.put(self.zgyro, 14)
            w.put(self.xmag, 16)
            w.put(self.ymag, 18)
            w.put(self.zmag, 20)
            w.put(self.temperature, 22)
        }
    }
}

/// LOG_REQUEST_LIST (#117)
extension MAV {
    public struct LogRequestList: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 117, name: "LOG_REQUEST_LIST", crcExtra: 128, minLength: 6, length: 6)
        public var start: UInt16
        public var end: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(start: UInt16 = 0, end: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.start = start
            self.end = end
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.start = p.uint16(0)
            self.end = p.uint16(2)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.start, 0)
            w.put(self.end, 2)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
        }
    }
}

/// LOG_ENTRY (#118)
extension MAV {
    public struct LogEntry: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 118, name: "LOG_ENTRY", crcExtra: 56, minLength: 14, length: 14)
        public var timeUtc: UInt32
        public var size: UInt32
        public var id: UInt16
        public var numLogs: UInt16
        public var lastLogNum: UInt16

        public init(timeUtc: UInt32 = 0, size: UInt32 = 0, id: UInt16 = 0, numLogs: UInt16 = 0, lastLogNum: UInt16 = 0) {
            self.timeUtc = timeUtc
            self.size = size
            self.id = id
            self.numLogs = numLogs
            self.lastLogNum = lastLogNum
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUtc = p.uint32(0)
            self.size = p.uint32(4)
            self.id = p.uint16(8)
            self.numLogs = p.uint16(10)
            self.lastLogNum = p.uint16(12)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUtc, 0)
            w.put(self.size, 4)
            w.put(self.id, 8)
            w.put(self.numLogs, 10)
            w.put(self.lastLogNum, 12)
        }
    }
}

/// LOG_REQUEST_DATA (#119)
extension MAV {
    public struct LogRequestData: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 119, name: "LOG_REQUEST_DATA", crcExtra: 116, minLength: 12, length: 12)
        public var ofs: UInt32
        public var count: UInt32
        public var id: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(ofs: UInt32 = 0, count: UInt32 = 0, id: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.ofs = ofs
            self.count = count
            self.id = id
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.ofs = p.uint32(0)
            self.count = p.uint32(4)
            self.id = p.uint16(8)
            self.targetSystem = p.uint8(10)
            self.targetComponent = p.uint8(11)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.ofs, 0)
            w.put(self.count, 4)
            w.put(self.id, 8)
            w.put(self.targetSystem, 10)
            w.put(self.targetComponent, 11)
        }
    }
}

/// LOG_DATA (#120)
extension MAV {
    public struct LogData: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 120, name: "LOG_DATA", crcExtra: 134, minLength: 97, length: 97)
        public var ofs: UInt32
        public var id: UInt16
        public var count: UInt8
        public var data: [UInt8]

        public init(ofs: UInt32 = 0, id: UInt16 = 0, count: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 90)) {
            self.ofs = ofs
            self.id = id
            self.count = count
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.ofs = p.uint32(0)
            self.id = p.uint16(4)
            self.count = p.uint8(6)
            self.data = (0..<90).map { p.uint8(7 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.ofs, 0)
            w.put(self.id, 4)
            w.put(self.count, 6)
            for k in 0..<Swift.min(90, self.data.count) { w.put(self.data[k], 7 + k * 1) }
        }
    }
}

/// LOG_ERASE (#121)
extension MAV {
    public struct LogErase: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 121, name: "LOG_ERASE", crcExtra: 237, minLength: 2, length: 2)
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
        }
    }
}

/// LOG_REQUEST_END (#122)
extension MAV {
    public struct LogRequestEnd: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 122, name: "LOG_REQUEST_END", crcExtra: 203, minLength: 2, length: 2)
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
        }
    }
}

/// GPS_INJECT_DATA (#123)
extension MAV {
    public struct GpsInjectData: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 123, name: "GPS_INJECT_DATA", crcExtra: 250, minLength: 113, length: 113)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var len: UInt8
        public var data: [UInt8]

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, len: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 110)) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.len = len
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.len = p.uint8(2)
            self.data = (0..<110).map { p.uint8(3 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            w.put(self.len, 2)
            for k in 0..<Swift.min(110, self.data.count) { w.put(self.data[k], 3 + k * 1) }
        }
    }
}

/// GPS2_RAW (#124)
extension MAV {
    public struct Gps2Raw: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 124, name: "GPS2_RAW", crcExtra: 87, minLength: 35, length: 57)
        public var timeUsec: UInt64
        public var lat: Int32
        public var lon: Int32
        public var alt: Int32
        public var dgpsAge: UInt32
        public var eph: UInt16
        public var epv: UInt16
        public var vel: UInt16
        public var cog: UInt16
        public var fixType: UInt8
        public var satellitesVisible: UInt8
        public var dgpsNumch: UInt8
        public var yaw: UInt16  // extension field
        public var altEllipsoid: Int32  // extension field
        public var hAcc: UInt32  // extension field
        public var vAcc: UInt32  // extension field
        public var velAcc: UInt32  // extension field
        public var hdgAcc: UInt32  // extension field

        public init(timeUsec: UInt64 = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Int32 = 0, dgpsAge: UInt32 = 0, eph: UInt16 = 0, epv: UInt16 = 0, vel: UInt16 = 0, cog: UInt16 = 0, fixType: UInt8 = 0, satellitesVisible: UInt8 = 0, dgpsNumch: UInt8 = 0, yaw: UInt16 = 0, altEllipsoid: Int32 = 0, hAcc: UInt32 = 0, vAcc: UInt32 = 0, velAcc: UInt32 = 0, hdgAcc: UInt32 = 0) {
            self.timeUsec = timeUsec
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.dgpsAge = dgpsAge
            self.eph = eph
            self.epv = epv
            self.vel = vel
            self.cog = cog
            self.fixType = fixType
            self.satellitesVisible = satellitesVisible
            self.dgpsNumch = dgpsNumch
            self.yaw = yaw
            self.altEllipsoid = altEllipsoid
            self.hAcc = hAcc
            self.vAcc = vAcc
            self.velAcc = velAcc
            self.hdgAcc = hdgAcc
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.lat = p.int32(8)
            self.lon = p.int32(12)
            self.alt = p.int32(16)
            self.dgpsAge = p.uint32(20)
            self.eph = p.uint16(24)
            self.epv = p.uint16(26)
            self.vel = p.uint16(28)
            self.cog = p.uint16(30)
            self.fixType = p.uint8(32)
            self.satellitesVisible = p.uint8(33)
            self.dgpsNumch = p.uint8(34)
            self.yaw = p.uint16(35)
            self.altEllipsoid = p.int32(37)
            self.hAcc = p.uint32(41)
            self.vAcc = p.uint32(45)
            self.velAcc = p.uint32(49)
            self.hdgAcc = p.uint32(53)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.lat, 8)
            w.put(self.lon, 12)
            w.put(self.alt, 16)
            w.put(self.dgpsAge, 20)
            w.put(self.eph, 24)
            w.put(self.epv, 26)
            w.put(self.vel, 28)
            w.put(self.cog, 30)
            w.put(self.fixType, 32)
            w.put(self.satellitesVisible, 33)
            w.put(self.dgpsNumch, 34)
            w.put(self.yaw, 35)
            w.put(self.altEllipsoid, 37)
            w.put(self.hAcc, 41)
            w.put(self.vAcc, 45)
            w.put(self.velAcc, 49)
            w.put(self.hdgAcc, 53)
        }
    }
}

/// POWER_STATUS (#125)
extension MAV {
    public struct PowerStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 125, name: "POWER_STATUS", crcExtra: 203, minLength: 6, length: 6)
        public var Vcc: UInt16
        public var Vservo: UInt16
        public var flags: UInt16

        public init(Vcc: UInt16 = 0, Vservo: UInt16 = 0, flags: UInt16 = 0) {
            self.Vcc = Vcc
            self.Vservo = Vservo
            self.flags = flags
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.Vcc = p.uint16(0)
            self.Vservo = p.uint16(2)
            self.flags = p.uint16(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.Vcc, 0)
            w.put(self.Vservo, 2)
            w.put(self.flags, 4)
        }
    }
}

/// SERIAL_CONTROL (#126)
extension MAV {
    public struct SerialControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 126, name: "SERIAL_CONTROL", crcExtra: 220, minLength: 79, length: 79)
        public var baudrate: UInt32
        public var timeout: UInt16
        public var device: UInt8
        public var flags: UInt8
        public var count: UInt8
        public var data: [UInt8]

        public init(baudrate: UInt32 = 0, timeout: UInt16 = 0, device: UInt8 = 0, flags: UInt8 = 0, count: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 70)) {
            self.baudrate = baudrate
            self.timeout = timeout
            self.device = device
            self.flags = flags
            self.count = count
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.baudrate = p.uint32(0)
            self.timeout = p.uint16(4)
            self.device = p.uint8(6)
            self.flags = p.uint8(7)
            self.count = p.uint8(8)
            self.data = (0..<70).map { p.uint8(9 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.baudrate, 0)
            w.put(self.timeout, 4)
            w.put(self.device, 6)
            w.put(self.flags, 7)
            w.put(self.count, 8)
            for k in 0..<Swift.min(70, self.data.count) { w.put(self.data[k], 9 + k * 1) }
        }
    }
}

/// GPS_RTK (#127)
extension MAV {
    public struct GpsRtk: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 127, name: "GPS_RTK", crcExtra: 25, minLength: 35, length: 35)
        public var timeLastBaselineMs: UInt32
        public var tow: UInt32
        public var baselineAMm: Int32
        public var baselineBMm: Int32
        public var baselineCMm: Int32
        public var accuracy: UInt32
        public var iarNumHypotheses: Int32
        public var wn: UInt16
        public var rtkReceiverId: UInt8
        public var rtkHealth: UInt8
        public var rtkRate: UInt8
        public var nsats: UInt8
        public var baselineCoordsType: UInt8

        public init(timeLastBaselineMs: UInt32 = 0, tow: UInt32 = 0, baselineAMm: Int32 = 0, baselineBMm: Int32 = 0, baselineCMm: Int32 = 0, accuracy: UInt32 = 0, iarNumHypotheses: Int32 = 0, wn: UInt16 = 0, rtkReceiverId: UInt8 = 0, rtkHealth: UInt8 = 0, rtkRate: UInt8 = 0, nsats: UInt8 = 0, baselineCoordsType: UInt8 = 0) {
            self.timeLastBaselineMs = timeLastBaselineMs
            self.tow = tow
            self.baselineAMm = baselineAMm
            self.baselineBMm = baselineBMm
            self.baselineCMm = baselineCMm
            self.accuracy = accuracy
            self.iarNumHypotheses = iarNumHypotheses
            self.wn = wn
            self.rtkReceiverId = rtkReceiverId
            self.rtkHealth = rtkHealth
            self.rtkRate = rtkRate
            self.nsats = nsats
            self.baselineCoordsType = baselineCoordsType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeLastBaselineMs = p.uint32(0)
            self.tow = p.uint32(4)
            self.baselineAMm = p.int32(8)
            self.baselineBMm = p.int32(12)
            self.baselineCMm = p.int32(16)
            self.accuracy = p.uint32(20)
            self.iarNumHypotheses = p.int32(24)
            self.wn = p.uint16(28)
            self.rtkReceiverId = p.uint8(30)
            self.rtkHealth = p.uint8(31)
            self.rtkRate = p.uint8(32)
            self.nsats = p.uint8(33)
            self.baselineCoordsType = p.uint8(34)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeLastBaselineMs, 0)
            w.put(self.tow, 4)
            w.put(self.baselineAMm, 8)
            w.put(self.baselineBMm, 12)
            w.put(self.baselineCMm, 16)
            w.put(self.accuracy, 20)
            w.put(self.iarNumHypotheses, 24)
            w.put(self.wn, 28)
            w.put(self.rtkReceiverId, 30)
            w.put(self.rtkHealth, 31)
            w.put(self.rtkRate, 32)
            w.put(self.nsats, 33)
            w.put(self.baselineCoordsType, 34)
        }
    }
}

/// GPS2_RTK (#128)
extension MAV {
    public struct Gps2Rtk: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 128, name: "GPS2_RTK", crcExtra: 226, minLength: 35, length: 35)
        public var timeLastBaselineMs: UInt32
        public var tow: UInt32
        public var baselineAMm: Int32
        public var baselineBMm: Int32
        public var baselineCMm: Int32
        public var accuracy: UInt32
        public var iarNumHypotheses: Int32
        public var wn: UInt16
        public var rtkReceiverId: UInt8
        public var rtkHealth: UInt8
        public var rtkRate: UInt8
        public var nsats: UInt8
        public var baselineCoordsType: UInt8

        public init(timeLastBaselineMs: UInt32 = 0, tow: UInt32 = 0, baselineAMm: Int32 = 0, baselineBMm: Int32 = 0, baselineCMm: Int32 = 0, accuracy: UInt32 = 0, iarNumHypotheses: Int32 = 0, wn: UInt16 = 0, rtkReceiverId: UInt8 = 0, rtkHealth: UInt8 = 0, rtkRate: UInt8 = 0, nsats: UInt8 = 0, baselineCoordsType: UInt8 = 0) {
            self.timeLastBaselineMs = timeLastBaselineMs
            self.tow = tow
            self.baselineAMm = baselineAMm
            self.baselineBMm = baselineBMm
            self.baselineCMm = baselineCMm
            self.accuracy = accuracy
            self.iarNumHypotheses = iarNumHypotheses
            self.wn = wn
            self.rtkReceiverId = rtkReceiverId
            self.rtkHealth = rtkHealth
            self.rtkRate = rtkRate
            self.nsats = nsats
            self.baselineCoordsType = baselineCoordsType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeLastBaselineMs = p.uint32(0)
            self.tow = p.uint32(4)
            self.baselineAMm = p.int32(8)
            self.baselineBMm = p.int32(12)
            self.baselineCMm = p.int32(16)
            self.accuracy = p.uint32(20)
            self.iarNumHypotheses = p.int32(24)
            self.wn = p.uint16(28)
            self.rtkReceiverId = p.uint8(30)
            self.rtkHealth = p.uint8(31)
            self.rtkRate = p.uint8(32)
            self.nsats = p.uint8(33)
            self.baselineCoordsType = p.uint8(34)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeLastBaselineMs, 0)
            w.put(self.tow, 4)
            w.put(self.baselineAMm, 8)
            w.put(self.baselineBMm, 12)
            w.put(self.baselineCMm, 16)
            w.put(self.accuracy, 20)
            w.put(self.iarNumHypotheses, 24)
            w.put(self.wn, 28)
            w.put(self.rtkReceiverId, 30)
            w.put(self.rtkHealth, 31)
            w.put(self.rtkRate, 32)
            w.put(self.nsats, 33)
            w.put(self.baselineCoordsType, 34)
        }
    }
}

/// SCALED_IMU3 (#129)
extension MAV {
    public struct ScaledImu3: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 129, name: "SCALED_IMU3", crcExtra: 46, minLength: 22, length: 24)
        public var timeBootMs: UInt32
        public var xacc: Int16
        public var yacc: Int16
        public var zacc: Int16
        public var xgyro: Int16
        public var ygyro: Int16
        public var zgyro: Int16
        public var xmag: Int16
        public var ymag: Int16
        public var zmag: Int16
        public var temperature: Int16  // extension field

        public init(timeBootMs: UInt32 = 0, xacc: Int16 = 0, yacc: Int16 = 0, zacc: Int16 = 0, xgyro: Int16 = 0, ygyro: Int16 = 0, zgyro: Int16 = 0, xmag: Int16 = 0, ymag: Int16 = 0, zmag: Int16 = 0, temperature: Int16 = 0) {
            self.timeBootMs = timeBootMs
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
            self.xgyro = xgyro
            self.ygyro = ygyro
            self.zgyro = zgyro
            self.xmag = xmag
            self.ymag = ymag
            self.zmag = zmag
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.xacc = p.int16(4)
            self.yacc = p.int16(6)
            self.zacc = p.int16(8)
            self.xgyro = p.int16(10)
            self.ygyro = p.int16(12)
            self.zgyro = p.int16(14)
            self.xmag = p.int16(16)
            self.ymag = p.int16(18)
            self.zmag = p.int16(20)
            self.temperature = p.int16(22)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.xacc, 4)
            w.put(self.yacc, 6)
            w.put(self.zacc, 8)
            w.put(self.xgyro, 10)
            w.put(self.ygyro, 12)
            w.put(self.zgyro, 14)
            w.put(self.xmag, 16)
            w.put(self.ymag, 18)
            w.put(self.zmag, 20)
            w.put(self.temperature, 22)
        }
    }
}

/// DATA_TRANSMISSION_HANDSHAKE (#130)
extension MAV {
    public struct DataTransmissionHandshake: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 130, name: "DATA_TRANSMISSION_HANDSHAKE", crcExtra: 29, minLength: 13, length: 13)
        public var size: UInt32
        public var width: UInt16
        public var height: UInt16
        public var packets: UInt16
        public var type: UInt8
        public var payload: UInt8
        public var jpgQuality: UInt8

        public init(size: UInt32 = 0, width: UInt16 = 0, height: UInt16 = 0, packets: UInt16 = 0, type: UInt8 = 0, payload: UInt8 = 0, jpgQuality: UInt8 = 0) {
            self.size = size
            self.width = width
            self.height = height
            self.packets = packets
            self.type = type
            self.payload = payload
            self.jpgQuality = jpgQuality
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.size = p.uint32(0)
            self.width = p.uint16(4)
            self.height = p.uint16(6)
            self.packets = p.uint16(8)
            self.type = p.uint8(10)
            self.payload = p.uint8(11)
            self.jpgQuality = p.uint8(12)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.size, 0)
            w.put(self.width, 4)
            w.put(self.height, 6)
            w.put(self.packets, 8)
            w.put(self.type, 10)
            w.put(self.payload, 11)
            w.put(self.jpgQuality, 12)
        }
    }
}

/// ENCAPSULATED_DATA (#131)
extension MAV {
    public struct EncapsulatedData: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 131, name: "ENCAPSULATED_DATA", crcExtra: 223, minLength: 255, length: 255)
        public var seqnr: UInt16
        public var data: [UInt8]

        public init(seqnr: UInt16 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 253)) {
            self.seqnr = seqnr
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.seqnr = p.uint16(0)
            self.data = (0..<253).map { p.uint8(2 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.seqnr, 0)
            for k in 0..<Swift.min(253, self.data.count) { w.put(self.data[k], 2 + k * 1) }
        }
    }
}

/// DISTANCE_SENSOR (#132)
extension MAV {
    public struct DistanceSensor: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 132, name: "DISTANCE_SENSOR", crcExtra: 85, minLength: 14, length: 39)
        public var timeBootMs: UInt32
        public var minDistance: UInt16
        public var maxDistance: UInt16
        public var currentDistance: UInt16
        public var type: UInt8
        public var id: UInt8
        public var orientation: UInt8
        public var covariance: UInt8
        public var horizontalFov: Float  // extension field
        public var verticalFov: Float  // extension field
        public var quaternion: [Float]  // extension field
        public var signalQuality: UInt8  // extension field

        public init(timeBootMs: UInt32 = 0, minDistance: UInt16 = 0, maxDistance: UInt16 = 0, currentDistance: UInt16 = 0, type: UInt8 = 0, id: UInt8 = 0, orientation: UInt8 = 0, covariance: UInt8 = 0, horizontalFov: Float = 0, verticalFov: Float = 0, quaternion: [Float] = [Float](repeating: 0, count: 4), signalQuality: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.minDistance = minDistance
            self.maxDistance = maxDistance
            self.currentDistance = currentDistance
            self.type = type
            self.id = id
            self.orientation = orientation
            self.covariance = covariance
            self.horizontalFov = horizontalFov
            self.verticalFov = verticalFov
            self.quaternion = quaternion
            self.signalQuality = signalQuality
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.minDistance = p.uint16(4)
            self.maxDistance = p.uint16(6)
            self.currentDistance = p.uint16(8)
            self.type = p.uint8(10)
            self.id = p.uint8(11)
            self.orientation = p.uint8(12)
            self.covariance = p.uint8(13)
            self.horizontalFov = p.float(14)
            self.verticalFov = p.float(18)
            self.quaternion = (0..<4).map { p.float(22 + $0 * 4) }
            self.signalQuality = p.uint8(38)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.minDistance, 4)
            w.put(self.maxDistance, 6)
            w.put(self.currentDistance, 8)
            w.put(self.type, 10)
            w.put(self.id, 11)
            w.put(self.orientation, 12)
            w.put(self.covariance, 13)
            w.put(self.horizontalFov, 14)
            w.put(self.verticalFov, 18)
            for k in 0..<Swift.min(4, self.quaternion.count) { w.put(self.quaternion[k], 22 + k * 4) }
            w.put(self.signalQuality, 38)
        }
    }
}

/// TERRAIN_REQUEST (#133)
extension MAV {
    public struct TerrainRequest: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 133, name: "TERRAIN_REQUEST", crcExtra: 6, minLength: 18, length: 18)
        public var mask: UInt64
        public var lat: Int32
        public var lon: Int32
        public var gridSpacing: UInt16

        public init(mask: UInt64 = 0, lat: Int32 = 0, lon: Int32 = 0, gridSpacing: UInt16 = 0) {
            self.mask = mask
            self.lat = lat
            self.lon = lon
            self.gridSpacing = gridSpacing
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.mask = p.uint64(0)
            self.lat = p.int32(8)
            self.lon = p.int32(12)
            self.gridSpacing = p.uint16(16)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.mask, 0)
            w.put(self.lat, 8)
            w.put(self.lon, 12)
            w.put(self.gridSpacing, 16)
        }
    }
}

/// TERRAIN_DATA (#134)
extension MAV {
    public struct TerrainData: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 134, name: "TERRAIN_DATA", crcExtra: 229, minLength: 43, length: 43)
        public var lat: Int32
        public var lon: Int32
        public var gridSpacing: UInt16
        public var data: [Int16]
        public var gridbit: UInt8

        public init(lat: Int32 = 0, lon: Int32 = 0, gridSpacing: UInt16 = 0, data: [Int16] = [Int16](repeating: 0, count: 16), gridbit: UInt8 = 0) {
            self.lat = lat
            self.lon = lon
            self.gridSpacing = gridSpacing
            self.data = data
            self.gridbit = gridbit
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.lat = p.int32(0)
            self.lon = p.int32(4)
            self.gridSpacing = p.uint16(8)
            self.data = (0..<16).map { p.int16(10 + $0 * 2) }
            self.gridbit = p.uint8(42)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.lat, 0)
            w.put(self.lon, 4)
            w.put(self.gridSpacing, 8)
            for k in 0..<Swift.min(16, self.data.count) { w.put(self.data[k], 10 + k * 2) }
            w.put(self.gridbit, 42)
        }
    }
}

/// TERRAIN_CHECK (#135)
extension MAV {
    public struct TerrainCheck: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 135, name: "TERRAIN_CHECK", crcExtra: 203, minLength: 8, length: 8)
        public var lat: Int32
        public var lon: Int32

        public init(lat: Int32 = 0, lon: Int32 = 0) {
            self.lat = lat
            self.lon = lon
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.lat = p.int32(0)
            self.lon = p.int32(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.lat, 0)
            w.put(self.lon, 4)
        }
    }
}

/// TERRAIN_REPORT (#136)
extension MAV {
    public struct TerrainReport: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 136, name: "TERRAIN_REPORT", crcExtra: 1, minLength: 22, length: 22)
        public var lat: Int32
        public var lon: Int32
        public var terrainHeight: Float
        public var currentHeight: Float
        public var spacing: UInt16
        public var pending: UInt16
        public var loaded: UInt16

        public init(lat: Int32 = 0, lon: Int32 = 0, terrainHeight: Float = 0, currentHeight: Float = 0, spacing: UInt16 = 0, pending: UInt16 = 0, loaded: UInt16 = 0) {
            self.lat = lat
            self.lon = lon
            self.terrainHeight = terrainHeight
            self.currentHeight = currentHeight
            self.spacing = spacing
            self.pending = pending
            self.loaded = loaded
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.lat = p.int32(0)
            self.lon = p.int32(4)
            self.terrainHeight = p.float(8)
            self.currentHeight = p.float(12)
            self.spacing = p.uint16(16)
            self.pending = p.uint16(18)
            self.loaded = p.uint16(20)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.lat, 0)
            w.put(self.lon, 4)
            w.put(self.terrainHeight, 8)
            w.put(self.currentHeight, 12)
            w.put(self.spacing, 16)
            w.put(self.pending, 18)
            w.put(self.loaded, 20)
        }
    }
}

/// SCALED_PRESSURE2 (#137)
extension MAV {
    public struct ScaledPressure2: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 137, name: "SCALED_PRESSURE2", crcExtra: 195, minLength: 14, length: 16)
        public var timeBootMs: UInt32
        public var pressAbs: Float
        public var pressDiff: Float
        public var temperature: Int16
        public var temperaturePressDiff: Int16  // extension field

        public init(timeBootMs: UInt32 = 0, pressAbs: Float = 0, pressDiff: Float = 0, temperature: Int16 = 0, temperaturePressDiff: Int16 = 0) {
            self.timeBootMs = timeBootMs
            self.pressAbs = pressAbs
            self.pressDiff = pressDiff
            self.temperature = temperature
            self.temperaturePressDiff = temperaturePressDiff
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.pressAbs = p.float(4)
            self.pressDiff = p.float(8)
            self.temperature = p.int16(12)
            self.temperaturePressDiff = p.int16(14)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.pressAbs, 4)
            w.put(self.pressDiff, 8)
            w.put(self.temperature, 12)
            w.put(self.temperaturePressDiff, 14)
        }
    }
}

/// ATT_POS_MOCAP (#138)
extension MAV {
    public struct AttPosMocap: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 138, name: "ATT_POS_MOCAP", crcExtra: 109, minLength: 36, length: 120)
        public var timeUsec: UInt64
        public var q: [Float]
        public var x: Float
        public var y: Float
        public var z: Float
        public var covariance: [Float]  // extension field

        public init(timeUsec: UInt64 = 0, q: [Float] = [Float](repeating: 0, count: 4), x: Float = 0, y: Float = 0, z: Float = 0, covariance: [Float] = [Float](repeating: 0, count: 21)) {
            self.timeUsec = timeUsec
            self.q = q
            self.x = x
            self.y = y
            self.z = z
            self.covariance = covariance
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.q = (0..<4).map { p.float(8 + $0 * 4) }
            self.x = p.float(24)
            self.y = p.float(28)
            self.z = p.float(32)
            self.covariance = (0..<21).map { p.float(36 + $0 * 4) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 8 + k * 4) }
            w.put(self.x, 24)
            w.put(self.y, 28)
            w.put(self.z, 32)
            for k in 0..<Swift.min(21, self.covariance.count) { w.put(self.covariance[k], 36 + k * 4) }
        }
    }
}

/// SET_ACTUATOR_CONTROL_TARGET (#139)
extension MAV {
    public struct SetActuatorControlTarget: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 139, name: "SET_ACTUATOR_CONTROL_TARGET", crcExtra: 168, minLength: 43, length: 43)
        public var timeUsec: UInt64
        public var controls: [Float]
        public var groupMlx: UInt8
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(timeUsec: UInt64 = 0, controls: [Float] = [Float](repeating: 0, count: 8), groupMlx: UInt8 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.controls = controls
            self.groupMlx = groupMlx
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.controls = (0..<8).map { p.float(8 + $0 * 4) }
            self.groupMlx = p.uint8(40)
            self.targetSystem = p.uint8(41)
            self.targetComponent = p.uint8(42)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            for k in 0..<Swift.min(8, self.controls.count) { w.put(self.controls[k], 8 + k * 4) }
            w.put(self.groupMlx, 40)
            w.put(self.targetSystem, 41)
            w.put(self.targetComponent, 42)
        }
    }
}

/// ACTUATOR_CONTROL_TARGET (#140)
extension MAV {
    public struct ActuatorControlTarget: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 140, name: "ACTUATOR_CONTROL_TARGET", crcExtra: 181, minLength: 41, length: 41)
        public var timeUsec: UInt64
        public var controls: [Float]
        public var groupMlx: UInt8

        public init(timeUsec: UInt64 = 0, controls: [Float] = [Float](repeating: 0, count: 8), groupMlx: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.controls = controls
            self.groupMlx = groupMlx
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.controls = (0..<8).map { p.float(8 + $0 * 4) }
            self.groupMlx = p.uint8(40)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            for k in 0..<Swift.min(8, self.controls.count) { w.put(self.controls[k], 8 + k * 4) }
            w.put(self.groupMlx, 40)
        }
    }
}

/// ALTITUDE (#141)
extension MAV {
    public struct Altitude: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 141, name: "ALTITUDE", crcExtra: 47, minLength: 32, length: 32)
        public var timeUsec: UInt64
        public var altitudeMonotonic: Float
        public var altitudeAmsl: Float
        public var altitudeLocal: Float
        public var altitudeRelative: Float
        public var altitudeTerrain: Float
        public var bottomClearance: Float

        public init(timeUsec: UInt64 = 0, altitudeMonotonic: Float = 0, altitudeAmsl: Float = 0, altitudeLocal: Float = 0, altitudeRelative: Float = 0, altitudeTerrain: Float = 0, bottomClearance: Float = 0) {
            self.timeUsec = timeUsec
            self.altitudeMonotonic = altitudeMonotonic
            self.altitudeAmsl = altitudeAmsl
            self.altitudeLocal = altitudeLocal
            self.altitudeRelative = altitudeRelative
            self.altitudeTerrain = altitudeTerrain
            self.bottomClearance = bottomClearance
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.altitudeMonotonic = p.float(8)
            self.altitudeAmsl = p.float(12)
            self.altitudeLocal = p.float(16)
            self.altitudeRelative = p.float(20)
            self.altitudeTerrain = p.float(24)
            self.bottomClearance = p.float(28)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.altitudeMonotonic, 8)
            w.put(self.altitudeAmsl, 12)
            w.put(self.altitudeLocal, 16)
            w.put(self.altitudeRelative, 20)
            w.put(self.altitudeTerrain, 24)
            w.put(self.bottomClearance, 28)
        }
    }
}

/// RESOURCE_REQUEST (#142)
extension MAV {
    public struct ResourceRequest: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 142, name: "RESOURCE_REQUEST", crcExtra: 72, minLength: 243, length: 243)
        public var requestId: UInt8
        public var uriType: UInt8
        public var uri: [UInt8]
        public var transferType: UInt8
        public var storage: [UInt8]

        public init(requestId: UInt8 = 0, uriType: UInt8 = 0, uri: [UInt8] = [UInt8](repeating: 0, count: 120), transferType: UInt8 = 0, storage: [UInt8] = [UInt8](repeating: 0, count: 120)) {
            self.requestId = requestId
            self.uriType = uriType
            self.uri = uri
            self.transferType = transferType
            self.storage = storage
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.requestId = p.uint8(0)
            self.uriType = p.uint8(1)
            self.uri = (0..<120).map { p.uint8(2 + $0 * 1) }
            self.transferType = p.uint8(122)
            self.storage = (0..<120).map { p.uint8(123 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.requestId, 0)
            w.put(self.uriType, 1)
            for k in 0..<Swift.min(120, self.uri.count) { w.put(self.uri[k], 2 + k * 1) }
            w.put(self.transferType, 122)
            for k in 0..<Swift.min(120, self.storage.count) { w.put(self.storage[k], 123 + k * 1) }
        }
    }
}

/// SCALED_PRESSURE3 (#143)
extension MAV {
    public struct ScaledPressure3: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 143, name: "SCALED_PRESSURE3", crcExtra: 131, minLength: 14, length: 16)
        public var timeBootMs: UInt32
        public var pressAbs: Float
        public var pressDiff: Float
        public var temperature: Int16
        public var temperaturePressDiff: Int16  // extension field

        public init(timeBootMs: UInt32 = 0, pressAbs: Float = 0, pressDiff: Float = 0, temperature: Int16 = 0, temperaturePressDiff: Int16 = 0) {
            self.timeBootMs = timeBootMs
            self.pressAbs = pressAbs
            self.pressDiff = pressDiff
            self.temperature = temperature
            self.temperaturePressDiff = temperaturePressDiff
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.pressAbs = p.float(4)
            self.pressDiff = p.float(8)
            self.temperature = p.int16(12)
            self.temperaturePressDiff = p.int16(14)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.pressAbs, 4)
            w.put(self.pressDiff, 8)
            w.put(self.temperature, 12)
            w.put(self.temperaturePressDiff, 14)
        }
    }
}

/// FOLLOW_TARGET (#144)
extension MAV {
    public struct FollowTarget: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 144, name: "FOLLOW_TARGET", crcExtra: 127, minLength: 93, length: 93)
        public var timestamp: UInt64
        public var customState: UInt64
        public var lat: Int32
        public var lon: Int32
        public var alt: Float
        public var vel: [Float]
        public var acc: [Float]
        public var attitudeQ: [Float]
        public var rates: [Float]
        public var positionCov: [Float]
        public var estCapabilities: UInt8

        public init(timestamp: UInt64 = 0, customState: UInt64 = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Float = 0, vel: [Float] = [Float](repeating: 0, count: 3), acc: [Float] = [Float](repeating: 0, count: 3), attitudeQ: [Float] = [Float](repeating: 0, count: 4), rates: [Float] = [Float](repeating: 0, count: 3), positionCov: [Float] = [Float](repeating: 0, count: 3), estCapabilities: UInt8 = 0) {
            self.timestamp = timestamp
            self.customState = customState
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.vel = vel
            self.acc = acc
            self.attitudeQ = attitudeQ
            self.rates = rates
            self.positionCov = positionCov
            self.estCapabilities = estCapabilities
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.customState = p.uint64(8)
            self.lat = p.int32(16)
            self.lon = p.int32(20)
            self.alt = p.float(24)
            self.vel = (0..<3).map { p.float(28 + $0 * 4) }
            self.acc = (0..<3).map { p.float(40 + $0 * 4) }
            self.attitudeQ = (0..<4).map { p.float(52 + $0 * 4) }
            self.rates = (0..<3).map { p.float(68 + $0 * 4) }
            self.positionCov = (0..<3).map { p.float(80 + $0 * 4) }
            self.estCapabilities = p.uint8(92)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.customState, 8)
            w.put(self.lat, 16)
            w.put(self.lon, 20)
            w.put(self.alt, 24)
            for k in 0..<Swift.min(3, self.vel.count) { w.put(self.vel[k], 28 + k * 4) }
            for k in 0..<Swift.min(3, self.acc.count) { w.put(self.acc[k], 40 + k * 4) }
            for k in 0..<Swift.min(4, self.attitudeQ.count) { w.put(self.attitudeQ[k], 52 + k * 4) }
            for k in 0..<Swift.min(3, self.rates.count) { w.put(self.rates[k], 68 + k * 4) }
            for k in 0..<Swift.min(3, self.positionCov.count) { w.put(self.positionCov[k], 80 + k * 4) }
            w.put(self.estCapabilities, 92)
        }
    }
}

/// CONTROL_SYSTEM_STATE (#146)
extension MAV {
    public struct ControlSystemState: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 146, name: "CONTROL_SYSTEM_STATE", crcExtra: 103, minLength: 100, length: 100)
        public var timeUsec: UInt64
        public var xAcc: Float
        public var yAcc: Float
        public var zAcc: Float
        public var xVel: Float
        public var yVel: Float
        public var zVel: Float
        public var xPos: Float
        public var yPos: Float
        public var zPos: Float
        public var airspeed: Float
        public var velVariance: [Float]
        public var posVariance: [Float]
        public var q: [Float]
        public var rollRate: Float
        public var pitchRate: Float
        public var yawRate: Float

        public init(timeUsec: UInt64 = 0, xAcc: Float = 0, yAcc: Float = 0, zAcc: Float = 0, xVel: Float = 0, yVel: Float = 0, zVel: Float = 0, xPos: Float = 0, yPos: Float = 0, zPos: Float = 0, airspeed: Float = 0, velVariance: [Float] = [Float](repeating: 0, count: 3), posVariance: [Float] = [Float](repeating: 0, count: 3), q: [Float] = [Float](repeating: 0, count: 4), rollRate: Float = 0, pitchRate: Float = 0, yawRate: Float = 0) {
            self.timeUsec = timeUsec
            self.xAcc = xAcc
            self.yAcc = yAcc
            self.zAcc = zAcc
            self.xVel = xVel
            self.yVel = yVel
            self.zVel = zVel
            self.xPos = xPos
            self.yPos = yPos
            self.zPos = zPos
            self.airspeed = airspeed
            self.velVariance = velVariance
            self.posVariance = posVariance
            self.q = q
            self.rollRate = rollRate
            self.pitchRate = pitchRate
            self.yawRate = yawRate
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.xAcc = p.float(8)
            self.yAcc = p.float(12)
            self.zAcc = p.float(16)
            self.xVel = p.float(20)
            self.yVel = p.float(24)
            self.zVel = p.float(28)
            self.xPos = p.float(32)
            self.yPos = p.float(36)
            self.zPos = p.float(40)
            self.airspeed = p.float(44)
            self.velVariance = (0..<3).map { p.float(48 + $0 * 4) }
            self.posVariance = (0..<3).map { p.float(60 + $0 * 4) }
            self.q = (0..<4).map { p.float(72 + $0 * 4) }
            self.rollRate = p.float(88)
            self.pitchRate = p.float(92)
            self.yawRate = p.float(96)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.xAcc, 8)
            w.put(self.yAcc, 12)
            w.put(self.zAcc, 16)
            w.put(self.xVel, 20)
            w.put(self.yVel, 24)
            w.put(self.zVel, 28)
            w.put(self.xPos, 32)
            w.put(self.yPos, 36)
            w.put(self.zPos, 40)
            w.put(self.airspeed, 44)
            for k in 0..<Swift.min(3, self.velVariance.count) { w.put(self.velVariance[k], 48 + k * 4) }
            for k in 0..<Swift.min(3, self.posVariance.count) { w.put(self.posVariance[k], 60 + k * 4) }
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 72 + k * 4) }
            w.put(self.rollRate, 88)
            w.put(self.pitchRate, 92)
            w.put(self.yawRate, 96)
        }
    }
}

/// BATTERY_STATUS (#147)
extension MAV {
    public struct BatteryStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 147, name: "BATTERY_STATUS", crcExtra: 154, minLength: 36, length: 54)
        public var currentConsumed: Int32
        public var energyConsumed: Int32
        public var temperature: Int16
        public var voltages: [UInt16]
        public var currentBattery: Int16
        public var id: UInt8
        public var batteryFunction: UInt8
        public var type: UInt8
        public var batteryRemaining: Int8
        public var timeRemaining: Int32  // extension field
        public var chargeState: UInt8  // extension field
        public var voltagesExt: [UInt16]  // extension field
        public var mode: UInt8  // extension field
        public var faultBitmask: UInt32  // extension field

        public init(currentConsumed: Int32 = 0, energyConsumed: Int32 = 0, temperature: Int16 = 0, voltages: [UInt16] = [UInt16](repeating: 0, count: 10), currentBattery: Int16 = 0, id: UInt8 = 0, batteryFunction: UInt8 = 0, type: UInt8 = 0, batteryRemaining: Int8 = 0, timeRemaining: Int32 = 0, chargeState: UInt8 = 0, voltagesExt: [UInt16] = [UInt16](repeating: 0, count: 4), mode: UInt8 = 0, faultBitmask: UInt32 = 0) {
            self.currentConsumed = currentConsumed
            self.energyConsumed = energyConsumed
            self.temperature = temperature
            self.voltages = voltages
            self.currentBattery = currentBattery
            self.id = id
            self.batteryFunction = batteryFunction
            self.type = type
            self.batteryRemaining = batteryRemaining
            self.timeRemaining = timeRemaining
            self.chargeState = chargeState
            self.voltagesExt = voltagesExt
            self.mode = mode
            self.faultBitmask = faultBitmask
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.currentConsumed = p.int32(0)
            self.energyConsumed = p.int32(4)
            self.temperature = p.int16(8)
            self.voltages = (0..<10).map { p.uint16(10 + $0 * 2) }
            self.currentBattery = p.int16(30)
            self.id = p.uint8(32)
            self.batteryFunction = p.uint8(33)
            self.type = p.uint8(34)
            self.batteryRemaining = p.int8(35)
            self.timeRemaining = p.int32(36)
            self.chargeState = p.uint8(40)
            self.voltagesExt = (0..<4).map { p.uint16(41 + $0 * 2) }
            self.mode = p.uint8(49)
            self.faultBitmask = p.uint32(50)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.currentConsumed, 0)
            w.put(self.energyConsumed, 4)
            w.put(self.temperature, 8)
            for k in 0..<Swift.min(10, self.voltages.count) { w.put(self.voltages[k], 10 + k * 2) }
            w.put(self.currentBattery, 30)
            w.put(self.id, 32)
            w.put(self.batteryFunction, 33)
            w.put(self.type, 34)
            w.put(self.batteryRemaining, 35)
            w.put(self.timeRemaining, 36)
            w.put(self.chargeState, 40)
            for k in 0..<Swift.min(4, self.voltagesExt.count) { w.put(self.voltagesExt[k], 41 + k * 2) }
            w.put(self.mode, 49)
            w.put(self.faultBitmask, 50)
        }
    }
}

/// AUTOPILOT_VERSION (#148)
extension MAV {
    public struct AutopilotVersion: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 148, name: "AUTOPILOT_VERSION", crcExtra: 178, minLength: 60, length: 78)
        public var capabilities: UInt64
        public var uid: UInt64
        public var flightSwVersion: UInt32
        public var middlewareSwVersion: UInt32
        public var osSwVersion: UInt32
        public var boardVersion: UInt32
        public var vendorId: UInt16
        public var productId: UInt16
        public var flightCustomVersion: [UInt8]
        public var middlewareCustomVersion: [UInt8]
        public var osCustomVersion: [UInt8]
        public var uid2: [UInt8]  // extension field

        public init(capabilities: UInt64 = 0, uid: UInt64 = 0, flightSwVersion: UInt32 = 0, middlewareSwVersion: UInt32 = 0, osSwVersion: UInt32 = 0, boardVersion: UInt32 = 0, vendorId: UInt16 = 0, productId: UInt16 = 0, flightCustomVersion: [UInt8] = [UInt8](repeating: 0, count: 8), middlewareCustomVersion: [UInt8] = [UInt8](repeating: 0, count: 8), osCustomVersion: [UInt8] = [UInt8](repeating: 0, count: 8), uid2: [UInt8] = [UInt8](repeating: 0, count: 18)) {
            self.capabilities = capabilities
            self.uid = uid
            self.flightSwVersion = flightSwVersion
            self.middlewareSwVersion = middlewareSwVersion
            self.osSwVersion = osSwVersion
            self.boardVersion = boardVersion
            self.vendorId = vendorId
            self.productId = productId
            self.flightCustomVersion = flightCustomVersion
            self.middlewareCustomVersion = middlewareCustomVersion
            self.osCustomVersion = osCustomVersion
            self.uid2 = uid2
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.capabilities = p.uint64(0)
            self.uid = p.uint64(8)
            self.flightSwVersion = p.uint32(16)
            self.middlewareSwVersion = p.uint32(20)
            self.osSwVersion = p.uint32(24)
            self.boardVersion = p.uint32(28)
            self.vendorId = p.uint16(32)
            self.productId = p.uint16(34)
            self.flightCustomVersion = (0..<8).map { p.uint8(36 + $0 * 1) }
            self.middlewareCustomVersion = (0..<8).map { p.uint8(44 + $0 * 1) }
            self.osCustomVersion = (0..<8).map { p.uint8(52 + $0 * 1) }
            self.uid2 = (0..<18).map { p.uint8(60 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.capabilities, 0)
            w.put(self.uid, 8)
            w.put(self.flightSwVersion, 16)
            w.put(self.middlewareSwVersion, 20)
            w.put(self.osSwVersion, 24)
            w.put(self.boardVersion, 28)
            w.put(self.vendorId, 32)
            w.put(self.productId, 34)
            for k in 0..<Swift.min(8, self.flightCustomVersion.count) { w.put(self.flightCustomVersion[k], 36 + k * 1) }
            for k in 0..<Swift.min(8, self.middlewareCustomVersion.count) { w.put(self.middlewareCustomVersion[k], 44 + k * 1) }
            for k in 0..<Swift.min(8, self.osCustomVersion.count) { w.put(self.osCustomVersion[k], 52 + k * 1) }
            for k in 0..<Swift.min(18, self.uid2.count) { w.put(self.uid2[k], 60 + k * 1) }
        }
    }
}

/// LANDING_TARGET (#149)
extension MAV {
    public struct LandingTarget: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 149, name: "LANDING_TARGET", crcExtra: 200, minLength: 30, length: 60)
        public var timeUsec: UInt64
        public var angleX: Float
        public var angleY: Float
        public var distance: Float
        public var sizeX: Float
        public var sizeY: Float
        public var targetNum: UInt8
        public var frame: UInt8
        public var x: Float  // extension field
        public var y: Float  // extension field
        public var z: Float  // extension field
        public var q: [Float]  // extension field
        public var type: UInt8  // extension field
        public var positionValid: UInt8  // extension field

        public init(timeUsec: UInt64 = 0, angleX: Float = 0, angleY: Float = 0, distance: Float = 0, sizeX: Float = 0, sizeY: Float = 0, targetNum: UInt8 = 0, frame: UInt8 = 0, x: Float = 0, y: Float = 0, z: Float = 0, q: [Float] = [Float](repeating: 0, count: 4), type: UInt8 = 0, positionValid: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.angleX = angleX
            self.angleY = angleY
            self.distance = distance
            self.sizeX = sizeX
            self.sizeY = sizeY
            self.targetNum = targetNum
            self.frame = frame
            self.x = x
            self.y = y
            self.z = z
            self.q = q
            self.type = type
            self.positionValid = positionValid
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.angleX = p.float(8)
            self.angleY = p.float(12)
            self.distance = p.float(16)
            self.sizeX = p.float(20)
            self.sizeY = p.float(24)
            self.targetNum = p.uint8(28)
            self.frame = p.uint8(29)
            self.x = p.float(30)
            self.y = p.float(34)
            self.z = p.float(38)
            self.q = (0..<4).map { p.float(42 + $0 * 4) }
            self.type = p.uint8(58)
            self.positionValid = p.uint8(59)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.angleX, 8)
            w.put(self.angleY, 12)
            w.put(self.distance, 16)
            w.put(self.sizeX, 20)
            w.put(self.sizeY, 24)
            w.put(self.targetNum, 28)
            w.put(self.frame, 29)
            w.put(self.x, 30)
            w.put(self.y, 34)
            w.put(self.z, 38)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 42 + k * 4) }
            w.put(self.type, 58)
            w.put(self.positionValid, 59)
        }
    }
}

/// SENSOR_OFFSETS (#150)
extension MAV {
    public struct SensorOffsets: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 150, name: "SENSOR_OFFSETS", crcExtra: 134, minLength: 42, length: 42)
        public var magDeclination: Float
        public var rawPress: Int32
        public var rawTemp: Int32
        public var gyroCalX: Float
        public var gyroCalY: Float
        public var gyroCalZ: Float
        public var accelCalX: Float
        public var accelCalY: Float
        public var accelCalZ: Float
        public var magOfsX: Int16
        public var magOfsY: Int16
        public var magOfsZ: Int16

        public init(magDeclination: Float = 0, rawPress: Int32 = 0, rawTemp: Int32 = 0, gyroCalX: Float = 0, gyroCalY: Float = 0, gyroCalZ: Float = 0, accelCalX: Float = 0, accelCalY: Float = 0, accelCalZ: Float = 0, magOfsX: Int16 = 0, magOfsY: Int16 = 0, magOfsZ: Int16 = 0) {
            self.magDeclination = magDeclination
            self.rawPress = rawPress
            self.rawTemp = rawTemp
            self.gyroCalX = gyroCalX
            self.gyroCalY = gyroCalY
            self.gyroCalZ = gyroCalZ
            self.accelCalX = accelCalX
            self.accelCalY = accelCalY
            self.accelCalZ = accelCalZ
            self.magOfsX = magOfsX
            self.magOfsY = magOfsY
            self.magOfsZ = magOfsZ
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.magDeclination = p.float(0)
            self.rawPress = p.int32(4)
            self.rawTemp = p.int32(8)
            self.gyroCalX = p.float(12)
            self.gyroCalY = p.float(16)
            self.gyroCalZ = p.float(20)
            self.accelCalX = p.float(24)
            self.accelCalY = p.float(28)
            self.accelCalZ = p.float(32)
            self.magOfsX = p.int16(36)
            self.magOfsY = p.int16(38)
            self.magOfsZ = p.int16(40)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.magDeclination, 0)
            w.put(self.rawPress, 4)
            w.put(self.rawTemp, 8)
            w.put(self.gyroCalX, 12)
            w.put(self.gyroCalY, 16)
            w.put(self.gyroCalZ, 20)
            w.put(self.accelCalX, 24)
            w.put(self.accelCalY, 28)
            w.put(self.accelCalZ, 32)
            w.put(self.magOfsX, 36)
            w.put(self.magOfsY, 38)
            w.put(self.magOfsZ, 40)
        }
    }
}

/// SET_MAG_OFFSETS (#151)
extension MAV {
    public struct SetMagOffsets: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 151, name: "SET_MAG_OFFSETS", crcExtra: 219, minLength: 8, length: 8)
        public var magOfsX: Int16
        public var magOfsY: Int16
        public var magOfsZ: Int16
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(magOfsX: Int16 = 0, magOfsY: Int16 = 0, magOfsZ: Int16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.magOfsX = magOfsX
            self.magOfsY = magOfsY
            self.magOfsZ = magOfsZ
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.magOfsX = p.int16(0)
            self.magOfsY = p.int16(2)
            self.magOfsZ = p.int16(4)
            self.targetSystem = p.uint8(6)
            self.targetComponent = p.uint8(7)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.magOfsX, 0)
            w.put(self.magOfsY, 2)
            w.put(self.magOfsZ, 4)
            w.put(self.targetSystem, 6)
            w.put(self.targetComponent, 7)
        }
    }
}

/// MEMINFO (#152)
extension MAV {
    public struct Meminfo: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 152, name: "MEMINFO", crcExtra: 208, minLength: 4, length: 8)
        public var brkval: UInt16
        public var freemem: UInt16
        public var freemem32: UInt32  // extension field

        public init(brkval: UInt16 = 0, freemem: UInt16 = 0, freemem32: UInt32 = 0) {
            self.brkval = brkval
            self.freemem = freemem
            self.freemem32 = freemem32
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.brkval = p.uint16(0)
            self.freemem = p.uint16(2)
            self.freemem32 = p.uint32(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.brkval, 0)
            w.put(self.freemem, 2)
            w.put(self.freemem32, 4)
        }
    }
}

/// AP_ADC (#153)
extension MAV {
    public struct ApAdc: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 153, name: "AP_ADC", crcExtra: 188, minLength: 12, length: 12)
        public var adc1: UInt16
        public var adc2: UInt16
        public var adc3: UInt16
        public var adc4: UInt16
        public var adc5: UInt16
        public var adc6: UInt16

        public init(adc1: UInt16 = 0, adc2: UInt16 = 0, adc3: UInt16 = 0, adc4: UInt16 = 0, adc5: UInt16 = 0, adc6: UInt16 = 0) {
            self.adc1 = adc1
            self.adc2 = adc2
            self.adc3 = adc3
            self.adc4 = adc4
            self.adc5 = adc5
            self.adc6 = adc6
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.adc1 = p.uint16(0)
            self.adc2 = p.uint16(2)
            self.adc3 = p.uint16(4)
            self.adc4 = p.uint16(6)
            self.adc5 = p.uint16(8)
            self.adc6 = p.uint16(10)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.adc1, 0)
            w.put(self.adc2, 2)
            w.put(self.adc3, 4)
            w.put(self.adc4, 6)
            w.put(self.adc5, 8)
            w.put(self.adc6, 10)
        }
    }
}

/// DIGICAM_CONFIGURE (#154)
extension MAV {
    public struct DigicamConfigure: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 154, name: "DIGICAM_CONFIGURE", crcExtra: 84, minLength: 15, length: 15)
        public var extraValue: Float
        public var shutterSpeed: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var mode: UInt8
        public var aperture: UInt8
        public var iso: UInt8
        public var exposureType: UInt8
        public var commandId: UInt8
        public var engineCutOff: UInt8
        public var extraParam: UInt8

        public init(extraValue: Float = 0, shutterSpeed: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, mode: UInt8 = 0, aperture: UInt8 = 0, iso: UInt8 = 0, exposureType: UInt8 = 0, commandId: UInt8 = 0, engineCutOff: UInt8 = 0, extraParam: UInt8 = 0) {
            self.extraValue = extraValue
            self.shutterSpeed = shutterSpeed
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.mode = mode
            self.aperture = aperture
            self.iso = iso
            self.exposureType = exposureType
            self.commandId = commandId
            self.engineCutOff = engineCutOff
            self.extraParam = extraParam
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.extraValue = p.float(0)
            self.shutterSpeed = p.uint16(4)
            self.targetSystem = p.uint8(6)
            self.targetComponent = p.uint8(7)
            self.mode = p.uint8(8)
            self.aperture = p.uint8(9)
            self.iso = p.uint8(10)
            self.exposureType = p.uint8(11)
            self.commandId = p.uint8(12)
            self.engineCutOff = p.uint8(13)
            self.extraParam = p.uint8(14)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.extraValue, 0)
            w.put(self.shutterSpeed, 4)
            w.put(self.targetSystem, 6)
            w.put(self.targetComponent, 7)
            w.put(self.mode, 8)
            w.put(self.aperture, 9)
            w.put(self.iso, 10)
            w.put(self.exposureType, 11)
            w.put(self.commandId, 12)
            w.put(self.engineCutOff, 13)
            w.put(self.extraParam, 14)
        }
    }
}

/// DIGICAM_CONTROL (#155)
extension MAV {
    public struct DigicamControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 155, name: "DIGICAM_CONTROL", crcExtra: 22, minLength: 13, length: 13)
        public var extraValue: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var session: UInt8
        public var zoomPos: UInt8
        public var zoomStep: Int8
        public var focusLock: UInt8
        public var shot: UInt8
        public var commandId: UInt8
        public var extraParam: UInt8

        public init(extraValue: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, session: UInt8 = 0, zoomPos: UInt8 = 0, zoomStep: Int8 = 0, focusLock: UInt8 = 0, shot: UInt8 = 0, commandId: UInt8 = 0, extraParam: UInt8 = 0) {
            self.extraValue = extraValue
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.session = session
            self.zoomPos = zoomPos
            self.zoomStep = zoomStep
            self.focusLock = focusLock
            self.shot = shot
            self.commandId = commandId
            self.extraParam = extraParam
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.extraValue = p.float(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.session = p.uint8(6)
            self.zoomPos = p.uint8(7)
            self.zoomStep = p.int8(8)
            self.focusLock = p.uint8(9)
            self.shot = p.uint8(10)
            self.commandId = p.uint8(11)
            self.extraParam = p.uint8(12)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.extraValue, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            w.put(self.session, 6)
            w.put(self.zoomPos, 7)
            w.put(self.zoomStep, 8)
            w.put(self.focusLock, 9)
            w.put(self.shot, 10)
            w.put(self.commandId, 11)
            w.put(self.extraParam, 12)
        }
    }
}

/// MOUNT_CONFIGURE (#156)
extension MAV {
    public struct MountConfigure: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 156, name: "MOUNT_CONFIGURE", crcExtra: 19, minLength: 6, length: 6)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var mountMode: UInt8
        public var stabRoll: UInt8
        public var stabPitch: UInt8
        public var stabYaw: UInt8

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, mountMode: UInt8 = 0, stabRoll: UInt8 = 0, stabPitch: UInt8 = 0, stabYaw: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.mountMode = mountMode
            self.stabRoll = stabRoll
            self.stabPitch = stabPitch
            self.stabYaw = stabYaw
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.mountMode = p.uint8(2)
            self.stabRoll = p.uint8(3)
            self.stabPitch = p.uint8(4)
            self.stabYaw = p.uint8(5)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            w.put(self.mountMode, 2)
            w.put(self.stabRoll, 3)
            w.put(self.stabPitch, 4)
            w.put(self.stabYaw, 5)
        }
    }
}

/// MOUNT_CONTROL (#157)
extension MAV {
    public struct MountControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 157, name: "MOUNT_CONTROL", crcExtra: 21, minLength: 15, length: 15)
        public var inputA: Int32
        public var inputB: Int32
        public var inputC: Int32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var savePosition: UInt8

        public init(inputA: Int32 = 0, inputB: Int32 = 0, inputC: Int32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, savePosition: UInt8 = 0) {
            self.inputA = inputA
            self.inputB = inputB
            self.inputC = inputC
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.savePosition = savePosition
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.inputA = p.int32(0)
            self.inputB = p.int32(4)
            self.inputC = p.int32(8)
            self.targetSystem = p.uint8(12)
            self.targetComponent = p.uint8(13)
            self.savePosition = p.uint8(14)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.inputA, 0)
            w.put(self.inputB, 4)
            w.put(self.inputC, 8)
            w.put(self.targetSystem, 12)
            w.put(self.targetComponent, 13)
            w.put(self.savePosition, 14)
        }
    }
}

/// MOUNT_STATUS (#158)
extension MAV {
    public struct MountStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 158, name: "MOUNT_STATUS", crcExtra: 134, minLength: 14, length: 15)
        public var pointingA: Int32
        public var pointingB: Int32
        public var pointingC: Int32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var mountMode: UInt8  // extension field

        public init(pointingA: Int32 = 0, pointingB: Int32 = 0, pointingC: Int32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, mountMode: UInt8 = 0) {
            self.pointingA = pointingA
            self.pointingB = pointingB
            self.pointingC = pointingC
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.mountMode = mountMode
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.pointingA = p.int32(0)
            self.pointingB = p.int32(4)
            self.pointingC = p.int32(8)
            self.targetSystem = p.uint8(12)
            self.targetComponent = p.uint8(13)
            self.mountMode = p.uint8(14)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.pointingA, 0)
            w.put(self.pointingB, 4)
            w.put(self.pointingC, 8)
            w.put(self.targetSystem, 12)
            w.put(self.targetComponent, 13)
            w.put(self.mountMode, 14)
        }
    }
}

/// FENCE_POINT (#160)
extension MAV {
    public struct FencePoint: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 160, name: "FENCE_POINT", crcExtra: 78, minLength: 12, length: 12)
        public var lat: Float
        public var lng: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idx: UInt8
        public var count: UInt8

        public init(lat: Float = 0, lng: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idx: UInt8 = 0, count: UInt8 = 0) {
            self.lat = lat
            self.lng = lng
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idx = idx
            self.count = count
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.lat = p.float(0)
            self.lng = p.float(4)
            self.targetSystem = p.uint8(8)
            self.targetComponent = p.uint8(9)
            self.idx = p.uint8(10)
            self.count = p.uint8(11)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.lat, 0)
            w.put(self.lng, 4)
            w.put(self.targetSystem, 8)
            w.put(self.targetComponent, 9)
            w.put(self.idx, 10)
            w.put(self.count, 11)
        }
    }
}

/// FENCE_FETCH_POINT (#161)
extension MAV {
    public struct FenceFetchPoint: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 161, name: "FENCE_FETCH_POINT", crcExtra: 68, minLength: 3, length: 3)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idx: UInt8

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idx: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idx = idx
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.idx = p.uint8(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            w.put(self.idx, 2)
        }
    }
}

/// FENCE_STATUS (#162)
extension MAV {
    public struct FenceStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 162, name: "FENCE_STATUS", crcExtra: 189, minLength: 8, length: 9)
        public var breachTime: UInt32
        public var breachCount: UInt16
        public var breachStatus: UInt8
        public var breachType: UInt8
        public var breachMitigation: UInt8  // extension field

        public init(breachTime: UInt32 = 0, breachCount: UInt16 = 0, breachStatus: UInt8 = 0, breachType: UInt8 = 0, breachMitigation: UInt8 = 0) {
            self.breachTime = breachTime
            self.breachCount = breachCount
            self.breachStatus = breachStatus
            self.breachType = breachType
            self.breachMitigation = breachMitigation
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.breachTime = p.uint32(0)
            self.breachCount = p.uint16(4)
            self.breachStatus = p.uint8(6)
            self.breachType = p.uint8(7)
            self.breachMitigation = p.uint8(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.breachTime, 0)
            w.put(self.breachCount, 4)
            w.put(self.breachStatus, 6)
            w.put(self.breachType, 7)
            w.put(self.breachMitigation, 8)
        }
    }
}

/// AHRS (#163)
extension MAV {
    public struct Ahrs: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 163, name: "AHRS", crcExtra: 127, minLength: 28, length: 28)
        public var omegaIx: Float
        public var omegaIy: Float
        public var omegaIz: Float
        public var accelWeight: Float
        public var renormVal: Float
        public var errorRp: Float
        public var errorYaw: Float

        public init(omegaIx: Float = 0, omegaIy: Float = 0, omegaIz: Float = 0, accelWeight: Float = 0, renormVal: Float = 0, errorRp: Float = 0, errorYaw: Float = 0) {
            self.omegaIx = omegaIx
            self.omegaIy = omegaIy
            self.omegaIz = omegaIz
            self.accelWeight = accelWeight
            self.renormVal = renormVal
            self.errorRp = errorRp
            self.errorYaw = errorYaw
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.omegaIx = p.float(0)
            self.omegaIy = p.float(4)
            self.omegaIz = p.float(8)
            self.accelWeight = p.float(12)
            self.renormVal = p.float(16)
            self.errorRp = p.float(20)
            self.errorYaw = p.float(24)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.omegaIx, 0)
            w.put(self.omegaIy, 4)
            w.put(self.omegaIz, 8)
            w.put(self.accelWeight, 12)
            w.put(self.renormVal, 16)
            w.put(self.errorRp, 20)
            w.put(self.errorYaw, 24)
        }
    }
}

/// SIMSTATE (#164)
extension MAV {
    public struct Simstate: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 164, name: "SIMSTATE", crcExtra: 154, minLength: 44, length: 44)
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var xacc: Float
        public var yacc: Float
        public var zacc: Float
        public var xgyro: Float
        public var ygyro: Float
        public var zgyro: Float
        public var lat: Int32
        public var lng: Int32

        public init(roll: Float = 0, pitch: Float = 0, yaw: Float = 0, xacc: Float = 0, yacc: Float = 0, zacc: Float = 0, xgyro: Float = 0, ygyro: Float = 0, zgyro: Float = 0, lat: Int32 = 0, lng: Int32 = 0) {
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
            self.xgyro = xgyro
            self.ygyro = ygyro
            self.zgyro = zgyro
            self.lat = lat
            self.lng = lng
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.roll = p.float(0)
            self.pitch = p.float(4)
            self.yaw = p.float(8)
            self.xacc = p.float(12)
            self.yacc = p.float(16)
            self.zacc = p.float(20)
            self.xgyro = p.float(24)
            self.ygyro = p.float(28)
            self.zgyro = p.float(32)
            self.lat = p.int32(36)
            self.lng = p.int32(40)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.roll, 0)
            w.put(self.pitch, 4)
            w.put(self.yaw, 8)
            w.put(self.xacc, 12)
            w.put(self.yacc, 16)
            w.put(self.zacc, 20)
            w.put(self.xgyro, 24)
            w.put(self.ygyro, 28)
            w.put(self.zgyro, 32)
            w.put(self.lat, 36)
            w.put(self.lng, 40)
        }
    }
}

/// HWSTATUS (#165)
extension MAV {
    public struct Hwstatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 165, name: "HWSTATUS", crcExtra: 21, minLength: 3, length: 3)
        public var Vcc: UInt16
        public var I2Cerr: UInt8

        public init(Vcc: UInt16 = 0, I2Cerr: UInt8 = 0) {
            self.Vcc = Vcc
            self.I2Cerr = I2Cerr
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.Vcc = p.uint16(0)
            self.I2Cerr = p.uint8(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.Vcc, 0)
            w.put(self.I2Cerr, 2)
        }
    }
}

/// RADIO (#166)
extension MAV {
    public struct Radio: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 166, name: "RADIO", crcExtra: 21, minLength: 9, length: 9)
        public var rxerrors: UInt16
        public var fixed: UInt16
        public var rssi: UInt8
        public var remrssi: UInt8
        public var txbuf: UInt8
        public var noise: UInt8
        public var remnoise: UInt8

        public init(rxerrors: UInt16 = 0, fixed: UInt16 = 0, rssi: UInt8 = 0, remrssi: UInt8 = 0, txbuf: UInt8 = 0, noise: UInt8 = 0, remnoise: UInt8 = 0) {
            self.rxerrors = rxerrors
            self.fixed = fixed
            self.rssi = rssi
            self.remrssi = remrssi
            self.txbuf = txbuf
            self.noise = noise
            self.remnoise = remnoise
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.rxerrors = p.uint16(0)
            self.fixed = p.uint16(2)
            self.rssi = p.uint8(4)
            self.remrssi = p.uint8(5)
            self.txbuf = p.uint8(6)
            self.noise = p.uint8(7)
            self.remnoise = p.uint8(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.rxerrors, 0)
            w.put(self.fixed, 2)
            w.put(self.rssi, 4)
            w.put(self.remrssi, 5)
            w.put(self.txbuf, 6)
            w.put(self.noise, 7)
            w.put(self.remnoise, 8)
        }
    }
}

/// LIMITS_STATUS (#167)
extension MAV {
    public struct LimitsStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 167, name: "LIMITS_STATUS", crcExtra: 144, minLength: 22, length: 22)
        public var lastTrigger: UInt32
        public var lastAction: UInt32
        public var lastRecovery: UInt32
        public var lastClear: UInt32
        public var breachCount: UInt16
        public var limitsState: UInt8
        public var modsEnabled: UInt8
        public var modsRequired: UInt8
        public var modsTriggered: UInt8

        public init(lastTrigger: UInt32 = 0, lastAction: UInt32 = 0, lastRecovery: UInt32 = 0, lastClear: UInt32 = 0, breachCount: UInt16 = 0, limitsState: UInt8 = 0, modsEnabled: UInt8 = 0, modsRequired: UInt8 = 0, modsTriggered: UInt8 = 0) {
            self.lastTrigger = lastTrigger
            self.lastAction = lastAction
            self.lastRecovery = lastRecovery
            self.lastClear = lastClear
            self.breachCount = breachCount
            self.limitsState = limitsState
            self.modsEnabled = modsEnabled
            self.modsRequired = modsRequired
            self.modsTriggered = modsTriggered
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.lastTrigger = p.uint32(0)
            self.lastAction = p.uint32(4)
            self.lastRecovery = p.uint32(8)
            self.lastClear = p.uint32(12)
            self.breachCount = p.uint16(16)
            self.limitsState = p.uint8(18)
            self.modsEnabled = p.uint8(19)
            self.modsRequired = p.uint8(20)
            self.modsTriggered = p.uint8(21)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.lastTrigger, 0)
            w.put(self.lastAction, 4)
            w.put(self.lastRecovery, 8)
            w.put(self.lastClear, 12)
            w.put(self.breachCount, 16)
            w.put(self.limitsState, 18)
            w.put(self.modsEnabled, 19)
            w.put(self.modsRequired, 20)
            w.put(self.modsTriggered, 21)
        }
    }
}

/// WIND (#168)
extension MAV {
    public struct Wind: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 168, name: "WIND", crcExtra: 1, minLength: 12, length: 12)
        public var direction: Float
        public var speed: Float
        public var speedZ: Float

        public init(direction: Float = 0, speed: Float = 0, speedZ: Float = 0) {
            self.direction = direction
            self.speed = speed
            self.speedZ = speedZ
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.direction = p.float(0)
            self.speed = p.float(4)
            self.speedZ = p.float(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.direction, 0)
            w.put(self.speed, 4)
            w.put(self.speedZ, 8)
        }
    }
}

/// DATA16 (#169)
extension MAV {
    public struct Data16: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 169, name: "DATA16", crcExtra: 234, minLength: 18, length: 18)
        public var type: UInt8
        public var len: UInt8
        public var data: [UInt8]

        public init(type: UInt8 = 0, len: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 16)) {
            self.type = type
            self.len = len
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.type = p.uint8(0)
            self.len = p.uint8(1)
            self.data = (0..<16).map { p.uint8(2 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.type, 0)
            w.put(self.len, 1)
            for k in 0..<Swift.min(16, self.data.count) { w.put(self.data[k], 2 + k * 1) }
        }
    }
}

/// DATA32 (#170)
extension MAV {
    public struct Data32: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 170, name: "DATA32", crcExtra: 73, minLength: 34, length: 34)
        public var type: UInt8
        public var len: UInt8
        public var data: [UInt8]

        public init(type: UInt8 = 0, len: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 32)) {
            self.type = type
            self.len = len
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.type = p.uint8(0)
            self.len = p.uint8(1)
            self.data = (0..<32).map { p.uint8(2 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.type, 0)
            w.put(self.len, 1)
            for k in 0..<Swift.min(32, self.data.count) { w.put(self.data[k], 2 + k * 1) }
        }
    }
}

/// DATA64 (#171)
extension MAV {
    public struct Data64: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 171, name: "DATA64", crcExtra: 181, minLength: 66, length: 66)
        public var type: UInt8
        public var len: UInt8
        public var data: [UInt8]

        public init(type: UInt8 = 0, len: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 64)) {
            self.type = type
            self.len = len
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.type = p.uint8(0)
            self.len = p.uint8(1)
            self.data = (0..<64).map { p.uint8(2 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.type, 0)
            w.put(self.len, 1)
            for k in 0..<Swift.min(64, self.data.count) { w.put(self.data[k], 2 + k * 1) }
        }
    }
}

/// DATA96 (#172)
extension MAV {
    public struct Data96: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 172, name: "DATA96", crcExtra: 22, minLength: 98, length: 98)
        public var type: UInt8
        public var len: UInt8
        public var data: [UInt8]

        public init(type: UInt8 = 0, len: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 96)) {
            self.type = type
            self.len = len
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.type = p.uint8(0)
            self.len = p.uint8(1)
            self.data = (0..<96).map { p.uint8(2 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.type, 0)
            w.put(self.len, 1)
            for k in 0..<Swift.min(96, self.data.count) { w.put(self.data[k], 2 + k * 1) }
        }
    }
}

/// RANGEFINDER (#173)
extension MAV {
    public struct Rangefinder: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 173, name: "RANGEFINDER", crcExtra: 83, minLength: 8, length: 8)
        public var distance: Float
        public var voltage: Float

        public init(distance: Float = 0, voltage: Float = 0) {
            self.distance = distance
            self.voltage = voltage
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.distance = p.float(0)
            self.voltage = p.float(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.distance, 0)
            w.put(self.voltage, 4)
        }
    }
}

/// AIRSPEED_AUTOCAL (#174)
extension MAV {
    public struct AirspeedAutocal: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 174, name: "AIRSPEED_AUTOCAL", crcExtra: 167, minLength: 48, length: 48)
        public var vx: Float
        public var vy: Float
        public var vz: Float
        public var diffPressure: Float
        public var EAS2TAS: Float
        public var ratio: Float
        public var stateX: Float
        public var stateY: Float
        public var stateZ: Float
        public var Pax: Float
        public var Pby: Float
        public var Pcz: Float

        public init(vx: Float = 0, vy: Float = 0, vz: Float = 0, diffPressure: Float = 0, EAS2TAS: Float = 0, ratio: Float = 0, stateX: Float = 0, stateY: Float = 0, stateZ: Float = 0, Pax: Float = 0, Pby: Float = 0, Pcz: Float = 0) {
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.diffPressure = diffPressure
            self.EAS2TAS = EAS2TAS
            self.ratio = ratio
            self.stateX = stateX
            self.stateY = stateY
            self.stateZ = stateZ
            self.Pax = Pax
            self.Pby = Pby
            self.Pcz = Pcz
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.vx = p.float(0)
            self.vy = p.float(4)
            self.vz = p.float(8)
            self.diffPressure = p.float(12)
            self.EAS2TAS = p.float(16)
            self.ratio = p.float(20)
            self.stateX = p.float(24)
            self.stateY = p.float(28)
            self.stateZ = p.float(32)
            self.Pax = p.float(36)
            self.Pby = p.float(40)
            self.Pcz = p.float(44)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.vx, 0)
            w.put(self.vy, 4)
            w.put(self.vz, 8)
            w.put(self.diffPressure, 12)
            w.put(self.EAS2TAS, 16)
            w.put(self.ratio, 20)
            w.put(self.stateX, 24)
            w.put(self.stateY, 28)
            w.put(self.stateZ, 32)
            w.put(self.Pax, 36)
            w.put(self.Pby, 40)
            w.put(self.Pcz, 44)
        }
    }
}

/// RALLY_POINT (#175)
extension MAV {
    public struct RallyPoint: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 175, name: "RALLY_POINT", crcExtra: 138, minLength: 19, length: 19)
        public var lat: Int32
        public var lng: Int32
        public var alt: Int16
        public var breakAlt: Int16
        public var landDir: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idx: UInt8
        public var count: UInt8
        public var flags: UInt8

        public init(lat: Int32 = 0, lng: Int32 = 0, alt: Int16 = 0, breakAlt: Int16 = 0, landDir: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idx: UInt8 = 0, count: UInt8 = 0, flags: UInt8 = 0) {
            self.lat = lat
            self.lng = lng
            self.alt = alt
            self.breakAlt = breakAlt
            self.landDir = landDir
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idx = idx
            self.count = count
            self.flags = flags
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.lat = p.int32(0)
            self.lng = p.int32(4)
            self.alt = p.int16(8)
            self.breakAlt = p.int16(10)
            self.landDir = p.uint16(12)
            self.targetSystem = p.uint8(14)
            self.targetComponent = p.uint8(15)
            self.idx = p.uint8(16)
            self.count = p.uint8(17)
            self.flags = p.uint8(18)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.lat, 0)
            w.put(self.lng, 4)
            w.put(self.alt, 8)
            w.put(self.breakAlt, 10)
            w.put(self.landDir, 12)
            w.put(self.targetSystem, 14)
            w.put(self.targetComponent, 15)
            w.put(self.idx, 16)
            w.put(self.count, 17)
            w.put(self.flags, 18)
        }
    }
}

/// RALLY_FETCH_POINT (#176)
extension MAV {
    public struct RallyFetchPoint: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 176, name: "RALLY_FETCH_POINT", crcExtra: 234, minLength: 3, length: 3)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idx: UInt8

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idx: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idx = idx
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.idx = p.uint8(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            w.put(self.idx, 2)
        }
    }
}

/// COMPASSMOT_STATUS (#177)
extension MAV {
    public struct CompassmotStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 177, name: "COMPASSMOT_STATUS", crcExtra: 240, minLength: 20, length: 20)
        public var current: Float
        public var CompensationX: Float
        public var CompensationY: Float
        public var CompensationZ: Float
        public var throttle: UInt16
        public var interference: UInt16

        public init(current: Float = 0, CompensationX: Float = 0, CompensationY: Float = 0, CompensationZ: Float = 0, throttle: UInt16 = 0, interference: UInt16 = 0) {
            self.current = current
            self.CompensationX = CompensationX
            self.CompensationY = CompensationY
            self.CompensationZ = CompensationZ
            self.throttle = throttle
            self.interference = interference
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.current = p.float(0)
            self.CompensationX = p.float(4)
            self.CompensationY = p.float(8)
            self.CompensationZ = p.float(12)
            self.throttle = p.uint16(16)
            self.interference = p.uint16(18)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.current, 0)
            w.put(self.CompensationX, 4)
            w.put(self.CompensationY, 8)
            w.put(self.CompensationZ, 12)
            w.put(self.throttle, 16)
            w.put(self.interference, 18)
        }
    }
}

/// AHRS2 (#178)
extension MAV {
    public struct Ahrs2: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 178, name: "AHRS2", crcExtra: 47, minLength: 24, length: 24)
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var altitude: Float
        public var lat: Int32
        public var lng: Int32

        public init(roll: Float = 0, pitch: Float = 0, yaw: Float = 0, altitude: Float = 0, lat: Int32 = 0, lng: Int32 = 0) {
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.altitude = altitude
            self.lat = lat
            self.lng = lng
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.roll = p.float(0)
            self.pitch = p.float(4)
            self.yaw = p.float(8)
            self.altitude = p.float(12)
            self.lat = p.int32(16)
            self.lng = p.int32(20)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.roll, 0)
            w.put(self.pitch, 4)
            w.put(self.yaw, 8)
            w.put(self.altitude, 12)
            w.put(self.lat, 16)
            w.put(self.lng, 20)
        }
    }
}

/// CAMERA_STATUS (#179)
extension MAV {
    public struct CameraStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 179, name: "CAMERA_STATUS", crcExtra: 189, minLength: 29, length: 29)
        public var timeUsec: UInt64
        public var p1: Float
        public var p2: Float
        public var p3: Float
        public var p4: Float
        public var imgIdx: UInt16
        public var targetSystem: UInt8
        public var camIdx: UInt8
        public var eventId: UInt8

        public init(timeUsec: UInt64 = 0, p1: Float = 0, p2: Float = 0, p3: Float = 0, p4: Float = 0, imgIdx: UInt16 = 0, targetSystem: UInt8 = 0, camIdx: UInt8 = 0, eventId: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.p1 = p1
            self.p2 = p2
            self.p3 = p3
            self.p4 = p4
            self.imgIdx = imgIdx
            self.targetSystem = targetSystem
            self.camIdx = camIdx
            self.eventId = eventId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.p1 = p.float(8)
            self.p2 = p.float(12)
            self.p3 = p.float(16)
            self.p4 = p.float(20)
            self.imgIdx = p.uint16(24)
            self.targetSystem = p.uint8(26)
            self.camIdx = p.uint8(27)
            self.eventId = p.uint8(28)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.p1, 8)
            w.put(self.p2, 12)
            w.put(self.p3, 16)
            w.put(self.p4, 20)
            w.put(self.imgIdx, 24)
            w.put(self.targetSystem, 26)
            w.put(self.camIdx, 27)
            w.put(self.eventId, 28)
        }
    }
}

/// CAMERA_FEEDBACK (#180)
extension MAV {
    public struct CameraFeedback: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 180, name: "CAMERA_FEEDBACK", crcExtra: 52, minLength: 45, length: 47)
        public var timeUsec: UInt64
        public var lat: Int32
        public var lng: Int32
        public var altMsl: Float
        public var altRel: Float
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var focLen: Float
        public var imgIdx: UInt16
        public var targetSystem: UInt8
        public var camIdx: UInt8
        public var flags: UInt8
        public var completedCaptures: UInt16  // extension field

        public init(timeUsec: UInt64 = 0, lat: Int32 = 0, lng: Int32 = 0, altMsl: Float = 0, altRel: Float = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0, focLen: Float = 0, imgIdx: UInt16 = 0, targetSystem: UInt8 = 0, camIdx: UInt8 = 0, flags: UInt8 = 0, completedCaptures: UInt16 = 0) {
            self.timeUsec = timeUsec
            self.lat = lat
            self.lng = lng
            self.altMsl = altMsl
            self.altRel = altRel
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.focLen = focLen
            self.imgIdx = imgIdx
            self.targetSystem = targetSystem
            self.camIdx = camIdx
            self.flags = flags
            self.completedCaptures = completedCaptures
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.lat = p.int32(8)
            self.lng = p.int32(12)
            self.altMsl = p.float(16)
            self.altRel = p.float(20)
            self.roll = p.float(24)
            self.pitch = p.float(28)
            self.yaw = p.float(32)
            self.focLen = p.float(36)
            self.imgIdx = p.uint16(40)
            self.targetSystem = p.uint8(42)
            self.camIdx = p.uint8(43)
            self.flags = p.uint8(44)
            self.completedCaptures = p.uint16(45)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.lat, 8)
            w.put(self.lng, 12)
            w.put(self.altMsl, 16)
            w.put(self.altRel, 20)
            w.put(self.roll, 24)
            w.put(self.pitch, 28)
            w.put(self.yaw, 32)
            w.put(self.focLen, 36)
            w.put(self.imgIdx, 40)
            w.put(self.targetSystem, 42)
            w.put(self.camIdx, 43)
            w.put(self.flags, 44)
            w.put(self.completedCaptures, 45)
        }
    }
}

/// BATTERY2 (#181)
extension MAV {
    public struct Battery2: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 181, name: "BATTERY2", crcExtra: 174, minLength: 4, length: 4)
        public var voltage: UInt16
        public var currentBattery: Int16

        public init(voltage: UInt16 = 0, currentBattery: Int16 = 0) {
            self.voltage = voltage
            self.currentBattery = currentBattery
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.voltage = p.uint16(0)
            self.currentBattery = p.int16(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.voltage, 0)
            w.put(self.currentBattery, 2)
        }
    }
}

/// AHRS3 (#182)
extension MAV {
    public struct Ahrs3: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 182, name: "AHRS3", crcExtra: 229, minLength: 40, length: 40)
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var altitude: Float
        public var lat: Int32
        public var lng: Int32
        public var v1: Float
        public var v2: Float
        public var v3: Float
        public var v4: Float

        public init(roll: Float = 0, pitch: Float = 0, yaw: Float = 0, altitude: Float = 0, lat: Int32 = 0, lng: Int32 = 0, v1: Float = 0, v2: Float = 0, v3: Float = 0, v4: Float = 0) {
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.altitude = altitude
            self.lat = lat
            self.lng = lng
            self.v1 = v1
            self.v2 = v2
            self.v3 = v3
            self.v4 = v4
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.roll = p.float(0)
            self.pitch = p.float(4)
            self.yaw = p.float(8)
            self.altitude = p.float(12)
            self.lat = p.int32(16)
            self.lng = p.int32(20)
            self.v1 = p.float(24)
            self.v2 = p.float(28)
            self.v3 = p.float(32)
            self.v4 = p.float(36)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.roll, 0)
            w.put(self.pitch, 4)
            w.put(self.yaw, 8)
            w.put(self.altitude, 12)
            w.put(self.lat, 16)
            w.put(self.lng, 20)
            w.put(self.v1, 24)
            w.put(self.v2, 28)
            w.put(self.v3, 32)
            w.put(self.v4, 36)
        }
    }
}

/// AUTOPILOT_VERSION_REQUEST (#183)
extension MAV {
    public struct AutopilotVersionRequest: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 183, name: "AUTOPILOT_VERSION_REQUEST", crcExtra: 85, minLength: 2, length: 2)
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
        }
    }
}

/// REMOTE_LOG_DATA_BLOCK (#184)
extension MAV {
    public struct RemoteLogDataBlock: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 184, name: "REMOTE_LOG_DATA_BLOCK", crcExtra: 159, minLength: 206, length: 206)
        public var seqno: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var data: [UInt8]

        public init(seqno: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 200)) {
            self.seqno = seqno
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.seqno = p.uint32(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.data = (0..<200).map { p.uint8(6 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.seqno, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            for k in 0..<Swift.min(200, self.data.count) { w.put(self.data[k], 6 + k * 1) }
        }
    }
}

/// REMOTE_LOG_BLOCK_STATUS (#185)
extension MAV {
    public struct RemoteLogBlockStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 185, name: "REMOTE_LOG_BLOCK_STATUS", crcExtra: 186, minLength: 7, length: 7)
        public var seqno: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var status: UInt8

        public init(seqno: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, status: UInt8 = 0) {
            self.seqno = seqno
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.status = status
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.seqno = p.uint32(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.status = p.uint8(6)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.seqno, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            w.put(self.status, 6)
        }
    }
}

/// LED_CONTROL (#186)
extension MAV {
    public struct LedControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 186, name: "LED_CONTROL", crcExtra: 72, minLength: 29, length: 29)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var instance: UInt8
        public var pattern: UInt8
        public var customLen: UInt8
        public var customBytes: [UInt8]

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, instance: UInt8 = 0, pattern: UInt8 = 0, customLen: UInt8 = 0, customBytes: [UInt8] = [UInt8](repeating: 0, count: 24)) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.instance = instance
            self.pattern = pattern
            self.customLen = customLen
            self.customBytes = customBytes
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.instance = p.uint8(2)
            self.pattern = p.uint8(3)
            self.customLen = p.uint8(4)
            self.customBytes = (0..<24).map { p.uint8(5 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            w.put(self.instance, 2)
            w.put(self.pattern, 3)
            w.put(self.customLen, 4)
            for k in 0..<Swift.min(24, self.customBytes.count) { w.put(self.customBytes[k], 5 + k * 1) }
        }
    }
}

/// MAG_CAL_PROGRESS (#191)
extension MAV {
    public struct MagCalProgress: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 191, name: "MAG_CAL_PROGRESS", crcExtra: 92, minLength: 27, length: 27)
        public var directionX: Float
        public var directionY: Float
        public var directionZ: Float
        public var compassId: UInt8
        public var calMask: UInt8
        public var calStatus: UInt8
        public var attempt: UInt8
        public var completionPct: UInt8
        public var completionMask: [UInt8]

        public init(directionX: Float = 0, directionY: Float = 0, directionZ: Float = 0, compassId: UInt8 = 0, calMask: UInt8 = 0, calStatus: UInt8 = 0, attempt: UInt8 = 0, completionPct: UInt8 = 0, completionMask: [UInt8] = [UInt8](repeating: 0, count: 10)) {
            self.directionX = directionX
            self.directionY = directionY
            self.directionZ = directionZ
            self.compassId = compassId
            self.calMask = calMask
            self.calStatus = calStatus
            self.attempt = attempt
            self.completionPct = completionPct
            self.completionMask = completionMask
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.directionX = p.float(0)
            self.directionY = p.float(4)
            self.directionZ = p.float(8)
            self.compassId = p.uint8(12)
            self.calMask = p.uint8(13)
            self.calStatus = p.uint8(14)
            self.attempt = p.uint8(15)
            self.completionPct = p.uint8(16)
            self.completionMask = (0..<10).map { p.uint8(17 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.directionX, 0)
            w.put(self.directionY, 4)
            w.put(self.directionZ, 8)
            w.put(self.compassId, 12)
            w.put(self.calMask, 13)
            w.put(self.calStatus, 14)
            w.put(self.attempt, 15)
            w.put(self.completionPct, 16)
            for k in 0..<Swift.min(10, self.completionMask.count) { w.put(self.completionMask[k], 17 + k * 1) }
        }
    }
}

/// MAG_CAL_REPORT (#192)
extension MAV {
    public struct MagCalReport: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 192, name: "MAG_CAL_REPORT", crcExtra: 36, minLength: 44, length: 54)
        public var fitness: Float
        public var ofsX: Float
        public var ofsY: Float
        public var ofsZ: Float
        public var diagX: Float
        public var diagY: Float
        public var diagZ: Float
        public var offdiagX: Float
        public var offdiagY: Float
        public var offdiagZ: Float
        public var compassId: UInt8
        public var calMask: UInt8
        public var calStatus: UInt8
        public var autosaved: UInt8
        public var orientationConfidence: Float  // extension field
        public var oldOrientation: UInt8  // extension field
        public var newOrientation: UInt8  // extension field
        public var scaleFactor: Float  // extension field

        public init(fitness: Float = 0, ofsX: Float = 0, ofsY: Float = 0, ofsZ: Float = 0, diagX: Float = 0, diagY: Float = 0, diagZ: Float = 0, offdiagX: Float = 0, offdiagY: Float = 0, offdiagZ: Float = 0, compassId: UInt8 = 0, calMask: UInt8 = 0, calStatus: UInt8 = 0, autosaved: UInt8 = 0, orientationConfidence: Float = 0, oldOrientation: UInt8 = 0, newOrientation: UInt8 = 0, scaleFactor: Float = 0) {
            self.fitness = fitness
            self.ofsX = ofsX
            self.ofsY = ofsY
            self.ofsZ = ofsZ
            self.diagX = diagX
            self.diagY = diagY
            self.diagZ = diagZ
            self.offdiagX = offdiagX
            self.offdiagY = offdiagY
            self.offdiagZ = offdiagZ
            self.compassId = compassId
            self.calMask = calMask
            self.calStatus = calStatus
            self.autosaved = autosaved
            self.orientationConfidence = orientationConfidence
            self.oldOrientation = oldOrientation
            self.newOrientation = newOrientation
            self.scaleFactor = scaleFactor
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.fitness = p.float(0)
            self.ofsX = p.float(4)
            self.ofsY = p.float(8)
            self.ofsZ = p.float(12)
            self.diagX = p.float(16)
            self.diagY = p.float(20)
            self.diagZ = p.float(24)
            self.offdiagX = p.float(28)
            self.offdiagY = p.float(32)
            self.offdiagZ = p.float(36)
            self.compassId = p.uint8(40)
            self.calMask = p.uint8(41)
            self.calStatus = p.uint8(42)
            self.autosaved = p.uint8(43)
            self.orientationConfidence = p.float(44)
            self.oldOrientation = p.uint8(48)
            self.newOrientation = p.uint8(49)
            self.scaleFactor = p.float(50)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.fitness, 0)
            w.put(self.ofsX, 4)
            w.put(self.ofsY, 8)
            w.put(self.ofsZ, 12)
            w.put(self.diagX, 16)
            w.put(self.diagY, 20)
            w.put(self.diagZ, 24)
            w.put(self.offdiagX, 28)
            w.put(self.offdiagY, 32)
            w.put(self.offdiagZ, 36)
            w.put(self.compassId, 40)
            w.put(self.calMask, 41)
            w.put(self.calStatus, 42)
            w.put(self.autosaved, 43)
            w.put(self.orientationConfidence, 44)
            w.put(self.oldOrientation, 48)
            w.put(self.newOrientation, 49)
            w.put(self.scaleFactor, 50)
        }
    }
}

/// EKF_STATUS_REPORT (#193)
extension MAV {
    public struct EkfStatusReport: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 193, name: "EKF_STATUS_REPORT", crcExtra: 71, minLength: 22, length: 26)
        public var velocityVariance: Float
        public var posHorizVariance: Float
        public var posVertVariance: Float
        public var compassVariance: Float
        public var terrainAltVariance: Float
        public var flags: UInt16
        public var airspeedVariance: Float  // extension field

        public init(velocityVariance: Float = 0, posHorizVariance: Float = 0, posVertVariance: Float = 0, compassVariance: Float = 0, terrainAltVariance: Float = 0, flags: UInt16 = 0, airspeedVariance: Float = 0) {
            self.velocityVariance = velocityVariance
            self.posHorizVariance = posHorizVariance
            self.posVertVariance = posVertVariance
            self.compassVariance = compassVariance
            self.terrainAltVariance = terrainAltVariance
            self.flags = flags
            self.airspeedVariance = airspeedVariance
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.velocityVariance = p.float(0)
            self.posHorizVariance = p.float(4)
            self.posVertVariance = p.float(8)
            self.compassVariance = p.float(12)
            self.terrainAltVariance = p.float(16)
            self.flags = p.uint16(20)
            self.airspeedVariance = p.float(22)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.velocityVariance, 0)
            w.put(self.posHorizVariance, 4)
            w.put(self.posVertVariance, 8)
            w.put(self.compassVariance, 12)
            w.put(self.terrainAltVariance, 16)
            w.put(self.flags, 20)
            w.put(self.airspeedVariance, 22)
        }
    }
}

/// PID_TUNING (#194)
extension MAV {
    public struct PidTuning: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 194, name: "PID_TUNING", crcExtra: 98, minLength: 25, length: 33)
        public var desired: Float
        public var achieved: Float
        public var FF: Float
        public var P: Float
        public var I: Float
        public var D: Float
        public var axis: UInt8
        public var SRate: Float  // extension field
        public var PDmod: Float  // extension field

        public init(desired: Float = 0, achieved: Float = 0, FF: Float = 0, P: Float = 0, I: Float = 0, D: Float = 0, axis: UInt8 = 0, SRate: Float = 0, PDmod: Float = 0) {
            self.desired = desired
            self.achieved = achieved
            self.FF = FF
            self.P = P
            self.I = I
            self.D = D
            self.axis = axis
            self.SRate = SRate
            self.PDmod = PDmod
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.desired = p.float(0)
            self.achieved = p.float(4)
            self.FF = p.float(8)
            self.P = p.float(12)
            self.I = p.float(16)
            self.D = p.float(20)
            self.axis = p.uint8(24)
            self.SRate = p.float(25)
            self.PDmod = p.float(29)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.desired, 0)
            w.put(self.achieved, 4)
            w.put(self.FF, 8)
            w.put(self.P, 12)
            w.put(self.I, 16)
            w.put(self.D, 20)
            w.put(self.axis, 24)
            w.put(self.SRate, 25)
            w.put(self.PDmod, 29)
        }
    }
}

/// DEEPSTALL (#195)
extension MAV {
    public struct Deepstall: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 195, name: "DEEPSTALL", crcExtra: 120, minLength: 37, length: 37)
        public var landingLat: Int32
        public var landingLon: Int32
        public var pathLat: Int32
        public var pathLon: Int32
        public var arcEntryLat: Int32
        public var arcEntryLon: Int32
        public var altitude: Float
        public var expectedTravelDistance: Float
        public var crossTrackError: Float
        public var stage: UInt8

        public init(landingLat: Int32 = 0, landingLon: Int32 = 0, pathLat: Int32 = 0, pathLon: Int32 = 0, arcEntryLat: Int32 = 0, arcEntryLon: Int32 = 0, altitude: Float = 0, expectedTravelDistance: Float = 0, crossTrackError: Float = 0, stage: UInt8 = 0) {
            self.landingLat = landingLat
            self.landingLon = landingLon
            self.pathLat = pathLat
            self.pathLon = pathLon
            self.arcEntryLat = arcEntryLat
            self.arcEntryLon = arcEntryLon
            self.altitude = altitude
            self.expectedTravelDistance = expectedTravelDistance
            self.crossTrackError = crossTrackError
            self.stage = stage
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.landingLat = p.int32(0)
            self.landingLon = p.int32(4)
            self.pathLat = p.int32(8)
            self.pathLon = p.int32(12)
            self.arcEntryLat = p.int32(16)
            self.arcEntryLon = p.int32(20)
            self.altitude = p.float(24)
            self.expectedTravelDistance = p.float(28)
            self.crossTrackError = p.float(32)
            self.stage = p.uint8(36)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.landingLat, 0)
            w.put(self.landingLon, 4)
            w.put(self.pathLat, 8)
            w.put(self.pathLon, 12)
            w.put(self.arcEntryLat, 16)
            w.put(self.arcEntryLon, 20)
            w.put(self.altitude, 24)
            w.put(self.expectedTravelDistance, 28)
            w.put(self.crossTrackError, 32)
            w.put(self.stage, 36)
        }
    }
}

/// GIMBAL_REPORT (#200)
extension MAV {
    public struct GimbalReport: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 200, name: "GIMBAL_REPORT", crcExtra: 134, minLength: 42, length: 42)
        public var deltaTime: Float
        public var deltaAngleX: Float
        public var deltaAngleY: Float
        public var deltaAngleZ: Float
        public var deltaVelocityX: Float
        public var deltaVelocityY: Float
        public var deltaVelocityZ: Float
        public var jointRoll: Float
        public var jointEl: Float
        public var jointAz: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(deltaTime: Float = 0, deltaAngleX: Float = 0, deltaAngleY: Float = 0, deltaAngleZ: Float = 0, deltaVelocityX: Float = 0, deltaVelocityY: Float = 0, deltaVelocityZ: Float = 0, jointRoll: Float = 0, jointEl: Float = 0, jointAz: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.deltaTime = deltaTime
            self.deltaAngleX = deltaAngleX
            self.deltaAngleY = deltaAngleY
            self.deltaAngleZ = deltaAngleZ
            self.deltaVelocityX = deltaVelocityX
            self.deltaVelocityY = deltaVelocityY
            self.deltaVelocityZ = deltaVelocityZ
            self.jointRoll = jointRoll
            self.jointEl = jointEl
            self.jointAz = jointAz
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.deltaTime = p.float(0)
            self.deltaAngleX = p.float(4)
            self.deltaAngleY = p.float(8)
            self.deltaAngleZ = p.float(12)
            self.deltaVelocityX = p.float(16)
            self.deltaVelocityY = p.float(20)
            self.deltaVelocityZ = p.float(24)
            self.jointRoll = p.float(28)
            self.jointEl = p.float(32)
            self.jointAz = p.float(36)
            self.targetSystem = p.uint8(40)
            self.targetComponent = p.uint8(41)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.deltaTime, 0)
            w.put(self.deltaAngleX, 4)
            w.put(self.deltaAngleY, 8)
            w.put(self.deltaAngleZ, 12)
            w.put(self.deltaVelocityX, 16)
            w.put(self.deltaVelocityY, 20)
            w.put(self.deltaVelocityZ, 24)
            w.put(self.jointRoll, 28)
            w.put(self.jointEl, 32)
            w.put(self.jointAz, 36)
            w.put(self.targetSystem, 40)
            w.put(self.targetComponent, 41)
        }
    }
}

/// GIMBAL_CONTROL (#201)
extension MAV {
    public struct GimbalControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 201, name: "GIMBAL_CONTROL", crcExtra: 205, minLength: 14, length: 14)
        public var demandedRateX: Float
        public var demandedRateY: Float
        public var demandedRateZ: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(demandedRateX: Float = 0, demandedRateY: Float = 0, demandedRateZ: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.demandedRateX = demandedRateX
            self.demandedRateY = demandedRateY
            self.demandedRateZ = demandedRateZ
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.demandedRateX = p.float(0)
            self.demandedRateY = p.float(4)
            self.demandedRateZ = p.float(8)
            self.targetSystem = p.uint8(12)
            self.targetComponent = p.uint8(13)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.demandedRateX, 0)
            w.put(self.demandedRateY, 4)
            w.put(self.demandedRateZ, 8)
            w.put(self.targetSystem, 12)
            w.put(self.targetComponent, 13)
        }
    }
}

/// GIMBAL_TORQUE_CMD_REPORT (#214)
extension MAV {
    public struct GimbalTorqueCmdReport: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 214, name: "GIMBAL_TORQUE_CMD_REPORT", crcExtra: 69, minLength: 8, length: 8)
        public var rlTorqueCmd: Int16
        public var elTorqueCmd: Int16
        public var azTorqueCmd: Int16
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(rlTorqueCmd: Int16 = 0, elTorqueCmd: Int16 = 0, azTorqueCmd: Int16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.rlTorqueCmd = rlTorqueCmd
            self.elTorqueCmd = elTorqueCmd
            self.azTorqueCmd = azTorqueCmd
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.rlTorqueCmd = p.int16(0)
            self.elTorqueCmd = p.int16(2)
            self.azTorqueCmd = p.int16(4)
            self.targetSystem = p.uint8(6)
            self.targetComponent = p.uint8(7)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.rlTorqueCmd, 0)
            w.put(self.elTorqueCmd, 2)
            w.put(self.azTorqueCmd, 4)
            w.put(self.targetSystem, 6)
            w.put(self.targetComponent, 7)
        }
    }
}

/// GOPRO_HEARTBEAT (#215)
extension MAV {
    public struct GoproHeartbeat: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 215, name: "GOPRO_HEARTBEAT", crcExtra: 101, minLength: 3, length: 3)
        public var status: UInt8
        public var captureMode: UInt8
        public var flags: UInt8

        public init(status: UInt8 = 0, captureMode: UInt8 = 0, flags: UInt8 = 0) {
            self.status = status
            self.captureMode = captureMode
            self.flags = flags
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.status = p.uint8(0)
            self.captureMode = p.uint8(1)
            self.flags = p.uint8(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.status, 0)
            w.put(self.captureMode, 1)
            w.put(self.flags, 2)
        }
    }
}

/// GOPRO_GET_REQUEST (#216)
extension MAV {
    public struct GoproGetRequest: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 216, name: "GOPRO_GET_REQUEST", crcExtra: 50, minLength: 3, length: 3)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var cmdId: UInt8

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, cmdId: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.cmdId = cmdId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.cmdId = p.uint8(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            w.put(self.cmdId, 2)
        }
    }
}

/// GOPRO_GET_RESPONSE (#217)
extension MAV {
    public struct GoproGetResponse: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 217, name: "GOPRO_GET_RESPONSE", crcExtra: 202, minLength: 6, length: 6)
        public var cmdId: UInt8
        public var status: UInt8
        public var value: [UInt8]

        public init(cmdId: UInt8 = 0, status: UInt8 = 0, value: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.cmdId = cmdId
            self.status = status
            self.value = value
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.cmdId = p.uint8(0)
            self.status = p.uint8(1)
            self.value = (0..<4).map { p.uint8(2 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.cmdId, 0)
            w.put(self.status, 1)
            for k in 0..<Swift.min(4, self.value.count) { w.put(self.value[k], 2 + k * 1) }
        }
    }
}

/// GOPRO_SET_REQUEST (#218)
extension MAV {
    public struct GoproSetRequest: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 218, name: "GOPRO_SET_REQUEST", crcExtra: 17, minLength: 7, length: 7)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var cmdId: UInt8
        public var value: [UInt8]

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, cmdId: UInt8 = 0, value: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.cmdId = cmdId
            self.value = value
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.cmdId = p.uint8(2)
            self.value = (0..<4).map { p.uint8(3 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            w.put(self.cmdId, 2)
            for k in 0..<Swift.min(4, self.value.count) { w.put(self.value[k], 3 + k * 1) }
        }
    }
}

/// GOPRO_SET_RESPONSE (#219)
extension MAV {
    public struct GoproSetResponse: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 219, name: "GOPRO_SET_RESPONSE", crcExtra: 162, minLength: 2, length: 2)
        public var cmdId: UInt8
        public var status: UInt8

        public init(cmdId: UInt8 = 0, status: UInt8 = 0) {
            self.cmdId = cmdId
            self.status = status
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.cmdId = p.uint8(0)
            self.status = p.uint8(1)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.cmdId, 0)
            w.put(self.status, 1)
        }
    }
}

/// NAV_FILTER_BIAS (#220)
extension MAV {
    public struct NavFilterBias: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 220, name: "NAV_FILTER_BIAS", crcExtra: 34, minLength: 32, length: 32)
        public var usec: UInt64
        public var accel0: Float
        public var accel1: Float
        public var accel2: Float
        public var gyro0: Float
        public var gyro1: Float
        public var gyro2: Float

        public init(usec: UInt64 = 0, accel0: Float = 0, accel1: Float = 0, accel2: Float = 0, gyro0: Float = 0, gyro1: Float = 0, gyro2: Float = 0) {
            self.usec = usec
            self.accel0 = accel0
            self.accel1 = accel1
            self.accel2 = accel2
            self.gyro0 = gyro0
            self.gyro1 = gyro1
            self.gyro2 = gyro2
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.usec = p.uint64(0)
            self.accel0 = p.float(8)
            self.accel1 = p.float(12)
            self.accel2 = p.float(16)
            self.gyro0 = p.float(20)
            self.gyro1 = p.float(24)
            self.gyro2 = p.float(28)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.usec, 0)
            w.put(self.accel0, 8)
            w.put(self.accel1, 12)
            w.put(self.accel2, 16)
            w.put(self.gyro0, 20)
            w.put(self.gyro1, 24)
            w.put(self.gyro2, 28)
        }
    }
}

/// RADIO_CALIBRATION (#221)
extension MAV {
    public struct RadioCalibration: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 221, name: "RADIO_CALIBRATION", crcExtra: 71, minLength: 42, length: 42)
        public var aileron: [UInt16]
        public var elevator: [UInt16]
        public var rudder: [UInt16]
        public var gyro: [UInt16]
        public var pitch: [UInt16]
        public var throttle: [UInt16]

        public init(aileron: [UInt16] = [UInt16](repeating: 0, count: 3), elevator: [UInt16] = [UInt16](repeating: 0, count: 3), rudder: [UInt16] = [UInt16](repeating: 0, count: 3), gyro: [UInt16] = [UInt16](repeating: 0, count: 2), pitch: [UInt16] = [UInt16](repeating: 0, count: 5), throttle: [UInt16] = [UInt16](repeating: 0, count: 5)) {
            self.aileron = aileron
            self.elevator = elevator
            self.rudder = rudder
            self.gyro = gyro
            self.pitch = pitch
            self.throttle = throttle
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.aileron = (0..<3).map { p.uint16(0 + $0 * 2) }
            self.elevator = (0..<3).map { p.uint16(6 + $0 * 2) }
            self.rudder = (0..<3).map { p.uint16(12 + $0 * 2) }
            self.gyro = (0..<2).map { p.uint16(18 + $0 * 2) }
            self.pitch = (0..<5).map { p.uint16(22 + $0 * 2) }
            self.throttle = (0..<5).map { p.uint16(32 + $0 * 2) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(3, self.aileron.count) { w.put(self.aileron[k], 0 + k * 2) }
            for k in 0..<Swift.min(3, self.elevator.count) { w.put(self.elevator[k], 6 + k * 2) }
            for k in 0..<Swift.min(3, self.rudder.count) { w.put(self.rudder[k], 12 + k * 2) }
            for k in 0..<Swift.min(2, self.gyro.count) { w.put(self.gyro[k], 18 + k * 2) }
            for k in 0..<Swift.min(5, self.pitch.count) { w.put(self.pitch[k], 22 + k * 2) }
            for k in 0..<Swift.min(5, self.throttle.count) { w.put(self.throttle[k], 32 + k * 2) }
        }
    }
}

/// UALBERTA_SYS_STATUS (#222)
extension MAV {
    public struct UalbertaSysStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 222, name: "UALBERTA_SYS_STATUS", crcExtra: 15, minLength: 3, length: 3)
        public var mode: UInt8
        public var navMode: UInt8
        public var pilot: UInt8

        public init(mode: UInt8 = 0, navMode: UInt8 = 0, pilot: UInt8 = 0) {
            self.mode = mode
            self.navMode = navMode
            self.pilot = pilot
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.mode = p.uint8(0)
            self.navMode = p.uint8(1)
            self.pilot = p.uint8(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.mode, 0)
            w.put(self.navMode, 1)
            w.put(self.pilot, 2)
        }
    }
}

/// COMMAND_INT_STAMPED (#223)
extension MAV {
    public struct CommandIntStamped: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 223, name: "COMMAND_INT_STAMPED", crcExtra: 119, minLength: 47, length: 47)
        public var vehicleTimestamp: UInt64
        public var utcTime: UInt32
        public var param1: Float
        public var param2: Float
        public var param3: Float
        public var param4: Float
        public var x: Int32
        public var y: Int32
        public var z: Float
        public var command: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var frame: UInt8
        public var current: UInt8
        public var autocontinue: UInt8

        public init(vehicleTimestamp: UInt64 = 0, utcTime: UInt32 = 0, param1: Float = 0, param2: Float = 0, param3: Float = 0, param4: Float = 0, x: Int32 = 0, y: Int32 = 0, z: Float = 0, command: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, frame: UInt8 = 0, current: UInt8 = 0, autocontinue: UInt8 = 0) {
            self.vehicleTimestamp = vehicleTimestamp
            self.utcTime = utcTime
            self.param1 = param1
            self.param2 = param2
            self.param3 = param3
            self.param4 = param4
            self.x = x
            self.y = y
            self.z = z
            self.command = command
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.frame = frame
            self.current = current
            self.autocontinue = autocontinue
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.vehicleTimestamp = p.uint64(0)
            self.utcTime = p.uint32(8)
            self.param1 = p.float(12)
            self.param2 = p.float(16)
            self.param3 = p.float(20)
            self.param4 = p.float(24)
            self.x = p.int32(28)
            self.y = p.int32(32)
            self.z = p.float(36)
            self.command = p.uint16(40)
            self.targetSystem = p.uint8(42)
            self.targetComponent = p.uint8(43)
            self.frame = p.uint8(44)
            self.current = p.uint8(45)
            self.autocontinue = p.uint8(46)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.vehicleTimestamp, 0)
            w.put(self.utcTime, 8)
            w.put(self.param1, 12)
            w.put(self.param2, 16)
            w.put(self.param3, 20)
            w.put(self.param4, 24)
            w.put(self.x, 28)
            w.put(self.y, 32)
            w.put(self.z, 36)
            w.put(self.command, 40)
            w.put(self.targetSystem, 42)
            w.put(self.targetComponent, 43)
            w.put(self.frame, 44)
            w.put(self.current, 45)
            w.put(self.autocontinue, 46)
        }
    }
}

/// COMMAND_LONG_STAMPED (#224)
extension MAV {
    public struct CommandLongStamped: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 224, name: "COMMAND_LONG_STAMPED", crcExtra: 102, minLength: 45, length: 45)
        public var vehicleTimestamp: UInt64
        public var utcTime: UInt32
        public var param1: Float
        public var param2: Float
        public var param3: Float
        public var param4: Float
        public var param5: Float
        public var param6: Float
        public var param7: Float
        public var command: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var confirmation: UInt8

        public init(vehicleTimestamp: UInt64 = 0, utcTime: UInt32 = 0, param1: Float = 0, param2: Float = 0, param3: Float = 0, param4: Float = 0, param5: Float = 0, param6: Float = 0, param7: Float = 0, command: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, confirmation: UInt8 = 0) {
            self.vehicleTimestamp = vehicleTimestamp
            self.utcTime = utcTime
            self.param1 = param1
            self.param2 = param2
            self.param3 = param3
            self.param4 = param4
            self.param5 = param5
            self.param6 = param6
            self.param7 = param7
            self.command = command
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.confirmation = confirmation
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.vehicleTimestamp = p.uint64(0)
            self.utcTime = p.uint32(8)
            self.param1 = p.float(12)
            self.param2 = p.float(16)
            self.param3 = p.float(20)
            self.param4 = p.float(24)
            self.param5 = p.float(28)
            self.param6 = p.float(32)
            self.param7 = p.float(36)
            self.command = p.uint16(40)
            self.targetSystem = p.uint8(42)
            self.targetComponent = p.uint8(43)
            self.confirmation = p.uint8(44)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.vehicleTimestamp, 0)
            w.put(self.utcTime, 8)
            w.put(self.param1, 12)
            w.put(self.param2, 16)
            w.put(self.param3, 20)
            w.put(self.param4, 24)
            w.put(self.param5, 28)
            w.put(self.param6, 32)
            w.put(self.param7, 36)
            w.put(self.command, 40)
            w.put(self.targetSystem, 42)
            w.put(self.targetComponent, 43)
            w.put(self.confirmation, 44)
        }
    }
}

/// EFI_STATUS (#225)
extension MAV {
    public struct EfiStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 225, name: "EFI_STATUS", crcExtra: 208, minLength: 65, length: 73)
        public var ecuIndex: Float
        public var rpm: Float
        public var fuelConsumed: Float
        public var fuelFlow: Float
        public var engineLoad: Float
        public var throttlePosition: Float
        public var sparkDwellTime: Float
        public var barometricPressure: Float
        public var intakeManifoldPressure: Float
        public var intakeManifoldTemperature: Float
        public var cylinderHeadTemperature: Float
        public var ignitionTiming: Float
        public var injectionTime: Float
        public var exhaustGasTemperature: Float
        public var throttleOut: Float
        public var ptCompensation: Float
        public var health: UInt8
        public var ignitionVoltage: Float  // extension field
        public var fuelPressure: Float  // extension field

        public init(ecuIndex: Float = 0, rpm: Float = 0, fuelConsumed: Float = 0, fuelFlow: Float = 0, engineLoad: Float = 0, throttlePosition: Float = 0, sparkDwellTime: Float = 0, barometricPressure: Float = 0, intakeManifoldPressure: Float = 0, intakeManifoldTemperature: Float = 0, cylinderHeadTemperature: Float = 0, ignitionTiming: Float = 0, injectionTime: Float = 0, exhaustGasTemperature: Float = 0, throttleOut: Float = 0, ptCompensation: Float = 0, health: UInt8 = 0, ignitionVoltage: Float = 0, fuelPressure: Float = 0) {
            self.ecuIndex = ecuIndex
            self.rpm = rpm
            self.fuelConsumed = fuelConsumed
            self.fuelFlow = fuelFlow
            self.engineLoad = engineLoad
            self.throttlePosition = throttlePosition
            self.sparkDwellTime = sparkDwellTime
            self.barometricPressure = barometricPressure
            self.intakeManifoldPressure = intakeManifoldPressure
            self.intakeManifoldTemperature = intakeManifoldTemperature
            self.cylinderHeadTemperature = cylinderHeadTemperature
            self.ignitionTiming = ignitionTiming
            self.injectionTime = injectionTime
            self.exhaustGasTemperature = exhaustGasTemperature
            self.throttleOut = throttleOut
            self.ptCompensation = ptCompensation
            self.health = health
            self.ignitionVoltage = ignitionVoltage
            self.fuelPressure = fuelPressure
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.ecuIndex = p.float(0)
            self.rpm = p.float(4)
            self.fuelConsumed = p.float(8)
            self.fuelFlow = p.float(12)
            self.engineLoad = p.float(16)
            self.throttlePosition = p.float(20)
            self.sparkDwellTime = p.float(24)
            self.barometricPressure = p.float(28)
            self.intakeManifoldPressure = p.float(32)
            self.intakeManifoldTemperature = p.float(36)
            self.cylinderHeadTemperature = p.float(40)
            self.ignitionTiming = p.float(44)
            self.injectionTime = p.float(48)
            self.exhaustGasTemperature = p.float(52)
            self.throttleOut = p.float(56)
            self.ptCompensation = p.float(60)
            self.health = p.uint8(64)
            self.ignitionVoltage = p.float(65)
            self.fuelPressure = p.float(69)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.ecuIndex, 0)
            w.put(self.rpm, 4)
            w.put(self.fuelConsumed, 8)
            w.put(self.fuelFlow, 12)
            w.put(self.engineLoad, 16)
            w.put(self.throttlePosition, 20)
            w.put(self.sparkDwellTime, 24)
            w.put(self.barometricPressure, 28)
            w.put(self.intakeManifoldPressure, 32)
            w.put(self.intakeManifoldTemperature, 36)
            w.put(self.cylinderHeadTemperature, 40)
            w.put(self.ignitionTiming, 44)
            w.put(self.injectionTime, 48)
            w.put(self.exhaustGasTemperature, 52)
            w.put(self.throttleOut, 56)
            w.put(self.ptCompensation, 60)
            w.put(self.health, 64)
            w.put(self.ignitionVoltage, 65)
            w.put(self.fuelPressure, 69)
        }
    }
}

/// RPM (#226)
extension MAV {
    public struct Rpm: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 226, name: "RPM", crcExtra: 207, minLength: 8, length: 8)
        public var rpm1: Float
        public var rpm2: Float

        public init(rpm1: Float = 0, rpm2: Float = 0) {
            self.rpm1 = rpm1
            self.rpm2 = rpm2
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.rpm1 = p.float(0)
            self.rpm2 = p.float(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.rpm1, 0)
            w.put(self.rpm2, 4)
        }
    }
}

/// ESTIMATOR_STATUS (#230)
extension MAV {
    public struct EstimatorStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 230, name: "ESTIMATOR_STATUS", crcExtra: 163, minLength: 42, length: 42)
        public var timeUsec: UInt64
        public var velRatio: Float
        public var posHorizRatio: Float
        public var posVertRatio: Float
        public var magRatio: Float
        public var haglRatio: Float
        public var tasRatio: Float
        public var posHorizAccuracy: Float
        public var posVertAccuracy: Float
        public var flags: UInt16

        public init(timeUsec: UInt64 = 0, velRatio: Float = 0, posHorizRatio: Float = 0, posVertRatio: Float = 0, magRatio: Float = 0, haglRatio: Float = 0, tasRatio: Float = 0, posHorizAccuracy: Float = 0, posVertAccuracy: Float = 0, flags: UInt16 = 0) {
            self.timeUsec = timeUsec
            self.velRatio = velRatio
            self.posHorizRatio = posHorizRatio
            self.posVertRatio = posVertRatio
            self.magRatio = magRatio
            self.haglRatio = haglRatio
            self.tasRatio = tasRatio
            self.posHorizAccuracy = posHorizAccuracy
            self.posVertAccuracy = posVertAccuracy
            self.flags = flags
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.velRatio = p.float(8)
            self.posHorizRatio = p.float(12)
            self.posVertRatio = p.float(16)
            self.magRatio = p.float(20)
            self.haglRatio = p.float(24)
            self.tasRatio = p.float(28)
            self.posHorizAccuracy = p.float(32)
            self.posVertAccuracy = p.float(36)
            self.flags = p.uint16(40)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.velRatio, 8)
            w.put(self.posHorizRatio, 12)
            w.put(self.posVertRatio, 16)
            w.put(self.magRatio, 20)
            w.put(self.haglRatio, 24)
            w.put(self.tasRatio, 28)
            w.put(self.posHorizAccuracy, 32)
            w.put(self.posVertAccuracy, 36)
            w.put(self.flags, 40)
        }
    }
}

/// WIND_COV (#231)
extension MAV {
    public struct WindCov: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 231, name: "WIND_COV", crcExtra: 105, minLength: 40, length: 40)
        public var timeUsec: UInt64
        public var windX: Float
        public var windY: Float
        public var windZ: Float
        public var varHoriz: Float
        public var varVert: Float
        public var windAlt: Float
        public var horizAccuracy: Float
        public var vertAccuracy: Float

        public init(timeUsec: UInt64 = 0, windX: Float = 0, windY: Float = 0, windZ: Float = 0, varHoriz: Float = 0, varVert: Float = 0, windAlt: Float = 0, horizAccuracy: Float = 0, vertAccuracy: Float = 0) {
            self.timeUsec = timeUsec
            self.windX = windX
            self.windY = windY
            self.windZ = windZ
            self.varHoriz = varHoriz
            self.varVert = varVert
            self.windAlt = windAlt
            self.horizAccuracy = horizAccuracy
            self.vertAccuracy = vertAccuracy
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.windX = p.float(8)
            self.windY = p.float(12)
            self.windZ = p.float(16)
            self.varHoriz = p.float(20)
            self.varVert = p.float(24)
            self.windAlt = p.float(28)
            self.horizAccuracy = p.float(32)
            self.vertAccuracy = p.float(36)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.windX, 8)
            w.put(self.windY, 12)
            w.put(self.windZ, 16)
            w.put(self.varHoriz, 20)
            w.put(self.varVert, 24)
            w.put(self.windAlt, 28)
            w.put(self.horizAccuracy, 32)
            w.put(self.vertAccuracy, 36)
        }
    }
}

/// GPS_INPUT (#232)
extension MAV {
    public struct GpsInput: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 232, name: "GPS_INPUT", crcExtra: 151, minLength: 63, length: 65)
        public var timeUsec: UInt64
        public var timeWeekMs: UInt32
        public var lat: Int32
        public var lon: Int32
        public var alt: Float
        public var hdop: Float
        public var vdop: Float
        public var vn: Float
        public var ve: Float
        public var vd: Float
        public var speedAccuracy: Float
        public var horizAccuracy: Float
        public var vertAccuracy: Float
        public var ignoreFlags: UInt16
        public var timeWeek: UInt16
        public var gpsId: UInt8
        public var fixType: UInt8
        public var satellitesVisible: UInt8
        public var yaw: UInt16  // extension field

        public init(timeUsec: UInt64 = 0, timeWeekMs: UInt32 = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Float = 0, hdop: Float = 0, vdop: Float = 0, vn: Float = 0, ve: Float = 0, vd: Float = 0, speedAccuracy: Float = 0, horizAccuracy: Float = 0, vertAccuracy: Float = 0, ignoreFlags: UInt16 = 0, timeWeek: UInt16 = 0, gpsId: UInt8 = 0, fixType: UInt8 = 0, satellitesVisible: UInt8 = 0, yaw: UInt16 = 0) {
            self.timeUsec = timeUsec
            self.timeWeekMs = timeWeekMs
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.hdop = hdop
            self.vdop = vdop
            self.vn = vn
            self.ve = ve
            self.vd = vd
            self.speedAccuracy = speedAccuracy
            self.horizAccuracy = horizAccuracy
            self.vertAccuracy = vertAccuracy
            self.ignoreFlags = ignoreFlags
            self.timeWeek = timeWeek
            self.gpsId = gpsId
            self.fixType = fixType
            self.satellitesVisible = satellitesVisible
            self.yaw = yaw
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.timeWeekMs = p.uint32(8)
            self.lat = p.int32(12)
            self.lon = p.int32(16)
            self.alt = p.float(20)
            self.hdop = p.float(24)
            self.vdop = p.float(28)
            self.vn = p.float(32)
            self.ve = p.float(36)
            self.vd = p.float(40)
            self.speedAccuracy = p.float(44)
            self.horizAccuracy = p.float(48)
            self.vertAccuracy = p.float(52)
            self.ignoreFlags = p.uint16(56)
            self.timeWeek = p.uint16(58)
            self.gpsId = p.uint8(60)
            self.fixType = p.uint8(61)
            self.satellitesVisible = p.uint8(62)
            self.yaw = p.uint16(63)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.timeWeekMs, 8)
            w.put(self.lat, 12)
            w.put(self.lon, 16)
            w.put(self.alt, 20)
            w.put(self.hdop, 24)
            w.put(self.vdop, 28)
            w.put(self.vn, 32)
            w.put(self.ve, 36)
            w.put(self.vd, 40)
            w.put(self.speedAccuracy, 44)
            w.put(self.horizAccuracy, 48)
            w.put(self.vertAccuracy, 52)
            w.put(self.ignoreFlags, 56)
            w.put(self.timeWeek, 58)
            w.put(self.gpsId, 60)
            w.put(self.fixType, 61)
            w.put(self.satellitesVisible, 62)
            w.put(self.yaw, 63)
        }
    }
}

/// GPS_RTCM_DATA (#233)
extension MAV {
    public struct GpsRtcmData: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 233, name: "GPS_RTCM_DATA", crcExtra: 35, minLength: 182, length: 182)
        public var flags: UInt8
        public var len: UInt8
        public var data: [UInt8]

        public init(flags: UInt8 = 0, len: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 180)) {
            self.flags = flags
            self.len = len
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.flags = p.uint8(0)
            self.len = p.uint8(1)
            self.data = (0..<180).map { p.uint8(2 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.flags, 0)
            w.put(self.len, 1)
            for k in 0..<Swift.min(180, self.data.count) { w.put(self.data[k], 2 + k * 1) }
        }
    }
}

/// HIGH_LATENCY (#234)
extension MAV {
    public struct HighLatency: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 234, name: "HIGH_LATENCY", crcExtra: 150, minLength: 40, length: 40)
        public var customMode: UInt32
        public var latitude: Int32
        public var longitude: Int32
        public var roll: Int16
        public var pitch: Int16
        public var heading: UInt16
        public var headingSp: Int16
        public var altitudeAmsl: Int16
        public var altitudeSp: Int16
        public var wpDistance: UInt16
        public var baseMode: UInt8
        public var landedState: UInt8
        public var throttle: Int8
        public var airspeed: UInt8
        public var airspeedSp: UInt8
        public var groundspeed: UInt8
        public var climbRate: Int8
        public var gpsNsat: UInt8
        public var gpsFixType: UInt8
        public var batteryRemaining: UInt8
        public var temperature: Int8
        public var temperatureAir: Int8
        public var failsafe: UInt8
        public var wpNum: UInt8

        public init(customMode: UInt32 = 0, latitude: Int32 = 0, longitude: Int32 = 0, roll: Int16 = 0, pitch: Int16 = 0, heading: UInt16 = 0, headingSp: Int16 = 0, altitudeAmsl: Int16 = 0, altitudeSp: Int16 = 0, wpDistance: UInt16 = 0, baseMode: UInt8 = 0, landedState: UInt8 = 0, throttle: Int8 = 0, airspeed: UInt8 = 0, airspeedSp: UInt8 = 0, groundspeed: UInt8 = 0, climbRate: Int8 = 0, gpsNsat: UInt8 = 0, gpsFixType: UInt8 = 0, batteryRemaining: UInt8 = 0, temperature: Int8 = 0, temperatureAir: Int8 = 0, failsafe: UInt8 = 0, wpNum: UInt8 = 0) {
            self.customMode = customMode
            self.latitude = latitude
            self.longitude = longitude
            self.roll = roll
            self.pitch = pitch
            self.heading = heading
            self.headingSp = headingSp
            self.altitudeAmsl = altitudeAmsl
            self.altitudeSp = altitudeSp
            self.wpDistance = wpDistance
            self.baseMode = baseMode
            self.landedState = landedState
            self.throttle = throttle
            self.airspeed = airspeed
            self.airspeedSp = airspeedSp
            self.groundspeed = groundspeed
            self.climbRate = climbRate
            self.gpsNsat = gpsNsat
            self.gpsFixType = gpsFixType
            self.batteryRemaining = batteryRemaining
            self.temperature = temperature
            self.temperatureAir = temperatureAir
            self.failsafe = failsafe
            self.wpNum = wpNum
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.customMode = p.uint32(0)
            self.latitude = p.int32(4)
            self.longitude = p.int32(8)
            self.roll = p.int16(12)
            self.pitch = p.int16(14)
            self.heading = p.uint16(16)
            self.headingSp = p.int16(18)
            self.altitudeAmsl = p.int16(20)
            self.altitudeSp = p.int16(22)
            self.wpDistance = p.uint16(24)
            self.baseMode = p.uint8(26)
            self.landedState = p.uint8(27)
            self.throttle = p.int8(28)
            self.airspeed = p.uint8(29)
            self.airspeedSp = p.uint8(30)
            self.groundspeed = p.uint8(31)
            self.climbRate = p.int8(32)
            self.gpsNsat = p.uint8(33)
            self.gpsFixType = p.uint8(34)
            self.batteryRemaining = p.uint8(35)
            self.temperature = p.int8(36)
            self.temperatureAir = p.int8(37)
            self.failsafe = p.uint8(38)
            self.wpNum = p.uint8(39)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.customMode, 0)
            w.put(self.latitude, 4)
            w.put(self.longitude, 8)
            w.put(self.roll, 12)
            w.put(self.pitch, 14)
            w.put(self.heading, 16)
            w.put(self.headingSp, 18)
            w.put(self.altitudeAmsl, 20)
            w.put(self.altitudeSp, 22)
            w.put(self.wpDistance, 24)
            w.put(self.baseMode, 26)
            w.put(self.landedState, 27)
            w.put(self.throttle, 28)
            w.put(self.airspeed, 29)
            w.put(self.airspeedSp, 30)
            w.put(self.groundspeed, 31)
            w.put(self.climbRate, 32)
            w.put(self.gpsNsat, 33)
            w.put(self.gpsFixType, 34)
            w.put(self.batteryRemaining, 35)
            w.put(self.temperature, 36)
            w.put(self.temperatureAir, 37)
            w.put(self.failsafe, 38)
            w.put(self.wpNum, 39)
        }
    }
}

/// HIGH_LATENCY2 (#235)
extension MAV {
    public struct HighLatency2: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 235, name: "HIGH_LATENCY2", crcExtra: 179, minLength: 42, length: 42)
        public var timestamp: UInt32
        public var latitude: Int32
        public var longitude: Int32
        public var customMode: UInt16
        public var altitude: Int16
        public var targetAltitude: Int16
        public var targetDistance: UInt16
        public var wpNum: UInt16
        public var failureFlags: UInt16
        public var type: UInt8
        public var autopilot: UInt8
        public var heading: UInt8
        public var targetHeading: UInt8
        public var throttle: UInt8
        public var airspeed: UInt8
        public var airspeedSp: UInt8
        public var groundspeed: UInt8
        public var windspeed: UInt8
        public var windHeading: UInt8
        public var eph: UInt8
        public var epv: UInt8
        public var temperatureAir: Int8
        public var climbRate: Int8
        public var battery: Int8
        public var custom0: Int8
        public var custom1: Int8
        public var custom2: Int8

        public init(timestamp: UInt32 = 0, latitude: Int32 = 0, longitude: Int32 = 0, customMode: UInt16 = 0, altitude: Int16 = 0, targetAltitude: Int16 = 0, targetDistance: UInt16 = 0, wpNum: UInt16 = 0, failureFlags: UInt16 = 0, type: UInt8 = 0, autopilot: UInt8 = 0, heading: UInt8 = 0, targetHeading: UInt8 = 0, throttle: UInt8 = 0, airspeed: UInt8 = 0, airspeedSp: UInt8 = 0, groundspeed: UInt8 = 0, windspeed: UInt8 = 0, windHeading: UInt8 = 0, eph: UInt8 = 0, epv: UInt8 = 0, temperatureAir: Int8 = 0, climbRate: Int8 = 0, battery: Int8 = 0, custom0: Int8 = 0, custom1: Int8 = 0, custom2: Int8 = 0) {
            self.timestamp = timestamp
            self.latitude = latitude
            self.longitude = longitude
            self.customMode = customMode
            self.altitude = altitude
            self.targetAltitude = targetAltitude
            self.targetDistance = targetDistance
            self.wpNum = wpNum
            self.failureFlags = failureFlags
            self.type = type
            self.autopilot = autopilot
            self.heading = heading
            self.targetHeading = targetHeading
            self.throttle = throttle
            self.airspeed = airspeed
            self.airspeedSp = airspeedSp
            self.groundspeed = groundspeed
            self.windspeed = windspeed
            self.windHeading = windHeading
            self.eph = eph
            self.epv = epv
            self.temperatureAir = temperatureAir
            self.climbRate = climbRate
            self.battery = battery
            self.custom0 = custom0
            self.custom1 = custom1
            self.custom2 = custom2
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint32(0)
            self.latitude = p.int32(4)
            self.longitude = p.int32(8)
            self.customMode = p.uint16(12)
            self.altitude = p.int16(14)
            self.targetAltitude = p.int16(16)
            self.targetDistance = p.uint16(18)
            self.wpNum = p.uint16(20)
            self.failureFlags = p.uint16(22)
            self.type = p.uint8(24)
            self.autopilot = p.uint8(25)
            self.heading = p.uint8(26)
            self.targetHeading = p.uint8(27)
            self.throttle = p.uint8(28)
            self.airspeed = p.uint8(29)
            self.airspeedSp = p.uint8(30)
            self.groundspeed = p.uint8(31)
            self.windspeed = p.uint8(32)
            self.windHeading = p.uint8(33)
            self.eph = p.uint8(34)
            self.epv = p.uint8(35)
            self.temperatureAir = p.int8(36)
            self.climbRate = p.int8(37)
            self.battery = p.int8(38)
            self.custom0 = p.int8(39)
            self.custom1 = p.int8(40)
            self.custom2 = p.int8(41)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.latitude, 4)
            w.put(self.longitude, 8)
            w.put(self.customMode, 12)
            w.put(self.altitude, 14)
            w.put(self.targetAltitude, 16)
            w.put(self.targetDistance, 18)
            w.put(self.wpNum, 20)
            w.put(self.failureFlags, 22)
            w.put(self.type, 24)
            w.put(self.autopilot, 25)
            w.put(self.heading, 26)
            w.put(self.targetHeading, 27)
            w.put(self.throttle, 28)
            w.put(self.airspeed, 29)
            w.put(self.airspeedSp, 30)
            w.put(self.groundspeed, 31)
            w.put(self.windspeed, 32)
            w.put(self.windHeading, 33)
            w.put(self.eph, 34)
            w.put(self.epv, 35)
            w.put(self.temperatureAir, 36)
            w.put(self.climbRate, 37)
            w.put(self.battery, 38)
            w.put(self.custom0, 39)
            w.put(self.custom1, 40)
            w.put(self.custom2, 41)
        }
    }
}

/// VIBRATION (#241)
extension MAV {
    public struct Vibration: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 241, name: "VIBRATION", crcExtra: 90, minLength: 32, length: 32)
        public var timeUsec: UInt64
        public var vibrationX: Float
        public var vibrationY: Float
        public var vibrationZ: Float
        public var clipping0: UInt32
        public var clipping1: UInt32
        public var clipping2: UInt32

        public init(timeUsec: UInt64 = 0, vibrationX: Float = 0, vibrationY: Float = 0, vibrationZ: Float = 0, clipping0: UInt32 = 0, clipping1: UInt32 = 0, clipping2: UInt32 = 0) {
            self.timeUsec = timeUsec
            self.vibrationX = vibrationX
            self.vibrationY = vibrationY
            self.vibrationZ = vibrationZ
            self.clipping0 = clipping0
            self.clipping1 = clipping1
            self.clipping2 = clipping2
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.vibrationX = p.float(8)
            self.vibrationY = p.float(12)
            self.vibrationZ = p.float(16)
            self.clipping0 = p.uint32(20)
            self.clipping1 = p.uint32(24)
            self.clipping2 = p.uint32(28)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.vibrationX, 8)
            w.put(self.vibrationY, 12)
            w.put(self.vibrationZ, 16)
            w.put(self.clipping0, 20)
            w.put(self.clipping1, 24)
            w.put(self.clipping2, 28)
        }
    }
}

/// HOME_POSITION (#242)
extension MAV {
    public struct HomePosition: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 242, name: "HOME_POSITION", crcExtra: 104, minLength: 52, length: 60)
        public var latitude: Int32
        public var longitude: Int32
        public var altitude: Int32
        public var x: Float
        public var y: Float
        public var z: Float
        public var q: [Float]
        public var approachX: Float
        public var approachY: Float
        public var approachZ: Float
        public var timeUsec: UInt64  // extension field

        public init(latitude: Int32 = 0, longitude: Int32 = 0, altitude: Int32 = 0, x: Float = 0, y: Float = 0, z: Float = 0, q: [Float] = [Float](repeating: 0, count: 4), approachX: Float = 0, approachY: Float = 0, approachZ: Float = 0, timeUsec: UInt64 = 0) {
            self.latitude = latitude
            self.longitude = longitude
            self.altitude = altitude
            self.x = x
            self.y = y
            self.z = z
            self.q = q
            self.approachX = approachX
            self.approachY = approachY
            self.approachZ = approachZ
            self.timeUsec = timeUsec
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.latitude = p.int32(0)
            self.longitude = p.int32(4)
            self.altitude = p.int32(8)
            self.x = p.float(12)
            self.y = p.float(16)
            self.z = p.float(20)
            self.q = (0..<4).map { p.float(24 + $0 * 4) }
            self.approachX = p.float(40)
            self.approachY = p.float(44)
            self.approachZ = p.float(48)
            self.timeUsec = p.uint64(52)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.latitude, 0)
            w.put(self.longitude, 4)
            w.put(self.altitude, 8)
            w.put(self.x, 12)
            w.put(self.y, 16)
            w.put(self.z, 20)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 24 + k * 4) }
            w.put(self.approachX, 40)
            w.put(self.approachY, 44)
            w.put(self.approachZ, 48)
            w.put(self.timeUsec, 52)
        }
    }
}

/// SET_HOME_POSITION (#243)
extension MAV {
    public struct SetHomePosition: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 243, name: "SET_HOME_POSITION", crcExtra: 85, minLength: 53, length: 61)
        public var latitude: Int32
        public var longitude: Int32
        public var altitude: Int32
        public var x: Float
        public var y: Float
        public var z: Float
        public var q: [Float]
        public var approachX: Float
        public var approachY: Float
        public var approachZ: Float
        public var targetSystem: UInt8
        public var timeUsec: UInt64  // extension field

        public init(latitude: Int32 = 0, longitude: Int32 = 0, altitude: Int32 = 0, x: Float = 0, y: Float = 0, z: Float = 0, q: [Float] = [Float](repeating: 0, count: 4), approachX: Float = 0, approachY: Float = 0, approachZ: Float = 0, targetSystem: UInt8 = 0, timeUsec: UInt64 = 0) {
            self.latitude = latitude
            self.longitude = longitude
            self.altitude = altitude
            self.x = x
            self.y = y
            self.z = z
            self.q = q
            self.approachX = approachX
            self.approachY = approachY
            self.approachZ = approachZ
            self.targetSystem = targetSystem
            self.timeUsec = timeUsec
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.latitude = p.int32(0)
            self.longitude = p.int32(4)
            self.altitude = p.int32(8)
            self.x = p.float(12)
            self.y = p.float(16)
            self.z = p.float(20)
            self.q = (0..<4).map { p.float(24 + $0 * 4) }
            self.approachX = p.float(40)
            self.approachY = p.float(44)
            self.approachZ = p.float(48)
            self.targetSystem = p.uint8(52)
            self.timeUsec = p.uint64(53)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.latitude, 0)
            w.put(self.longitude, 4)
            w.put(self.altitude, 8)
            w.put(self.x, 12)
            w.put(self.y, 16)
            w.put(self.z, 20)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 24 + k * 4) }
            w.put(self.approachX, 40)
            w.put(self.approachY, 44)
            w.put(self.approachZ, 48)
            w.put(self.targetSystem, 52)
            w.put(self.timeUsec, 53)
        }
    }
}

/// MESSAGE_INTERVAL (#244)
extension MAV {
    public struct MessageInterval: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 244, name: "MESSAGE_INTERVAL", crcExtra: 95, minLength: 6, length: 6)
        public var intervalUs: Int32
        public var messageId: UInt16

        public init(intervalUs: Int32 = 0, messageId: UInt16 = 0) {
            self.intervalUs = intervalUs
            self.messageId = messageId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.intervalUs = p.int32(0)
            self.messageId = p.uint16(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.intervalUs, 0)
            w.put(self.messageId, 4)
        }
    }
}

/// EXTENDED_SYS_STATE (#245)
extension MAV {
    public struct ExtendedSysState: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 245, name: "EXTENDED_SYS_STATE", crcExtra: 130, minLength: 2, length: 2)
        public var vtolState: UInt8
        public var landedState: UInt8

        public init(vtolState: UInt8 = 0, landedState: UInt8 = 0) {
            self.vtolState = vtolState
            self.landedState = landedState
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.vtolState = p.uint8(0)
            self.landedState = p.uint8(1)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.vtolState, 0)
            w.put(self.landedState, 1)
        }
    }
}

/// ADSB_VEHICLE (#246)
extension MAV {
    public struct AdsbVehicle: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 246, name: "ADSB_VEHICLE", crcExtra: 184, minLength: 38, length: 38)
        public var ICAOAddress: UInt32
        public var lat: Int32
        public var lon: Int32
        public var altitude: Int32
        public var heading: UInt16
        public var horVelocity: UInt16
        public var verVelocity: Int16
        public var flags: UInt16
        public var squawk: UInt16
        public var altitudeType: UInt8
        public var callsign: [UInt8]
        public var emitterType: UInt8
        public var tslc: UInt8

        public init(ICAOAddress: UInt32 = 0, lat: Int32 = 0, lon: Int32 = 0, altitude: Int32 = 0, heading: UInt16 = 0, horVelocity: UInt16 = 0, verVelocity: Int16 = 0, flags: UInt16 = 0, squawk: UInt16 = 0, altitudeType: UInt8 = 0, callsign: [UInt8] = [UInt8](repeating: 0, count: 9), emitterType: UInt8 = 0, tslc: UInt8 = 0) {
            self.ICAOAddress = ICAOAddress
            self.lat = lat
            self.lon = lon
            self.altitude = altitude
            self.heading = heading
            self.horVelocity = horVelocity
            self.verVelocity = verVelocity
            self.flags = flags
            self.squawk = squawk
            self.altitudeType = altitudeType
            self.callsign = callsign
            self.emitterType = emitterType
            self.tslc = tslc
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.ICAOAddress = p.uint32(0)
            self.lat = p.int32(4)
            self.lon = p.int32(8)
            self.altitude = p.int32(12)
            self.heading = p.uint16(16)
            self.horVelocity = p.uint16(18)
            self.verVelocity = p.int16(20)
            self.flags = p.uint16(22)
            self.squawk = p.uint16(24)
            self.altitudeType = p.uint8(26)
            self.callsign = (0..<9).map { p.uint8(27 + $0 * 1) }
            self.emitterType = p.uint8(36)
            self.tslc = p.uint8(37)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.ICAOAddress, 0)
            w.put(self.lat, 4)
            w.put(self.lon, 8)
            w.put(self.altitude, 12)
            w.put(self.heading, 16)
            w.put(self.horVelocity, 18)
            w.put(self.verVelocity, 20)
            w.put(self.flags, 22)
            w.put(self.squawk, 24)
            w.put(self.altitudeType, 26)
            for k in 0..<Swift.min(9, self.callsign.count) { w.put(self.callsign[k], 27 + k * 1) }
            w.put(self.emitterType, 36)
            w.put(self.tslc, 37)
        }
    }
}

/// COLLISION (#247)
extension MAV {
    public struct Collision: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 247, name: "COLLISION", crcExtra: 81, minLength: 19, length: 19)
        public var id: UInt32
        public var timeToMinimumDelta: Float
        public var altitudeMinimumDelta: Float
        public var horizontalMinimumDelta: Float
        public var src: UInt8
        public var action: UInt8
        public var threatLevel: UInt8

        public init(id: UInt32 = 0, timeToMinimumDelta: Float = 0, altitudeMinimumDelta: Float = 0, horizontalMinimumDelta: Float = 0, src: UInt8 = 0, action: UInt8 = 0, threatLevel: UInt8 = 0) {
            self.id = id
            self.timeToMinimumDelta = timeToMinimumDelta
            self.altitudeMinimumDelta = altitudeMinimumDelta
            self.horizontalMinimumDelta = horizontalMinimumDelta
            self.src = src
            self.action = action
            self.threatLevel = threatLevel
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.id = p.uint32(0)
            self.timeToMinimumDelta = p.float(4)
            self.altitudeMinimumDelta = p.float(8)
            self.horizontalMinimumDelta = p.float(12)
            self.src = p.uint8(16)
            self.action = p.uint8(17)
            self.threatLevel = p.uint8(18)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.id, 0)
            w.put(self.timeToMinimumDelta, 4)
            w.put(self.altitudeMinimumDelta, 8)
            w.put(self.horizontalMinimumDelta, 12)
            w.put(self.src, 16)
            w.put(self.action, 17)
            w.put(self.threatLevel, 18)
        }
    }
}

/// V2_EXTENSION (#248)
extension MAV {
    public struct V2Extension: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 248, name: "V2_EXTENSION", crcExtra: 8, minLength: 254, length: 254)
        public var messageType: UInt16
        public var targetNetwork: UInt8
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var payload: [UInt8]

        public init(messageType: UInt16 = 0, targetNetwork: UInt8 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, payload: [UInt8] = [UInt8](repeating: 0, count: 249)) {
            self.messageType = messageType
            self.targetNetwork = targetNetwork
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.payload = payload
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.messageType = p.uint16(0)
            self.targetNetwork = p.uint8(2)
            self.targetSystem = p.uint8(3)
            self.targetComponent = p.uint8(4)
            self.payload = (0..<249).map { p.uint8(5 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.messageType, 0)
            w.put(self.targetNetwork, 2)
            w.put(self.targetSystem, 3)
            w.put(self.targetComponent, 4)
            for k in 0..<Swift.min(249, self.payload.count) { w.put(self.payload[k], 5 + k * 1) }
        }
    }
}

/// MEMORY_VECT (#249)
extension MAV {
    public struct MemoryVect: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 249, name: "MEMORY_VECT", crcExtra: 204, minLength: 36, length: 36)
        public var address: UInt16
        public var ver: UInt8
        public var type: UInt8
        public var value: [Int8]

        public init(address: UInt16 = 0, ver: UInt8 = 0, type: UInt8 = 0, value: [Int8] = [Int8](repeating: 0, count: 32)) {
            self.address = address
            self.ver = ver
            self.type = type
            self.value = value
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.address = p.uint16(0)
            self.ver = p.uint8(2)
            self.type = p.uint8(3)
            self.value = (0..<32).map { p.int8(4 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.address, 0)
            w.put(self.ver, 2)
            w.put(self.type, 3)
            for k in 0..<Swift.min(32, self.value.count) { w.put(self.value[k], 4 + k * 1) }
        }
    }
}

/// DEBUG_VECT (#250)
extension MAV {
    public struct DebugVect: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 250, name: "DEBUG_VECT", crcExtra: 49, minLength: 30, length: 30)
        public var timeUsec: UInt64
        public var x: Float
        public var y: Float
        public var z: Float
        public var name: [UInt8]

        public init(timeUsec: UInt64 = 0, x: Float = 0, y: Float = 0, z: Float = 0, name: [UInt8] = [UInt8](repeating: 0, count: 10)) {
            self.timeUsec = timeUsec
            self.x = x
            self.y = y
            self.z = z
            self.name = name
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.x = p.float(8)
            self.y = p.float(12)
            self.z = p.float(16)
            self.name = (0..<10).map { p.uint8(20 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.x, 8)
            w.put(self.y, 12)
            w.put(self.z, 16)
            for k in 0..<Swift.min(10, self.name.count) { w.put(self.name[k], 20 + k * 1) }
        }
    }
}

/// NAMED_VALUE_FLOAT (#251)
extension MAV {
    public struct NamedValueFloat: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 251, name: "NAMED_VALUE_FLOAT", crcExtra: 170, minLength: 18, length: 18)
        public var timeBootMs: UInt32
        public var value: Float
        public var name: [UInt8]

        public init(timeBootMs: UInt32 = 0, value: Float = 0, name: [UInt8] = [UInt8](repeating: 0, count: 10)) {
            self.timeBootMs = timeBootMs
            self.value = value
            self.name = name
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.value = p.float(4)
            self.name = (0..<10).map { p.uint8(8 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.value, 4)
            for k in 0..<Swift.min(10, self.name.count) { w.put(self.name[k], 8 + k * 1) }
        }
    }
}

/// NAMED_VALUE_INT (#252)
extension MAV {
    public struct NamedValueInt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 252, name: "NAMED_VALUE_INT", crcExtra: 44, minLength: 18, length: 18)
        public var timeBootMs: UInt32
        public var value: Int32
        public var name: [UInt8]

        public init(timeBootMs: UInt32 = 0, value: Int32 = 0, name: [UInt8] = [UInt8](repeating: 0, count: 10)) {
            self.timeBootMs = timeBootMs
            self.value = value
            self.name = name
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.value = p.int32(4)
            self.name = (0..<10).map { p.uint8(8 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.value, 4)
            for k in 0..<Swift.min(10, self.name.count) { w.put(self.name[k], 8 + k * 1) }
        }
    }
}

/// STATUSTEXT (#253)
extension MAV {
    public struct Statustext: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 253, name: "STATUSTEXT", crcExtra: 83, minLength: 51, length: 54)
        public var severity: UInt8
        public var text: [UInt8]
        public var id: UInt16  // extension field
        public var chunkSeq: UInt8  // extension field

        public init(severity: UInt8 = 0, text: [UInt8] = [UInt8](repeating: 0, count: 50), id: UInt16 = 0, chunkSeq: UInt8 = 0) {
            self.severity = severity
            self.text = text
            self.id = id
            self.chunkSeq = chunkSeq
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.severity = p.uint8(0)
            self.text = (0..<50).map { p.uint8(1 + $0 * 1) }
            self.id = p.uint16(51)
            self.chunkSeq = p.uint8(53)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.severity, 0)
            for k in 0..<Swift.min(50, self.text.count) { w.put(self.text[k], 1 + k * 1) }
            w.put(self.id, 51)
            w.put(self.chunkSeq, 53)
        }
    }
}

/// DEBUG (#254)
extension MAV {
    public struct Debug: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 254, name: "DEBUG", crcExtra: 46, minLength: 9, length: 9)
        public var timeBootMs: UInt32
        public var value: Float
        public var ind: UInt8

        public init(timeBootMs: UInt32 = 0, value: Float = 0, ind: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.value = value
            self.ind = ind
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.value = p.float(4)
            self.ind = p.uint8(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.value, 4)
            w.put(self.ind, 8)
        }
    }
}

/// SETUP_SIGNING (#256)
extension MAV {
    public struct SetupSigning: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 256, name: "SETUP_SIGNING", crcExtra: 71, minLength: 42, length: 42)
        public var initialTimestamp: UInt64
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var secretKey: [UInt8]

        public init(initialTimestamp: UInt64 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, secretKey: [UInt8] = [UInt8](repeating: 0, count: 32)) {
            self.initialTimestamp = initialTimestamp
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.secretKey = secretKey
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.initialTimestamp = p.uint64(0)
            self.targetSystem = p.uint8(8)
            self.targetComponent = p.uint8(9)
            self.secretKey = (0..<32).map { p.uint8(10 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.initialTimestamp, 0)
            w.put(self.targetSystem, 8)
            w.put(self.targetComponent, 9)
            for k in 0..<Swift.min(32, self.secretKey.count) { w.put(self.secretKey[k], 10 + k * 1) }
        }
    }
}

/// BUTTON_CHANGE (#257)
extension MAV {
    public struct ButtonChange: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 257, name: "BUTTON_CHANGE", crcExtra: 131, minLength: 9, length: 9)
        public var timeBootMs: UInt32
        public var lastChangeMs: UInt32
        public var state: UInt8

        public init(timeBootMs: UInt32 = 0, lastChangeMs: UInt32 = 0, state: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.lastChangeMs = lastChangeMs
            self.state = state
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.lastChangeMs = p.uint32(4)
            self.state = p.uint8(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.lastChangeMs, 4)
            w.put(self.state, 8)
        }
    }
}

/// PLAY_TUNE (#258)
extension MAV {
    public struct PlayTune: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 258, name: "PLAY_TUNE", crcExtra: 187, minLength: 32, length: 232)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var tune: [UInt8]
        public var tune2: [UInt8]  // extension field

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, tune: [UInt8] = [UInt8](repeating: 0, count: 30), tune2: [UInt8] = [UInt8](repeating: 0, count: 200)) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.tune = tune
            self.tune2 = tune2
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.tune = (0..<30).map { p.uint8(2 + $0 * 1) }
            self.tune2 = (0..<200).map { p.uint8(32 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            for k in 0..<Swift.min(30, self.tune.count) { w.put(self.tune[k], 2 + k * 1) }
            for k in 0..<Swift.min(200, self.tune2.count) { w.put(self.tune2[k], 32 + k * 1) }
        }
    }
}

/// CAMERA_INFORMATION (#259)
extension MAV {
    public struct CameraInformation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 259, name: "CAMERA_INFORMATION", crcExtra: 92, minLength: 235, length: 236)
        public var timeBootMs: UInt32
        public var firmwareVersion: UInt32
        public var focalLength: Float
        public var sensorSizeH: Float
        public var sensorSizeV: Float
        public var flags: UInt32
        public var resolutionH: UInt16
        public var resolutionV: UInt16
        public var camDefinitionVersion: UInt16
        public var vendorName: [UInt8]
        public var modelName: [UInt8]
        public var lensId: UInt8
        public var camDefinitionUri: [UInt8]
        public var gimbalDeviceId: UInt8  // extension field

        public init(timeBootMs: UInt32 = 0, firmwareVersion: UInt32 = 0, focalLength: Float = 0, sensorSizeH: Float = 0, sensorSizeV: Float = 0, flags: UInt32 = 0, resolutionH: UInt16 = 0, resolutionV: UInt16 = 0, camDefinitionVersion: UInt16 = 0, vendorName: [UInt8] = [UInt8](repeating: 0, count: 32), modelName: [UInt8] = [UInt8](repeating: 0, count: 32), lensId: UInt8 = 0, camDefinitionUri: [UInt8] = [UInt8](repeating: 0, count: 140), gimbalDeviceId: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.firmwareVersion = firmwareVersion
            self.focalLength = focalLength
            self.sensorSizeH = sensorSizeH
            self.sensorSizeV = sensorSizeV
            self.flags = flags
            self.resolutionH = resolutionH
            self.resolutionV = resolutionV
            self.camDefinitionVersion = camDefinitionVersion
            self.vendorName = vendorName
            self.modelName = modelName
            self.lensId = lensId
            self.camDefinitionUri = camDefinitionUri
            self.gimbalDeviceId = gimbalDeviceId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.firmwareVersion = p.uint32(4)
            self.focalLength = p.float(8)
            self.sensorSizeH = p.float(12)
            self.sensorSizeV = p.float(16)
            self.flags = p.uint32(20)
            self.resolutionH = p.uint16(24)
            self.resolutionV = p.uint16(26)
            self.camDefinitionVersion = p.uint16(28)
            self.vendorName = (0..<32).map { p.uint8(30 + $0 * 1) }
            self.modelName = (0..<32).map { p.uint8(62 + $0 * 1) }
            self.lensId = p.uint8(94)
            self.camDefinitionUri = (0..<140).map { p.uint8(95 + $0 * 1) }
            self.gimbalDeviceId = p.uint8(235)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.firmwareVersion, 4)
            w.put(self.focalLength, 8)
            w.put(self.sensorSizeH, 12)
            w.put(self.sensorSizeV, 16)
            w.put(self.flags, 20)
            w.put(self.resolutionH, 24)
            w.put(self.resolutionV, 26)
            w.put(self.camDefinitionVersion, 28)
            for k in 0..<Swift.min(32, self.vendorName.count) { w.put(self.vendorName[k], 30 + k * 1) }
            for k in 0..<Swift.min(32, self.modelName.count) { w.put(self.modelName[k], 62 + k * 1) }
            w.put(self.lensId, 94)
            for k in 0..<Swift.min(140, self.camDefinitionUri.count) { w.put(self.camDefinitionUri[k], 95 + k * 1) }
            w.put(self.gimbalDeviceId, 235)
        }
    }
}

/// CAMERA_SETTINGS (#260)
extension MAV {
    public struct CameraSettings: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 260, name: "CAMERA_SETTINGS", crcExtra: 146, minLength: 5, length: 13)
        public var timeBootMs: UInt32
        public var modeId: UInt8
        public var zoomLevel: Float  // extension field
        public var focusLevel: Float  // extension field

        public init(timeBootMs: UInt32 = 0, modeId: UInt8 = 0, zoomLevel: Float = 0, focusLevel: Float = 0) {
            self.timeBootMs = timeBootMs
            self.modeId = modeId
            self.zoomLevel = zoomLevel
            self.focusLevel = focusLevel
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.modeId = p.uint8(4)
            self.zoomLevel = p.float(5)
            self.focusLevel = p.float(9)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.modeId, 4)
            w.put(self.zoomLevel, 5)
            w.put(self.focusLevel, 9)
        }
    }
}

/// STORAGE_INFORMATION (#261)
extension MAV {
    public struct StorageInformation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 261, name: "STORAGE_INFORMATION", crcExtra: 179, minLength: 27, length: 60)
        public var timeBootMs: UInt32
        public var totalCapacity: Float
        public var usedCapacity: Float
        public var availableCapacity: Float
        public var readSpeed: Float
        public var writeSpeed: Float
        public var storageId: UInt8
        public var storageCount: UInt8
        public var status: UInt8
        public var type: UInt8  // extension field
        public var name: [UInt8]  // extension field

        public init(timeBootMs: UInt32 = 0, totalCapacity: Float = 0, usedCapacity: Float = 0, availableCapacity: Float = 0, readSpeed: Float = 0, writeSpeed: Float = 0, storageId: UInt8 = 0, storageCount: UInt8 = 0, status: UInt8 = 0, type: UInt8 = 0, name: [UInt8] = [UInt8](repeating: 0, count: 32)) {
            self.timeBootMs = timeBootMs
            self.totalCapacity = totalCapacity
            self.usedCapacity = usedCapacity
            self.availableCapacity = availableCapacity
            self.readSpeed = readSpeed
            self.writeSpeed = writeSpeed
            self.storageId = storageId
            self.storageCount = storageCount
            self.status = status
            self.type = type
            self.name = name
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.totalCapacity = p.float(4)
            self.usedCapacity = p.float(8)
            self.availableCapacity = p.float(12)
            self.readSpeed = p.float(16)
            self.writeSpeed = p.float(20)
            self.storageId = p.uint8(24)
            self.storageCount = p.uint8(25)
            self.status = p.uint8(26)
            self.type = p.uint8(27)
            self.name = (0..<32).map { p.uint8(28 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.totalCapacity, 4)
            w.put(self.usedCapacity, 8)
            w.put(self.availableCapacity, 12)
            w.put(self.readSpeed, 16)
            w.put(self.writeSpeed, 20)
            w.put(self.storageId, 24)
            w.put(self.storageCount, 25)
            w.put(self.status, 26)
            w.put(self.type, 27)
            for k in 0..<Swift.min(32, self.name.count) { w.put(self.name[k], 28 + k * 1) }
        }
    }
}

/// CAMERA_CAPTURE_STATUS (#262)
extension MAV {
    public struct CameraCaptureStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 262, name: "CAMERA_CAPTURE_STATUS", crcExtra: 12, minLength: 18, length: 22)
        public var timeBootMs: UInt32
        public var imageInterval: Float
        public var recordingTimeMs: UInt32
        public var availableCapacity: Float
        public var imageStatus: UInt8
        public var videoStatus: UInt8
        public var imageCount: Int32  // extension field

        public init(timeBootMs: UInt32 = 0, imageInterval: Float = 0, recordingTimeMs: UInt32 = 0, availableCapacity: Float = 0, imageStatus: UInt8 = 0, videoStatus: UInt8 = 0, imageCount: Int32 = 0) {
            self.timeBootMs = timeBootMs
            self.imageInterval = imageInterval
            self.recordingTimeMs = recordingTimeMs
            self.availableCapacity = availableCapacity
            self.imageStatus = imageStatus
            self.videoStatus = videoStatus
            self.imageCount = imageCount
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.imageInterval = p.float(4)
            self.recordingTimeMs = p.uint32(8)
            self.availableCapacity = p.float(12)
            self.imageStatus = p.uint8(16)
            self.videoStatus = p.uint8(17)
            self.imageCount = p.int32(18)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.imageInterval, 4)
            w.put(self.recordingTimeMs, 8)
            w.put(self.availableCapacity, 12)
            w.put(self.imageStatus, 16)
            w.put(self.videoStatus, 17)
            w.put(self.imageCount, 18)
        }
    }
}

/// CAMERA_IMAGE_CAPTURED (#263)
extension MAV {
    public struct CameraImageCaptured: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 263, name: "CAMERA_IMAGE_CAPTURED", crcExtra: 133, minLength: 255, length: 255)
        public var timeUtc: UInt64
        public var timeBootMs: UInt32
        public var lat: Int32
        public var lon: Int32
        public var alt: Int32
        public var relativeAlt: Int32
        public var q: [Float]
        public var imageIndex: Int32
        public var cameraId: UInt8
        public var captureResult: Int8
        public var fileUrl: [UInt8]

        public init(timeUtc: UInt64 = 0, timeBootMs: UInt32 = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Int32 = 0, relativeAlt: Int32 = 0, q: [Float] = [Float](repeating: 0, count: 4), imageIndex: Int32 = 0, cameraId: UInt8 = 0, captureResult: Int8 = 0, fileUrl: [UInt8] = [UInt8](repeating: 0, count: 205)) {
            self.timeUtc = timeUtc
            self.timeBootMs = timeBootMs
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.relativeAlt = relativeAlt
            self.q = q
            self.imageIndex = imageIndex
            self.cameraId = cameraId
            self.captureResult = captureResult
            self.fileUrl = fileUrl
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUtc = p.uint64(0)
            self.timeBootMs = p.uint32(8)
            self.lat = p.int32(12)
            self.lon = p.int32(16)
            self.alt = p.int32(20)
            self.relativeAlt = p.int32(24)
            self.q = (0..<4).map { p.float(28 + $0 * 4) }
            self.imageIndex = p.int32(44)
            self.cameraId = p.uint8(48)
            self.captureResult = p.int8(49)
            self.fileUrl = (0..<205).map { p.uint8(50 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUtc, 0)
            w.put(self.timeBootMs, 8)
            w.put(self.lat, 12)
            w.put(self.lon, 16)
            w.put(self.alt, 20)
            w.put(self.relativeAlt, 24)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 28 + k * 4) }
            w.put(self.imageIndex, 44)
            w.put(self.cameraId, 48)
            w.put(self.captureResult, 49)
            for k in 0..<Swift.min(205, self.fileUrl.count) { w.put(self.fileUrl[k], 50 + k * 1) }
        }
    }
}

/// FLIGHT_INFORMATION (#264)
extension MAV {
    public struct FlightInformation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 264, name: "FLIGHT_INFORMATION", crcExtra: 49, minLength: 28, length: 28)
        public var armingTimeUtc: UInt64
        public var takeoffTimeUtc: UInt64
        public var flightUuid: UInt64
        public var timeBootMs: UInt32

        public init(armingTimeUtc: UInt64 = 0, takeoffTimeUtc: UInt64 = 0, flightUuid: UInt64 = 0, timeBootMs: UInt32 = 0) {
            self.armingTimeUtc = armingTimeUtc
            self.takeoffTimeUtc = takeoffTimeUtc
            self.flightUuid = flightUuid
            self.timeBootMs = timeBootMs
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.armingTimeUtc = p.uint64(0)
            self.takeoffTimeUtc = p.uint64(8)
            self.flightUuid = p.uint64(16)
            self.timeBootMs = p.uint32(24)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.armingTimeUtc, 0)
            w.put(self.takeoffTimeUtc, 8)
            w.put(self.flightUuid, 16)
            w.put(self.timeBootMs, 24)
        }
    }
}

/// MOUNT_ORIENTATION (#265)
extension MAV {
    public struct MountOrientation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 265, name: "MOUNT_ORIENTATION", crcExtra: 26, minLength: 16, length: 20)
        public var timeBootMs: UInt32
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var yawAbsolute: Float  // extension field

        public init(timeBootMs: UInt32 = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0, yawAbsolute: Float = 0) {
            self.timeBootMs = timeBootMs
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.yawAbsolute = yawAbsolute
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.roll = p.float(4)
            self.pitch = p.float(8)
            self.yaw = p.float(12)
            self.yawAbsolute = p.float(16)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.roll, 4)
            w.put(self.pitch, 8)
            w.put(self.yaw, 12)
            w.put(self.yawAbsolute, 16)
        }
    }
}

/// LOGGING_DATA (#266)
extension MAV {
    public struct LoggingData: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 266, name: "LOGGING_DATA", crcExtra: 193, minLength: 255, length: 255)
        public var sequence: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var length: UInt8
        public var firstMessageOffset: UInt8
        public var data: [UInt8]

        public init(sequence: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, length: UInt8 = 0, firstMessageOffset: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 249)) {
            self.sequence = sequence
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.length = length
            self.firstMessageOffset = firstMessageOffset
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.sequence = p.uint16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
            self.length = p.uint8(4)
            self.firstMessageOffset = p.uint8(5)
            self.data = (0..<249).map { p.uint8(6 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.sequence, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
            w.put(self.length, 4)
            w.put(self.firstMessageOffset, 5)
            for k in 0..<Swift.min(249, self.data.count) { w.put(self.data[k], 6 + k * 1) }
        }
    }
}

/// LOGGING_DATA_ACKED (#267)
extension MAV {
    public struct LoggingDataAcked: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 267, name: "LOGGING_DATA_ACKED", crcExtra: 35, minLength: 255, length: 255)
        public var sequence: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var length: UInt8
        public var firstMessageOffset: UInt8
        public var data: [UInt8]

        public init(sequence: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, length: UInt8 = 0, firstMessageOffset: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 249)) {
            self.sequence = sequence
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.length = length
            self.firstMessageOffset = firstMessageOffset
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.sequence = p.uint16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
            self.length = p.uint8(4)
            self.firstMessageOffset = p.uint8(5)
            self.data = (0..<249).map { p.uint8(6 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.sequence, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
            w.put(self.length, 4)
            w.put(self.firstMessageOffset, 5)
            for k in 0..<Swift.min(249, self.data.count) { w.put(self.data[k], 6 + k * 1) }
        }
    }
}

/// LOGGING_ACK (#268)
extension MAV {
    public struct LoggingAck: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 268, name: "LOGGING_ACK", crcExtra: 14, minLength: 4, length: 4)
        public var sequence: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(sequence: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.sequence = sequence
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.sequence = p.uint16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.sequence, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
        }
    }
}

/// VIDEO_STREAM_INFORMATION (#269)
extension MAV {
    public struct VideoStreamInformation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 269, name: "VIDEO_STREAM_INFORMATION", crcExtra: 109, minLength: 213, length: 214)
        public var framerate: Float
        public var bitrate: UInt32
        public var flags: UInt16
        public var resolutionH: UInt16
        public var resolutionV: UInt16
        public var rotation: UInt16
        public var hfov: UInt16
        public var streamId: UInt8
        public var count: UInt8
        public var type: UInt8
        public var name: [UInt8]
        public var uri: [UInt8]
        public var encoding: UInt8  // extension field

        public init(framerate: Float = 0, bitrate: UInt32 = 0, flags: UInt16 = 0, resolutionH: UInt16 = 0, resolutionV: UInt16 = 0, rotation: UInt16 = 0, hfov: UInt16 = 0, streamId: UInt8 = 0, count: UInt8 = 0, type: UInt8 = 0, name: [UInt8] = [UInt8](repeating: 0, count: 32), uri: [UInt8] = [UInt8](repeating: 0, count: 160), encoding: UInt8 = 0) {
            self.framerate = framerate
            self.bitrate = bitrate
            self.flags = flags
            self.resolutionH = resolutionH
            self.resolutionV = resolutionV
            self.rotation = rotation
            self.hfov = hfov
            self.streamId = streamId
            self.count = count
            self.type = type
            self.name = name
            self.uri = uri
            self.encoding = encoding
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.framerate = p.float(0)
            self.bitrate = p.uint32(4)
            self.flags = p.uint16(8)
            self.resolutionH = p.uint16(10)
            self.resolutionV = p.uint16(12)
            self.rotation = p.uint16(14)
            self.hfov = p.uint16(16)
            self.streamId = p.uint8(18)
            self.count = p.uint8(19)
            self.type = p.uint8(20)
            self.name = (0..<32).map { p.uint8(21 + $0 * 1) }
            self.uri = (0..<160).map { p.uint8(53 + $0 * 1) }
            self.encoding = p.uint8(213)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.framerate, 0)
            w.put(self.bitrate, 4)
            w.put(self.flags, 8)
            w.put(self.resolutionH, 10)
            w.put(self.resolutionV, 12)
            w.put(self.rotation, 14)
            w.put(self.hfov, 16)
            w.put(self.streamId, 18)
            w.put(self.count, 19)
            w.put(self.type, 20)
            for k in 0..<Swift.min(32, self.name.count) { w.put(self.name[k], 21 + k * 1) }
            for k in 0..<Swift.min(160, self.uri.count) { w.put(self.uri[k], 53 + k * 1) }
            w.put(self.encoding, 213)
        }
    }
}

/// VIDEO_STREAM_STATUS (#270)
extension MAV {
    public struct VideoStreamStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 270, name: "VIDEO_STREAM_STATUS", crcExtra: 59, minLength: 19, length: 19)
        public var framerate: Float
        public var bitrate: UInt32
        public var flags: UInt16
        public var resolutionH: UInt16
        public var resolutionV: UInt16
        public var rotation: UInt16
        public var hfov: UInt16
        public var streamId: UInt8

        public init(framerate: Float = 0, bitrate: UInt32 = 0, flags: UInt16 = 0, resolutionH: UInt16 = 0, resolutionV: UInt16 = 0, rotation: UInt16 = 0, hfov: UInt16 = 0, streamId: UInt8 = 0) {
            self.framerate = framerate
            self.bitrate = bitrate
            self.flags = flags
            self.resolutionH = resolutionH
            self.resolutionV = resolutionV
            self.rotation = rotation
            self.hfov = hfov
            self.streamId = streamId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.framerate = p.float(0)
            self.bitrate = p.uint32(4)
            self.flags = p.uint16(8)
            self.resolutionH = p.uint16(10)
            self.resolutionV = p.uint16(12)
            self.rotation = p.uint16(14)
            self.hfov = p.uint16(16)
            self.streamId = p.uint8(18)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.framerate, 0)
            w.put(self.bitrate, 4)
            w.put(self.flags, 8)
            w.put(self.resolutionH, 10)
            w.put(self.resolutionV, 12)
            w.put(self.rotation, 14)
            w.put(self.hfov, 16)
            w.put(self.streamId, 18)
        }
    }
}

/// CAMERA_FOV_STATUS (#271)
extension MAV {
    public struct CameraFovStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 271, name: "CAMERA_FOV_STATUS", crcExtra: 22, minLength: 52, length: 52)
        public var timeBootMs: UInt32
        public var latCamera: Int32
        public var lonCamera: Int32
        public var altCamera: Int32
        public var latImage: Int32
        public var lonImage: Int32
        public var altImage: Int32
        public var q: [Float]
        public var hfov: Float
        public var vfov: Float

        public init(timeBootMs: UInt32 = 0, latCamera: Int32 = 0, lonCamera: Int32 = 0, altCamera: Int32 = 0, latImage: Int32 = 0, lonImage: Int32 = 0, altImage: Int32 = 0, q: [Float] = [Float](repeating: 0, count: 4), hfov: Float = 0, vfov: Float = 0) {
            self.timeBootMs = timeBootMs
            self.latCamera = latCamera
            self.lonCamera = lonCamera
            self.altCamera = altCamera
            self.latImage = latImage
            self.lonImage = lonImage
            self.altImage = altImage
            self.q = q
            self.hfov = hfov
            self.vfov = vfov
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.latCamera = p.int32(4)
            self.lonCamera = p.int32(8)
            self.altCamera = p.int32(12)
            self.latImage = p.int32(16)
            self.lonImage = p.int32(20)
            self.altImage = p.int32(24)
            self.q = (0..<4).map { p.float(28 + $0 * 4) }
            self.hfov = p.float(44)
            self.vfov = p.float(48)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.latCamera, 4)
            w.put(self.lonCamera, 8)
            w.put(self.altCamera, 12)
            w.put(self.latImage, 16)
            w.put(self.lonImage, 20)
            w.put(self.altImage, 24)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 28 + k * 4) }
            w.put(self.hfov, 44)
            w.put(self.vfov, 48)
        }
    }
}

/// CAMERA_TRACKING_IMAGE_STATUS (#275)
extension MAV {
    public struct CameraTrackingImageStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 275, name: "CAMERA_TRACKING_IMAGE_STATUS", crcExtra: 126, minLength: 31, length: 31)
        public var pointX: Float
        public var pointY: Float
        public var radius: Float
        public var recTopX: Float
        public var recTopY: Float
        public var recBottomX: Float
        public var recBottomY: Float
        public var trackingStatus: UInt8
        public var trackingMode: UInt8
        public var targetData: UInt8

        public init(pointX: Float = 0, pointY: Float = 0, radius: Float = 0, recTopX: Float = 0, recTopY: Float = 0, recBottomX: Float = 0, recBottomY: Float = 0, trackingStatus: UInt8 = 0, trackingMode: UInt8 = 0, targetData: UInt8 = 0) {
            self.pointX = pointX
            self.pointY = pointY
            self.radius = radius
            self.recTopX = recTopX
            self.recTopY = recTopY
            self.recBottomX = recBottomX
            self.recBottomY = recBottomY
            self.trackingStatus = trackingStatus
            self.trackingMode = trackingMode
            self.targetData = targetData
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.pointX = p.float(0)
            self.pointY = p.float(4)
            self.radius = p.float(8)
            self.recTopX = p.float(12)
            self.recTopY = p.float(16)
            self.recBottomX = p.float(20)
            self.recBottomY = p.float(24)
            self.trackingStatus = p.uint8(28)
            self.trackingMode = p.uint8(29)
            self.targetData = p.uint8(30)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.pointX, 0)
            w.put(self.pointY, 4)
            w.put(self.radius, 8)
            w.put(self.recTopX, 12)
            w.put(self.recTopY, 16)
            w.put(self.recBottomX, 20)
            w.put(self.recBottomY, 24)
            w.put(self.trackingStatus, 28)
            w.put(self.trackingMode, 29)
            w.put(self.targetData, 30)
        }
    }
}

/// CAMERA_TRACKING_GEO_STATUS (#276)
extension MAV {
    public struct CameraTrackingGeoStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 276, name: "CAMERA_TRACKING_GEO_STATUS", crcExtra: 18, minLength: 49, length: 49)
        public var lat: Int32
        public var lon: Int32
        public var alt: Float
        public var hAcc: Float
        public var vAcc: Float
        public var velN: Float
        public var velE: Float
        public var velD: Float
        public var velAcc: Float
        public var dist: Float
        public var hdg: Float
        public var hdgAcc: Float
        public var trackingStatus: UInt8

        public init(lat: Int32 = 0, lon: Int32 = 0, alt: Float = 0, hAcc: Float = 0, vAcc: Float = 0, velN: Float = 0, velE: Float = 0, velD: Float = 0, velAcc: Float = 0, dist: Float = 0, hdg: Float = 0, hdgAcc: Float = 0, trackingStatus: UInt8 = 0) {
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.hAcc = hAcc
            self.vAcc = vAcc
            self.velN = velN
            self.velE = velE
            self.velD = velD
            self.velAcc = velAcc
            self.dist = dist
            self.hdg = hdg
            self.hdgAcc = hdgAcc
            self.trackingStatus = trackingStatus
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.lat = p.int32(0)
            self.lon = p.int32(4)
            self.alt = p.float(8)
            self.hAcc = p.float(12)
            self.vAcc = p.float(16)
            self.velN = p.float(20)
            self.velE = p.float(24)
            self.velD = p.float(28)
            self.velAcc = p.float(32)
            self.dist = p.float(36)
            self.hdg = p.float(40)
            self.hdgAcc = p.float(44)
            self.trackingStatus = p.uint8(48)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.lat, 0)
            w.put(self.lon, 4)
            w.put(self.alt, 8)
            w.put(self.hAcc, 12)
            w.put(self.vAcc, 16)
            w.put(self.velN, 20)
            w.put(self.velE, 24)
            w.put(self.velD, 28)
            w.put(self.velAcc, 32)
            w.put(self.dist, 36)
            w.put(self.hdg, 40)
            w.put(self.hdgAcc, 44)
            w.put(self.trackingStatus, 48)
        }
    }
}

/// CAMERA_THERMAL_RANGE (#277)
extension MAV {
    public struct CameraThermalRange: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 277, name: "CAMERA_THERMAL_RANGE", crcExtra: 62, minLength: 30, length: 30)
        public var timeBootMs: UInt32
        public var max: Float
        public var maxPointX: Float
        public var maxPointY: Float
        public var min: Float
        public var minPointX: Float
        public var minPointY: Float
        public var streamId: UInt8
        public var cameraDeviceId: UInt8

        public init(timeBootMs: UInt32 = 0, max: Float = 0, maxPointX: Float = 0, maxPointY: Float = 0, min: Float = 0, minPointX: Float = 0, minPointY: Float = 0, streamId: UInt8 = 0, cameraDeviceId: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.max = max
            self.maxPointX = maxPointX
            self.maxPointY = maxPointY
            self.min = min
            self.minPointX = minPointX
            self.minPointY = minPointY
            self.streamId = streamId
            self.cameraDeviceId = cameraDeviceId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.max = p.float(4)
            self.maxPointX = p.float(8)
            self.maxPointY = p.float(12)
            self.min = p.float(16)
            self.minPointX = p.float(20)
            self.minPointY = p.float(24)
            self.streamId = p.uint8(28)
            self.cameraDeviceId = p.uint8(29)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.max, 4)
            w.put(self.maxPointX, 8)
            w.put(self.maxPointY, 12)
            w.put(self.min, 16)
            w.put(self.minPointX, 20)
            w.put(self.minPointY, 24)
            w.put(self.streamId, 28)
            w.put(self.cameraDeviceId, 29)
        }
    }
}

/// GIMBAL_MANAGER_INFORMATION (#280)
extension MAV {
    public struct GimbalManagerInformation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 280, name: "GIMBAL_MANAGER_INFORMATION", crcExtra: 70, minLength: 33, length: 33)
        public var timeBootMs: UInt32
        public var capFlags: UInt32
        public var rollMin: Float
        public var rollMax: Float
        public var pitchMin: Float
        public var pitchMax: Float
        public var yawMin: Float
        public var yawMax: Float
        public var gimbalDeviceId: UInt8

        public init(timeBootMs: UInt32 = 0, capFlags: UInt32 = 0, rollMin: Float = 0, rollMax: Float = 0, pitchMin: Float = 0, pitchMax: Float = 0, yawMin: Float = 0, yawMax: Float = 0, gimbalDeviceId: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.capFlags = capFlags
            self.rollMin = rollMin
            self.rollMax = rollMax
            self.pitchMin = pitchMin
            self.pitchMax = pitchMax
            self.yawMin = yawMin
            self.yawMax = yawMax
            self.gimbalDeviceId = gimbalDeviceId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.capFlags = p.uint32(4)
            self.rollMin = p.float(8)
            self.rollMax = p.float(12)
            self.pitchMin = p.float(16)
            self.pitchMax = p.float(20)
            self.yawMin = p.float(24)
            self.yawMax = p.float(28)
            self.gimbalDeviceId = p.uint8(32)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.capFlags, 4)
            w.put(self.rollMin, 8)
            w.put(self.rollMax, 12)
            w.put(self.pitchMin, 16)
            w.put(self.pitchMax, 20)
            w.put(self.yawMin, 24)
            w.put(self.yawMax, 28)
            w.put(self.gimbalDeviceId, 32)
        }
    }
}

/// GIMBAL_MANAGER_STATUS (#281)
extension MAV {
    public struct GimbalManagerStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 281, name: "GIMBAL_MANAGER_STATUS", crcExtra: 48, minLength: 13, length: 13)
        public var timeBootMs: UInt32
        public var flags: UInt32
        public var gimbalDeviceId: UInt8
        public var primaryControlSysid: UInt8
        public var primaryControlCompid: UInt8
        public var secondaryControlSysid: UInt8
        public var secondaryControlCompid: UInt8

        public init(timeBootMs: UInt32 = 0, flags: UInt32 = 0, gimbalDeviceId: UInt8 = 0, primaryControlSysid: UInt8 = 0, primaryControlCompid: UInt8 = 0, secondaryControlSysid: UInt8 = 0, secondaryControlCompid: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.flags = flags
            self.gimbalDeviceId = gimbalDeviceId
            self.primaryControlSysid = primaryControlSysid
            self.primaryControlCompid = primaryControlCompid
            self.secondaryControlSysid = secondaryControlSysid
            self.secondaryControlCompid = secondaryControlCompid
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.flags = p.uint32(4)
            self.gimbalDeviceId = p.uint8(8)
            self.primaryControlSysid = p.uint8(9)
            self.primaryControlCompid = p.uint8(10)
            self.secondaryControlSysid = p.uint8(11)
            self.secondaryControlCompid = p.uint8(12)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.flags, 4)
            w.put(self.gimbalDeviceId, 8)
            w.put(self.primaryControlSysid, 9)
            w.put(self.primaryControlCompid, 10)
            w.put(self.secondaryControlSysid, 11)
            w.put(self.secondaryControlCompid, 12)
        }
    }
}

/// GIMBAL_MANAGER_SET_ATTITUDE (#282)
extension MAV {
    public struct GimbalManagerSetAttitude: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 282, name: "GIMBAL_MANAGER_SET_ATTITUDE", crcExtra: 123, minLength: 35, length: 35)
        public var flags: UInt32
        public var q: [Float]
        public var angularVelocityX: Float
        public var angularVelocityY: Float
        public var angularVelocityZ: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var gimbalDeviceId: UInt8

        public init(flags: UInt32 = 0, q: [Float] = [Float](repeating: 0, count: 4), angularVelocityX: Float = 0, angularVelocityY: Float = 0, angularVelocityZ: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, gimbalDeviceId: UInt8 = 0) {
            self.flags = flags
            self.q = q
            self.angularVelocityX = angularVelocityX
            self.angularVelocityY = angularVelocityY
            self.angularVelocityZ = angularVelocityZ
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.gimbalDeviceId = gimbalDeviceId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.flags = p.uint32(0)
            self.q = (0..<4).map { p.float(4 + $0 * 4) }
            self.angularVelocityX = p.float(20)
            self.angularVelocityY = p.float(24)
            self.angularVelocityZ = p.float(28)
            self.targetSystem = p.uint8(32)
            self.targetComponent = p.uint8(33)
            self.gimbalDeviceId = p.uint8(34)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.flags, 0)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 4 + k * 4) }
            w.put(self.angularVelocityX, 20)
            w.put(self.angularVelocityY, 24)
            w.put(self.angularVelocityZ, 28)
            w.put(self.targetSystem, 32)
            w.put(self.targetComponent, 33)
            w.put(self.gimbalDeviceId, 34)
        }
    }
}

/// GIMBAL_DEVICE_INFORMATION (#283)
extension MAV {
    public struct GimbalDeviceInformation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 283, name: "GIMBAL_DEVICE_INFORMATION", crcExtra: 74, minLength: 144, length: 145)
        public var uid: UInt64
        public var timeBootMs: UInt32
        public var firmwareVersion: UInt32
        public var hardwareVersion: UInt32
        public var rollMin: Float
        public var rollMax: Float
        public var pitchMin: Float
        public var pitchMax: Float
        public var yawMin: Float
        public var yawMax: Float
        public var capFlags: UInt16
        public var customCapFlags: UInt16
        public var vendorName: [UInt8]
        public var modelName: [UInt8]
        public var customName: [UInt8]
        public var gimbalDeviceId: UInt8  // extension field

        public init(uid: UInt64 = 0, timeBootMs: UInt32 = 0, firmwareVersion: UInt32 = 0, hardwareVersion: UInt32 = 0, rollMin: Float = 0, rollMax: Float = 0, pitchMin: Float = 0, pitchMax: Float = 0, yawMin: Float = 0, yawMax: Float = 0, capFlags: UInt16 = 0, customCapFlags: UInt16 = 0, vendorName: [UInt8] = [UInt8](repeating: 0, count: 32), modelName: [UInt8] = [UInt8](repeating: 0, count: 32), customName: [UInt8] = [UInt8](repeating: 0, count: 32), gimbalDeviceId: UInt8 = 0) {
            self.uid = uid
            self.timeBootMs = timeBootMs
            self.firmwareVersion = firmwareVersion
            self.hardwareVersion = hardwareVersion
            self.rollMin = rollMin
            self.rollMax = rollMax
            self.pitchMin = pitchMin
            self.pitchMax = pitchMax
            self.yawMin = yawMin
            self.yawMax = yawMax
            self.capFlags = capFlags
            self.customCapFlags = customCapFlags
            self.vendorName = vendorName
            self.modelName = modelName
            self.customName = customName
            self.gimbalDeviceId = gimbalDeviceId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.uid = p.uint64(0)
            self.timeBootMs = p.uint32(8)
            self.firmwareVersion = p.uint32(12)
            self.hardwareVersion = p.uint32(16)
            self.rollMin = p.float(20)
            self.rollMax = p.float(24)
            self.pitchMin = p.float(28)
            self.pitchMax = p.float(32)
            self.yawMin = p.float(36)
            self.yawMax = p.float(40)
            self.capFlags = p.uint16(44)
            self.customCapFlags = p.uint16(46)
            self.vendorName = (0..<32).map { p.uint8(48 + $0 * 1) }
            self.modelName = (0..<32).map { p.uint8(80 + $0 * 1) }
            self.customName = (0..<32).map { p.uint8(112 + $0 * 1) }
            self.gimbalDeviceId = p.uint8(144)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.uid, 0)
            w.put(self.timeBootMs, 8)
            w.put(self.firmwareVersion, 12)
            w.put(self.hardwareVersion, 16)
            w.put(self.rollMin, 20)
            w.put(self.rollMax, 24)
            w.put(self.pitchMin, 28)
            w.put(self.pitchMax, 32)
            w.put(self.yawMin, 36)
            w.put(self.yawMax, 40)
            w.put(self.capFlags, 44)
            w.put(self.customCapFlags, 46)
            for k in 0..<Swift.min(32, self.vendorName.count) { w.put(self.vendorName[k], 48 + k * 1) }
            for k in 0..<Swift.min(32, self.modelName.count) { w.put(self.modelName[k], 80 + k * 1) }
            for k in 0..<Swift.min(32, self.customName.count) { w.put(self.customName[k], 112 + k * 1) }
            w.put(self.gimbalDeviceId, 144)
        }
    }
}

/// GIMBAL_DEVICE_SET_ATTITUDE (#284)
extension MAV {
    public struct GimbalDeviceSetAttitude: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 284, name: "GIMBAL_DEVICE_SET_ATTITUDE", crcExtra: 99, minLength: 32, length: 32)
        public var q: [Float]
        public var angularVelocityX: Float
        public var angularVelocityY: Float
        public var angularVelocityZ: Float
        public var flags: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(q: [Float] = [Float](repeating: 0, count: 4), angularVelocityX: Float = 0, angularVelocityY: Float = 0, angularVelocityZ: Float = 0, flags: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.q = q
            self.angularVelocityX = angularVelocityX
            self.angularVelocityY = angularVelocityY
            self.angularVelocityZ = angularVelocityZ
            self.flags = flags
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.q = (0..<4).map { p.float(0 + $0 * 4) }
            self.angularVelocityX = p.float(16)
            self.angularVelocityY = p.float(20)
            self.angularVelocityZ = p.float(24)
            self.flags = p.uint16(28)
            self.targetSystem = p.uint8(30)
            self.targetComponent = p.uint8(31)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 0 + k * 4) }
            w.put(self.angularVelocityX, 16)
            w.put(self.angularVelocityY, 20)
            w.put(self.angularVelocityZ, 24)
            w.put(self.flags, 28)
            w.put(self.targetSystem, 30)
            w.put(self.targetComponent, 31)
        }
    }
}

/// GIMBAL_DEVICE_ATTITUDE_STATUS (#285)
extension MAV {
    public struct GimbalDeviceAttitudeStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 285, name: "GIMBAL_DEVICE_ATTITUDE_STATUS", crcExtra: 137, minLength: 40, length: 49)
        public var timeBootMs: UInt32
        public var q: [Float]
        public var angularVelocityX: Float
        public var angularVelocityY: Float
        public var angularVelocityZ: Float
        public var failureFlags: UInt32
        public var flags: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var deltaYaw: Float  // extension field
        public var deltaYawVelocity: Float  // extension field
        public var gimbalDeviceId: UInt8  // extension field

        public init(timeBootMs: UInt32 = 0, q: [Float] = [Float](repeating: 0, count: 4), angularVelocityX: Float = 0, angularVelocityY: Float = 0, angularVelocityZ: Float = 0, failureFlags: UInt32 = 0, flags: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, deltaYaw: Float = 0, deltaYawVelocity: Float = 0, gimbalDeviceId: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.q = q
            self.angularVelocityX = angularVelocityX
            self.angularVelocityY = angularVelocityY
            self.angularVelocityZ = angularVelocityZ
            self.failureFlags = failureFlags
            self.flags = flags
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.deltaYaw = deltaYaw
            self.deltaYawVelocity = deltaYawVelocity
            self.gimbalDeviceId = gimbalDeviceId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.q = (0..<4).map { p.float(4 + $0 * 4) }
            self.angularVelocityX = p.float(20)
            self.angularVelocityY = p.float(24)
            self.angularVelocityZ = p.float(28)
            self.failureFlags = p.uint32(32)
            self.flags = p.uint16(36)
            self.targetSystem = p.uint8(38)
            self.targetComponent = p.uint8(39)
            self.deltaYaw = p.float(40)
            self.deltaYawVelocity = p.float(44)
            self.gimbalDeviceId = p.uint8(48)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 4 + k * 4) }
            w.put(self.angularVelocityX, 20)
            w.put(self.angularVelocityY, 24)
            w.put(self.angularVelocityZ, 28)
            w.put(self.failureFlags, 32)
            w.put(self.flags, 36)
            w.put(self.targetSystem, 38)
            w.put(self.targetComponent, 39)
            w.put(self.deltaYaw, 40)
            w.put(self.deltaYawVelocity, 44)
            w.put(self.gimbalDeviceId, 48)
        }
    }
}

/// AUTOPILOT_STATE_FOR_GIMBAL_DEVICE (#286)
extension MAV {
    public struct AutopilotStateForGimbalDevice: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 286, name: "AUTOPILOT_STATE_FOR_GIMBAL_DEVICE", crcExtra: 210, minLength: 53, length: 57)
        public var timeBootUs: UInt64
        public var q: [Float]
        public var qEstimatedDelayUs: UInt32
        public var vx: Float
        public var vy: Float
        public var vz: Float
        public var vEstimatedDelayUs: UInt32
        public var feedForwardAngularVelocityZ: Float
        public var estimatorStatus: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var landedState: UInt8
        public var angularVelocityZ: Float  // extension field

        public init(timeBootUs: UInt64 = 0, q: [Float] = [Float](repeating: 0, count: 4), qEstimatedDelayUs: UInt32 = 0, vx: Float = 0, vy: Float = 0, vz: Float = 0, vEstimatedDelayUs: UInt32 = 0, feedForwardAngularVelocityZ: Float = 0, estimatorStatus: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, landedState: UInt8 = 0, angularVelocityZ: Float = 0) {
            self.timeBootUs = timeBootUs
            self.q = q
            self.qEstimatedDelayUs = qEstimatedDelayUs
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.vEstimatedDelayUs = vEstimatedDelayUs
            self.feedForwardAngularVelocityZ = feedForwardAngularVelocityZ
            self.estimatorStatus = estimatorStatus
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.landedState = landedState
            self.angularVelocityZ = angularVelocityZ
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootUs = p.uint64(0)
            self.q = (0..<4).map { p.float(8 + $0 * 4) }
            self.qEstimatedDelayUs = p.uint32(24)
            self.vx = p.float(28)
            self.vy = p.float(32)
            self.vz = p.float(36)
            self.vEstimatedDelayUs = p.uint32(40)
            self.feedForwardAngularVelocityZ = p.float(44)
            self.estimatorStatus = p.uint16(48)
            self.targetSystem = p.uint8(50)
            self.targetComponent = p.uint8(51)
            self.landedState = p.uint8(52)
            self.angularVelocityZ = p.float(53)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootUs, 0)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 8 + k * 4) }
            w.put(self.qEstimatedDelayUs, 24)
            w.put(self.vx, 28)
            w.put(self.vy, 32)
            w.put(self.vz, 36)
            w.put(self.vEstimatedDelayUs, 40)
            w.put(self.feedForwardAngularVelocityZ, 44)
            w.put(self.estimatorStatus, 48)
            w.put(self.targetSystem, 50)
            w.put(self.targetComponent, 51)
            w.put(self.landedState, 52)
            w.put(self.angularVelocityZ, 53)
        }
    }
}

/// GIMBAL_MANAGER_SET_PITCHYAW (#287)
extension MAV {
    public struct GimbalManagerSetPitchyaw: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 287, name: "GIMBAL_MANAGER_SET_PITCHYAW", crcExtra: 1, minLength: 23, length: 23)
        public var flags: UInt32
        public var pitch: Float
        public var yaw: Float
        public var pitchRate: Float
        public var yawRate: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var gimbalDeviceId: UInt8

        public init(flags: UInt32 = 0, pitch: Float = 0, yaw: Float = 0, pitchRate: Float = 0, yawRate: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, gimbalDeviceId: UInt8 = 0) {
            self.flags = flags
            self.pitch = pitch
            self.yaw = yaw
            self.pitchRate = pitchRate
            self.yawRate = yawRate
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.gimbalDeviceId = gimbalDeviceId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.flags = p.uint32(0)
            self.pitch = p.float(4)
            self.yaw = p.float(8)
            self.pitchRate = p.float(12)
            self.yawRate = p.float(16)
            self.targetSystem = p.uint8(20)
            self.targetComponent = p.uint8(21)
            self.gimbalDeviceId = p.uint8(22)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.flags, 0)
            w.put(self.pitch, 4)
            w.put(self.yaw, 8)
            w.put(self.pitchRate, 12)
            w.put(self.yawRate, 16)
            w.put(self.targetSystem, 20)
            w.put(self.targetComponent, 21)
            w.put(self.gimbalDeviceId, 22)
        }
    }
}

/// GIMBAL_MANAGER_SET_MANUAL_CONTROL (#288)
extension MAV {
    public struct GimbalManagerSetManualControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 288, name: "GIMBAL_MANAGER_SET_MANUAL_CONTROL", crcExtra: 20, minLength: 23, length: 23)
        public var flags: UInt32
        public var pitch: Float
        public var yaw: Float
        public var pitchRate: Float
        public var yawRate: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var gimbalDeviceId: UInt8

        public init(flags: UInt32 = 0, pitch: Float = 0, yaw: Float = 0, pitchRate: Float = 0, yawRate: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, gimbalDeviceId: UInt8 = 0) {
            self.flags = flags
            self.pitch = pitch
            self.yaw = yaw
            self.pitchRate = pitchRate
            self.yawRate = yawRate
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.gimbalDeviceId = gimbalDeviceId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.flags = p.uint32(0)
            self.pitch = p.float(4)
            self.yaw = p.float(8)
            self.pitchRate = p.float(12)
            self.yawRate = p.float(16)
            self.targetSystem = p.uint8(20)
            self.targetComponent = p.uint8(21)
            self.gimbalDeviceId = p.uint8(22)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.flags, 0)
            w.put(self.pitch, 4)
            w.put(self.yaw, 8)
            w.put(self.pitchRate, 12)
            w.put(self.yawRate, 16)
            w.put(self.targetSystem, 20)
            w.put(self.targetComponent, 21)
            w.put(self.gimbalDeviceId, 22)
        }
    }
}

/// AIRSPEED (#295)
extension MAV {
    public struct Airspeed: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 295, name: "AIRSPEED", crcExtra: 234, minLength: 12, length: 12)
        public var airspeed: Float
        public var rawPress: Float
        public var temperature: Int16
        public var id: UInt8
        public var flags: UInt8

        public init(airspeed: Float = 0, rawPress: Float = 0, temperature: Int16 = 0, id: UInt8 = 0, flags: UInt8 = 0) {
            self.airspeed = airspeed
            self.rawPress = rawPress
            self.temperature = temperature
            self.id = id
            self.flags = flags
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.airspeed = p.float(0)
            self.rawPress = p.float(4)
            self.temperature = p.int16(8)
            self.id = p.uint8(10)
            self.flags = p.uint8(11)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.airspeed, 0)
            w.put(self.rawPress, 4)
            w.put(self.temperature, 8)
            w.put(self.id, 10)
            w.put(self.flags, 11)
        }
    }
}

/// WIFI_CONFIG_AP (#299)
extension MAV {
    public struct WifiConfigAp: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 299, name: "WIFI_CONFIG_AP", crcExtra: 19, minLength: 96, length: 96)
        public var ssid: [UInt8]
        public var password: [UInt8]

        public init(ssid: [UInt8] = [UInt8](repeating: 0, count: 32), password: [UInt8] = [UInt8](repeating: 0, count: 64)) {
            self.ssid = ssid
            self.password = password
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.ssid = (0..<32).map { p.uint8(0 + $0 * 1) }
            self.password = (0..<64).map { p.uint8(32 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(32, self.ssid.count) { w.put(self.ssid[k], 0 + k * 1) }
            for k in 0..<Swift.min(64, self.password.count) { w.put(self.password[k], 32 + k * 1) }
        }
    }
}

/// AIS_VESSEL (#301)
extension MAV {
    public struct AisVessel: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 301, name: "AIS_VESSEL", crcExtra: 243, minLength: 58, length: 58)
        public var MMSI: UInt32
        public var lat: Int32
        public var lon: Int32
        public var COG: UInt16
        public var heading: UInt16
        public var velocity: UInt16
        public var dimensionBow: UInt16
        public var dimensionStern: UInt16
        public var tslc: UInt16
        public var flags: UInt16
        public var turnRate: Int8
        public var navigationalStatus: UInt8
        public var type: UInt8
        public var dimensionPort: UInt8
        public var dimensionStarboard: UInt8
        public var callsign: [UInt8]
        public var name: [UInt8]

        public init(MMSI: UInt32 = 0, lat: Int32 = 0, lon: Int32 = 0, COG: UInt16 = 0, heading: UInt16 = 0, velocity: UInt16 = 0, dimensionBow: UInt16 = 0, dimensionStern: UInt16 = 0, tslc: UInt16 = 0, flags: UInt16 = 0, turnRate: Int8 = 0, navigationalStatus: UInt8 = 0, type: UInt8 = 0, dimensionPort: UInt8 = 0, dimensionStarboard: UInt8 = 0, callsign: [UInt8] = [UInt8](repeating: 0, count: 7), name: [UInt8] = [UInt8](repeating: 0, count: 20)) {
            self.MMSI = MMSI
            self.lat = lat
            self.lon = lon
            self.COG = COG
            self.heading = heading
            self.velocity = velocity
            self.dimensionBow = dimensionBow
            self.dimensionStern = dimensionStern
            self.tslc = tslc
            self.flags = flags
            self.turnRate = turnRate
            self.navigationalStatus = navigationalStatus
            self.type = type
            self.dimensionPort = dimensionPort
            self.dimensionStarboard = dimensionStarboard
            self.callsign = callsign
            self.name = name
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.MMSI = p.uint32(0)
            self.lat = p.int32(4)
            self.lon = p.int32(8)
            self.COG = p.uint16(12)
            self.heading = p.uint16(14)
            self.velocity = p.uint16(16)
            self.dimensionBow = p.uint16(18)
            self.dimensionStern = p.uint16(20)
            self.tslc = p.uint16(22)
            self.flags = p.uint16(24)
            self.turnRate = p.int8(26)
            self.navigationalStatus = p.uint8(27)
            self.type = p.uint8(28)
            self.dimensionPort = p.uint8(29)
            self.dimensionStarboard = p.uint8(30)
            self.callsign = (0..<7).map { p.uint8(31 + $0 * 1) }
            self.name = (0..<20).map { p.uint8(38 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.MMSI, 0)
            w.put(self.lat, 4)
            w.put(self.lon, 8)
            w.put(self.COG, 12)
            w.put(self.heading, 14)
            w.put(self.velocity, 16)
            w.put(self.dimensionBow, 18)
            w.put(self.dimensionStern, 20)
            w.put(self.tslc, 22)
            w.put(self.flags, 24)
            w.put(self.turnRate, 26)
            w.put(self.navigationalStatus, 27)
            w.put(self.type, 28)
            w.put(self.dimensionPort, 29)
            w.put(self.dimensionStarboard, 30)
            for k in 0..<Swift.min(7, self.callsign.count) { w.put(self.callsign[k], 31 + k * 1) }
            for k in 0..<Swift.min(20, self.name.count) { w.put(self.name[k], 38 + k * 1) }
        }
    }
}

/// UAVCAN_NODE_STATUS (#310)
extension MAV {
    public struct UavcanNodeStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 310, name: "UAVCAN_NODE_STATUS", crcExtra: 28, minLength: 17, length: 17)
        public var timeUsec: UInt64
        public var uptimeSec: UInt32
        public var vendorSpecificStatusCode: UInt16
        public var health: UInt8
        public var mode: UInt8
        public var subMode: UInt8

        public init(timeUsec: UInt64 = 0, uptimeSec: UInt32 = 0, vendorSpecificStatusCode: UInt16 = 0, health: UInt8 = 0, mode: UInt8 = 0, subMode: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.uptimeSec = uptimeSec
            self.vendorSpecificStatusCode = vendorSpecificStatusCode
            self.health = health
            self.mode = mode
            self.subMode = subMode
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.uptimeSec = p.uint32(8)
            self.vendorSpecificStatusCode = p.uint16(12)
            self.health = p.uint8(14)
            self.mode = p.uint8(15)
            self.subMode = p.uint8(16)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.uptimeSec, 8)
            w.put(self.vendorSpecificStatusCode, 12)
            w.put(self.health, 14)
            w.put(self.mode, 15)
            w.put(self.subMode, 16)
        }
    }
}

/// UAVCAN_NODE_INFO (#311)
extension MAV {
    public struct UavcanNodeInfo: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 311, name: "UAVCAN_NODE_INFO", crcExtra: 95, minLength: 116, length: 116)
        public var timeUsec: UInt64
        public var uptimeSec: UInt32
        public var swVcsCommit: UInt32
        public var name: [UInt8]
        public var hwVersionMajor: UInt8
        public var hwVersionMinor: UInt8
        public var hwUniqueId: [UInt8]
        public var swVersionMajor: UInt8
        public var swVersionMinor: UInt8

        public init(timeUsec: UInt64 = 0, uptimeSec: UInt32 = 0, swVcsCommit: UInt32 = 0, name: [UInt8] = [UInt8](repeating: 0, count: 80), hwVersionMajor: UInt8 = 0, hwVersionMinor: UInt8 = 0, hwUniqueId: [UInt8] = [UInt8](repeating: 0, count: 16), swVersionMajor: UInt8 = 0, swVersionMinor: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.uptimeSec = uptimeSec
            self.swVcsCommit = swVcsCommit
            self.name = name
            self.hwVersionMajor = hwVersionMajor
            self.hwVersionMinor = hwVersionMinor
            self.hwUniqueId = hwUniqueId
            self.swVersionMajor = swVersionMajor
            self.swVersionMinor = swVersionMinor
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.uptimeSec = p.uint32(8)
            self.swVcsCommit = p.uint32(12)
            self.name = (0..<80).map { p.uint8(16 + $0 * 1) }
            self.hwVersionMajor = p.uint8(96)
            self.hwVersionMinor = p.uint8(97)
            self.hwUniqueId = (0..<16).map { p.uint8(98 + $0 * 1) }
            self.swVersionMajor = p.uint8(114)
            self.swVersionMinor = p.uint8(115)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.uptimeSec, 8)
            w.put(self.swVcsCommit, 12)
            for k in 0..<Swift.min(80, self.name.count) { w.put(self.name[k], 16 + k * 1) }
            w.put(self.hwVersionMajor, 96)
            w.put(self.hwVersionMinor, 97)
            for k in 0..<Swift.min(16, self.hwUniqueId.count) { w.put(self.hwUniqueId[k], 98 + k * 1) }
            w.put(self.swVersionMajor, 114)
            w.put(self.swVersionMinor, 115)
        }
    }
}

/// PARAM_EXT_REQUEST_READ (#320)
extension MAV {
    public struct ParamExtRequestRead: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 320, name: "PARAM_EXT_REQUEST_READ", crcExtra: 243, minLength: 20, length: 20)
        public var paramIndex: Int16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var paramId: [UInt8]

        public init(paramIndex: Int16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, paramId: [UInt8] = [UInt8](repeating: 0, count: 16)) {
            self.paramIndex = paramIndex
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.paramId = paramId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.paramIndex = p.int16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
            self.paramId = (0..<16).map { p.uint8(4 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.paramIndex, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
            for k in 0..<Swift.min(16, self.paramId.count) { w.put(self.paramId[k], 4 + k * 1) }
        }
    }
}

/// PARAM_EXT_REQUEST_LIST (#321)
extension MAV {
    public struct ParamExtRequestList: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 321, name: "PARAM_EXT_REQUEST_LIST", crcExtra: 88, minLength: 2, length: 2)
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
        }
    }
}

/// PARAM_EXT_VALUE (#322)
extension MAV {
    public struct ParamExtValue: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 322, name: "PARAM_EXT_VALUE", crcExtra: 243, minLength: 149, length: 149)
        public var paramCount: UInt16
        public var paramIndex: UInt16
        public var paramId: [UInt8]
        public var paramValue: [UInt8]
        public var paramType: UInt8

        public init(paramCount: UInt16 = 0, paramIndex: UInt16 = 0, paramId: [UInt8] = [UInt8](repeating: 0, count: 16), paramValue: [UInt8] = [UInt8](repeating: 0, count: 128), paramType: UInt8 = 0) {
            self.paramCount = paramCount
            self.paramIndex = paramIndex
            self.paramId = paramId
            self.paramValue = paramValue
            self.paramType = paramType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.paramCount = p.uint16(0)
            self.paramIndex = p.uint16(2)
            self.paramId = (0..<16).map { p.uint8(4 + $0 * 1) }
            self.paramValue = (0..<128).map { p.uint8(20 + $0 * 1) }
            self.paramType = p.uint8(148)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.paramCount, 0)
            w.put(self.paramIndex, 2)
            for k in 0..<Swift.min(16, self.paramId.count) { w.put(self.paramId[k], 4 + k * 1) }
            for k in 0..<Swift.min(128, self.paramValue.count) { w.put(self.paramValue[k], 20 + k * 1) }
            w.put(self.paramType, 148)
        }
    }
}

/// PARAM_EXT_SET (#323)
extension MAV {
    public struct ParamExtSet: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 323, name: "PARAM_EXT_SET", crcExtra: 78, minLength: 147, length: 147)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var paramId: [UInt8]
        public var paramValue: [UInt8]
        public var paramType: UInt8

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, paramId: [UInt8] = [UInt8](repeating: 0, count: 16), paramValue: [UInt8] = [UInt8](repeating: 0, count: 128), paramType: UInt8 = 0) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.paramId = paramId
            self.paramValue = paramValue
            self.paramType = paramType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.paramId = (0..<16).map { p.uint8(2 + $0 * 1) }
            self.paramValue = (0..<128).map { p.uint8(18 + $0 * 1) }
            self.paramType = p.uint8(146)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            for k in 0..<Swift.min(16, self.paramId.count) { w.put(self.paramId[k], 2 + k * 1) }
            for k in 0..<Swift.min(128, self.paramValue.count) { w.put(self.paramValue[k], 18 + k * 1) }
            w.put(self.paramType, 146)
        }
    }
}

/// PARAM_EXT_ACK (#324)
extension MAV {
    public struct ParamExtAck: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 324, name: "PARAM_EXT_ACK", crcExtra: 132, minLength: 146, length: 146)
        public var paramId: [UInt8]
        public var paramValue: [UInt8]
        public var paramType: UInt8
        public var paramResult: UInt8

        public init(paramId: [UInt8] = [UInt8](repeating: 0, count: 16), paramValue: [UInt8] = [UInt8](repeating: 0, count: 128), paramType: UInt8 = 0, paramResult: UInt8 = 0) {
            self.paramId = paramId
            self.paramValue = paramValue
            self.paramType = paramType
            self.paramResult = paramResult
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.paramId = (0..<16).map { p.uint8(0 + $0 * 1) }
            self.paramValue = (0..<128).map { p.uint8(16 + $0 * 1) }
            self.paramType = p.uint8(144)
            self.paramResult = p.uint8(145)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(16, self.paramId.count) { w.put(self.paramId[k], 0 + k * 1) }
            for k in 0..<Swift.min(128, self.paramValue.count) { w.put(self.paramValue[k], 16 + k * 1) }
            w.put(self.paramType, 144)
            w.put(self.paramResult, 145)
        }
    }
}

/// OBSTACLE_DISTANCE (#330)
extension MAV {
    public struct ObstacleDistance: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 330, name: "OBSTACLE_DISTANCE", crcExtra: 23, minLength: 158, length: 167)
        public var timeUsec: UInt64
        public var distances: [UInt16]
        public var minDistance: UInt16
        public var maxDistance: UInt16
        public var sensorType: UInt8
        public var increment: UInt8
        public var incrementF: Float  // extension field
        public var angleOffset: Float  // extension field
        public var frame: UInt8  // extension field

        public init(timeUsec: UInt64 = 0, distances: [UInt16] = [UInt16](repeating: 0, count: 72), minDistance: UInt16 = 0, maxDistance: UInt16 = 0, sensorType: UInt8 = 0, increment: UInt8 = 0, incrementF: Float = 0, angleOffset: Float = 0, frame: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.distances = distances
            self.minDistance = minDistance
            self.maxDistance = maxDistance
            self.sensorType = sensorType
            self.increment = increment
            self.incrementF = incrementF
            self.angleOffset = angleOffset
            self.frame = frame
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.distances = (0..<72).map { p.uint16(8 + $0 * 2) }
            self.minDistance = p.uint16(152)
            self.maxDistance = p.uint16(154)
            self.sensorType = p.uint8(156)
            self.increment = p.uint8(157)
            self.incrementF = p.float(158)
            self.angleOffset = p.float(162)
            self.frame = p.uint8(166)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            for k in 0..<Swift.min(72, self.distances.count) { w.put(self.distances[k], 8 + k * 2) }
            w.put(self.minDistance, 152)
            w.put(self.maxDistance, 154)
            w.put(self.sensorType, 156)
            w.put(self.increment, 157)
            w.put(self.incrementF, 158)
            w.put(self.angleOffset, 162)
            w.put(self.frame, 166)
        }
    }
}

/// ODOMETRY (#331)
extension MAV {
    public struct Odometry: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 331, name: "ODOMETRY", crcExtra: 91, minLength: 230, length: 233)
        public var timeUsec: UInt64
        public var x: Float
        public var y: Float
        public var z: Float
        public var q: [Float]
        public var vx: Float
        public var vy: Float
        public var vz: Float
        public var rollspeed: Float
        public var pitchspeed: Float
        public var yawspeed: Float
        public var poseCovariance: [Float]
        public var velocityCovariance: [Float]
        public var frameId: UInt8
        public var childFrameId: UInt8
        public var resetCounter: UInt8  // extension field
        public var estimatorType: UInt8  // extension field
        public var quality: Int8  // extension field

        public init(timeUsec: UInt64 = 0, x: Float = 0, y: Float = 0, z: Float = 0, q: [Float] = [Float](repeating: 0, count: 4), vx: Float = 0, vy: Float = 0, vz: Float = 0, rollspeed: Float = 0, pitchspeed: Float = 0, yawspeed: Float = 0, poseCovariance: [Float] = [Float](repeating: 0, count: 21), velocityCovariance: [Float] = [Float](repeating: 0, count: 21), frameId: UInt8 = 0, childFrameId: UInt8 = 0, resetCounter: UInt8 = 0, estimatorType: UInt8 = 0, quality: Int8 = 0) {
            self.timeUsec = timeUsec
            self.x = x
            self.y = y
            self.z = z
            self.q = q
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.rollspeed = rollspeed
            self.pitchspeed = pitchspeed
            self.yawspeed = yawspeed
            self.poseCovariance = poseCovariance
            self.velocityCovariance = velocityCovariance
            self.frameId = frameId
            self.childFrameId = childFrameId
            self.resetCounter = resetCounter
            self.estimatorType = estimatorType
            self.quality = quality
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.x = p.float(8)
            self.y = p.float(12)
            self.z = p.float(16)
            self.q = (0..<4).map { p.float(20 + $0 * 4) }
            self.vx = p.float(36)
            self.vy = p.float(40)
            self.vz = p.float(44)
            self.rollspeed = p.float(48)
            self.pitchspeed = p.float(52)
            self.yawspeed = p.float(56)
            self.poseCovariance = (0..<21).map { p.float(60 + $0 * 4) }
            self.velocityCovariance = (0..<21).map { p.float(144 + $0 * 4) }
            self.frameId = p.uint8(228)
            self.childFrameId = p.uint8(229)
            self.resetCounter = p.uint8(230)
            self.estimatorType = p.uint8(231)
            self.quality = p.int8(232)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.x, 8)
            w.put(self.y, 12)
            w.put(self.z, 16)
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 20 + k * 4) }
            w.put(self.vx, 36)
            w.put(self.vy, 40)
            w.put(self.vz, 44)
            w.put(self.rollspeed, 48)
            w.put(self.pitchspeed, 52)
            w.put(self.yawspeed, 56)
            for k in 0..<Swift.min(21, self.poseCovariance.count) { w.put(self.poseCovariance[k], 60 + k * 4) }
            for k in 0..<Swift.min(21, self.velocityCovariance.count) { w.put(self.velocityCovariance[k], 144 + k * 4) }
            w.put(self.frameId, 228)
            w.put(self.childFrameId, 229)
            w.put(self.resetCounter, 230)
            w.put(self.estimatorType, 231)
            w.put(self.quality, 232)
        }
    }
}

/// TRAJECTORY_REPRESENTATION_WAYPOINTS (#332)
extension MAV {
    public struct TrajectoryRepresentationWaypoints: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 332, name: "TRAJECTORY_REPRESENTATION_WAYPOINTS", crcExtra: 236, minLength: 239, length: 239)
        public var timeUsec: UInt64
        public var posX: [Float]
        public var posY: [Float]
        public var posZ: [Float]
        public var velX: [Float]
        public var velY: [Float]
        public var velZ: [Float]
        public var accX: [Float]
        public var accY: [Float]
        public var accZ: [Float]
        public var posYaw: [Float]
        public var velYaw: [Float]
        public var command: [UInt16]
        public var validPoints: UInt8

        public init(timeUsec: UInt64 = 0, posX: [Float] = [Float](repeating: 0, count: 5), posY: [Float] = [Float](repeating: 0, count: 5), posZ: [Float] = [Float](repeating: 0, count: 5), velX: [Float] = [Float](repeating: 0, count: 5), velY: [Float] = [Float](repeating: 0, count: 5), velZ: [Float] = [Float](repeating: 0, count: 5), accX: [Float] = [Float](repeating: 0, count: 5), accY: [Float] = [Float](repeating: 0, count: 5), accZ: [Float] = [Float](repeating: 0, count: 5), posYaw: [Float] = [Float](repeating: 0, count: 5), velYaw: [Float] = [Float](repeating: 0, count: 5), command: [UInt16] = [UInt16](repeating: 0, count: 5), validPoints: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.posX = posX
            self.posY = posY
            self.posZ = posZ
            self.velX = velX
            self.velY = velY
            self.velZ = velZ
            self.accX = accX
            self.accY = accY
            self.accZ = accZ
            self.posYaw = posYaw
            self.velYaw = velYaw
            self.command = command
            self.validPoints = validPoints
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.posX = (0..<5).map { p.float(8 + $0 * 4) }
            self.posY = (0..<5).map { p.float(28 + $0 * 4) }
            self.posZ = (0..<5).map { p.float(48 + $0 * 4) }
            self.velX = (0..<5).map { p.float(68 + $0 * 4) }
            self.velY = (0..<5).map { p.float(88 + $0 * 4) }
            self.velZ = (0..<5).map { p.float(108 + $0 * 4) }
            self.accX = (0..<5).map { p.float(128 + $0 * 4) }
            self.accY = (0..<5).map { p.float(148 + $0 * 4) }
            self.accZ = (0..<5).map { p.float(168 + $0 * 4) }
            self.posYaw = (0..<5).map { p.float(188 + $0 * 4) }
            self.velYaw = (0..<5).map { p.float(208 + $0 * 4) }
            self.command = (0..<5).map { p.uint16(228 + $0 * 2) }
            self.validPoints = p.uint8(238)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            for k in 0..<Swift.min(5, self.posX.count) { w.put(self.posX[k], 8 + k * 4) }
            for k in 0..<Swift.min(5, self.posY.count) { w.put(self.posY[k], 28 + k * 4) }
            for k in 0..<Swift.min(5, self.posZ.count) { w.put(self.posZ[k], 48 + k * 4) }
            for k in 0..<Swift.min(5, self.velX.count) { w.put(self.velX[k], 68 + k * 4) }
            for k in 0..<Swift.min(5, self.velY.count) { w.put(self.velY[k], 88 + k * 4) }
            for k in 0..<Swift.min(5, self.velZ.count) { w.put(self.velZ[k], 108 + k * 4) }
            for k in 0..<Swift.min(5, self.accX.count) { w.put(self.accX[k], 128 + k * 4) }
            for k in 0..<Swift.min(5, self.accY.count) { w.put(self.accY[k], 148 + k * 4) }
            for k in 0..<Swift.min(5, self.accZ.count) { w.put(self.accZ[k], 168 + k * 4) }
            for k in 0..<Swift.min(5, self.posYaw.count) { w.put(self.posYaw[k], 188 + k * 4) }
            for k in 0..<Swift.min(5, self.velYaw.count) { w.put(self.velYaw[k], 208 + k * 4) }
            for k in 0..<Swift.min(5, self.command.count) { w.put(self.command[k], 228 + k * 2) }
            w.put(self.validPoints, 238)
        }
    }
}

/// TRAJECTORY_REPRESENTATION_BEZIER (#333)
extension MAV {
    public struct TrajectoryRepresentationBezier: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 333, name: "TRAJECTORY_REPRESENTATION_BEZIER", crcExtra: 231, minLength: 109, length: 109)
        public var timeUsec: UInt64
        public var posX: [Float]
        public var posY: [Float]
        public var posZ: [Float]
        public var delta: [Float]
        public var posYaw: [Float]
        public var validPoints: UInt8

        public init(timeUsec: UInt64 = 0, posX: [Float] = [Float](repeating: 0, count: 5), posY: [Float] = [Float](repeating: 0, count: 5), posZ: [Float] = [Float](repeating: 0, count: 5), delta: [Float] = [Float](repeating: 0, count: 5), posYaw: [Float] = [Float](repeating: 0, count: 5), validPoints: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.posX = posX
            self.posY = posY
            self.posZ = posZ
            self.delta = delta
            self.posYaw = posYaw
            self.validPoints = validPoints
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.posX = (0..<5).map { p.float(8 + $0 * 4) }
            self.posY = (0..<5).map { p.float(28 + $0 * 4) }
            self.posZ = (0..<5).map { p.float(48 + $0 * 4) }
            self.delta = (0..<5).map { p.float(68 + $0 * 4) }
            self.posYaw = (0..<5).map { p.float(88 + $0 * 4) }
            self.validPoints = p.uint8(108)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            for k in 0..<Swift.min(5, self.posX.count) { w.put(self.posX[k], 8 + k * 4) }
            for k in 0..<Swift.min(5, self.posY.count) { w.put(self.posY[k], 28 + k * 4) }
            for k in 0..<Swift.min(5, self.posZ.count) { w.put(self.posZ[k], 48 + k * 4) }
            for k in 0..<Swift.min(5, self.delta.count) { w.put(self.delta[k], 68 + k * 4) }
            for k in 0..<Swift.min(5, self.posYaw.count) { w.put(self.posYaw[k], 88 + k * 4) }
            w.put(self.validPoints, 108)
        }
    }
}

/// ISBD_LINK_STATUS (#335)
extension MAV {
    public struct IsbdLinkStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 335, name: "ISBD_LINK_STATUS", crcExtra: 225, minLength: 24, length: 24)
        public var timestamp: UInt64
        public var lastHeartbeat: UInt64
        public var failedSessions: UInt16
        public var successfulSessions: UInt16
        public var signalQuality: UInt8
        public var ringPending: UInt8
        public var txSessionPending: UInt8
        public var rxSessionPending: UInt8

        public init(timestamp: UInt64 = 0, lastHeartbeat: UInt64 = 0, failedSessions: UInt16 = 0, successfulSessions: UInt16 = 0, signalQuality: UInt8 = 0, ringPending: UInt8 = 0, txSessionPending: UInt8 = 0, rxSessionPending: UInt8 = 0) {
            self.timestamp = timestamp
            self.lastHeartbeat = lastHeartbeat
            self.failedSessions = failedSessions
            self.successfulSessions = successfulSessions
            self.signalQuality = signalQuality
            self.ringPending = ringPending
            self.txSessionPending = txSessionPending
            self.rxSessionPending = rxSessionPending
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.lastHeartbeat = p.uint64(8)
            self.failedSessions = p.uint16(16)
            self.successfulSessions = p.uint16(18)
            self.signalQuality = p.uint8(20)
            self.ringPending = p.uint8(21)
            self.txSessionPending = p.uint8(22)
            self.rxSessionPending = p.uint8(23)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.lastHeartbeat, 8)
            w.put(self.failedSessions, 16)
            w.put(self.successfulSessions, 18)
            w.put(self.signalQuality, 20)
            w.put(self.ringPending, 21)
            w.put(self.txSessionPending, 22)
            w.put(self.rxSessionPending, 23)
        }
    }
}

/// RAW_RPM (#339)
extension MAV {
    public struct RawRpm: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 339, name: "RAW_RPM", crcExtra: 199, minLength: 5, length: 5)
        public var frequency: Float
        public var index: UInt8

        public init(frequency: Float = 0, index: UInt8 = 0) {
            self.frequency = frequency
            self.index = index
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.frequency = p.float(0)
            self.index = p.uint8(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.frequency, 0)
            w.put(self.index, 4)
        }
    }
}

/// UTM_GLOBAL_POSITION (#340)
extension MAV {
    public struct UtmGlobalPosition: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 340, name: "UTM_GLOBAL_POSITION", crcExtra: 99, minLength: 70, length: 70)
        public var time: UInt64
        public var lat: Int32
        public var lon: Int32
        public var alt: Int32
        public var relativeAlt: Int32
        public var nextLat: Int32
        public var nextLon: Int32
        public var nextAlt: Int32
        public var vx: Int16
        public var vy: Int16
        public var vz: Int16
        public var hAcc: UInt16
        public var vAcc: UInt16
        public var velAcc: UInt16
        public var updateRate: UInt16
        public var uasId: [UInt8]
        public var flightState: UInt8
        public var flags: UInt8

        public init(time: UInt64 = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Int32 = 0, relativeAlt: Int32 = 0, nextLat: Int32 = 0, nextLon: Int32 = 0, nextAlt: Int32 = 0, vx: Int16 = 0, vy: Int16 = 0, vz: Int16 = 0, hAcc: UInt16 = 0, vAcc: UInt16 = 0, velAcc: UInt16 = 0, updateRate: UInt16 = 0, uasId: [UInt8] = [UInt8](repeating: 0, count: 18), flightState: UInt8 = 0, flags: UInt8 = 0) {
            self.time = time
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.relativeAlt = relativeAlt
            self.nextLat = nextLat
            self.nextLon = nextLon
            self.nextAlt = nextAlt
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.hAcc = hAcc
            self.vAcc = vAcc
            self.velAcc = velAcc
            self.updateRate = updateRate
            self.uasId = uasId
            self.flightState = flightState
            self.flags = flags
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.time = p.uint64(0)
            self.lat = p.int32(8)
            self.lon = p.int32(12)
            self.alt = p.int32(16)
            self.relativeAlt = p.int32(20)
            self.nextLat = p.int32(24)
            self.nextLon = p.int32(28)
            self.nextAlt = p.int32(32)
            self.vx = p.int16(36)
            self.vy = p.int16(38)
            self.vz = p.int16(40)
            self.hAcc = p.uint16(42)
            self.vAcc = p.uint16(44)
            self.velAcc = p.uint16(46)
            self.updateRate = p.uint16(48)
            self.uasId = (0..<18).map { p.uint8(50 + $0 * 1) }
            self.flightState = p.uint8(68)
            self.flags = p.uint8(69)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.time, 0)
            w.put(self.lat, 8)
            w.put(self.lon, 12)
            w.put(self.alt, 16)
            w.put(self.relativeAlt, 20)
            w.put(self.nextLat, 24)
            w.put(self.nextLon, 28)
            w.put(self.nextAlt, 32)
            w.put(self.vx, 36)
            w.put(self.vy, 38)
            w.put(self.vz, 40)
            w.put(self.hAcc, 42)
            w.put(self.vAcc, 44)
            w.put(self.velAcc, 46)
            w.put(self.updateRate, 48)
            for k in 0..<Swift.min(18, self.uasId.count) { w.put(self.uasId[k], 50 + k * 1) }
            w.put(self.flightState, 68)
            w.put(self.flags, 69)
        }
    }
}

/// DEBUG_FLOAT_ARRAY (#350)
extension MAV {
    public struct DebugFloatArray: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 350, name: "DEBUG_FLOAT_ARRAY", crcExtra: 232, minLength: 20, length: 252)
        public var timeUsec: UInt64
        public var arrayId: UInt16
        public var name: [UInt8]
        public var data: [Float]  // extension field

        public init(timeUsec: UInt64 = 0, arrayId: UInt16 = 0, name: [UInt8] = [UInt8](repeating: 0, count: 10), data: [Float] = [Float](repeating: 0, count: 58)) {
            self.timeUsec = timeUsec
            self.arrayId = arrayId
            self.name = name
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.arrayId = p.uint16(8)
            self.name = (0..<10).map { p.uint8(10 + $0 * 1) }
            self.data = (0..<58).map { p.float(20 + $0 * 4) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.arrayId, 8)
            for k in 0..<Swift.min(10, self.name.count) { w.put(self.name[k], 10 + k * 1) }
            for k in 0..<Swift.min(58, self.data.count) { w.put(self.data[k], 20 + k * 4) }
        }
    }
}

/// SMART_BATTERY_INFO (#370)
extension MAV {
    public struct SmartBatteryInfo: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 370, name: "SMART_BATTERY_INFO", crcExtra: 75, minLength: 87, length: 109)
        public var capacityFullSpecification: Int32
        public var capacityFull: Int32
        public var cycleCount: UInt16
        public var weight: UInt16
        public var dischargeMinimumVoltage: UInt16
        public var chargingMinimumVoltage: UInt16
        public var restingMinimumVoltage: UInt16
        public var id: UInt8
        public var batteryFunction: UInt8
        public var type: UInt8
        public var serialNumber: [UInt8]
        public var deviceName: [UInt8]
        public var chargingMaximumVoltage: UInt16  // extension field
        public var cellsInSeries: UInt8  // extension field
        public var dischargeMaximumCurrent: UInt32  // extension field
        public var dischargeMaximumBurstCurrent: UInt32  // extension field
        public var manufactureDate: [UInt8]  // extension field

        public init(capacityFullSpecification: Int32 = 0, capacityFull: Int32 = 0, cycleCount: UInt16 = 0, weight: UInt16 = 0, dischargeMinimumVoltage: UInt16 = 0, chargingMinimumVoltage: UInt16 = 0, restingMinimumVoltage: UInt16 = 0, id: UInt8 = 0, batteryFunction: UInt8 = 0, type: UInt8 = 0, serialNumber: [UInt8] = [UInt8](repeating: 0, count: 16), deviceName: [UInt8] = [UInt8](repeating: 0, count: 50), chargingMaximumVoltage: UInt16 = 0, cellsInSeries: UInt8 = 0, dischargeMaximumCurrent: UInt32 = 0, dischargeMaximumBurstCurrent: UInt32 = 0, manufactureDate: [UInt8] = [UInt8](repeating: 0, count: 11)) {
            self.capacityFullSpecification = capacityFullSpecification
            self.capacityFull = capacityFull
            self.cycleCount = cycleCount
            self.weight = weight
            self.dischargeMinimumVoltage = dischargeMinimumVoltage
            self.chargingMinimumVoltage = chargingMinimumVoltage
            self.restingMinimumVoltage = restingMinimumVoltage
            self.id = id
            self.batteryFunction = batteryFunction
            self.type = type
            self.serialNumber = serialNumber
            self.deviceName = deviceName
            self.chargingMaximumVoltage = chargingMaximumVoltage
            self.cellsInSeries = cellsInSeries
            self.dischargeMaximumCurrent = dischargeMaximumCurrent
            self.dischargeMaximumBurstCurrent = dischargeMaximumBurstCurrent
            self.manufactureDate = manufactureDate
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.capacityFullSpecification = p.int32(0)
            self.capacityFull = p.int32(4)
            self.cycleCount = p.uint16(8)
            self.weight = p.uint16(10)
            self.dischargeMinimumVoltage = p.uint16(12)
            self.chargingMinimumVoltage = p.uint16(14)
            self.restingMinimumVoltage = p.uint16(16)
            self.id = p.uint8(18)
            self.batteryFunction = p.uint8(19)
            self.type = p.uint8(20)
            self.serialNumber = (0..<16).map { p.uint8(21 + $0 * 1) }
            self.deviceName = (0..<50).map { p.uint8(37 + $0 * 1) }
            self.chargingMaximumVoltage = p.uint16(87)
            self.cellsInSeries = p.uint8(89)
            self.dischargeMaximumCurrent = p.uint32(90)
            self.dischargeMaximumBurstCurrent = p.uint32(94)
            self.manufactureDate = (0..<11).map { p.uint8(98 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.capacityFullSpecification, 0)
            w.put(self.capacityFull, 4)
            w.put(self.cycleCount, 8)
            w.put(self.weight, 10)
            w.put(self.dischargeMinimumVoltage, 12)
            w.put(self.chargingMinimumVoltage, 14)
            w.put(self.restingMinimumVoltage, 16)
            w.put(self.id, 18)
            w.put(self.batteryFunction, 19)
            w.put(self.type, 20)
            for k in 0..<Swift.min(16, self.serialNumber.count) { w.put(self.serialNumber[k], 21 + k * 1) }
            for k in 0..<Swift.min(50, self.deviceName.count) { w.put(self.deviceName[k], 37 + k * 1) }
            w.put(self.chargingMaximumVoltage, 87)
            w.put(self.cellsInSeries, 89)
            w.put(self.dischargeMaximumCurrent, 90)
            w.put(self.dischargeMaximumBurstCurrent, 94)
            for k in 0..<Swift.min(11, self.manufactureDate.count) { w.put(self.manufactureDate[k], 98 + k * 1) }
        }
    }
}

/// GENERATOR_STATUS (#373)
extension MAV {
    public struct GeneratorStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 373, name: "GENERATOR_STATUS", crcExtra: 117, minLength: 42, length: 42)
        public var status: UInt64
        public var batteryCurrent: Float
        public var loadCurrent: Float
        public var powerGenerated: Float
        public var busVoltage: Float
        public var batCurrentSetpoint: Float
        public var runtime: UInt32
        public var timeUntilMaintenance: Int32
        public var generatorSpeed: UInt16
        public var rectifierTemperature: Int16
        public var generatorTemperature: Int16

        public init(status: UInt64 = 0, batteryCurrent: Float = 0, loadCurrent: Float = 0, powerGenerated: Float = 0, busVoltage: Float = 0, batCurrentSetpoint: Float = 0, runtime: UInt32 = 0, timeUntilMaintenance: Int32 = 0, generatorSpeed: UInt16 = 0, rectifierTemperature: Int16 = 0, generatorTemperature: Int16 = 0) {
            self.status = status
            self.batteryCurrent = batteryCurrent
            self.loadCurrent = loadCurrent
            self.powerGenerated = powerGenerated
            self.busVoltage = busVoltage
            self.batCurrentSetpoint = batCurrentSetpoint
            self.runtime = runtime
            self.timeUntilMaintenance = timeUntilMaintenance
            self.generatorSpeed = generatorSpeed
            self.rectifierTemperature = rectifierTemperature
            self.generatorTemperature = generatorTemperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.status = p.uint64(0)
            self.batteryCurrent = p.float(8)
            self.loadCurrent = p.float(12)
            self.powerGenerated = p.float(16)
            self.busVoltage = p.float(20)
            self.batCurrentSetpoint = p.float(24)
            self.runtime = p.uint32(28)
            self.timeUntilMaintenance = p.int32(32)
            self.generatorSpeed = p.uint16(36)
            self.rectifierTemperature = p.int16(38)
            self.generatorTemperature = p.int16(40)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.status, 0)
            w.put(self.batteryCurrent, 8)
            w.put(self.loadCurrent, 12)
            w.put(self.powerGenerated, 16)
            w.put(self.busVoltage, 20)
            w.put(self.batCurrentSetpoint, 24)
            w.put(self.runtime, 28)
            w.put(self.timeUntilMaintenance, 32)
            w.put(self.generatorSpeed, 36)
            w.put(self.rectifierTemperature, 38)
            w.put(self.generatorTemperature, 40)
        }
    }
}

/// ACTUATOR_OUTPUT_STATUS (#375)
extension MAV {
    public struct ActuatorOutputStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 375, name: "ACTUATOR_OUTPUT_STATUS", crcExtra: 251, minLength: 140, length: 140)
        public var timeUsec: UInt64
        public var active: UInt32
        public var actuator: [Float]

        public init(timeUsec: UInt64 = 0, active: UInt32 = 0, actuator: [Float] = [Float](repeating: 0, count: 32)) {
            self.timeUsec = timeUsec
            self.active = active
            self.actuator = actuator
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.active = p.uint32(8)
            self.actuator = (0..<32).map { p.float(12 + $0 * 4) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.active, 8)
            for k in 0..<Swift.min(32, self.actuator.count) { w.put(self.actuator[k], 12 + k * 4) }
        }
    }
}

/// RELAY_STATUS (#376)
extension MAV {
    public struct RelayStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 376, name: "RELAY_STATUS", crcExtra: 199, minLength: 8, length: 8)
        public var timeBootMs: UInt32
        public var on: UInt16
        public var present: UInt16

        public init(timeBootMs: UInt32 = 0, on: UInt16 = 0, present: UInt16 = 0) {
            self.timeBootMs = timeBootMs
            self.on = on
            self.present = present
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.on = p.uint16(4)
            self.present = p.uint16(6)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.on, 4)
            w.put(self.present, 6)
        }
    }
}

/// TUNNEL (#385)
extension MAV {
    public struct Tunnel: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 385, name: "TUNNEL", crcExtra: 147, minLength: 133, length: 133)
        public var payloadType: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var payloadLength: UInt8
        public var payload: [UInt8]

        public init(payloadType: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, payloadLength: UInt8 = 0, payload: [UInt8] = [UInt8](repeating: 0, count: 128)) {
            self.payloadType = payloadType
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.payloadLength = payloadLength
            self.payload = payload
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.payloadType = p.uint16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
            self.payloadLength = p.uint8(4)
            self.payload = (0..<128).map { p.uint8(5 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.payloadType, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
            w.put(self.payloadLength, 4)
            for k in 0..<Swift.min(128, self.payload.count) { w.put(self.payload[k], 5 + k * 1) }
        }
    }
}

/// CAN_FRAME (#386)
extension MAV {
    public struct CanFrame: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 386, name: "CAN_FRAME", crcExtra: 132, minLength: 16, length: 16)
        public var id: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var bus: UInt8
        public var len: UInt8
        public var data: [UInt8]

        public init(id: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, bus: UInt8 = 0, len: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 8)) {
            self.id = id
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.bus = bus
            self.len = len
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.id = p.uint32(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.bus = p.uint8(6)
            self.len = p.uint8(7)
            self.data = (0..<8).map { p.uint8(8 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.id, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            w.put(self.bus, 6)
            w.put(self.len, 7)
            for k in 0..<Swift.min(8, self.data.count) { w.put(self.data[k], 8 + k * 1) }
        }
    }
}

/// CANFD_FRAME (#387)
extension MAV {
    public struct CanfdFrame: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 387, name: "CANFD_FRAME", crcExtra: 4, minLength: 72, length: 72)
        public var id: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var bus: UInt8
        public var len: UInt8
        public var data: [UInt8]

        public init(id: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, bus: UInt8 = 0, len: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 64)) {
            self.id = id
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.bus = bus
            self.len = len
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.id = p.uint32(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.bus = p.uint8(6)
            self.len = p.uint8(7)
            self.data = (0..<64).map { p.uint8(8 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.id, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            w.put(self.bus, 6)
            w.put(self.len, 7)
            for k in 0..<Swift.min(64, self.data.count) { w.put(self.data[k], 8 + k * 1) }
        }
    }
}

/// CAN_FILTER_MODIFY (#388)
extension MAV {
    public struct CanFilterModify: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 388, name: "CAN_FILTER_MODIFY", crcExtra: 8, minLength: 37, length: 37)
        public var ids: [UInt16]
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var bus: UInt8
        public var operation: UInt8
        public var numIds: UInt8

        public init(ids: [UInt16] = [UInt16](repeating: 0, count: 16), targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, bus: UInt8 = 0, operation: UInt8 = 0, numIds: UInt8 = 0) {
            self.ids = ids
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.bus = bus
            self.operation = operation
            self.numIds = numIds
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.ids = (0..<16).map { p.uint16(0 + $0 * 2) }
            self.targetSystem = p.uint8(32)
            self.targetComponent = p.uint8(33)
            self.bus = p.uint8(34)
            self.operation = p.uint8(35)
            self.numIds = p.uint8(36)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(16, self.ids.count) { w.put(self.ids[k], 0 + k * 2) }
            w.put(self.targetSystem, 32)
            w.put(self.targetComponent, 33)
            w.put(self.bus, 34)
            w.put(self.operation, 35)
            w.put(self.numIds, 36)
        }
    }
}

/// RADIO_RC_CHANNELS (#420)
extension MAV {
    public struct RadioRcChannels: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 420, name: "RADIO_RC_CHANNELS", crcExtra: 20, minLength: 9, length: 73)
        public var timeLastUpdateMs: UInt32
        public var flags: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var count: UInt8
        public var channels: [Int16]  // extension field

        public init(timeLastUpdateMs: UInt32 = 0, flags: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, count: UInt8 = 0, channels: [Int16] = [Int16](repeating: 0, count: 32)) {
            self.timeLastUpdateMs = timeLastUpdateMs
            self.flags = flags
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.count = count
            self.channels = channels
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeLastUpdateMs = p.uint32(0)
            self.flags = p.uint16(4)
            self.targetSystem = p.uint8(6)
            self.targetComponent = p.uint8(7)
            self.count = p.uint8(8)
            self.channels = (0..<32).map { p.int16(9 + $0 * 2) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeLastUpdateMs, 0)
            w.put(self.flags, 4)
            w.put(self.targetSystem, 6)
            w.put(self.targetComponent, 7)
            w.put(self.count, 8)
            for k in 0..<Swift.min(32, self.channels.count) { w.put(self.channels[k], 9 + k * 2) }
        }
    }
}

/// AVAILABLE_MODES (#435)
extension MAV {
    public struct AvailableModes: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 435, name: "AVAILABLE_MODES", crcExtra: 134, minLength: 46, length: 46)
        public var customMode: UInt32
        public var properties: UInt32
        public var numberModes: UInt8
        public var modeIndex: UInt8
        public var standardMode: UInt8
        public var modeName: [UInt8]

        public init(customMode: UInt32 = 0, properties: UInt32 = 0, numberModes: UInt8 = 0, modeIndex: UInt8 = 0, standardMode: UInt8 = 0, modeName: [UInt8] = [UInt8](repeating: 0, count: 35)) {
            self.customMode = customMode
            self.properties = properties
            self.numberModes = numberModes
            self.modeIndex = modeIndex
            self.standardMode = standardMode
            self.modeName = modeName
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.customMode = p.uint32(0)
            self.properties = p.uint32(4)
            self.numberModes = p.uint8(8)
            self.modeIndex = p.uint8(9)
            self.standardMode = p.uint8(10)
            self.modeName = (0..<35).map { p.uint8(11 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.customMode, 0)
            w.put(self.properties, 4)
            w.put(self.numberModes, 8)
            w.put(self.modeIndex, 9)
            w.put(self.standardMode, 10)
            for k in 0..<Swift.min(35, self.modeName.count) { w.put(self.modeName[k], 11 + k * 1) }
        }
    }
}

/// CURRENT_MODE (#436)
extension MAV {
    public struct CurrentMode: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 436, name: "CURRENT_MODE", crcExtra: 193, minLength: 9, length: 9)
        public var customMode: UInt32
        public var intendedCustomMode: UInt32
        public var standardMode: UInt8

        public init(customMode: UInt32 = 0, intendedCustomMode: UInt32 = 0, standardMode: UInt8 = 0) {
            self.customMode = customMode
            self.intendedCustomMode = intendedCustomMode
            self.standardMode = standardMode
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.customMode = p.uint32(0)
            self.intendedCustomMode = p.uint32(4)
            self.standardMode = p.uint8(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.customMode, 0)
            w.put(self.intendedCustomMode, 4)
            w.put(self.standardMode, 8)
        }
    }
}

/// AVAILABLE_MODES_MONITOR (#437)
extension MAV {
    public struct AvailableModesMonitor: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 437, name: "AVAILABLE_MODES_MONITOR", crcExtra: 30, minLength: 1, length: 1)
        public var seq: UInt8

        public init(seq: UInt8 = 0) {
            self.seq = seq
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.seq = p.uint8(0)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.seq, 0)
        }
    }
}

/// GNSS_INTEGRITY (#441)
extension MAV {
    public struct GnssIntegrity: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 441, name: "GNSS_INTEGRITY", crcExtra: 169, minLength: 17, length: 17)
        public var systemErrors: UInt32
        public var raimHfom: UInt16
        public var raimVfom: UInt16
        public var id: UInt8
        public var authenticationState: UInt8
        public var jammingState: UInt8
        public var spoofingState: UInt8
        public var raimState: UInt8
        public var correctionsQuality: UInt8
        public var systemStatusSummary: UInt8
        public var gnssSignalQuality: UInt8
        public var postProcessingQuality: UInt8

        public init(systemErrors: UInt32 = 0, raimHfom: UInt16 = 0, raimVfom: UInt16 = 0, id: UInt8 = 0, authenticationState: UInt8 = 0, jammingState: UInt8 = 0, spoofingState: UInt8 = 0, raimState: UInt8 = 0, correctionsQuality: UInt8 = 0, systemStatusSummary: UInt8 = 0, gnssSignalQuality: UInt8 = 0, postProcessingQuality: UInt8 = 0) {
            self.systemErrors = systemErrors
            self.raimHfom = raimHfom
            self.raimVfom = raimVfom
            self.id = id
            self.authenticationState = authenticationState
            self.jammingState = jammingState
            self.spoofingState = spoofingState
            self.raimState = raimState
            self.correctionsQuality = correctionsQuality
            self.systemStatusSummary = systemStatusSummary
            self.gnssSignalQuality = gnssSignalQuality
            self.postProcessingQuality = postProcessingQuality
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.systemErrors = p.uint32(0)
            self.raimHfom = p.uint16(4)
            self.raimVfom = p.uint16(6)
            self.id = p.uint8(8)
            self.authenticationState = p.uint8(9)
            self.jammingState = p.uint8(10)
            self.spoofingState = p.uint8(11)
            self.raimState = p.uint8(12)
            self.correctionsQuality = p.uint8(13)
            self.systemStatusSummary = p.uint8(14)
            self.gnssSignalQuality = p.uint8(15)
            self.postProcessingQuality = p.uint8(16)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.systemErrors, 0)
            w.put(self.raimHfom, 4)
            w.put(self.raimVfom, 6)
            w.put(self.id, 8)
            w.put(self.authenticationState, 9)
            w.put(self.jammingState, 10)
            w.put(self.spoofingState, 11)
            w.put(self.raimState, 12)
            w.put(self.correctionsQuality, 13)
            w.put(self.systemStatusSummary, 14)
            w.put(self.gnssSignalQuality, 15)
            w.put(self.postProcessingQuality, 16)
        }
    }
}

/// SENS_POWER (#8002)
extension MAV {
    public struct SensPower: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8002, name: "SENS_POWER", crcExtra: 218, minLength: 16, length: 16)
        public var adc121VspbVolt: Float
        public var adc121CspbAmp: Float
        public var adc121Cs1Amp: Float
        public var adc121Cs2Amp: Float

        public init(adc121VspbVolt: Float = 0, adc121CspbAmp: Float = 0, adc121Cs1Amp: Float = 0, adc121Cs2Amp: Float = 0) {
            self.adc121VspbVolt = adc121VspbVolt
            self.adc121CspbAmp = adc121CspbAmp
            self.adc121Cs1Amp = adc121Cs1Amp
            self.adc121Cs2Amp = adc121Cs2Amp
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.adc121VspbVolt = p.float(0)
            self.adc121CspbAmp = p.float(4)
            self.adc121Cs1Amp = p.float(8)
            self.adc121Cs2Amp = p.float(12)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.adc121VspbVolt, 0)
            w.put(self.adc121CspbAmp, 4)
            w.put(self.adc121Cs1Amp, 8)
            w.put(self.adc121Cs2Amp, 12)
        }
    }
}

/// SENS_MPPT (#8003)
extension MAV {
    public struct SensMppt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8003, name: "SENS_MPPT", crcExtra: 231, minLength: 41, length: 41)
        public var mpptTimestamp: UInt64
        public var mppt1Volt: Float
        public var mppt1Amp: Float
        public var mppt2Volt: Float
        public var mppt2Amp: Float
        public var mppt3Volt: Float
        public var mppt3Amp: Float
        public var mppt1Pwm: UInt16
        public var mppt2Pwm: UInt16
        public var mppt3Pwm: UInt16
        public var mppt1Status: UInt8
        public var mppt2Status: UInt8
        public var mppt3Status: UInt8

        public init(mpptTimestamp: UInt64 = 0, mppt1Volt: Float = 0, mppt1Amp: Float = 0, mppt2Volt: Float = 0, mppt2Amp: Float = 0, mppt3Volt: Float = 0, mppt3Amp: Float = 0, mppt1Pwm: UInt16 = 0, mppt2Pwm: UInt16 = 0, mppt3Pwm: UInt16 = 0, mppt1Status: UInt8 = 0, mppt2Status: UInt8 = 0, mppt3Status: UInt8 = 0) {
            self.mpptTimestamp = mpptTimestamp
            self.mppt1Volt = mppt1Volt
            self.mppt1Amp = mppt1Amp
            self.mppt2Volt = mppt2Volt
            self.mppt2Amp = mppt2Amp
            self.mppt3Volt = mppt3Volt
            self.mppt3Amp = mppt3Amp
            self.mppt1Pwm = mppt1Pwm
            self.mppt2Pwm = mppt2Pwm
            self.mppt3Pwm = mppt3Pwm
            self.mppt1Status = mppt1Status
            self.mppt2Status = mppt2Status
            self.mppt3Status = mppt3Status
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.mpptTimestamp = p.uint64(0)
            self.mppt1Volt = p.float(8)
            self.mppt1Amp = p.float(12)
            self.mppt2Volt = p.float(16)
            self.mppt2Amp = p.float(20)
            self.mppt3Volt = p.float(24)
            self.mppt3Amp = p.float(28)
            self.mppt1Pwm = p.uint16(32)
            self.mppt2Pwm = p.uint16(34)
            self.mppt3Pwm = p.uint16(36)
            self.mppt1Status = p.uint8(38)
            self.mppt2Status = p.uint8(39)
            self.mppt3Status = p.uint8(40)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.mpptTimestamp, 0)
            w.put(self.mppt1Volt, 8)
            w.put(self.mppt1Amp, 12)
            w.put(self.mppt2Volt, 16)
            w.put(self.mppt2Amp, 20)
            w.put(self.mppt3Volt, 24)
            w.put(self.mppt3Amp, 28)
            w.put(self.mppt1Pwm, 32)
            w.put(self.mppt2Pwm, 34)
            w.put(self.mppt3Pwm, 36)
            w.put(self.mppt1Status, 38)
            w.put(self.mppt2Status, 39)
            w.put(self.mppt3Status, 40)
        }
    }
}

/// ASLCTRL_DATA (#8004)
extension MAV {
    public struct AslctrlData: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8004, name: "ASLCTRL_DATA", crcExtra: 172, minLength: 98, length: 98)
        public var timestamp: UInt64
        public var h: Float
        public var hRef: Float
        public var hRefT: Float
        public var PitchAngle: Float
        public var PitchAngleRef: Float
        public var q: Float
        public var qRef: Float
        public var uElev: Float
        public var uThrot: Float
        public var uThrot2: Float
        public var nZ: Float
        public var AirspeedRef: Float
        public var YawAngle: Float
        public var YawAngleRef: Float
        public var RollAngle: Float
        public var RollAngleRef: Float
        public var p: Float
        public var pRef: Float
        public var r: Float
        public var rRef: Float
        public var uAil: Float
        public var uRud: Float
        public var aslctrlMode: UInt8
        public var SpoilersEngaged: UInt8

        public init(timestamp: UInt64 = 0, h: Float = 0, hRef: Float = 0, hRefT: Float = 0, PitchAngle: Float = 0, PitchAngleRef: Float = 0, q: Float = 0, qRef: Float = 0, uElev: Float = 0, uThrot: Float = 0, uThrot2: Float = 0, nZ: Float = 0, AirspeedRef: Float = 0, YawAngle: Float = 0, YawAngleRef: Float = 0, RollAngle: Float = 0, RollAngleRef: Float = 0, p: Float = 0, pRef: Float = 0, r: Float = 0, rRef: Float = 0, uAil: Float = 0, uRud: Float = 0, aslctrlMode: UInt8 = 0, SpoilersEngaged: UInt8 = 0) {
            self.timestamp = timestamp
            self.h = h
            self.hRef = hRef
            self.hRefT = hRefT
            self.PitchAngle = PitchAngle
            self.PitchAngleRef = PitchAngleRef
            self.q = q
            self.qRef = qRef
            self.uElev = uElev
            self.uThrot = uThrot
            self.uThrot2 = uThrot2
            self.nZ = nZ
            self.AirspeedRef = AirspeedRef
            self.YawAngle = YawAngle
            self.YawAngleRef = YawAngleRef
            self.RollAngle = RollAngle
            self.RollAngleRef = RollAngleRef
            self.p = p
            self.pRef = pRef
            self.r = r
            self.rRef = rRef
            self.uAil = uAil
            self.uRud = uRud
            self.aslctrlMode = aslctrlMode
            self.SpoilersEngaged = SpoilersEngaged
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.h = p.float(8)
            self.hRef = p.float(12)
            self.hRefT = p.float(16)
            self.PitchAngle = p.float(20)
            self.PitchAngleRef = p.float(24)
            self.q = p.float(28)
            self.qRef = p.float(32)
            self.uElev = p.float(36)
            self.uThrot = p.float(40)
            self.uThrot2 = p.float(44)
            self.nZ = p.float(48)
            self.AirspeedRef = p.float(52)
            self.YawAngle = p.float(56)
            self.YawAngleRef = p.float(60)
            self.RollAngle = p.float(64)
            self.RollAngleRef = p.float(68)
            self.p = p.float(72)
            self.pRef = p.float(76)
            self.r = p.float(80)
            self.rRef = p.float(84)
            self.uAil = p.float(88)
            self.uRud = p.float(92)
            self.aslctrlMode = p.uint8(96)
            self.SpoilersEngaged = p.uint8(97)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.h, 8)
            w.put(self.hRef, 12)
            w.put(self.hRefT, 16)
            w.put(self.PitchAngle, 20)
            w.put(self.PitchAngleRef, 24)
            w.put(self.q, 28)
            w.put(self.qRef, 32)
            w.put(self.uElev, 36)
            w.put(self.uThrot, 40)
            w.put(self.uThrot2, 44)
            w.put(self.nZ, 48)
            w.put(self.AirspeedRef, 52)
            w.put(self.YawAngle, 56)
            w.put(self.YawAngleRef, 60)
            w.put(self.RollAngle, 64)
            w.put(self.RollAngleRef, 68)
            w.put(self.p, 72)
            w.put(self.pRef, 76)
            w.put(self.r, 80)
            w.put(self.rRef, 84)
            w.put(self.uAil, 88)
            w.put(self.uRud, 92)
            w.put(self.aslctrlMode, 96)
            w.put(self.SpoilersEngaged, 97)
        }
    }
}

/// ASLCTRL_DEBUG (#8005)
extension MAV {
    public struct AslctrlDebug: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8005, name: "ASLCTRL_DEBUG", crcExtra: 251, minLength: 38, length: 38)
        public var i321: UInt32
        public var f1: Float
        public var f2: Float
        public var f3: Float
        public var f4: Float
        public var f5: Float
        public var f6: Float
        public var f7: Float
        public var f8: Float
        public var i81: UInt8
        public var i82: UInt8

        public init(i321: UInt32 = 0, f1: Float = 0, f2: Float = 0, f3: Float = 0, f4: Float = 0, f5: Float = 0, f6: Float = 0, f7: Float = 0, f8: Float = 0, i81: UInt8 = 0, i82: UInt8 = 0) {
            self.i321 = i321
            self.f1 = f1
            self.f2 = f2
            self.f3 = f3
            self.f4 = f4
            self.f5 = f5
            self.f6 = f6
            self.f7 = f7
            self.f8 = f8
            self.i81 = i81
            self.i82 = i82
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.i321 = p.uint32(0)
            self.f1 = p.float(4)
            self.f2 = p.float(8)
            self.f3 = p.float(12)
            self.f4 = p.float(16)
            self.f5 = p.float(20)
            self.f6 = p.float(24)
            self.f7 = p.float(28)
            self.f8 = p.float(32)
            self.i81 = p.uint8(36)
            self.i82 = p.uint8(37)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.i321, 0)
            w.put(self.f1, 4)
            w.put(self.f2, 8)
            w.put(self.f3, 12)
            w.put(self.f4, 16)
            w.put(self.f5, 20)
            w.put(self.f6, 24)
            w.put(self.f7, 28)
            w.put(self.f8, 32)
            w.put(self.i81, 36)
            w.put(self.i82, 37)
        }
    }
}

/// ASLUAV_STATUS (#8006)
extension MAV {
    public struct AsluavStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8006, name: "ASLUAV_STATUS", crcExtra: 97, minLength: 14, length: 14)
        public var MotorRpm: Float
        public var LEDStatus: UInt8
        public var SATCOMStatus: UInt8
        public var ServoStatus: [UInt8]

        public init(MotorRpm: Float = 0, LEDStatus: UInt8 = 0, SATCOMStatus: UInt8 = 0, ServoStatus: [UInt8] = [UInt8](repeating: 0, count: 8)) {
            self.MotorRpm = MotorRpm
            self.LEDStatus = LEDStatus
            self.SATCOMStatus = SATCOMStatus
            self.ServoStatus = ServoStatus
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.MotorRpm = p.float(0)
            self.LEDStatus = p.uint8(4)
            self.SATCOMStatus = p.uint8(5)
            self.ServoStatus = (0..<8).map { p.uint8(6 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.MotorRpm, 0)
            w.put(self.LEDStatus, 4)
            w.put(self.SATCOMStatus, 5)
            for k in 0..<Swift.min(8, self.ServoStatus.count) { w.put(self.ServoStatus[k], 6 + k * 1) }
        }
    }
}

/// EKF_EXT (#8007)
extension MAV {
    public struct EkfExt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8007, name: "EKF_EXT", crcExtra: 64, minLength: 32, length: 32)
        public var timestamp: UInt64
        public var Windspeed: Float
        public var WindDir: Float
        public var WindZ: Float
        public var Airspeed: Float
        public var beta: Float
        public var alpha: Float

        public init(timestamp: UInt64 = 0, Windspeed: Float = 0, WindDir: Float = 0, WindZ: Float = 0, Airspeed: Float = 0, beta: Float = 0, alpha: Float = 0) {
            self.timestamp = timestamp
            self.Windspeed = Windspeed
            self.WindDir = WindDir
            self.WindZ = WindZ
            self.Airspeed = Airspeed
            self.beta = beta
            self.alpha = alpha
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.Windspeed = p.float(8)
            self.WindDir = p.float(12)
            self.WindZ = p.float(16)
            self.Airspeed = p.float(20)
            self.beta = p.float(24)
            self.alpha = p.float(28)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.Windspeed, 8)
            w.put(self.WindDir, 12)
            w.put(self.WindZ, 16)
            w.put(self.Airspeed, 20)
            w.put(self.beta, 24)
            w.put(self.alpha, 28)
        }
    }
}

/// ASL_OBCTRL (#8008)
extension MAV {
    public struct AslObctrl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8008, name: "ASL_OBCTRL", crcExtra: 234, minLength: 33, length: 33)
        public var timestamp: UInt64
        public var uElev: Float
        public var uThrot: Float
        public var uThrot2: Float
        public var uAilL: Float
        public var uAilR: Float
        public var uRud: Float
        public var obctrlStatus: UInt8

        public init(timestamp: UInt64 = 0, uElev: Float = 0, uThrot: Float = 0, uThrot2: Float = 0, uAilL: Float = 0, uAilR: Float = 0, uRud: Float = 0, obctrlStatus: UInt8 = 0) {
            self.timestamp = timestamp
            self.uElev = uElev
            self.uThrot = uThrot
            self.uThrot2 = uThrot2
            self.uAilL = uAilL
            self.uAilR = uAilR
            self.uRud = uRud
            self.obctrlStatus = obctrlStatus
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.uElev = p.float(8)
            self.uThrot = p.float(12)
            self.uThrot2 = p.float(16)
            self.uAilL = p.float(20)
            self.uAilR = p.float(24)
            self.uRud = p.float(28)
            self.obctrlStatus = p.uint8(32)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.uElev, 8)
            w.put(self.uThrot, 12)
            w.put(self.uThrot2, 16)
            w.put(self.uAilL, 20)
            w.put(self.uAilR, 24)
            w.put(self.uRud, 28)
            w.put(self.obctrlStatus, 32)
        }
    }
}

/// SENS_ATMOS (#8009)
extension MAV {
    public struct SensAtmos: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8009, name: "SENS_ATMOS", crcExtra: 144, minLength: 16, length: 16)
        public var timestamp: UInt64
        public var TempAmbient: Float
        public var Humidity: Float

        public init(timestamp: UInt64 = 0, TempAmbient: Float = 0, Humidity: Float = 0) {
            self.timestamp = timestamp
            self.TempAmbient = TempAmbient
            self.Humidity = Humidity
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.TempAmbient = p.float(8)
            self.Humidity = p.float(12)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.TempAmbient, 8)
            w.put(self.Humidity, 12)
        }
    }
}

/// SENS_BATMON (#8010)
extension MAV {
    public struct SensBatmon: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8010, name: "SENS_BATMON", crcExtra: 155, minLength: 41, length: 41)
        public var batmonTimestamp: UInt64
        public var temperature: Float
        public var safetystatus: UInt32
        public var operationstatus: UInt32
        public var voltage: UInt16
        public var current: Int16
        public var batterystatus: UInt16
        public var serialnumber: UInt16
        public var cellvoltage1: UInt16
        public var cellvoltage2: UInt16
        public var cellvoltage3: UInt16
        public var cellvoltage4: UInt16
        public var cellvoltage5: UInt16
        public var cellvoltage6: UInt16
        public var SoC: UInt8

        public init(batmonTimestamp: UInt64 = 0, temperature: Float = 0, safetystatus: UInt32 = 0, operationstatus: UInt32 = 0, voltage: UInt16 = 0, current: Int16 = 0, batterystatus: UInt16 = 0, serialnumber: UInt16 = 0, cellvoltage1: UInt16 = 0, cellvoltage2: UInt16 = 0, cellvoltage3: UInt16 = 0, cellvoltage4: UInt16 = 0, cellvoltage5: UInt16 = 0, cellvoltage6: UInt16 = 0, SoC: UInt8 = 0) {
            self.batmonTimestamp = batmonTimestamp
            self.temperature = temperature
            self.safetystatus = safetystatus
            self.operationstatus = operationstatus
            self.voltage = voltage
            self.current = current
            self.batterystatus = batterystatus
            self.serialnumber = serialnumber
            self.cellvoltage1 = cellvoltage1
            self.cellvoltage2 = cellvoltage2
            self.cellvoltage3 = cellvoltage3
            self.cellvoltage4 = cellvoltage4
            self.cellvoltage5 = cellvoltage5
            self.cellvoltage6 = cellvoltage6
            self.SoC = SoC
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.batmonTimestamp = p.uint64(0)
            self.temperature = p.float(8)
            self.safetystatus = p.uint32(12)
            self.operationstatus = p.uint32(16)
            self.voltage = p.uint16(20)
            self.current = p.int16(22)
            self.batterystatus = p.uint16(24)
            self.serialnumber = p.uint16(26)
            self.cellvoltage1 = p.uint16(28)
            self.cellvoltage2 = p.uint16(30)
            self.cellvoltage3 = p.uint16(32)
            self.cellvoltage4 = p.uint16(34)
            self.cellvoltage5 = p.uint16(36)
            self.cellvoltage6 = p.uint16(38)
            self.SoC = p.uint8(40)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.batmonTimestamp, 0)
            w.put(self.temperature, 8)
            w.put(self.safetystatus, 12)
            w.put(self.operationstatus, 16)
            w.put(self.voltage, 20)
            w.put(self.current, 22)
            w.put(self.batterystatus, 24)
            w.put(self.serialnumber, 26)
            w.put(self.cellvoltage1, 28)
            w.put(self.cellvoltage2, 30)
            w.put(self.cellvoltage3, 32)
            w.put(self.cellvoltage4, 34)
            w.put(self.cellvoltage5, 36)
            w.put(self.cellvoltage6, 38)
            w.put(self.SoC, 40)
        }
    }
}

/// FW_SOARING_DATA (#8011)
extension MAV {
    public struct FwSoaringData: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8011, name: "FW_SOARING_DATA", crcExtra: 20, minLength: 102, length: 102)
        public var timestamp: UInt64
        public var timestampModeChanged: UInt64
        public var xW: Float
        public var xR: Float
        public var xLat: Float
        public var xLon: Float
        public var VarW: Float
        public var VarR: Float
        public var VarLat: Float
        public var VarLon: Float
        public var LoiterRadius: Float
        public var LoiterDirection: Float
        public var DistToSoarPoint: Float
        public var vSinkExp: Float
        public var z1LocalUpdraftSpeed: Float
        public var z2DeltaRoll: Float
        public var z1Exp: Float
        public var z2Exp: Float
        public var ThermalGSNorth: Float
        public var ThermalGSEast: Float
        public var TSEDot: Float
        public var DebugVar1: Float
        public var DebugVar2: Float
        public var ControlMode: UInt8
        public var valid: UInt8

        public init(timestamp: UInt64 = 0, timestampModeChanged: UInt64 = 0, xW: Float = 0, xR: Float = 0, xLat: Float = 0, xLon: Float = 0, VarW: Float = 0, VarR: Float = 0, VarLat: Float = 0, VarLon: Float = 0, LoiterRadius: Float = 0, LoiterDirection: Float = 0, DistToSoarPoint: Float = 0, vSinkExp: Float = 0, z1LocalUpdraftSpeed: Float = 0, z2DeltaRoll: Float = 0, z1Exp: Float = 0, z2Exp: Float = 0, ThermalGSNorth: Float = 0, ThermalGSEast: Float = 0, TSEDot: Float = 0, DebugVar1: Float = 0, DebugVar2: Float = 0, ControlMode: UInt8 = 0, valid: UInt8 = 0) {
            self.timestamp = timestamp
            self.timestampModeChanged = timestampModeChanged
            self.xW = xW
            self.xR = xR
            self.xLat = xLat
            self.xLon = xLon
            self.VarW = VarW
            self.VarR = VarR
            self.VarLat = VarLat
            self.VarLon = VarLon
            self.LoiterRadius = LoiterRadius
            self.LoiterDirection = LoiterDirection
            self.DistToSoarPoint = DistToSoarPoint
            self.vSinkExp = vSinkExp
            self.z1LocalUpdraftSpeed = z1LocalUpdraftSpeed
            self.z2DeltaRoll = z2DeltaRoll
            self.z1Exp = z1Exp
            self.z2Exp = z2Exp
            self.ThermalGSNorth = ThermalGSNorth
            self.ThermalGSEast = ThermalGSEast
            self.TSEDot = TSEDot
            self.DebugVar1 = DebugVar1
            self.DebugVar2 = DebugVar2
            self.ControlMode = ControlMode
            self.valid = valid
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.timestampModeChanged = p.uint64(8)
            self.xW = p.float(16)
            self.xR = p.float(20)
            self.xLat = p.float(24)
            self.xLon = p.float(28)
            self.VarW = p.float(32)
            self.VarR = p.float(36)
            self.VarLat = p.float(40)
            self.VarLon = p.float(44)
            self.LoiterRadius = p.float(48)
            self.LoiterDirection = p.float(52)
            self.DistToSoarPoint = p.float(56)
            self.vSinkExp = p.float(60)
            self.z1LocalUpdraftSpeed = p.float(64)
            self.z2DeltaRoll = p.float(68)
            self.z1Exp = p.float(72)
            self.z2Exp = p.float(76)
            self.ThermalGSNorth = p.float(80)
            self.ThermalGSEast = p.float(84)
            self.TSEDot = p.float(88)
            self.DebugVar1 = p.float(92)
            self.DebugVar2 = p.float(96)
            self.ControlMode = p.uint8(100)
            self.valid = p.uint8(101)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.timestampModeChanged, 8)
            w.put(self.xW, 16)
            w.put(self.xR, 20)
            w.put(self.xLat, 24)
            w.put(self.xLon, 28)
            w.put(self.VarW, 32)
            w.put(self.VarR, 36)
            w.put(self.VarLat, 40)
            w.put(self.VarLon, 44)
            w.put(self.LoiterRadius, 48)
            w.put(self.LoiterDirection, 52)
            w.put(self.DistToSoarPoint, 56)
            w.put(self.vSinkExp, 60)
            w.put(self.z1LocalUpdraftSpeed, 64)
            w.put(self.z2DeltaRoll, 68)
            w.put(self.z1Exp, 72)
            w.put(self.z2Exp, 76)
            w.put(self.ThermalGSNorth, 80)
            w.put(self.ThermalGSEast, 84)
            w.put(self.TSEDot, 88)
            w.put(self.DebugVar1, 92)
            w.put(self.DebugVar2, 96)
            w.put(self.ControlMode, 100)
            w.put(self.valid, 101)
        }
    }
}

/// SENSORPOD_STATUS (#8012)
extension MAV {
    public struct SensorpodStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8012, name: "SENSORPOD_STATUS", crcExtra: 54, minLength: 16, length: 16)
        public var timestamp: UInt64
        public var freeSpace: UInt16
        public var visensorRate1: UInt8
        public var visensorRate2: UInt8
        public var visensorRate3: UInt8
        public var visensorRate4: UInt8
        public var recordingNodesCount: UInt8
        public var cpuTemp: UInt8

        public init(timestamp: UInt64 = 0, freeSpace: UInt16 = 0, visensorRate1: UInt8 = 0, visensorRate2: UInt8 = 0, visensorRate3: UInt8 = 0, visensorRate4: UInt8 = 0, recordingNodesCount: UInt8 = 0, cpuTemp: UInt8 = 0) {
            self.timestamp = timestamp
            self.freeSpace = freeSpace
            self.visensorRate1 = visensorRate1
            self.visensorRate2 = visensorRate2
            self.visensorRate3 = visensorRate3
            self.visensorRate4 = visensorRate4
            self.recordingNodesCount = recordingNodesCount
            self.cpuTemp = cpuTemp
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.freeSpace = p.uint16(8)
            self.visensorRate1 = p.uint8(10)
            self.visensorRate2 = p.uint8(11)
            self.visensorRate3 = p.uint8(12)
            self.visensorRate4 = p.uint8(13)
            self.recordingNodesCount = p.uint8(14)
            self.cpuTemp = p.uint8(15)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.freeSpace, 8)
            w.put(self.visensorRate1, 10)
            w.put(self.visensorRate2, 11)
            w.put(self.visensorRate3, 12)
            w.put(self.visensorRate4, 13)
            w.put(self.recordingNodesCount, 14)
            w.put(self.cpuTemp, 15)
        }
    }
}

/// SENS_POWER_BOARD (#8013)
extension MAV {
    public struct SensPowerBoard: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8013, name: "SENS_POWER_BOARD", crcExtra: 222, minLength: 46, length: 46)
        public var timestamp: UInt64
        public var pwrBrdSystemVolt: Float
        public var pwrBrdServoVolt: Float
        public var pwrBrdDigitalVolt: Float
        public var pwrBrdMotLAmp: Float
        public var pwrBrdMotRAmp: Float
        public var pwrBrdAnalogAmp: Float
        public var pwrBrdDigitalAmp: Float
        public var pwrBrdExtAmp: Float
        public var pwrBrdAuxAmp: Float
        public var pwrBrdStatus: UInt8
        public var pwrBrdLedStatus: UInt8

        public init(timestamp: UInt64 = 0, pwrBrdSystemVolt: Float = 0, pwrBrdServoVolt: Float = 0, pwrBrdDigitalVolt: Float = 0, pwrBrdMotLAmp: Float = 0, pwrBrdMotRAmp: Float = 0, pwrBrdAnalogAmp: Float = 0, pwrBrdDigitalAmp: Float = 0, pwrBrdExtAmp: Float = 0, pwrBrdAuxAmp: Float = 0, pwrBrdStatus: UInt8 = 0, pwrBrdLedStatus: UInt8 = 0) {
            self.timestamp = timestamp
            self.pwrBrdSystemVolt = pwrBrdSystemVolt
            self.pwrBrdServoVolt = pwrBrdServoVolt
            self.pwrBrdDigitalVolt = pwrBrdDigitalVolt
            self.pwrBrdMotLAmp = pwrBrdMotLAmp
            self.pwrBrdMotRAmp = pwrBrdMotRAmp
            self.pwrBrdAnalogAmp = pwrBrdAnalogAmp
            self.pwrBrdDigitalAmp = pwrBrdDigitalAmp
            self.pwrBrdExtAmp = pwrBrdExtAmp
            self.pwrBrdAuxAmp = pwrBrdAuxAmp
            self.pwrBrdStatus = pwrBrdStatus
            self.pwrBrdLedStatus = pwrBrdLedStatus
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.pwrBrdSystemVolt = p.float(8)
            self.pwrBrdServoVolt = p.float(12)
            self.pwrBrdDigitalVolt = p.float(16)
            self.pwrBrdMotLAmp = p.float(20)
            self.pwrBrdMotRAmp = p.float(24)
            self.pwrBrdAnalogAmp = p.float(28)
            self.pwrBrdDigitalAmp = p.float(32)
            self.pwrBrdExtAmp = p.float(36)
            self.pwrBrdAuxAmp = p.float(40)
            self.pwrBrdStatus = p.uint8(44)
            self.pwrBrdLedStatus = p.uint8(45)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.pwrBrdSystemVolt, 8)
            w.put(self.pwrBrdServoVolt, 12)
            w.put(self.pwrBrdDigitalVolt, 16)
            w.put(self.pwrBrdMotLAmp, 20)
            w.put(self.pwrBrdMotRAmp, 24)
            w.put(self.pwrBrdAnalogAmp, 28)
            w.put(self.pwrBrdDigitalAmp, 32)
            w.put(self.pwrBrdExtAmp, 36)
            w.put(self.pwrBrdAuxAmp, 40)
            w.put(self.pwrBrdStatus, 44)
            w.put(self.pwrBrdLedStatus, 45)
        }
    }
}

/// GSM_LINK_STATUS (#8014)
extension MAV {
    public struct GsmLinkStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8014, name: "GSM_LINK_STATUS", crcExtra: 200, minLength: 14, length: 14)
        public var timestamp: UInt64
        public var gsmModemType: UInt8
        public var gsmLinkType: UInt8
        public var rssi: UInt8
        public var rsrpRscp: UInt8
        public var sinrEcio: UInt8
        public var rsrq: UInt8

        public init(timestamp: UInt64 = 0, gsmModemType: UInt8 = 0, gsmLinkType: UInt8 = 0, rssi: UInt8 = 0, rsrpRscp: UInt8 = 0, sinrEcio: UInt8 = 0, rsrq: UInt8 = 0) {
            self.timestamp = timestamp
            self.gsmModemType = gsmModemType
            self.gsmLinkType = gsmLinkType
            self.rssi = rssi
            self.rsrpRscp = rsrpRscp
            self.sinrEcio = sinrEcio
            self.rsrq = rsrq
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.gsmModemType = p.uint8(8)
            self.gsmLinkType = p.uint8(9)
            self.rssi = p.uint8(10)
            self.rsrpRscp = p.uint8(11)
            self.sinrEcio = p.uint8(12)
            self.rsrq = p.uint8(13)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.gsmModemType, 8)
            w.put(self.gsmLinkType, 9)
            w.put(self.rssi, 10)
            w.put(self.rsrpRscp, 11)
            w.put(self.sinrEcio, 12)
            w.put(self.rsrq, 13)
        }
    }
}

/// SATCOM_LINK_STATUS (#8015)
extension MAV {
    public struct SatcomLinkStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8015, name: "SATCOM_LINK_STATUS", crcExtra: 23, minLength: 24, length: 24)
        public var timestamp: UInt64
        public var lastHeartbeat: UInt64
        public var failedSessions: UInt16
        public var successfulSessions: UInt16
        public var signalQuality: UInt8
        public var ringPending: UInt8
        public var txSessionPending: UInt8
        public var rxSessionPending: UInt8

        public init(timestamp: UInt64 = 0, lastHeartbeat: UInt64 = 0, failedSessions: UInt16 = 0, successfulSessions: UInt16 = 0, signalQuality: UInt8 = 0, ringPending: UInt8 = 0, txSessionPending: UInt8 = 0, rxSessionPending: UInt8 = 0) {
            self.timestamp = timestamp
            self.lastHeartbeat = lastHeartbeat
            self.failedSessions = failedSessions
            self.successfulSessions = successfulSessions
            self.signalQuality = signalQuality
            self.ringPending = ringPending
            self.txSessionPending = txSessionPending
            self.rxSessionPending = rxSessionPending
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.lastHeartbeat = p.uint64(8)
            self.failedSessions = p.uint16(16)
            self.successfulSessions = p.uint16(18)
            self.signalQuality = p.uint8(20)
            self.ringPending = p.uint8(21)
            self.txSessionPending = p.uint8(22)
            self.rxSessionPending = p.uint8(23)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.lastHeartbeat, 8)
            w.put(self.failedSessions, 16)
            w.put(self.successfulSessions, 18)
            w.put(self.signalQuality, 20)
            w.put(self.ringPending, 21)
            w.put(self.txSessionPending, 22)
            w.put(self.rxSessionPending, 23)
        }
    }
}

/// SENSOR_AIRFLOW_ANGLES (#8016)
extension MAV {
    public struct SensorAirflowAngles: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 8016, name: "SENSOR_AIRFLOW_ANGLES", crcExtra: 149, minLength: 18, length: 18)
        public var timestamp: UInt64
        public var angleofattack: Float
        public var sideslip: Float
        public var angleofattackValid: UInt8
        public var sideslipValid: UInt8

        public init(timestamp: UInt64 = 0, angleofattack: Float = 0, sideslip: Float = 0, angleofattackValid: UInt8 = 0, sideslipValid: UInt8 = 0) {
            self.timestamp = timestamp
            self.angleofattack = angleofattack
            self.sideslip = sideslip
            self.angleofattackValid = angleofattackValid
            self.sideslipValid = sideslipValid
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint64(0)
            self.angleofattack = p.float(8)
            self.sideslip = p.float(12)
            self.angleofattackValid = p.uint8(16)
            self.sideslipValid = p.uint8(17)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.angleofattack, 8)
            w.put(self.sideslip, 12)
            w.put(self.angleofattackValid, 16)
            w.put(self.sideslipValid, 17)
        }
    }
}

/// WHEEL_DISTANCE (#9000)
extension MAV {
    public struct WheelDistance: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 9000, name: "WHEEL_DISTANCE", crcExtra: 113, minLength: 137, length: 137)
        public var timeUsec: UInt64
        public var distance: [Double]
        public var count: UInt8

        public init(timeUsec: UInt64 = 0, distance: [Double] = [Double](repeating: 0, count: 16), count: UInt8 = 0) {
            self.timeUsec = timeUsec
            self.distance = distance
            self.count = count
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.distance = (0..<16).map { p.double(8 + $0 * 8) }
            self.count = p.uint8(136)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            for k in 0..<Swift.min(16, self.distance.count) { w.put(self.distance[k], 8 + k * 8) }
            w.put(self.count, 136)
        }
    }
}

/// WINCH_STATUS (#9005)
extension MAV {
    public struct WinchStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 9005, name: "WINCH_STATUS", crcExtra: 117, minLength: 34, length: 34)
        public var timeUsec: UInt64
        public var lineLength: Float
        public var speed: Float
        public var tension: Float
        public var voltage: Float
        public var current: Float
        public var status: UInt32
        public var temperature: Int16

        public init(timeUsec: UInt64 = 0, lineLength: Float = 0, speed: Float = 0, tension: Float = 0, voltage: Float = 0, current: Float = 0, status: UInt32 = 0, temperature: Int16 = 0) {
            self.timeUsec = timeUsec
            self.lineLength = lineLength
            self.speed = speed
            self.tension = tension
            self.voltage = voltage
            self.current = current
            self.status = status
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.lineLength = p.float(8)
            self.speed = p.float(12)
            self.tension = p.float(16)
            self.voltage = p.float(20)
            self.current = p.float(24)
            self.status = p.uint32(28)
            self.temperature = p.int16(32)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.lineLength, 8)
            w.put(self.speed, 12)
            w.put(self.tension, 16)
            w.put(self.voltage, 20)
            w.put(self.current, 24)
            w.put(self.status, 28)
            w.put(self.temperature, 32)
        }
    }
}

/// UAVIONIX_ADSB_OUT_CFG (#10001)
extension MAV {
    public struct UavionixAdsbOutCfg: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 10001, name: "UAVIONIX_ADSB_OUT_CFG", crcExtra: 209, minLength: 20, length: 20)
        public var ICAO: UInt32
        public var stallSpeed: UInt16
        public var callsign: [UInt8]
        public var emitterType: UInt8
        public var aircraftSize: UInt8
        public var gpsOffsetLat: UInt8
        public var gpsOffsetLon: UInt8
        public var rfSelect: UInt8

        public init(ICAO: UInt32 = 0, stallSpeed: UInt16 = 0, callsign: [UInt8] = [UInt8](repeating: 0, count: 9), emitterType: UInt8 = 0, aircraftSize: UInt8 = 0, gpsOffsetLat: UInt8 = 0, gpsOffsetLon: UInt8 = 0, rfSelect: UInt8 = 0) {
            self.ICAO = ICAO
            self.stallSpeed = stallSpeed
            self.callsign = callsign
            self.emitterType = emitterType
            self.aircraftSize = aircraftSize
            self.gpsOffsetLat = gpsOffsetLat
            self.gpsOffsetLon = gpsOffsetLon
            self.rfSelect = rfSelect
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.ICAO = p.uint32(0)
            self.stallSpeed = p.uint16(4)
            self.callsign = (0..<9).map { p.uint8(6 + $0 * 1) }
            self.emitterType = p.uint8(15)
            self.aircraftSize = p.uint8(16)
            self.gpsOffsetLat = p.uint8(17)
            self.gpsOffsetLon = p.uint8(18)
            self.rfSelect = p.uint8(19)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.ICAO, 0)
            w.put(self.stallSpeed, 4)
            for k in 0..<Swift.min(9, self.callsign.count) { w.put(self.callsign[k], 6 + k * 1) }
            w.put(self.emitterType, 15)
            w.put(self.aircraftSize, 16)
            w.put(self.gpsOffsetLat, 17)
            w.put(self.gpsOffsetLon, 18)
            w.put(self.rfSelect, 19)
        }
    }
}

/// UAVIONIX_ADSB_OUT_DYNAMIC (#10002)
extension MAV {
    public struct UavionixAdsbOutDynamic: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 10002, name: "UAVIONIX_ADSB_OUT_DYNAMIC", crcExtra: 186, minLength: 41, length: 41)
        public var utcTime: UInt32
        public var gpsLat: Int32
        public var gpsLon: Int32
        public var gpsAlt: Int32
        public var baroAltMSL: Int32
        public var accuracyHor: UInt32
        public var accuracyVert: UInt16
        public var accuracyVel: UInt16
        public var velVert: Int16
        public var velNS: Int16
        public var VelEW: Int16
        public var state: UInt16
        public var squawk: UInt16
        public var gpsFix: UInt8
        public var numSats: UInt8
        public var emergencyStatus: UInt8

        public init(utcTime: UInt32 = 0, gpsLat: Int32 = 0, gpsLon: Int32 = 0, gpsAlt: Int32 = 0, baroAltMSL: Int32 = 0, accuracyHor: UInt32 = 0, accuracyVert: UInt16 = 0, accuracyVel: UInt16 = 0, velVert: Int16 = 0, velNS: Int16 = 0, VelEW: Int16 = 0, state: UInt16 = 0, squawk: UInt16 = 0, gpsFix: UInt8 = 0, numSats: UInt8 = 0, emergencyStatus: UInt8 = 0) {
            self.utcTime = utcTime
            self.gpsLat = gpsLat
            self.gpsLon = gpsLon
            self.gpsAlt = gpsAlt
            self.baroAltMSL = baroAltMSL
            self.accuracyHor = accuracyHor
            self.accuracyVert = accuracyVert
            self.accuracyVel = accuracyVel
            self.velVert = velVert
            self.velNS = velNS
            self.VelEW = VelEW
            self.state = state
            self.squawk = squawk
            self.gpsFix = gpsFix
            self.numSats = numSats
            self.emergencyStatus = emergencyStatus
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.utcTime = p.uint32(0)
            self.gpsLat = p.int32(4)
            self.gpsLon = p.int32(8)
            self.gpsAlt = p.int32(12)
            self.baroAltMSL = p.int32(16)
            self.accuracyHor = p.uint32(20)
            self.accuracyVert = p.uint16(24)
            self.accuracyVel = p.uint16(26)
            self.velVert = p.int16(28)
            self.velNS = p.int16(30)
            self.VelEW = p.int16(32)
            self.state = p.uint16(34)
            self.squawk = p.uint16(36)
            self.gpsFix = p.uint8(38)
            self.numSats = p.uint8(39)
            self.emergencyStatus = p.uint8(40)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.utcTime, 0)
            w.put(self.gpsLat, 4)
            w.put(self.gpsLon, 8)
            w.put(self.gpsAlt, 12)
            w.put(self.baroAltMSL, 16)
            w.put(self.accuracyHor, 20)
            w.put(self.accuracyVert, 24)
            w.put(self.accuracyVel, 26)
            w.put(self.velVert, 28)
            w.put(self.velNS, 30)
            w.put(self.VelEW, 32)
            w.put(self.state, 34)
            w.put(self.squawk, 36)
            w.put(self.gpsFix, 38)
            w.put(self.numSats, 39)
            w.put(self.emergencyStatus, 40)
        }
    }
}

/// UAVIONIX_ADSB_TRANSCEIVER_HEALTH_REPORT (#10003)
extension MAV {
    public struct UavionixAdsbTransceiverHealthReport: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 10003, name: "UAVIONIX_ADSB_TRANSCEIVER_HEALTH_REPORT", crcExtra: 4, minLength: 1, length: 1)
        public var rfHealth: UInt8

        public init(rfHealth: UInt8 = 0) {
            self.rfHealth = rfHealth
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.rfHealth = p.uint8(0)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.rfHealth, 0)
        }
    }
}

/// UAVIONIX_ADSB_OUT_CFG_REGISTRATION (#10004)
extension MAV {
    public struct UavionixAdsbOutCfgRegistration: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 10004, name: "UAVIONIX_ADSB_OUT_CFG_REGISTRATION", crcExtra: 133, minLength: 9, length: 9)
        public var registration: [UInt8]

        public init(registration: [UInt8] = [UInt8](repeating: 0, count: 9)) {
            self.registration = registration
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.registration = (0..<9).map { p.uint8(0 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(9, self.registration.count) { w.put(self.registration[k], 0 + k * 1) }
        }
    }
}

/// UAVIONIX_ADSB_OUT_CFG_FLIGHTID (#10005)
extension MAV {
    public struct UavionixAdsbOutCfgFlightid: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 10005, name: "UAVIONIX_ADSB_OUT_CFG_FLIGHTID", crcExtra: 103, minLength: 9, length: 9)
        public var flightId: [UInt8]

        public init(flightId: [UInt8] = [UInt8](repeating: 0, count: 9)) {
            self.flightId = flightId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.flightId = (0..<9).map { p.uint8(0 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(9, self.flightId.count) { w.put(self.flightId[k], 0 + k * 1) }
        }
    }
}

/// UAVIONIX_ADSB_GET (#10006)
extension MAV {
    public struct UavionixAdsbGet: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 10006, name: "UAVIONIX_ADSB_GET", crcExtra: 193, minLength: 4, length: 4)
        public var ReqMessageId: UInt32

        public init(ReqMessageId: UInt32 = 0) {
            self.ReqMessageId = ReqMessageId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.ReqMessageId = p.uint32(0)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.ReqMessageId, 0)
        }
    }
}

/// UAVIONIX_ADSB_OUT_CONTROL (#10007)
extension MAV {
    public struct UavionixAdsbOutControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 10007, name: "UAVIONIX_ADSB_OUT_CONTROL", crcExtra: 71, minLength: 17, length: 17)
        public var baroAltMSL: Int32
        public var squawk: UInt16
        public var state: UInt8
        public var emergencyStatus: UInt8
        public var flightId: [UInt8]
        public var xBit: UInt8

        public init(baroAltMSL: Int32 = 0, squawk: UInt16 = 0, state: UInt8 = 0, emergencyStatus: UInt8 = 0, flightId: [UInt8] = [UInt8](repeating: 0, count: 8), xBit: UInt8 = 0) {
            self.baroAltMSL = baroAltMSL
            self.squawk = squawk
            self.state = state
            self.emergencyStatus = emergencyStatus
            self.flightId = flightId
            self.xBit = xBit
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.baroAltMSL = p.int32(0)
            self.squawk = p.uint16(4)
            self.state = p.uint8(6)
            self.emergencyStatus = p.uint8(7)
            self.flightId = (0..<8).map { p.uint8(8 + $0 * 1) }
            self.xBit = p.uint8(16)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.baroAltMSL, 0)
            w.put(self.squawk, 4)
            w.put(self.state, 6)
            w.put(self.emergencyStatus, 7)
            for k in 0..<Swift.min(8, self.flightId.count) { w.put(self.flightId[k], 8 + k * 1) }
            w.put(self.xBit, 16)
        }
    }
}

/// UAVIONIX_ADSB_OUT_STATUS (#10008)
extension MAV {
    public struct UavionixAdsbOutStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 10008, name: "UAVIONIX_ADSB_OUT_STATUS", crcExtra: 240, minLength: 14, length: 14)
        public var squawk: UInt16
        public var state: UInt8
        public var NICNACp: UInt8
        public var boardTemp: UInt8
        public var fault: UInt8
        public var flightId: [UInt8]

        public init(squawk: UInt16 = 0, state: UInt8 = 0, NICNACp: UInt8 = 0, boardTemp: UInt8 = 0, fault: UInt8 = 0, flightId: [UInt8] = [UInt8](repeating: 0, count: 8)) {
            self.squawk = squawk
            self.state = state
            self.NICNACp = NICNACp
            self.boardTemp = boardTemp
            self.fault = fault
            self.flightId = flightId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.squawk = p.uint16(0)
            self.state = p.uint8(2)
            self.NICNACp = p.uint8(3)
            self.boardTemp = p.uint8(4)
            self.fault = p.uint8(5)
            self.flightId = (0..<8).map { p.uint8(6 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.squawk, 0)
            w.put(self.state, 2)
            w.put(self.NICNACp, 3)
            w.put(self.boardTemp, 4)
            w.put(self.fault, 5)
            for k in 0..<Swift.min(8, self.flightId.count) { w.put(self.flightId[k], 6 + k * 1) }
        }
    }
}

/// LOWEHEISER_GOV_EFI (#10151)
extension MAV {
    public struct LoweheiserGovEfi: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 10151, name: "LOWEHEISER_GOV_EFI", crcExtra: 195, minLength: 85, length: 85)
        public var voltBatt: Float
        public var currBatt: Float
        public var currGen: Float
        public var currRot: Float
        public var fuelLevel: Float
        public var throttle: Float
        public var runtime: UInt32
        public var untilMaintenance: Int32
        public var rectifierTemp: Float
        public var generatorTemp: Float
        public var efiBatt: Float
        public var efiRpm: Float
        public var efiPw: Float
        public var efiFuelFlow: Float
        public var efiFuelConsumed: Float
        public var efiBaro: Float
        public var efiMat: Float
        public var efiClt: Float
        public var efiTps: Float
        public var efiExhaustGasTemperature: Float
        public var generatorStatus: UInt16
        public var efiStatus: UInt16
        public var efiIndex: UInt8

        public init(voltBatt: Float = 0, currBatt: Float = 0, currGen: Float = 0, currRot: Float = 0, fuelLevel: Float = 0, throttle: Float = 0, runtime: UInt32 = 0, untilMaintenance: Int32 = 0, rectifierTemp: Float = 0, generatorTemp: Float = 0, efiBatt: Float = 0, efiRpm: Float = 0, efiPw: Float = 0, efiFuelFlow: Float = 0, efiFuelConsumed: Float = 0, efiBaro: Float = 0, efiMat: Float = 0, efiClt: Float = 0, efiTps: Float = 0, efiExhaustGasTemperature: Float = 0, generatorStatus: UInt16 = 0, efiStatus: UInt16 = 0, efiIndex: UInt8 = 0) {
            self.voltBatt = voltBatt
            self.currBatt = currBatt
            self.currGen = currGen
            self.currRot = currRot
            self.fuelLevel = fuelLevel
            self.throttle = throttle
            self.runtime = runtime
            self.untilMaintenance = untilMaintenance
            self.rectifierTemp = rectifierTemp
            self.generatorTemp = generatorTemp
            self.efiBatt = efiBatt
            self.efiRpm = efiRpm
            self.efiPw = efiPw
            self.efiFuelFlow = efiFuelFlow
            self.efiFuelConsumed = efiFuelConsumed
            self.efiBaro = efiBaro
            self.efiMat = efiMat
            self.efiClt = efiClt
            self.efiTps = efiTps
            self.efiExhaustGasTemperature = efiExhaustGasTemperature
            self.generatorStatus = generatorStatus
            self.efiStatus = efiStatus
            self.efiIndex = efiIndex
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.voltBatt = p.float(0)
            self.currBatt = p.float(4)
            self.currGen = p.float(8)
            self.currRot = p.float(12)
            self.fuelLevel = p.float(16)
            self.throttle = p.float(20)
            self.runtime = p.uint32(24)
            self.untilMaintenance = p.int32(28)
            self.rectifierTemp = p.float(32)
            self.generatorTemp = p.float(36)
            self.efiBatt = p.float(40)
            self.efiRpm = p.float(44)
            self.efiPw = p.float(48)
            self.efiFuelFlow = p.float(52)
            self.efiFuelConsumed = p.float(56)
            self.efiBaro = p.float(60)
            self.efiMat = p.float(64)
            self.efiClt = p.float(68)
            self.efiTps = p.float(72)
            self.efiExhaustGasTemperature = p.float(76)
            self.generatorStatus = p.uint16(80)
            self.efiStatus = p.uint16(82)
            self.efiIndex = p.uint8(84)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.voltBatt, 0)
            w.put(self.currBatt, 4)
            w.put(self.currGen, 8)
            w.put(self.currRot, 12)
            w.put(self.fuelLevel, 16)
            w.put(self.throttle, 20)
            w.put(self.runtime, 24)
            w.put(self.untilMaintenance, 28)
            w.put(self.rectifierTemp, 32)
            w.put(self.generatorTemp, 36)
            w.put(self.efiBatt, 40)
            w.put(self.efiRpm, 44)
            w.put(self.efiPw, 48)
            w.put(self.efiFuelFlow, 52)
            w.put(self.efiFuelConsumed, 56)
            w.put(self.efiBaro, 60)
            w.put(self.efiMat, 64)
            w.put(self.efiClt, 68)
            w.put(self.efiTps, 72)
            w.put(self.efiExhaustGasTemperature, 76)
            w.put(self.generatorStatus, 80)
            w.put(self.efiStatus, 82)
            w.put(self.efiIndex, 84)
        }
    }
}

/// DEVICE_OP_READ (#11000)
extension MAV {
    public struct DeviceOpRead: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11000, name: "DEVICE_OP_READ", crcExtra: 134, minLength: 51, length: 52)
        public var requestId: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var bustype: UInt8
        public var bus: UInt8
        public var address: UInt8
        public var busname: [UInt8]
        public var regstart: UInt8
        public var count: UInt8
        public var bank: UInt8  // extension field

        public init(requestId: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, bustype: UInt8 = 0, bus: UInt8 = 0, address: UInt8 = 0, busname: [UInt8] = [UInt8](repeating: 0, count: 40), regstart: UInt8 = 0, count: UInt8 = 0, bank: UInt8 = 0) {
            self.requestId = requestId
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.bustype = bustype
            self.bus = bus
            self.address = address
            self.busname = busname
            self.regstart = regstart
            self.count = count
            self.bank = bank
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.requestId = p.uint32(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.bustype = p.uint8(6)
            self.bus = p.uint8(7)
            self.address = p.uint8(8)
            self.busname = (0..<40).map { p.uint8(9 + $0 * 1) }
            self.regstart = p.uint8(49)
            self.count = p.uint8(50)
            self.bank = p.uint8(51)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.requestId, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            w.put(self.bustype, 6)
            w.put(self.bus, 7)
            w.put(self.address, 8)
            for k in 0..<Swift.min(40, self.busname.count) { w.put(self.busname[k], 9 + k * 1) }
            w.put(self.regstart, 49)
            w.put(self.count, 50)
            w.put(self.bank, 51)
        }
    }
}

/// DEVICE_OP_READ_REPLY (#11001)
extension MAV {
    public struct DeviceOpReadReply: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11001, name: "DEVICE_OP_READ_REPLY", crcExtra: 15, minLength: 135, length: 136)
        public var requestId: UInt32
        public var result: UInt8
        public var regstart: UInt8
        public var count: UInt8
        public var data: [UInt8]
        public var bank: UInt8  // extension field

        public init(requestId: UInt32 = 0, result: UInt8 = 0, regstart: UInt8 = 0, count: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 128), bank: UInt8 = 0) {
            self.requestId = requestId
            self.result = result
            self.regstart = regstart
            self.count = count
            self.data = data
            self.bank = bank
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.requestId = p.uint32(0)
            self.result = p.uint8(4)
            self.regstart = p.uint8(5)
            self.count = p.uint8(6)
            self.data = (0..<128).map { p.uint8(7 + $0 * 1) }
            self.bank = p.uint8(135)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.requestId, 0)
            w.put(self.result, 4)
            w.put(self.regstart, 5)
            w.put(self.count, 6)
            for k in 0..<Swift.min(128, self.data.count) { w.put(self.data[k], 7 + k * 1) }
            w.put(self.bank, 135)
        }
    }
}

/// DEVICE_OP_WRITE (#11002)
extension MAV {
    public struct DeviceOpWrite: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11002, name: "DEVICE_OP_WRITE", crcExtra: 234, minLength: 179, length: 180)
        public var requestId: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var bustype: UInt8
        public var bus: UInt8
        public var address: UInt8
        public var busname: [UInt8]
        public var regstart: UInt8
        public var count: UInt8
        public var data: [UInt8]
        public var bank: UInt8  // extension field

        public init(requestId: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, bustype: UInt8 = 0, bus: UInt8 = 0, address: UInt8 = 0, busname: [UInt8] = [UInt8](repeating: 0, count: 40), regstart: UInt8 = 0, count: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 128), bank: UInt8 = 0) {
            self.requestId = requestId
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.bustype = bustype
            self.bus = bus
            self.address = address
            self.busname = busname
            self.regstart = regstart
            self.count = count
            self.data = data
            self.bank = bank
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.requestId = p.uint32(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.bustype = p.uint8(6)
            self.bus = p.uint8(7)
            self.address = p.uint8(8)
            self.busname = (0..<40).map { p.uint8(9 + $0 * 1) }
            self.regstart = p.uint8(49)
            self.count = p.uint8(50)
            self.data = (0..<128).map { p.uint8(51 + $0 * 1) }
            self.bank = p.uint8(179)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.requestId, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            w.put(self.bustype, 6)
            w.put(self.bus, 7)
            w.put(self.address, 8)
            for k in 0..<Swift.min(40, self.busname.count) { w.put(self.busname[k], 9 + k * 1) }
            w.put(self.regstart, 49)
            w.put(self.count, 50)
            for k in 0..<Swift.min(128, self.data.count) { w.put(self.data[k], 51 + k * 1) }
            w.put(self.bank, 179)
        }
    }
}

/// DEVICE_OP_WRITE_REPLY (#11003)
extension MAV {
    public struct DeviceOpWriteReply: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11003, name: "DEVICE_OP_WRITE_REPLY", crcExtra: 64, minLength: 5, length: 5)
        public var requestId: UInt32
        public var result: UInt8

        public init(requestId: UInt32 = 0, result: UInt8 = 0) {
            self.requestId = requestId
            self.result = result
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.requestId = p.uint32(0)
            self.result = p.uint8(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.requestId, 0)
            w.put(self.result, 4)
        }
    }
}

/// SECURE_COMMAND (#11004)
extension MAV {
    public struct SecureCommand: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11004, name: "SECURE_COMMAND", crcExtra: 11, minLength: 232, length: 232)
        public var sequence: UInt32
        public var operation: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var dataLength: UInt8
        public var sigLength: UInt8
        public var data: [UInt8]

        public init(sequence: UInt32 = 0, operation: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, dataLength: UInt8 = 0, sigLength: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 220)) {
            self.sequence = sequence
            self.operation = operation
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.dataLength = dataLength
            self.sigLength = sigLength
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.sequence = p.uint32(0)
            self.operation = p.uint32(4)
            self.targetSystem = p.uint8(8)
            self.targetComponent = p.uint8(9)
            self.dataLength = p.uint8(10)
            self.sigLength = p.uint8(11)
            self.data = (0..<220).map { p.uint8(12 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.sequence, 0)
            w.put(self.operation, 4)
            w.put(self.targetSystem, 8)
            w.put(self.targetComponent, 9)
            w.put(self.dataLength, 10)
            w.put(self.sigLength, 11)
            for k in 0..<Swift.min(220, self.data.count) { w.put(self.data[k], 12 + k * 1) }
        }
    }
}

/// SECURE_COMMAND_REPLY (#11005)
extension MAV {
    public struct SecureCommandReply: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11005, name: "SECURE_COMMAND_REPLY", crcExtra: 93, minLength: 230, length: 230)
        public var sequence: UInt32
        public var operation: UInt32
        public var result: UInt8
        public var dataLength: UInt8
        public var data: [UInt8]

        public init(sequence: UInt32 = 0, operation: UInt32 = 0, result: UInt8 = 0, dataLength: UInt8 = 0, data: [UInt8] = [UInt8](repeating: 0, count: 220)) {
            self.sequence = sequence
            self.operation = operation
            self.result = result
            self.dataLength = dataLength
            self.data = data
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.sequence = p.uint32(0)
            self.operation = p.uint32(4)
            self.result = p.uint8(8)
            self.dataLength = p.uint8(9)
            self.data = (0..<220).map { p.uint8(10 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.sequence, 0)
            w.put(self.operation, 4)
            w.put(self.result, 8)
            w.put(self.dataLength, 9)
            for k in 0..<Swift.min(220, self.data.count) { w.put(self.data[k], 10 + k * 1) }
        }
    }
}

/// ADAP_TUNING (#11010)
extension MAV {
    public struct AdapTuning: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11010, name: "ADAP_TUNING", crcExtra: 46, minLength: 49, length: 49)
        public var desired: Float
        public var achieved: Float
        public var error: Float
        public var theta: Float
        public var omega: Float
        public var sigma: Float
        public var thetaDot: Float
        public var omegaDot: Float
        public var sigmaDot: Float
        public var f: Float
        public var fDot: Float
        public var u: Float
        public var axis: UInt8

        public init(desired: Float = 0, achieved: Float = 0, error: Float = 0, theta: Float = 0, omega: Float = 0, sigma: Float = 0, thetaDot: Float = 0, omegaDot: Float = 0, sigmaDot: Float = 0, f: Float = 0, fDot: Float = 0, u: Float = 0, axis: UInt8 = 0) {
            self.desired = desired
            self.achieved = achieved
            self.error = error
            self.theta = theta
            self.omega = omega
            self.sigma = sigma
            self.thetaDot = thetaDot
            self.omegaDot = omegaDot
            self.sigmaDot = sigmaDot
            self.f = f
            self.fDot = fDot
            self.u = u
            self.axis = axis
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.desired = p.float(0)
            self.achieved = p.float(4)
            self.error = p.float(8)
            self.theta = p.float(12)
            self.omega = p.float(16)
            self.sigma = p.float(20)
            self.thetaDot = p.float(24)
            self.omegaDot = p.float(28)
            self.sigmaDot = p.float(32)
            self.f = p.float(36)
            self.fDot = p.float(40)
            self.u = p.float(44)
            self.axis = p.uint8(48)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.desired, 0)
            w.put(self.achieved, 4)
            w.put(self.error, 8)
            w.put(self.theta, 12)
            w.put(self.omega, 16)
            w.put(self.sigma, 20)
            w.put(self.thetaDot, 24)
            w.put(self.omegaDot, 28)
            w.put(self.sigmaDot, 32)
            w.put(self.f, 36)
            w.put(self.fDot, 40)
            w.put(self.u, 44)
            w.put(self.axis, 48)
        }
    }
}

/// VISION_POSITION_DELTA (#11011)
extension MAV {
    public struct VisionPositionDelta: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11011, name: "VISION_POSITION_DELTA", crcExtra: 106, minLength: 44, length: 44)
        public var timeUsec: UInt64
        public var timeDeltaUsec: UInt64
        public var angleDelta: [Float]
        public var positionDelta: [Float]
        public var confidence: Float

        public init(timeUsec: UInt64 = 0, timeDeltaUsec: UInt64 = 0, angleDelta: [Float] = [Float](repeating: 0, count: 3), positionDelta: [Float] = [Float](repeating: 0, count: 3), confidence: Float = 0) {
            self.timeUsec = timeUsec
            self.timeDeltaUsec = timeDeltaUsec
            self.angleDelta = angleDelta
            self.positionDelta = positionDelta
            self.confidence = confidence
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.timeDeltaUsec = p.uint64(8)
            self.angleDelta = (0..<3).map { p.float(16 + $0 * 4) }
            self.positionDelta = (0..<3).map { p.float(28 + $0 * 4) }
            self.confidence = p.float(40)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.timeDeltaUsec, 8)
            for k in 0..<Swift.min(3, self.angleDelta.count) { w.put(self.angleDelta[k], 16 + k * 4) }
            for k in 0..<Swift.min(3, self.positionDelta.count) { w.put(self.positionDelta[k], 28 + k * 4) }
            w.put(self.confidence, 40)
        }
    }
}

/// AOA_SSA (#11020)
extension MAV {
    public struct AoaSsa: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11020, name: "AOA_SSA", crcExtra: 205, minLength: 16, length: 16)
        public var timeUsec: UInt64
        public var AOA: Float
        public var SSA: Float

        public init(timeUsec: UInt64 = 0, AOA: Float = 0, SSA: Float = 0) {
            self.timeUsec = timeUsec
            self.AOA = AOA
            self.SSA = SSA
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeUsec = p.uint64(0)
            self.AOA = p.float(8)
            self.SSA = p.float(12)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeUsec, 0)
            w.put(self.AOA, 8)
            w.put(self.SSA, 12)
        }
    }
}

/// ESC_TELEMETRY_1_TO_4 (#11030)
extension MAV {
    public struct EscTelemetry1To4: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11030, name: "ESC_TELEMETRY_1_TO_4", crcExtra: 144, minLength: 44, length: 44)
        public var voltage: [UInt16]
        public var current: [UInt16]
        public var totalcurrent: [UInt16]
        public var rpm: [UInt16]
        public var count: [UInt16]
        public var temperature: [UInt8]

        public init(voltage: [UInt16] = [UInt16](repeating: 0, count: 4), current: [UInt16] = [UInt16](repeating: 0, count: 4), totalcurrent: [UInt16] = [UInt16](repeating: 0, count: 4), rpm: [UInt16] = [UInt16](repeating: 0, count: 4), count: [UInt16] = [UInt16](repeating: 0, count: 4), temperature: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.voltage = voltage
            self.current = current
            self.totalcurrent = totalcurrent
            self.rpm = rpm
            self.count = count
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.voltage = (0..<4).map { p.uint16(0 + $0 * 2) }
            self.current = (0..<4).map { p.uint16(8 + $0 * 2) }
            self.totalcurrent = (0..<4).map { p.uint16(16 + $0 * 2) }
            self.rpm = (0..<4).map { p.uint16(24 + $0 * 2) }
            self.count = (0..<4).map { p.uint16(32 + $0 * 2) }
            self.temperature = (0..<4).map { p.uint8(40 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.voltage.count) { w.put(self.voltage[k], 0 + k * 2) }
            for k in 0..<Swift.min(4, self.current.count) { w.put(self.current[k], 8 + k * 2) }
            for k in 0..<Swift.min(4, self.totalcurrent.count) { w.put(self.totalcurrent[k], 16 + k * 2) }
            for k in 0..<Swift.min(4, self.rpm.count) { w.put(self.rpm[k], 24 + k * 2) }
            for k in 0..<Swift.min(4, self.count.count) { w.put(self.count[k], 32 + k * 2) }
            for k in 0..<Swift.min(4, self.temperature.count) { w.put(self.temperature[k], 40 + k * 1) }
        }
    }
}

/// ESC_TELEMETRY_5_TO_8 (#11031)
extension MAV {
    public struct EscTelemetry5To8: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11031, name: "ESC_TELEMETRY_5_TO_8", crcExtra: 133, minLength: 44, length: 44)
        public var voltage: [UInt16]
        public var current: [UInt16]
        public var totalcurrent: [UInt16]
        public var rpm: [UInt16]
        public var count: [UInt16]
        public var temperature: [UInt8]

        public init(voltage: [UInt16] = [UInt16](repeating: 0, count: 4), current: [UInt16] = [UInt16](repeating: 0, count: 4), totalcurrent: [UInt16] = [UInt16](repeating: 0, count: 4), rpm: [UInt16] = [UInt16](repeating: 0, count: 4), count: [UInt16] = [UInt16](repeating: 0, count: 4), temperature: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.voltage = voltage
            self.current = current
            self.totalcurrent = totalcurrent
            self.rpm = rpm
            self.count = count
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.voltage = (0..<4).map { p.uint16(0 + $0 * 2) }
            self.current = (0..<4).map { p.uint16(8 + $0 * 2) }
            self.totalcurrent = (0..<4).map { p.uint16(16 + $0 * 2) }
            self.rpm = (0..<4).map { p.uint16(24 + $0 * 2) }
            self.count = (0..<4).map { p.uint16(32 + $0 * 2) }
            self.temperature = (0..<4).map { p.uint8(40 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.voltage.count) { w.put(self.voltage[k], 0 + k * 2) }
            for k in 0..<Swift.min(4, self.current.count) { w.put(self.current[k], 8 + k * 2) }
            for k in 0..<Swift.min(4, self.totalcurrent.count) { w.put(self.totalcurrent[k], 16 + k * 2) }
            for k in 0..<Swift.min(4, self.rpm.count) { w.put(self.rpm[k], 24 + k * 2) }
            for k in 0..<Swift.min(4, self.count.count) { w.put(self.count[k], 32 + k * 2) }
            for k in 0..<Swift.min(4, self.temperature.count) { w.put(self.temperature[k], 40 + k * 1) }
        }
    }
}

/// ESC_TELEMETRY_9_TO_12 (#11032)
extension MAV {
    public struct EscTelemetry9To12: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11032, name: "ESC_TELEMETRY_9_TO_12", crcExtra: 85, minLength: 44, length: 44)
        public var voltage: [UInt16]
        public var current: [UInt16]
        public var totalcurrent: [UInt16]
        public var rpm: [UInt16]
        public var count: [UInt16]
        public var temperature: [UInt8]

        public init(voltage: [UInt16] = [UInt16](repeating: 0, count: 4), current: [UInt16] = [UInt16](repeating: 0, count: 4), totalcurrent: [UInt16] = [UInt16](repeating: 0, count: 4), rpm: [UInt16] = [UInt16](repeating: 0, count: 4), count: [UInt16] = [UInt16](repeating: 0, count: 4), temperature: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.voltage = voltage
            self.current = current
            self.totalcurrent = totalcurrent
            self.rpm = rpm
            self.count = count
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.voltage = (0..<4).map { p.uint16(0 + $0 * 2) }
            self.current = (0..<4).map { p.uint16(8 + $0 * 2) }
            self.totalcurrent = (0..<4).map { p.uint16(16 + $0 * 2) }
            self.rpm = (0..<4).map { p.uint16(24 + $0 * 2) }
            self.count = (0..<4).map { p.uint16(32 + $0 * 2) }
            self.temperature = (0..<4).map { p.uint8(40 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.voltage.count) { w.put(self.voltage[k], 0 + k * 2) }
            for k in 0..<Swift.min(4, self.current.count) { w.put(self.current[k], 8 + k * 2) }
            for k in 0..<Swift.min(4, self.totalcurrent.count) { w.put(self.totalcurrent[k], 16 + k * 2) }
            for k in 0..<Swift.min(4, self.rpm.count) { w.put(self.rpm[k], 24 + k * 2) }
            for k in 0..<Swift.min(4, self.count.count) { w.put(self.count[k], 32 + k * 2) }
            for k in 0..<Swift.min(4, self.temperature.count) { w.put(self.temperature[k], 40 + k * 1) }
        }
    }
}

/// OSD_PARAM_CONFIG (#11033)
extension MAV {
    public struct OsdParamConfig: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11033, name: "OSD_PARAM_CONFIG", crcExtra: 195, minLength: 37, length: 37)
        public var requestId: UInt32
        public var minValue: Float
        public var maxValue: Float
        public var increment: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var osdScreen: UInt8
        public var osdIndex: UInt8
        public var paramId: [UInt8]
        public var configType: UInt8

        public init(requestId: UInt32 = 0, minValue: Float = 0, maxValue: Float = 0, increment: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, osdScreen: UInt8 = 0, osdIndex: UInt8 = 0, paramId: [UInt8] = [UInt8](repeating: 0, count: 16), configType: UInt8 = 0) {
            self.requestId = requestId
            self.minValue = minValue
            self.maxValue = maxValue
            self.increment = increment
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.osdScreen = osdScreen
            self.osdIndex = osdIndex
            self.paramId = paramId
            self.configType = configType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.requestId = p.uint32(0)
            self.minValue = p.float(4)
            self.maxValue = p.float(8)
            self.increment = p.float(12)
            self.targetSystem = p.uint8(16)
            self.targetComponent = p.uint8(17)
            self.osdScreen = p.uint8(18)
            self.osdIndex = p.uint8(19)
            self.paramId = (0..<16).map { p.uint8(20 + $0 * 1) }
            self.configType = p.uint8(36)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.requestId, 0)
            w.put(self.minValue, 4)
            w.put(self.maxValue, 8)
            w.put(self.increment, 12)
            w.put(self.targetSystem, 16)
            w.put(self.targetComponent, 17)
            w.put(self.osdScreen, 18)
            w.put(self.osdIndex, 19)
            for k in 0..<Swift.min(16, self.paramId.count) { w.put(self.paramId[k], 20 + k * 1) }
            w.put(self.configType, 36)
        }
    }
}

/// OSD_PARAM_CONFIG_REPLY (#11034)
extension MAV {
    public struct OsdParamConfigReply: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11034, name: "OSD_PARAM_CONFIG_REPLY", crcExtra: 79, minLength: 5, length: 5)
        public var requestId: UInt32
        public var result: UInt8

        public init(requestId: UInt32 = 0, result: UInt8 = 0) {
            self.requestId = requestId
            self.result = result
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.requestId = p.uint32(0)
            self.result = p.uint8(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.requestId, 0)
            w.put(self.result, 4)
        }
    }
}

/// OSD_PARAM_SHOW_CONFIG (#11035)
extension MAV {
    public struct OsdParamShowConfig: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11035, name: "OSD_PARAM_SHOW_CONFIG", crcExtra: 128, minLength: 8, length: 8)
        public var requestId: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var osdScreen: UInt8
        public var osdIndex: UInt8

        public init(requestId: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, osdScreen: UInt8 = 0, osdIndex: UInt8 = 0) {
            self.requestId = requestId
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.osdScreen = osdScreen
            self.osdIndex = osdIndex
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.requestId = p.uint32(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.osdScreen = p.uint8(6)
            self.osdIndex = p.uint8(7)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.requestId, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            w.put(self.osdScreen, 6)
            w.put(self.osdIndex, 7)
        }
    }
}

/// OSD_PARAM_SHOW_CONFIG_REPLY (#11036)
extension MAV {
    public struct OsdParamShowConfigReply: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11036, name: "OSD_PARAM_SHOW_CONFIG_REPLY", crcExtra: 177, minLength: 34, length: 34)
        public var requestId: UInt32
        public var minValue: Float
        public var maxValue: Float
        public var increment: Float
        public var result: UInt8
        public var paramId: [UInt8]
        public var configType: UInt8

        public init(requestId: UInt32 = 0, minValue: Float = 0, maxValue: Float = 0, increment: Float = 0, result: UInt8 = 0, paramId: [UInt8] = [UInt8](repeating: 0, count: 16), configType: UInt8 = 0) {
            self.requestId = requestId
            self.minValue = minValue
            self.maxValue = maxValue
            self.increment = increment
            self.result = result
            self.paramId = paramId
            self.configType = configType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.requestId = p.uint32(0)
            self.minValue = p.float(4)
            self.maxValue = p.float(8)
            self.increment = p.float(12)
            self.result = p.uint8(16)
            self.paramId = (0..<16).map { p.uint8(17 + $0 * 1) }
            self.configType = p.uint8(33)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.requestId, 0)
            w.put(self.minValue, 4)
            w.put(self.maxValue, 8)
            w.put(self.increment, 12)
            w.put(self.result, 16)
            for k in 0..<Swift.min(16, self.paramId.count) { w.put(self.paramId[k], 17 + k * 1) }
            w.put(self.configType, 33)
        }
    }
}

/// OBSTACLE_DISTANCE_3D (#11037)
extension MAV {
    public struct ObstacleDistance3d: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11037, name: "OBSTACLE_DISTANCE_3D", crcExtra: 130, minLength: 28, length: 28)
        public var timeBootMs: UInt32
        public var x: Float
        public var y: Float
        public var z: Float
        public var minDistance: Float
        public var maxDistance: Float
        public var obstacleId: UInt16
        public var sensorType: UInt8
        public var frame: UInt8

        public init(timeBootMs: UInt32 = 0, x: Float = 0, y: Float = 0, z: Float = 0, minDistance: Float = 0, maxDistance: Float = 0, obstacleId: UInt16 = 0, sensorType: UInt8 = 0, frame: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.x = x
            self.y = y
            self.z = z
            self.minDistance = minDistance
            self.maxDistance = maxDistance
            self.obstacleId = obstacleId
            self.sensorType = sensorType
            self.frame = frame
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.x = p.float(4)
            self.y = p.float(8)
            self.z = p.float(12)
            self.minDistance = p.float(16)
            self.maxDistance = p.float(20)
            self.obstacleId = p.uint16(24)
            self.sensorType = p.uint8(26)
            self.frame = p.uint8(27)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.x, 4)
            w.put(self.y, 8)
            w.put(self.z, 12)
            w.put(self.minDistance, 16)
            w.put(self.maxDistance, 20)
            w.put(self.obstacleId, 24)
            w.put(self.sensorType, 26)
            w.put(self.frame, 27)
        }
    }
}

/// WATER_DEPTH (#11038)
extension MAV {
    public struct WaterDepth: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11038, name: "WATER_DEPTH", crcExtra: 47, minLength: 38, length: 38)
        public var timeBootMs: UInt32
        public var lat: Int32
        public var lng: Int32
        public var alt: Float
        public var roll: Float
        public var pitch: Float
        public var yaw: Float
        public var distance: Float
        public var temperature: Float
        public var id: UInt8
        public var healthy: UInt8

        public init(timeBootMs: UInt32 = 0, lat: Int32 = 0, lng: Int32 = 0, alt: Float = 0, roll: Float = 0, pitch: Float = 0, yaw: Float = 0, distance: Float = 0, temperature: Float = 0, id: UInt8 = 0, healthy: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.lat = lat
            self.lng = lng
            self.alt = alt
            self.roll = roll
            self.pitch = pitch
            self.yaw = yaw
            self.distance = distance
            self.temperature = temperature
            self.id = id
            self.healthy = healthy
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.lat = p.int32(4)
            self.lng = p.int32(8)
            self.alt = p.float(12)
            self.roll = p.float(16)
            self.pitch = p.float(20)
            self.yaw = p.float(24)
            self.distance = p.float(28)
            self.temperature = p.float(32)
            self.id = p.uint8(36)
            self.healthy = p.uint8(37)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.lat, 4)
            w.put(self.lng, 8)
            w.put(self.alt, 12)
            w.put(self.roll, 16)
            w.put(self.pitch, 20)
            w.put(self.yaw, 24)
            w.put(self.distance, 28)
            w.put(self.temperature, 32)
            w.put(self.id, 36)
            w.put(self.healthy, 37)
        }
    }
}

/// MCU_STATUS (#11039)
extension MAV {
    public struct McuStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11039, name: "MCU_STATUS", crcExtra: 142, minLength: 9, length: 9)
        public var MCUTemperature: Int16
        public var MCUVoltage: UInt16
        public var MCUVoltageMin: UInt16
        public var MCUVoltageMax: UInt16
        public var id: UInt8

        public init(MCUTemperature: Int16 = 0, MCUVoltage: UInt16 = 0, MCUVoltageMin: UInt16 = 0, MCUVoltageMax: UInt16 = 0, id: UInt8 = 0) {
            self.MCUTemperature = MCUTemperature
            self.MCUVoltage = MCUVoltage
            self.MCUVoltageMin = MCUVoltageMin
            self.MCUVoltageMax = MCUVoltageMax
            self.id = id
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.MCUTemperature = p.int16(0)
            self.MCUVoltage = p.uint16(2)
            self.MCUVoltageMin = p.uint16(4)
            self.MCUVoltageMax = p.uint16(6)
            self.id = p.uint8(8)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.MCUTemperature, 0)
            w.put(self.MCUVoltage, 2)
            w.put(self.MCUVoltageMin, 4)
            w.put(self.MCUVoltageMax, 6)
            w.put(self.id, 8)
        }
    }
}

/// ESC_TELEMETRY_13_TO_16 (#11040)
extension MAV {
    public struct EscTelemetry13To16: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11040, name: "ESC_TELEMETRY_13_TO_16", crcExtra: 132, minLength: 44, length: 44)
        public var voltage: [UInt16]
        public var current: [UInt16]
        public var totalcurrent: [UInt16]
        public var rpm: [UInt16]
        public var count: [UInt16]
        public var temperature: [UInt8]

        public init(voltage: [UInt16] = [UInt16](repeating: 0, count: 4), current: [UInt16] = [UInt16](repeating: 0, count: 4), totalcurrent: [UInt16] = [UInt16](repeating: 0, count: 4), rpm: [UInt16] = [UInt16](repeating: 0, count: 4), count: [UInt16] = [UInt16](repeating: 0, count: 4), temperature: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.voltage = voltage
            self.current = current
            self.totalcurrent = totalcurrent
            self.rpm = rpm
            self.count = count
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.voltage = (0..<4).map { p.uint16(0 + $0 * 2) }
            self.current = (0..<4).map { p.uint16(8 + $0 * 2) }
            self.totalcurrent = (0..<4).map { p.uint16(16 + $0 * 2) }
            self.rpm = (0..<4).map { p.uint16(24 + $0 * 2) }
            self.count = (0..<4).map { p.uint16(32 + $0 * 2) }
            self.temperature = (0..<4).map { p.uint8(40 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.voltage.count) { w.put(self.voltage[k], 0 + k * 2) }
            for k in 0..<Swift.min(4, self.current.count) { w.put(self.current[k], 8 + k * 2) }
            for k in 0..<Swift.min(4, self.totalcurrent.count) { w.put(self.totalcurrent[k], 16 + k * 2) }
            for k in 0..<Swift.min(4, self.rpm.count) { w.put(self.rpm[k], 24 + k * 2) }
            for k in 0..<Swift.min(4, self.count.count) { w.put(self.count[k], 32 + k * 2) }
            for k in 0..<Swift.min(4, self.temperature.count) { w.put(self.temperature[k], 40 + k * 1) }
        }
    }
}

/// ESC_TELEMETRY_17_TO_20 (#11041)
extension MAV {
    public struct EscTelemetry17To20: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11041, name: "ESC_TELEMETRY_17_TO_20", crcExtra: 208, minLength: 44, length: 44)
        public var voltage: [UInt16]
        public var current: [UInt16]
        public var totalcurrent: [UInt16]
        public var rpm: [UInt16]
        public var count: [UInt16]
        public var temperature: [UInt8]

        public init(voltage: [UInt16] = [UInt16](repeating: 0, count: 4), current: [UInt16] = [UInt16](repeating: 0, count: 4), totalcurrent: [UInt16] = [UInt16](repeating: 0, count: 4), rpm: [UInt16] = [UInt16](repeating: 0, count: 4), count: [UInt16] = [UInt16](repeating: 0, count: 4), temperature: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.voltage = voltage
            self.current = current
            self.totalcurrent = totalcurrent
            self.rpm = rpm
            self.count = count
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.voltage = (0..<4).map { p.uint16(0 + $0 * 2) }
            self.current = (0..<4).map { p.uint16(8 + $0 * 2) }
            self.totalcurrent = (0..<4).map { p.uint16(16 + $0 * 2) }
            self.rpm = (0..<4).map { p.uint16(24 + $0 * 2) }
            self.count = (0..<4).map { p.uint16(32 + $0 * 2) }
            self.temperature = (0..<4).map { p.uint8(40 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.voltage.count) { w.put(self.voltage[k], 0 + k * 2) }
            for k in 0..<Swift.min(4, self.current.count) { w.put(self.current[k], 8 + k * 2) }
            for k in 0..<Swift.min(4, self.totalcurrent.count) { w.put(self.totalcurrent[k], 16 + k * 2) }
            for k in 0..<Swift.min(4, self.rpm.count) { w.put(self.rpm[k], 24 + k * 2) }
            for k in 0..<Swift.min(4, self.count.count) { w.put(self.count[k], 32 + k * 2) }
            for k in 0..<Swift.min(4, self.temperature.count) { w.put(self.temperature[k], 40 + k * 1) }
        }
    }
}

/// ESC_TELEMETRY_21_TO_24 (#11042)
extension MAV {
    public struct EscTelemetry21To24: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11042, name: "ESC_TELEMETRY_21_TO_24", crcExtra: 201, minLength: 44, length: 44)
        public var voltage: [UInt16]
        public var current: [UInt16]
        public var totalcurrent: [UInt16]
        public var rpm: [UInt16]
        public var count: [UInt16]
        public var temperature: [UInt8]

        public init(voltage: [UInt16] = [UInt16](repeating: 0, count: 4), current: [UInt16] = [UInt16](repeating: 0, count: 4), totalcurrent: [UInt16] = [UInt16](repeating: 0, count: 4), rpm: [UInt16] = [UInt16](repeating: 0, count: 4), count: [UInt16] = [UInt16](repeating: 0, count: 4), temperature: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.voltage = voltage
            self.current = current
            self.totalcurrent = totalcurrent
            self.rpm = rpm
            self.count = count
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.voltage = (0..<4).map { p.uint16(0 + $0 * 2) }
            self.current = (0..<4).map { p.uint16(8 + $0 * 2) }
            self.totalcurrent = (0..<4).map { p.uint16(16 + $0 * 2) }
            self.rpm = (0..<4).map { p.uint16(24 + $0 * 2) }
            self.count = (0..<4).map { p.uint16(32 + $0 * 2) }
            self.temperature = (0..<4).map { p.uint8(40 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.voltage.count) { w.put(self.voltage[k], 0 + k * 2) }
            for k in 0..<Swift.min(4, self.current.count) { w.put(self.current[k], 8 + k * 2) }
            for k in 0..<Swift.min(4, self.totalcurrent.count) { w.put(self.totalcurrent[k], 16 + k * 2) }
            for k in 0..<Swift.min(4, self.rpm.count) { w.put(self.rpm[k], 24 + k * 2) }
            for k in 0..<Swift.min(4, self.count.count) { w.put(self.count[k], 32 + k * 2) }
            for k in 0..<Swift.min(4, self.temperature.count) { w.put(self.temperature[k], 40 + k * 1) }
        }
    }
}

/// ESC_TELEMETRY_25_TO_28 (#11043)
extension MAV {
    public struct EscTelemetry25To28: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11043, name: "ESC_TELEMETRY_25_TO_28", crcExtra: 193, minLength: 44, length: 44)
        public var voltage: [UInt16]
        public var current: [UInt16]
        public var totalcurrent: [UInt16]
        public var rpm: [UInt16]
        public var count: [UInt16]
        public var temperature: [UInt8]

        public init(voltage: [UInt16] = [UInt16](repeating: 0, count: 4), current: [UInt16] = [UInt16](repeating: 0, count: 4), totalcurrent: [UInt16] = [UInt16](repeating: 0, count: 4), rpm: [UInt16] = [UInt16](repeating: 0, count: 4), count: [UInt16] = [UInt16](repeating: 0, count: 4), temperature: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.voltage = voltage
            self.current = current
            self.totalcurrent = totalcurrent
            self.rpm = rpm
            self.count = count
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.voltage = (0..<4).map { p.uint16(0 + $0 * 2) }
            self.current = (0..<4).map { p.uint16(8 + $0 * 2) }
            self.totalcurrent = (0..<4).map { p.uint16(16 + $0 * 2) }
            self.rpm = (0..<4).map { p.uint16(24 + $0 * 2) }
            self.count = (0..<4).map { p.uint16(32 + $0 * 2) }
            self.temperature = (0..<4).map { p.uint8(40 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.voltage.count) { w.put(self.voltage[k], 0 + k * 2) }
            for k in 0..<Swift.min(4, self.current.count) { w.put(self.current[k], 8 + k * 2) }
            for k in 0..<Swift.min(4, self.totalcurrent.count) { w.put(self.totalcurrent[k], 16 + k * 2) }
            for k in 0..<Swift.min(4, self.rpm.count) { w.put(self.rpm[k], 24 + k * 2) }
            for k in 0..<Swift.min(4, self.count.count) { w.put(self.count[k], 32 + k * 2) }
            for k in 0..<Swift.min(4, self.temperature.count) { w.put(self.temperature[k], 40 + k * 1) }
        }
    }
}

/// ESC_TELEMETRY_29_TO_32 (#11044)
extension MAV {
    public struct EscTelemetry29To32: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11044, name: "ESC_TELEMETRY_29_TO_32", crcExtra: 189, minLength: 44, length: 44)
        public var voltage: [UInt16]
        public var current: [UInt16]
        public var totalcurrent: [UInt16]
        public var rpm: [UInt16]
        public var count: [UInt16]
        public var temperature: [UInt8]

        public init(voltage: [UInt16] = [UInt16](repeating: 0, count: 4), current: [UInt16] = [UInt16](repeating: 0, count: 4), totalcurrent: [UInt16] = [UInt16](repeating: 0, count: 4), rpm: [UInt16] = [UInt16](repeating: 0, count: 4), count: [UInt16] = [UInt16](repeating: 0, count: 4), temperature: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.voltage = voltage
            self.current = current
            self.totalcurrent = totalcurrent
            self.rpm = rpm
            self.count = count
            self.temperature = temperature
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.voltage = (0..<4).map { p.uint16(0 + $0 * 2) }
            self.current = (0..<4).map { p.uint16(8 + $0 * 2) }
            self.totalcurrent = (0..<4).map { p.uint16(16 + $0 * 2) }
            self.rpm = (0..<4).map { p.uint16(24 + $0 * 2) }
            self.count = (0..<4).map { p.uint16(32 + $0 * 2) }
            self.temperature = (0..<4).map { p.uint8(40 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.voltage.count) { w.put(self.voltage[k], 0 + k * 2) }
            for k in 0..<Swift.min(4, self.current.count) { w.put(self.current[k], 8 + k * 2) }
            for k in 0..<Swift.min(4, self.totalcurrent.count) { w.put(self.totalcurrent[k], 16 + k * 2) }
            for k in 0..<Swift.min(4, self.rpm.count) { w.put(self.rpm[k], 24 + k * 2) }
            for k in 0..<Swift.min(4, self.count.count) { w.put(self.count[k], 32 + k * 2) }
            for k in 0..<Swift.min(4, self.temperature.count) { w.put(self.temperature[k], 40 + k * 1) }
        }
    }
}

/// NAMED_VALUE_STRING (#11060)
extension MAV {
    public struct NamedValueString: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 11060, name: "NAMED_VALUE_STRING", crcExtra: 162, minLength: 78, length: 78)
        public var timeBootMs: UInt32
        public var name: [UInt8]
        public var value: [UInt8]

        public init(timeBootMs: UInt32 = 0, name: [UInt8] = [UInt8](repeating: 0, count: 10), value: [UInt8] = [UInt8](repeating: 0, count: 64)) {
            self.timeBootMs = timeBootMs
            self.name = name
            self.value = value
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.name = (0..<10).map { p.uint8(4 + $0 * 1) }
            self.value = (0..<64).map { p.uint8(14 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            for k in 0..<Swift.min(10, self.name.count) { w.put(self.name[k], 4 + k * 1) }
            for k in 0..<Swift.min(64, self.value.count) { w.put(self.value[k], 14 + k * 1) }
        }
    }
}

/// OPEN_DRONE_ID_BASIC_ID (#12900)
extension MAV {
    public struct OpenDroneIdBasicId: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 12900, name: "OPEN_DRONE_ID_BASIC_ID", crcExtra: 114, minLength: 44, length: 44)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idOrMac: [UInt8]
        public var idType: UInt8
        public var uaType: UInt8
        public var uasId: [UInt8]

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idOrMac: [UInt8] = [UInt8](repeating: 0, count: 20), idType: UInt8 = 0, uaType: UInt8 = 0, uasId: [UInt8] = [UInt8](repeating: 0, count: 20)) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idOrMac = idOrMac
            self.idType = idType
            self.uaType = uaType
            self.uasId = uasId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.idOrMac = (0..<20).map { p.uint8(2 + $0 * 1) }
            self.idType = p.uint8(22)
            self.uaType = p.uint8(23)
            self.uasId = (0..<20).map { p.uint8(24 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            for k in 0..<Swift.min(20, self.idOrMac.count) { w.put(self.idOrMac[k], 2 + k * 1) }
            w.put(self.idType, 22)
            w.put(self.uaType, 23)
            for k in 0..<Swift.min(20, self.uasId.count) { w.put(self.uasId[k], 24 + k * 1) }
        }
    }
}

/// OPEN_DRONE_ID_LOCATION (#12901)
extension MAV {
    public struct OpenDroneIdLocation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 12901, name: "OPEN_DRONE_ID_LOCATION", crcExtra: 254, minLength: 59, length: 59)
        public var latitude: Int32
        public var longitude: Int32
        public var altitudeBarometric: Float
        public var altitudeGeodetic: Float
        public var height: Float
        public var timestamp: Float
        public var direction: UInt16
        public var speedHorizontal: UInt16
        public var speedVertical: Int16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idOrMac: [UInt8]
        public var status: UInt8
        public var heightReference: UInt8
        public var horizontalAccuracy: UInt8
        public var verticalAccuracy: UInt8
        public var barometerAccuracy: UInt8
        public var speedAccuracy: UInt8
        public var timestampAccuracy: UInt8

        public init(latitude: Int32 = 0, longitude: Int32 = 0, altitudeBarometric: Float = 0, altitudeGeodetic: Float = 0, height: Float = 0, timestamp: Float = 0, direction: UInt16 = 0, speedHorizontal: UInt16 = 0, speedVertical: Int16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idOrMac: [UInt8] = [UInt8](repeating: 0, count: 20), status: UInt8 = 0, heightReference: UInt8 = 0, horizontalAccuracy: UInt8 = 0, verticalAccuracy: UInt8 = 0, barometerAccuracy: UInt8 = 0, speedAccuracy: UInt8 = 0, timestampAccuracy: UInt8 = 0) {
            self.latitude = latitude
            self.longitude = longitude
            self.altitudeBarometric = altitudeBarometric
            self.altitudeGeodetic = altitudeGeodetic
            self.height = height
            self.timestamp = timestamp
            self.direction = direction
            self.speedHorizontal = speedHorizontal
            self.speedVertical = speedVertical
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idOrMac = idOrMac
            self.status = status
            self.heightReference = heightReference
            self.horizontalAccuracy = horizontalAccuracy
            self.verticalAccuracy = verticalAccuracy
            self.barometerAccuracy = barometerAccuracy
            self.speedAccuracy = speedAccuracy
            self.timestampAccuracy = timestampAccuracy
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.latitude = p.int32(0)
            self.longitude = p.int32(4)
            self.altitudeBarometric = p.float(8)
            self.altitudeGeodetic = p.float(12)
            self.height = p.float(16)
            self.timestamp = p.float(20)
            self.direction = p.uint16(24)
            self.speedHorizontal = p.uint16(26)
            self.speedVertical = p.int16(28)
            self.targetSystem = p.uint8(30)
            self.targetComponent = p.uint8(31)
            self.idOrMac = (0..<20).map { p.uint8(32 + $0 * 1) }
            self.status = p.uint8(52)
            self.heightReference = p.uint8(53)
            self.horizontalAccuracy = p.uint8(54)
            self.verticalAccuracy = p.uint8(55)
            self.barometerAccuracy = p.uint8(56)
            self.speedAccuracy = p.uint8(57)
            self.timestampAccuracy = p.uint8(58)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.latitude, 0)
            w.put(self.longitude, 4)
            w.put(self.altitudeBarometric, 8)
            w.put(self.altitudeGeodetic, 12)
            w.put(self.height, 16)
            w.put(self.timestamp, 20)
            w.put(self.direction, 24)
            w.put(self.speedHorizontal, 26)
            w.put(self.speedVertical, 28)
            w.put(self.targetSystem, 30)
            w.put(self.targetComponent, 31)
            for k in 0..<Swift.min(20, self.idOrMac.count) { w.put(self.idOrMac[k], 32 + k * 1) }
            w.put(self.status, 52)
            w.put(self.heightReference, 53)
            w.put(self.horizontalAccuracy, 54)
            w.put(self.verticalAccuracy, 55)
            w.put(self.barometerAccuracy, 56)
            w.put(self.speedAccuracy, 57)
            w.put(self.timestampAccuracy, 58)
        }
    }
}

/// OPEN_DRONE_ID_AUTHENTICATION (#12902)
extension MAV {
    public struct OpenDroneIdAuthentication: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 12902, name: "OPEN_DRONE_ID_AUTHENTICATION", crcExtra: 140, minLength: 53, length: 53)
        public var timestamp: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idOrMac: [UInt8]
        public var authenticationType: UInt8
        public var dataPage: UInt8
        public var lastPageIndex: UInt8
        public var length: UInt8
        public var authenticationData: [UInt8]

        public init(timestamp: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idOrMac: [UInt8] = [UInt8](repeating: 0, count: 20), authenticationType: UInt8 = 0, dataPage: UInt8 = 0, lastPageIndex: UInt8 = 0, length: UInt8 = 0, authenticationData: [UInt8] = [UInt8](repeating: 0, count: 23)) {
            self.timestamp = timestamp
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idOrMac = idOrMac
            self.authenticationType = authenticationType
            self.dataPage = dataPage
            self.lastPageIndex = lastPageIndex
            self.length = length
            self.authenticationData = authenticationData
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timestamp = p.uint32(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.idOrMac = (0..<20).map { p.uint8(6 + $0 * 1) }
            self.authenticationType = p.uint8(26)
            self.dataPage = p.uint8(27)
            self.lastPageIndex = p.uint8(28)
            self.length = p.uint8(29)
            self.authenticationData = (0..<23).map { p.uint8(30 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timestamp, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            for k in 0..<Swift.min(20, self.idOrMac.count) { w.put(self.idOrMac[k], 6 + k * 1) }
            w.put(self.authenticationType, 26)
            w.put(self.dataPage, 27)
            w.put(self.lastPageIndex, 28)
            w.put(self.length, 29)
            for k in 0..<Swift.min(23, self.authenticationData.count) { w.put(self.authenticationData[k], 30 + k * 1) }
        }
    }
}

/// OPEN_DRONE_ID_SELF_ID (#12903)
extension MAV {
    public struct OpenDroneIdSelfId: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 12903, name: "OPEN_DRONE_ID_SELF_ID", crcExtra: 249, minLength: 46, length: 46)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idOrMac: [UInt8]
        public var descriptionType: UInt8
        public var description: [UInt8]

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idOrMac: [UInt8] = [UInt8](repeating: 0, count: 20), descriptionType: UInt8 = 0, description: [UInt8] = [UInt8](repeating: 0, count: 23)) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idOrMac = idOrMac
            self.descriptionType = descriptionType
            self.description = description
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.idOrMac = (0..<20).map { p.uint8(2 + $0 * 1) }
            self.descriptionType = p.uint8(22)
            self.description = (0..<23).map { p.uint8(23 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            for k in 0..<Swift.min(20, self.idOrMac.count) { w.put(self.idOrMac[k], 2 + k * 1) }
            w.put(self.descriptionType, 22)
            for k in 0..<Swift.min(23, self.description.count) { w.put(self.description[k], 23 + k * 1) }
        }
    }
}

/// OPEN_DRONE_ID_SYSTEM (#12904)
extension MAV {
    public struct OpenDroneIdSystem: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 12904, name: "OPEN_DRONE_ID_SYSTEM", crcExtra: 77, minLength: 54, length: 54)
        public var operatorLatitude: Int32
        public var operatorLongitude: Int32
        public var areaCeiling: Float
        public var areaFloor: Float
        public var operatorAltitudeGeo: Float
        public var timestamp: UInt32
        public var areaCount: UInt16
        public var areaRadius: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idOrMac: [UInt8]
        public var operatorLocationType: UInt8
        public var classificationType: UInt8
        public var categoryEu: UInt8
        public var classEu: UInt8

        public init(operatorLatitude: Int32 = 0, operatorLongitude: Int32 = 0, areaCeiling: Float = 0, areaFloor: Float = 0, operatorAltitudeGeo: Float = 0, timestamp: UInt32 = 0, areaCount: UInt16 = 0, areaRadius: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idOrMac: [UInt8] = [UInt8](repeating: 0, count: 20), operatorLocationType: UInt8 = 0, classificationType: UInt8 = 0, categoryEu: UInt8 = 0, classEu: UInt8 = 0) {
            self.operatorLatitude = operatorLatitude
            self.operatorLongitude = operatorLongitude
            self.areaCeiling = areaCeiling
            self.areaFloor = areaFloor
            self.operatorAltitudeGeo = operatorAltitudeGeo
            self.timestamp = timestamp
            self.areaCount = areaCount
            self.areaRadius = areaRadius
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idOrMac = idOrMac
            self.operatorLocationType = operatorLocationType
            self.classificationType = classificationType
            self.categoryEu = categoryEu
            self.classEu = classEu
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.operatorLatitude = p.int32(0)
            self.operatorLongitude = p.int32(4)
            self.areaCeiling = p.float(8)
            self.areaFloor = p.float(12)
            self.operatorAltitudeGeo = p.float(16)
            self.timestamp = p.uint32(20)
            self.areaCount = p.uint16(24)
            self.areaRadius = p.uint16(26)
            self.targetSystem = p.uint8(28)
            self.targetComponent = p.uint8(29)
            self.idOrMac = (0..<20).map { p.uint8(30 + $0 * 1) }
            self.operatorLocationType = p.uint8(50)
            self.classificationType = p.uint8(51)
            self.categoryEu = p.uint8(52)
            self.classEu = p.uint8(53)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.operatorLatitude, 0)
            w.put(self.operatorLongitude, 4)
            w.put(self.areaCeiling, 8)
            w.put(self.areaFloor, 12)
            w.put(self.operatorAltitudeGeo, 16)
            w.put(self.timestamp, 20)
            w.put(self.areaCount, 24)
            w.put(self.areaRadius, 26)
            w.put(self.targetSystem, 28)
            w.put(self.targetComponent, 29)
            for k in 0..<Swift.min(20, self.idOrMac.count) { w.put(self.idOrMac[k], 30 + k * 1) }
            w.put(self.operatorLocationType, 50)
            w.put(self.classificationType, 51)
            w.put(self.categoryEu, 52)
            w.put(self.classEu, 53)
        }
    }
}

/// OPEN_DRONE_ID_OPERATOR_ID (#12905)
extension MAV {
    public struct OpenDroneIdOperatorId: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 12905, name: "OPEN_DRONE_ID_OPERATOR_ID", crcExtra: 49, minLength: 43, length: 43)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idOrMac: [UInt8]
        public var operatorIdType: UInt8
        public var operatorId: [UInt8]

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idOrMac: [UInt8] = [UInt8](repeating: 0, count: 20), operatorIdType: UInt8 = 0, operatorId: [UInt8] = [UInt8](repeating: 0, count: 20)) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idOrMac = idOrMac
            self.operatorIdType = operatorIdType
            self.operatorId = operatorId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.idOrMac = (0..<20).map { p.uint8(2 + $0 * 1) }
            self.operatorIdType = p.uint8(22)
            self.operatorId = (0..<20).map { p.uint8(23 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            for k in 0..<Swift.min(20, self.idOrMac.count) { w.put(self.idOrMac[k], 2 + k * 1) }
            w.put(self.operatorIdType, 22)
            for k in 0..<Swift.min(20, self.operatorId.count) { w.put(self.operatorId[k], 23 + k * 1) }
        }
    }
}

/// OPEN_DRONE_ID_MESSAGE_PACK (#12915)
extension MAV {
    public struct OpenDroneIdMessagePack: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 12915, name: "OPEN_DRONE_ID_MESSAGE_PACK", crcExtra: 94, minLength: 249, length: 249)
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var idOrMac: [UInt8]
        public var singleMessageSize: UInt8
        public var msgPackSize: UInt8
        public var messages: [UInt8]

        public init(targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, idOrMac: [UInt8] = [UInt8](repeating: 0, count: 20), singleMessageSize: UInt8 = 0, msgPackSize: UInt8 = 0, messages: [UInt8] = [UInt8](repeating: 0, count: 225)) {
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.idOrMac = idOrMac
            self.singleMessageSize = singleMessageSize
            self.msgPackSize = msgPackSize
            self.messages = messages
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.targetSystem = p.uint8(0)
            self.targetComponent = p.uint8(1)
            self.idOrMac = (0..<20).map { p.uint8(2 + $0 * 1) }
            self.singleMessageSize = p.uint8(22)
            self.msgPackSize = p.uint8(23)
            self.messages = (0..<225).map { p.uint8(24 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.targetSystem, 0)
            w.put(self.targetComponent, 1)
            for k in 0..<Swift.min(20, self.idOrMac.count) { w.put(self.idOrMac[k], 2 + k * 1) }
            w.put(self.singleMessageSize, 22)
            w.put(self.msgPackSize, 23)
            for k in 0..<Swift.min(225, self.messages.count) { w.put(self.messages[k], 24 + k * 1) }
        }
    }
}

/// OPEN_DRONE_ID_ARM_STATUS (#12918)
extension MAV {
    public struct OpenDroneIdArmStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 12918, name: "OPEN_DRONE_ID_ARM_STATUS", crcExtra: 139, minLength: 51, length: 51)
        public var status: UInt8
        public var error: [UInt8]

        public init(status: UInt8 = 0, error: [UInt8] = [UInt8](repeating: 0, count: 50)) {
            self.status = status
            self.error = error
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.status = p.uint8(0)
            self.error = (0..<50).map { p.uint8(1 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.status, 0)
            for k in 0..<Swift.min(50, self.error.count) { w.put(self.error[k], 1 + k * 1) }
        }
    }
}

/// OPEN_DRONE_ID_SYSTEM_UPDATE (#12919)
extension MAV {
    public struct OpenDroneIdSystemUpdate: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 12919, name: "OPEN_DRONE_ID_SYSTEM_UPDATE", crcExtra: 7, minLength: 18, length: 18)
        public var operatorLatitude: Int32
        public var operatorLongitude: Int32
        public var operatorAltitudeGeo: Float
        public var timestamp: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(operatorLatitude: Int32 = 0, operatorLongitude: Int32 = 0, operatorAltitudeGeo: Float = 0, timestamp: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.operatorLatitude = operatorLatitude
            self.operatorLongitude = operatorLongitude
            self.operatorAltitudeGeo = operatorAltitudeGeo
            self.timestamp = timestamp
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.operatorLatitude = p.int32(0)
            self.operatorLongitude = p.int32(4)
            self.operatorAltitudeGeo = p.float(8)
            self.timestamp = p.uint32(12)
            self.targetSystem = p.uint8(16)
            self.targetComponent = p.uint8(17)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.operatorLatitude, 0)
            w.put(self.operatorLongitude, 4)
            w.put(self.operatorAltitudeGeo, 8)
            w.put(self.timestamp, 12)
            w.put(self.targetSystem, 16)
            w.put(self.targetComponent, 17)
        }
    }
}

/// HYGROMETER_SENSOR (#12920)
extension MAV {
    public struct HygrometerSensor: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 12920, name: "HYGROMETER_SENSOR", crcExtra: 20, minLength: 5, length: 5)
        public var temperature: Int16
        public var humidity: UInt16
        public var id: UInt8

        public init(temperature: Int16 = 0, humidity: UInt16 = 0, id: UInt8 = 0) {
            self.temperature = temperature
            self.humidity = humidity
            self.id = id
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.temperature = p.int16(0)
            self.humidity = p.uint16(2)
            self.id = p.uint8(4)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.temperature, 0)
            w.put(self.humidity, 2)
            w.put(self.id, 4)
        }
    }
}

/// TEST_TYPES (#17000)
extension MAV {
    public struct TestTypes: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 17000, name: "TEST_TYPES", crcExtra: 103, minLength: 179, length: 179)
        public var u64: UInt64
        public var s64: Int64
        public var d: Double
        public var u64Array: [UInt64]
        public var s64Array: [Int64]
        public var dArray: [Double]
        public var u32: UInt32
        public var s32: Int32
        public var f: Float
        public var u32Array: [UInt32]
        public var s32Array: [Int32]
        public var fArray: [Float]
        public var u16: UInt16
        public var s16: Int16
        public var u16Array: [UInt16]
        public var s16Array: [Int16]
        public var c: UInt8
        public var s: [UInt8]
        public var u8: UInt8
        public var s8: Int8
        public var u8Array: [UInt8]
        public var s8Array: [Int8]

        public init(u64: UInt64 = 0, s64: Int64 = 0, d: Double = 0, u64Array: [UInt64] = [UInt64](repeating: 0, count: 3), s64Array: [Int64] = [Int64](repeating: 0, count: 3), dArray: [Double] = [Double](repeating: 0, count: 3), u32: UInt32 = 0, s32: Int32 = 0, f: Float = 0, u32Array: [UInt32] = [UInt32](repeating: 0, count: 3), s32Array: [Int32] = [Int32](repeating: 0, count: 3), fArray: [Float] = [Float](repeating: 0, count: 3), u16: UInt16 = 0, s16: Int16 = 0, u16Array: [UInt16] = [UInt16](repeating: 0, count: 3), s16Array: [Int16] = [Int16](repeating: 0, count: 3), c: UInt8 = 0, s: [UInt8] = [UInt8](repeating: 0, count: 10), u8: UInt8 = 0, s8: Int8 = 0, u8Array: [UInt8] = [UInt8](repeating: 0, count: 3), s8Array: [Int8] = [Int8](repeating: 0, count: 3)) {
            self.u64 = u64
            self.s64 = s64
            self.d = d
            self.u64Array = u64Array
            self.s64Array = s64Array
            self.dArray = dArray
            self.u32 = u32
            self.s32 = s32
            self.f = f
            self.u32Array = u32Array
            self.s32Array = s32Array
            self.fArray = fArray
            self.u16 = u16
            self.s16 = s16
            self.u16Array = u16Array
            self.s16Array = s16Array
            self.c = c
            self.s = s
            self.u8 = u8
            self.s8 = s8
            self.u8Array = u8Array
            self.s8Array = s8Array
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.u64 = p.uint64(0)
            self.s64 = p.int64(8)
            self.d = p.double(16)
            self.u64Array = (0..<3).map { p.uint64(24 + $0 * 8) }
            self.s64Array = (0..<3).map { p.int64(48 + $0 * 8) }
            self.dArray = (0..<3).map { p.double(72 + $0 * 8) }
            self.u32 = p.uint32(96)
            self.s32 = p.int32(100)
            self.f = p.float(104)
            self.u32Array = (0..<3).map { p.uint32(108 + $0 * 4) }
            self.s32Array = (0..<3).map { p.int32(120 + $0 * 4) }
            self.fArray = (0..<3).map { p.float(132 + $0 * 4) }
            self.u16 = p.uint16(144)
            self.s16 = p.int16(146)
            self.u16Array = (0..<3).map { p.uint16(148 + $0 * 2) }
            self.s16Array = (0..<3).map { p.int16(154 + $0 * 2) }
            self.c = p.uint8(160)
            self.s = (0..<10).map { p.uint8(161 + $0 * 1) }
            self.u8 = p.uint8(171)
            self.s8 = p.int8(172)
            self.u8Array = (0..<3).map { p.uint8(173 + $0 * 1) }
            self.s8Array = (0..<3).map { p.int8(176 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.u64, 0)
            w.put(self.s64, 8)
            w.put(self.d, 16)
            for k in 0..<Swift.min(3, self.u64Array.count) { w.put(self.u64Array[k], 24 + k * 8) }
            for k in 0..<Swift.min(3, self.s64Array.count) { w.put(self.s64Array[k], 48 + k * 8) }
            for k in 0..<Swift.min(3, self.dArray.count) { w.put(self.dArray[k], 72 + k * 8) }
            w.put(self.u32, 96)
            w.put(self.s32, 100)
            w.put(self.f, 104)
            for k in 0..<Swift.min(3, self.u32Array.count) { w.put(self.u32Array[k], 108 + k * 4) }
            for k in 0..<Swift.min(3, self.s32Array.count) { w.put(self.s32Array[k], 120 + k * 4) }
            for k in 0..<Swift.min(3, self.fArray.count) { w.put(self.fArray[k], 132 + k * 4) }
            w.put(self.u16, 144)
            w.put(self.s16, 146)
            for k in 0..<Swift.min(3, self.u16Array.count) { w.put(self.u16Array[k], 148 + k * 2) }
            for k in 0..<Swift.min(3, self.s16Array.count) { w.put(self.s16Array[k], 154 + k * 2) }
            w.put(self.c, 160)
            for k in 0..<Swift.min(10, self.s.count) { w.put(self.s[k], 161 + k * 1) }
            w.put(self.u8, 171)
            w.put(self.s8, 172)
            for k in 0..<Swift.min(3, self.u8Array.count) { w.put(self.u8Array[k], 173 + k * 1) }
            for k in 0..<Swift.min(3, self.s8Array.count) { w.put(self.s8Array[k], 176 + k * 1) }
        }
    }
}

/// ARRAY_TEST_0 (#17150)
extension MAV {
    public struct ArrayTest0: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 17150, name: "ARRAY_TEST_0", crcExtra: 26, minLength: 33, length: 33)
        public var arU32: [UInt32]
        public var arU16: [UInt16]
        public var v1: UInt8
        public var arI8: [Int8]
        public var arU8: [UInt8]

        public init(arU32: [UInt32] = [UInt32](repeating: 0, count: 4), arU16: [UInt16] = [UInt16](repeating: 0, count: 4), v1: UInt8 = 0, arI8: [Int8] = [Int8](repeating: 0, count: 4), arU8: [UInt8] = [UInt8](repeating: 0, count: 4)) {
            self.arU32 = arU32
            self.arU16 = arU16
            self.v1 = v1
            self.arI8 = arI8
            self.arU8 = arU8
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.arU32 = (0..<4).map { p.uint32(0 + $0 * 4) }
            self.arU16 = (0..<4).map { p.uint16(16 + $0 * 2) }
            self.v1 = p.uint8(24)
            self.arI8 = (0..<4).map { p.int8(25 + $0 * 1) }
            self.arU8 = (0..<4).map { p.uint8(29 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.arU32.count) { w.put(self.arU32[k], 0 + k * 4) }
            for k in 0..<Swift.min(4, self.arU16.count) { w.put(self.arU16[k], 16 + k * 2) }
            w.put(self.v1, 24)
            for k in 0..<Swift.min(4, self.arI8.count) { w.put(self.arI8[k], 25 + k * 1) }
            for k in 0..<Swift.min(4, self.arU8.count) { w.put(self.arU8[k], 29 + k * 1) }
        }
    }
}

/// ARRAY_TEST_1 (#17151)
extension MAV {
    public struct ArrayTest1: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 17151, name: "ARRAY_TEST_1", crcExtra: 72, minLength: 16, length: 16)
        public var arU32: [UInt32]

        public init(arU32: [UInt32] = [UInt32](repeating: 0, count: 4)) {
            self.arU32 = arU32
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.arU32 = (0..<4).map { p.uint32(0 + $0 * 4) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.arU32.count) { w.put(self.arU32[k], 0 + k * 4) }
        }
    }
}

/// ARRAY_TEST_3 (#17153)
extension MAV {
    public struct ArrayTest3: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 17153, name: "ARRAY_TEST_3", crcExtra: 19, minLength: 17, length: 17)
        public var arU32: [UInt32]
        public var v: UInt8

        public init(arU32: [UInt32] = [UInt32](repeating: 0, count: 4), v: UInt8 = 0) {
            self.arU32 = arU32
            self.v = v
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.arU32 = (0..<4).map { p.uint32(0 + $0 * 4) }
            self.v = p.uint8(16)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.arU32.count) { w.put(self.arU32[k], 0 + k * 4) }
            w.put(self.v, 16)
        }
    }
}

/// ARRAY_TEST_4 (#17154)
extension MAV {
    public struct ArrayTest4: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 17154, name: "ARRAY_TEST_4", crcExtra: 89, minLength: 17, length: 17)
        public var arU32: [UInt32]
        public var v: UInt8

        public init(arU32: [UInt32] = [UInt32](repeating: 0, count: 4), v: UInt8 = 0) {
            self.arU32 = arU32
            self.v = v
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.arU32 = (0..<4).map { p.uint32(0 + $0 * 4) }
            self.v = p.uint8(16)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.arU32.count) { w.put(self.arU32[k], 0 + k * 4) }
            w.put(self.v, 16)
        }
    }
}

/// ARRAY_TEST_5 (#17155)
extension MAV {
    public struct ArrayTest5: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 17155, name: "ARRAY_TEST_5", crcExtra: 27, minLength: 10, length: 10)
        public var c1: [UInt8]
        public var c2: [UInt8]

        public init(c1: [UInt8] = [UInt8](repeating: 0, count: 5), c2: [UInt8] = [UInt8](repeating: 0, count: 5)) {
            self.c1 = c1
            self.c2 = c2
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.c1 = (0..<5).map { p.uint8(0 + $0 * 1) }
            self.c2 = (0..<5).map { p.uint8(5 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(5, self.c1.count) { w.put(self.c1[k], 0 + k * 1) }
            for k in 0..<Swift.min(5, self.c2.count) { w.put(self.c2[k], 5 + k * 1) }
        }
    }
}

/// ARRAY_TEST_6 (#17156)
extension MAV {
    public struct ArrayTest6: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 17156, name: "ARRAY_TEST_6", crcExtra: 14, minLength: 91, length: 91)
        public var arD: [Double]
        public var v3: UInt32
        public var arU32: [UInt32]
        public var arI32: [Int32]
        public var arF: [Float]
        public var v2: UInt16
        public var arU16: [UInt16]
        public var arI16: [Int16]
        public var v1: UInt8
        public var arU8: [UInt8]
        public var arI8: [Int8]
        public var arC: [UInt8]

        public init(arD: [Double] = [Double](repeating: 0, count: 2), v3: UInt32 = 0, arU32: [UInt32] = [UInt32](repeating: 0, count: 2), arI32: [Int32] = [Int32](repeating: 0, count: 2), arF: [Float] = [Float](repeating: 0, count: 2), v2: UInt16 = 0, arU16: [UInt16] = [UInt16](repeating: 0, count: 2), arI16: [Int16] = [Int16](repeating: 0, count: 2), v1: UInt8 = 0, arU8: [UInt8] = [UInt8](repeating: 0, count: 2), arI8: [Int8] = [Int8](repeating: 0, count: 2), arC: [UInt8] = [UInt8](repeating: 0, count: 32)) {
            self.arD = arD
            self.v3 = v3
            self.arU32 = arU32
            self.arI32 = arI32
            self.arF = arF
            self.v2 = v2
            self.arU16 = arU16
            self.arI16 = arI16
            self.v1 = v1
            self.arU8 = arU8
            self.arI8 = arI8
            self.arC = arC
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.arD = (0..<2).map { p.double(0 + $0 * 8) }
            self.v3 = p.uint32(16)
            self.arU32 = (0..<2).map { p.uint32(20 + $0 * 4) }
            self.arI32 = (0..<2).map { p.int32(28 + $0 * 4) }
            self.arF = (0..<2).map { p.float(36 + $0 * 4) }
            self.v2 = p.uint16(44)
            self.arU16 = (0..<2).map { p.uint16(46 + $0 * 2) }
            self.arI16 = (0..<2).map { p.int16(50 + $0 * 2) }
            self.v1 = p.uint8(54)
            self.arU8 = (0..<2).map { p.uint8(55 + $0 * 1) }
            self.arI8 = (0..<2).map { p.int8(57 + $0 * 1) }
            self.arC = (0..<32).map { p.uint8(59 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(2, self.arD.count) { w.put(self.arD[k], 0 + k * 8) }
            w.put(self.v3, 16)
            for k in 0..<Swift.min(2, self.arU32.count) { w.put(self.arU32[k], 20 + k * 4) }
            for k in 0..<Swift.min(2, self.arI32.count) { w.put(self.arI32[k], 28 + k * 4) }
            for k in 0..<Swift.min(2, self.arF.count) { w.put(self.arF[k], 36 + k * 4) }
            w.put(self.v2, 44)
            for k in 0..<Swift.min(2, self.arU16.count) { w.put(self.arU16[k], 46 + k * 2) }
            for k in 0..<Swift.min(2, self.arI16.count) { w.put(self.arI16[k], 50 + k * 2) }
            w.put(self.v1, 54)
            for k in 0..<Swift.min(2, self.arU8.count) { w.put(self.arU8[k], 55 + k * 1) }
            for k in 0..<Swift.min(2, self.arI8.count) { w.put(self.arI8[k], 57 + k * 1) }
            for k in 0..<Swift.min(32, self.arC.count) { w.put(self.arC[k], 59 + k * 1) }
        }
    }
}

/// ARRAY_TEST_7 (#17157)
extension MAV {
    public struct ArrayTest7: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 17157, name: "ARRAY_TEST_7", crcExtra: 187, minLength: 84, length: 84)
        public var arD: [Double]
        public var arF: [Float]
        public var arU32: [UInt32]
        public var arI32: [Int32]
        public var arU16: [UInt16]
        public var arI16: [Int16]
        public var arU8: [UInt8]
        public var arI8: [Int8]
        public var arC: [UInt8]

        public init(arD: [Double] = [Double](repeating: 0, count: 2), arF: [Float] = [Float](repeating: 0, count: 2), arU32: [UInt32] = [UInt32](repeating: 0, count: 2), arI32: [Int32] = [Int32](repeating: 0, count: 2), arU16: [UInt16] = [UInt16](repeating: 0, count: 2), arI16: [Int16] = [Int16](repeating: 0, count: 2), arU8: [UInt8] = [UInt8](repeating: 0, count: 2), arI8: [Int8] = [Int8](repeating: 0, count: 2), arC: [UInt8] = [UInt8](repeating: 0, count: 32)) {
            self.arD = arD
            self.arF = arF
            self.arU32 = arU32
            self.arI32 = arI32
            self.arU16 = arU16
            self.arI16 = arI16
            self.arU8 = arU8
            self.arI8 = arI8
            self.arC = arC
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.arD = (0..<2).map { p.double(0 + $0 * 8) }
            self.arF = (0..<2).map { p.float(16 + $0 * 4) }
            self.arU32 = (0..<2).map { p.uint32(24 + $0 * 4) }
            self.arI32 = (0..<2).map { p.int32(32 + $0 * 4) }
            self.arU16 = (0..<2).map { p.uint16(40 + $0 * 2) }
            self.arI16 = (0..<2).map { p.int16(44 + $0 * 2) }
            self.arU8 = (0..<2).map { p.uint8(48 + $0 * 1) }
            self.arI8 = (0..<2).map { p.int8(50 + $0 * 1) }
            self.arC = (0..<32).map { p.uint8(52 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(2, self.arD.count) { w.put(self.arD[k], 0 + k * 8) }
            for k in 0..<Swift.min(2, self.arF.count) { w.put(self.arF[k], 16 + k * 4) }
            for k in 0..<Swift.min(2, self.arU32.count) { w.put(self.arU32[k], 24 + k * 4) }
            for k in 0..<Swift.min(2, self.arI32.count) { w.put(self.arI32[k], 32 + k * 4) }
            for k in 0..<Swift.min(2, self.arU16.count) { w.put(self.arU16[k], 40 + k * 2) }
            for k in 0..<Swift.min(2, self.arI16.count) { w.put(self.arI16[k], 44 + k * 2) }
            for k in 0..<Swift.min(2, self.arU8.count) { w.put(self.arU8[k], 48 + k * 1) }
            for k in 0..<Swift.min(2, self.arI8.count) { w.put(self.arI8[k], 50 + k * 1) }
            for k in 0..<Swift.min(32, self.arC.count) { w.put(self.arC[k], 52 + k * 1) }
        }
    }
}

/// ARRAY_TEST_8 (#17158)
extension MAV {
    public struct ArrayTest8: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 17158, name: "ARRAY_TEST_8", crcExtra: 106, minLength: 24, length: 24)
        public var arD: [Double]
        public var v3: UInt32
        public var arU16: [UInt16]

        public init(arD: [Double] = [Double](repeating: 0, count: 2), v3: UInt32 = 0, arU16: [UInt16] = [UInt16](repeating: 0, count: 2)) {
            self.arD = arD
            self.v3 = v3
            self.arU16 = arU16
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.arD = (0..<2).map { p.double(0 + $0 * 8) }
            self.v3 = p.uint32(16)
            self.arU16 = (0..<2).map { p.uint16(20 + $0 * 2) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(2, self.arD.count) { w.put(self.arD[k], 0 + k * 8) }
            w.put(self.v3, 16)
            for k in 0..<Swift.min(2, self.arU16.count) { w.put(self.arU16[k], 20 + k * 2) }
        }
    }
}

/// zVIDEO_STREAM_INFORMATION (#26900)
extension MAV {
    public struct ZvideoStreamInformation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 26900, name: "zVIDEO_STREAM_INFORMATION", crcExtra: 124, minLength: 246, length: 246)
        public var framerate: Float
        public var bitrate: UInt32
        public var resolutionH: UInt16
        public var resolutionV: UInt16
        public var rotation: UInt16
        public var cameraId: UInt8
        public var status: UInt8
        public var uri: [UInt8]

        public init(framerate: Float = 0, bitrate: UInt32 = 0, resolutionH: UInt16 = 0, resolutionV: UInt16 = 0, rotation: UInt16 = 0, cameraId: UInt8 = 0, status: UInt8 = 0, uri: [UInt8] = [UInt8](repeating: 0, count: 230)) {
            self.framerate = framerate
            self.bitrate = bitrate
            self.resolutionH = resolutionH
            self.resolutionV = resolutionV
            self.rotation = rotation
            self.cameraId = cameraId
            self.status = status
            self.uri = uri
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.framerate = p.float(0)
            self.bitrate = p.uint32(4)
            self.resolutionH = p.uint16(8)
            self.resolutionV = p.uint16(10)
            self.rotation = p.uint16(12)
            self.cameraId = p.uint8(14)
            self.status = p.uint8(15)
            self.uri = (0..<230).map { p.uint8(16 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.framerate, 0)
            w.put(self.bitrate, 4)
            w.put(self.resolutionH, 8)
            w.put(self.resolutionV, 10)
            w.put(self.rotation, 12)
            w.put(self.cameraId, 14)
            w.put(self.status, 15)
            for k in 0..<Swift.min(230, self.uri.count) { w.put(self.uri[k], 16 + k * 1) }
        }
    }
}

/// ICAROUS_HEARTBEAT (#42000)
extension MAV {
    public struct IcarousHeartbeat: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 42000, name: "ICAROUS_HEARTBEAT", crcExtra: 227, minLength: 1, length: 1)
        public var status: UInt8

        public init(status: UInt8 = 0) {
            self.status = status
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.status = p.uint8(0)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.status, 0)
        }
    }
}

/// ICAROUS_KINEMATIC_BANDS (#42001)
extension MAV {
    public struct IcarousKinematicBands: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 42001, name: "ICAROUS_KINEMATIC_BANDS", crcExtra: 239, minLength: 46, length: 46)
        public var min1: Float
        public var max1: Float
        public var min2: Float
        public var max2: Float
        public var min3: Float
        public var max3: Float
        public var min4: Float
        public var max4: Float
        public var min5: Float
        public var max5: Float
        public var numBands: Int8
        public var type1: UInt8
        public var type2: UInt8
        public var type3: UInt8
        public var type4: UInt8
        public var type5: UInt8

        public init(min1: Float = 0, max1: Float = 0, min2: Float = 0, max2: Float = 0, min3: Float = 0, max3: Float = 0, min4: Float = 0, max4: Float = 0, min5: Float = 0, max5: Float = 0, numBands: Int8 = 0, type1: UInt8 = 0, type2: UInt8 = 0, type3: UInt8 = 0, type4: UInt8 = 0, type5: UInt8 = 0) {
            self.min1 = min1
            self.max1 = max1
            self.min2 = min2
            self.max2 = max2
            self.min3 = min3
            self.max3 = max3
            self.min4 = min4
            self.max4 = max4
            self.min5 = min5
            self.max5 = max5
            self.numBands = numBands
            self.type1 = type1
            self.type2 = type2
            self.type3 = type3
            self.type4 = type4
            self.type5 = type5
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.min1 = p.float(0)
            self.max1 = p.float(4)
            self.min2 = p.float(8)
            self.max2 = p.float(12)
            self.min3 = p.float(16)
            self.max3 = p.float(20)
            self.min4 = p.float(24)
            self.max4 = p.float(28)
            self.min5 = p.float(32)
            self.max5 = p.float(36)
            self.numBands = p.int8(40)
            self.type1 = p.uint8(41)
            self.type2 = p.uint8(42)
            self.type3 = p.uint8(43)
            self.type4 = p.uint8(44)
            self.type5 = p.uint8(45)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.min1, 0)
            w.put(self.max1, 4)
            w.put(self.min2, 8)
            w.put(self.max2, 12)
            w.put(self.min3, 16)
            w.put(self.max3, 20)
            w.put(self.min4, 24)
            w.put(self.max4, 28)
            w.put(self.min5, 32)
            w.put(self.max5, 36)
            w.put(self.numBands, 40)
            w.put(self.type1, 41)
            w.put(self.type2, 42)
            w.put(self.type3, 43)
            w.put(self.type4, 44)
            w.put(self.type5, 45)
        }
    }
}

/// CUBEPILOT_RAW_RC (#50001)
extension MAV {
    public struct CubepilotRawRc: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 50001, name: "CUBEPILOT_RAW_RC", crcExtra: 246, minLength: 32, length: 32)
        public var rcRaw: [UInt8]

        public init(rcRaw: [UInt8] = [UInt8](repeating: 0, count: 32)) {
            self.rcRaw = rcRaw
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.rcRaw = (0..<32).map { p.uint8(0 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(32, self.rcRaw.count) { w.put(self.rcRaw[k], 0 + k * 1) }
        }
    }
}

/// HERELINK_VIDEO_STREAM_INFORMATION (#50002)
extension MAV {
    public struct HerelinkVideoStreamInformation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 50002, name: "HERELINK_VIDEO_STREAM_INFORMATION", crcExtra: 181, minLength: 246, length: 246)
        public var framerate: Float
        public var bitrate: UInt32
        public var resolutionH: UInt16
        public var resolutionV: UInt16
        public var rotation: UInt16
        public var cameraId: UInt8
        public var status: UInt8
        public var uri: [UInt8]

        public init(framerate: Float = 0, bitrate: UInt32 = 0, resolutionH: UInt16 = 0, resolutionV: UInt16 = 0, rotation: UInt16 = 0, cameraId: UInt8 = 0, status: UInt8 = 0, uri: [UInt8] = [UInt8](repeating: 0, count: 230)) {
            self.framerate = framerate
            self.bitrate = bitrate
            self.resolutionH = resolutionH
            self.resolutionV = resolutionV
            self.rotation = rotation
            self.cameraId = cameraId
            self.status = status
            self.uri = uri
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.framerate = p.float(0)
            self.bitrate = p.uint32(4)
            self.resolutionH = p.uint16(8)
            self.resolutionV = p.uint16(10)
            self.rotation = p.uint16(12)
            self.cameraId = p.uint8(14)
            self.status = p.uint8(15)
            self.uri = (0..<230).map { p.uint8(16 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.framerate, 0)
            w.put(self.bitrate, 4)
            w.put(self.resolutionH, 8)
            w.put(self.resolutionV, 10)
            w.put(self.rotation, 12)
            w.put(self.cameraId, 14)
            w.put(self.status, 15)
            for k in 0..<Swift.min(230, self.uri.count) { w.put(self.uri[k], 16 + k * 1) }
        }
    }
}

/// HERELINK_TELEM (#50003)
extension MAV {
    public struct HerelinkTelem: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 50003, name: "HERELINK_TELEM", crcExtra: 62, minLength: 19, length: 19)
        public var rfFreq: UInt32
        public var linkBw: UInt32
        public var linkRate: UInt32
        public var snr: Int16
        public var cpuTemp: Int16
        public var boardTemp: Int16
        public var rssi: UInt8

        public init(rfFreq: UInt32 = 0, linkBw: UInt32 = 0, linkRate: UInt32 = 0, snr: Int16 = 0, cpuTemp: Int16 = 0, boardTemp: Int16 = 0, rssi: UInt8 = 0) {
            self.rfFreq = rfFreq
            self.linkBw = linkBw
            self.linkRate = linkRate
            self.snr = snr
            self.cpuTemp = cpuTemp
            self.boardTemp = boardTemp
            self.rssi = rssi
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.rfFreq = p.uint32(0)
            self.linkBw = p.uint32(4)
            self.linkRate = p.uint32(8)
            self.snr = p.int16(12)
            self.cpuTemp = p.int16(14)
            self.boardTemp = p.int16(16)
            self.rssi = p.uint8(18)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.rfFreq, 0)
            w.put(self.linkBw, 4)
            w.put(self.linkRate, 8)
            w.put(self.snr, 12)
            w.put(self.cpuTemp, 14)
            w.put(self.boardTemp, 16)
            w.put(self.rssi, 18)
        }
    }
}

/// CUBEPILOT_FIRMWARE_UPDATE_START (#50004)
extension MAV {
    public struct CubepilotFirmwareUpdateStart: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 50004, name: "CUBEPILOT_FIRMWARE_UPDATE_START", crcExtra: 240, minLength: 10, length: 10)
        public var size: UInt32
        public var crc: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(size: UInt32 = 0, crc: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.size = size
            self.crc = crc
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.size = p.uint32(0)
            self.crc = p.uint32(4)
            self.targetSystem = p.uint8(8)
            self.targetComponent = p.uint8(9)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.size, 0)
            w.put(self.crc, 4)
            w.put(self.targetSystem, 8)
            w.put(self.targetComponent, 9)
        }
    }
}

/// CUBEPILOT_FIRMWARE_UPDATE_RESP (#50005)
extension MAV {
    public struct CubepilotFirmwareUpdateResp: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 50005, name: "CUBEPILOT_FIRMWARE_UPDATE_RESP", crcExtra: 152, minLength: 6, length: 6)
        public var offset: UInt32
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(offset: UInt32 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.offset = offset
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.offset = p.uint32(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.offset, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
        }
    }
}

/// AIRLINK_AUTH (#52000)
extension MAV {
    public struct AirlinkAuth: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 52000, name: "AIRLINK_AUTH", crcExtra: 13, minLength: 100, length: 100)
        public var login: [UInt8]
        public var password: [UInt8]

        public init(login: [UInt8] = [UInt8](repeating: 0, count: 50), password: [UInt8] = [UInt8](repeating: 0, count: 50)) {
            self.login = login
            self.password = password
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.login = (0..<50).map { p.uint8(0 + $0 * 1) }
            self.password = (0..<50).map { p.uint8(50 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(50, self.login.count) { w.put(self.login[k], 0 + k * 1) }
            for k in 0..<Swift.min(50, self.password.count) { w.put(self.password[k], 50 + k * 1) }
        }
    }
}

/// AIRLINK_AUTH_RESPONSE (#52001)
extension MAV {
    public struct AirlinkAuthResponse: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 52001, name: "AIRLINK_AUTH_RESPONSE", crcExtra: 239, minLength: 1, length: 1)
        public var respType: UInt8

        public init(respType: UInt8 = 0) {
            self.respType = respType
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.respType = p.uint8(0)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.respType, 0)
        }
    }
}

/// AUTOPILOT_STATE_FOR_GIMBAL_DEVICE_EXT (#60000)
extension MAV {
    public struct AutopilotStateForGimbalDeviceExt: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60000, name: "AUTOPILOT_STATE_FOR_GIMBAL_DEVICE_EXT", crcExtra: 4, minLength: 22, length: 22)
        public var timeBootUs: UInt64
        public var windX: Float
        public var windY: Float
        public var windCorrectionAngle: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8

        public init(timeBootUs: UInt64 = 0, windX: Float = 0, windY: Float = 0, windCorrectionAngle: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0) {
            self.timeBootUs = timeBootUs
            self.windX = windX
            self.windY = windY
            self.windCorrectionAngle = windCorrectionAngle
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootUs = p.uint64(0)
            self.windX = p.float(8)
            self.windY = p.float(12)
            self.windCorrectionAngle = p.float(16)
            self.targetSystem = p.uint8(20)
            self.targetComponent = p.uint8(21)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootUs, 0)
            w.put(self.windX, 8)
            w.put(self.windY, 12)
            w.put(self.windCorrectionAngle, 16)
            w.put(self.targetSystem, 20)
            w.put(self.targetComponent, 21)
        }
    }
}

/// STORM32_GIMBAL_MANAGER_INFORMATION (#60010)
extension MAV {
    public struct Storm32GimbalManagerInformation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60010, name: "STORM32_GIMBAL_MANAGER_INFORMATION", crcExtra: 208, minLength: 33, length: 33)
        public var deviceCapFlags: UInt32
        public var managerCapFlags: UInt32
        public var rollMin: Float
        public var rollMax: Float
        public var pitchMin: Float
        public var pitchMax: Float
        public var yawMin: Float
        public var yawMax: Float
        public var gimbalId: UInt8

        public init(deviceCapFlags: UInt32 = 0, managerCapFlags: UInt32 = 0, rollMin: Float = 0, rollMax: Float = 0, pitchMin: Float = 0, pitchMax: Float = 0, yawMin: Float = 0, yawMax: Float = 0, gimbalId: UInt8 = 0) {
            self.deviceCapFlags = deviceCapFlags
            self.managerCapFlags = managerCapFlags
            self.rollMin = rollMin
            self.rollMax = rollMax
            self.pitchMin = pitchMin
            self.pitchMax = pitchMax
            self.yawMin = yawMin
            self.yawMax = yawMax
            self.gimbalId = gimbalId
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.deviceCapFlags = p.uint32(0)
            self.managerCapFlags = p.uint32(4)
            self.rollMin = p.float(8)
            self.rollMax = p.float(12)
            self.pitchMin = p.float(16)
            self.pitchMax = p.float(20)
            self.yawMin = p.float(24)
            self.yawMax = p.float(28)
            self.gimbalId = p.uint8(32)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.deviceCapFlags, 0)
            w.put(self.managerCapFlags, 4)
            w.put(self.rollMin, 8)
            w.put(self.rollMax, 12)
            w.put(self.pitchMin, 16)
            w.put(self.pitchMax, 20)
            w.put(self.yawMin, 24)
            w.put(self.yawMax, 28)
            w.put(self.gimbalId, 32)
        }
    }
}

/// STORM32_GIMBAL_MANAGER_STATUS (#60011)
extension MAV {
    public struct Storm32GimbalManagerStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60011, name: "STORM32_GIMBAL_MANAGER_STATUS", crcExtra: 183, minLength: 7, length: 7)
        public var deviceFlags: UInt16
        public var managerFlags: UInt16
        public var gimbalId: UInt8
        public var supervisor: UInt8
        public var profile: UInt8

        public init(deviceFlags: UInt16 = 0, managerFlags: UInt16 = 0, gimbalId: UInt8 = 0, supervisor: UInt8 = 0, profile: UInt8 = 0) {
            self.deviceFlags = deviceFlags
            self.managerFlags = managerFlags
            self.gimbalId = gimbalId
            self.supervisor = supervisor
            self.profile = profile
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.deviceFlags = p.uint16(0)
            self.managerFlags = p.uint16(2)
            self.gimbalId = p.uint8(4)
            self.supervisor = p.uint8(5)
            self.profile = p.uint8(6)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.deviceFlags, 0)
            w.put(self.managerFlags, 2)
            w.put(self.gimbalId, 4)
            w.put(self.supervisor, 5)
            w.put(self.profile, 6)
        }
    }
}

/// STORM32_GIMBAL_MANAGER_CONTROL (#60012)
extension MAV {
    public struct Storm32GimbalManagerControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60012, name: "STORM32_GIMBAL_MANAGER_CONTROL", crcExtra: 99, minLength: 36, length: 36)
        public var q: [Float]
        public var angularVelocityX: Float
        public var angularVelocityY: Float
        public var angularVelocityZ: Float
        public var deviceFlags: UInt16
        public var managerFlags: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var gimbalId: UInt8
        public var client: UInt8

        public init(q: [Float] = [Float](repeating: 0, count: 4), angularVelocityX: Float = 0, angularVelocityY: Float = 0, angularVelocityZ: Float = 0, deviceFlags: UInt16 = 0, managerFlags: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, gimbalId: UInt8 = 0, client: UInt8 = 0) {
            self.q = q
            self.angularVelocityX = angularVelocityX
            self.angularVelocityY = angularVelocityY
            self.angularVelocityZ = angularVelocityZ
            self.deviceFlags = deviceFlags
            self.managerFlags = managerFlags
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.gimbalId = gimbalId
            self.client = client
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.q = (0..<4).map { p.float(0 + $0 * 4) }
            self.angularVelocityX = p.float(16)
            self.angularVelocityY = p.float(20)
            self.angularVelocityZ = p.float(24)
            self.deviceFlags = p.uint16(28)
            self.managerFlags = p.uint16(30)
            self.targetSystem = p.uint8(32)
            self.targetComponent = p.uint8(33)
            self.gimbalId = p.uint8(34)
            self.client = p.uint8(35)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            for k in 0..<Swift.min(4, self.q.count) { w.put(self.q[k], 0 + k * 4) }
            w.put(self.angularVelocityX, 16)
            w.put(self.angularVelocityY, 20)
            w.put(self.angularVelocityZ, 24)
            w.put(self.deviceFlags, 28)
            w.put(self.managerFlags, 30)
            w.put(self.targetSystem, 32)
            w.put(self.targetComponent, 33)
            w.put(self.gimbalId, 34)
            w.put(self.client, 35)
        }
    }
}

/// STORM32_GIMBAL_MANAGER_CONTROL_PITCHYAW (#60013)
extension MAV {
    public struct Storm32GimbalManagerControlPitchyaw: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60013, name: "STORM32_GIMBAL_MANAGER_CONTROL_PITCHYAW", crcExtra: 129, minLength: 24, length: 24)
        public var pitch: Float
        public var yaw: Float
        public var pitchRate: Float
        public var yawRate: Float
        public var deviceFlags: UInt16
        public var managerFlags: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var gimbalId: UInt8
        public var client: UInt8

        public init(pitch: Float = 0, yaw: Float = 0, pitchRate: Float = 0, yawRate: Float = 0, deviceFlags: UInt16 = 0, managerFlags: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, gimbalId: UInt8 = 0, client: UInt8 = 0) {
            self.pitch = pitch
            self.yaw = yaw
            self.pitchRate = pitchRate
            self.yawRate = yawRate
            self.deviceFlags = deviceFlags
            self.managerFlags = managerFlags
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.gimbalId = gimbalId
            self.client = client
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.pitch = p.float(0)
            self.yaw = p.float(4)
            self.pitchRate = p.float(8)
            self.yawRate = p.float(12)
            self.deviceFlags = p.uint16(16)
            self.managerFlags = p.uint16(18)
            self.targetSystem = p.uint8(20)
            self.targetComponent = p.uint8(21)
            self.gimbalId = p.uint8(22)
            self.client = p.uint8(23)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.pitch, 0)
            w.put(self.yaw, 4)
            w.put(self.pitchRate, 8)
            w.put(self.yawRate, 12)
            w.put(self.deviceFlags, 16)
            w.put(self.managerFlags, 18)
            w.put(self.targetSystem, 20)
            w.put(self.targetComponent, 21)
            w.put(self.gimbalId, 22)
            w.put(self.client, 23)
        }
    }
}

/// STORM32_GIMBAL_MANAGER_CORRECT_ROLL (#60014)
extension MAV {
    public struct Storm32GimbalManagerCorrectRoll: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60014, name: "STORM32_GIMBAL_MANAGER_CORRECT_ROLL", crcExtra: 134, minLength: 8, length: 8)
        public var roll: Float
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var gimbalId: UInt8
        public var client: UInt8

        public init(roll: Float = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, gimbalId: UInt8 = 0, client: UInt8 = 0) {
            self.roll = roll
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.gimbalId = gimbalId
            self.client = client
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.roll = p.float(0)
            self.targetSystem = p.uint8(4)
            self.targetComponent = p.uint8(5)
            self.gimbalId = p.uint8(6)
            self.client = p.uint8(7)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.roll, 0)
            w.put(self.targetSystem, 4)
            w.put(self.targetComponent, 5)
            w.put(self.gimbalId, 6)
            w.put(self.client, 7)
        }
    }
}

/// QSHOT_STATUS (#60020)
extension MAV {
    public struct QshotStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60020, name: "QSHOT_STATUS", crcExtra: 202, minLength: 4, length: 4)
        public var mode: UInt16
        public var shotState: UInt16

        public init(mode: UInt16 = 0, shotState: UInt16 = 0) {
            self.mode = mode
            self.shotState = shotState
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.mode = p.uint16(0)
            self.shotState = p.uint16(2)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.mode, 0)
            w.put(self.shotState, 2)
        }
    }
}

/// FRSKY_PASSTHROUGH_ARRAY (#60040)
extension MAV {
    public struct FrskyPassthroughArray: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60040, name: "FRSKY_PASSTHROUGH_ARRAY", crcExtra: 156, minLength: 245, length: 245)
        public var timeBootMs: UInt32
        public var count: UInt8
        public var packetBuf: [UInt8]

        public init(timeBootMs: UInt32 = 0, count: UInt8 = 0, packetBuf: [UInt8] = [UInt8](repeating: 0, count: 240)) {
            self.timeBootMs = timeBootMs
            self.count = count
            self.packetBuf = packetBuf
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.count = p.uint8(4)
            self.packetBuf = (0..<240).map { p.uint8(5 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.count, 4)
            for k in 0..<Swift.min(240, self.packetBuf.count) { w.put(self.packetBuf[k], 5 + k * 1) }
        }
    }
}

/// PARAM_VALUE_ARRAY (#60041)
extension MAV {
    public struct ParamValueArray: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60041, name: "PARAM_VALUE_ARRAY", crcExtra: 191, minLength: 255, length: 255)
        public var paramCount: UInt16
        public var paramIndexFirst: UInt16
        public var flags: UInt16
        public var paramArrayLen: UInt8
        public var packetBuf: [UInt8]

        public init(paramCount: UInt16 = 0, paramIndexFirst: UInt16 = 0, flags: UInt16 = 0, paramArrayLen: UInt8 = 0, packetBuf: [UInt8] = [UInt8](repeating: 0, count: 248)) {
            self.paramCount = paramCount
            self.paramIndexFirst = paramIndexFirst
            self.flags = flags
            self.paramArrayLen = paramArrayLen
            self.packetBuf = packetBuf
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.paramCount = p.uint16(0)
            self.paramIndexFirst = p.uint16(2)
            self.flags = p.uint16(4)
            self.paramArrayLen = p.uint8(6)
            self.packetBuf = (0..<248).map { p.uint8(7 + $0 * 1) }
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.paramCount, 0)
            w.put(self.paramIndexFirst, 2)
            w.put(self.flags, 4)
            w.put(self.paramArrayLen, 6)
            for k in 0..<Swift.min(248, self.packetBuf.count) { w.put(self.packetBuf[k], 7 + k * 1) }
        }
    }
}

/// MLRS_RADIO_LINK_STATS (#60045)
extension MAV {
    public struct MlrsRadioLinkStats: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60045, name: "MLRS_RADIO_LINK_STATS", crcExtra: 14, minLength: 15, length: 23)
        public var flags: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var rxLQRc: UInt8
        public var rxLQSer: UInt8
        public var rxRssi1: UInt8
        public var rxSnr1: Int8
        public var txLQSer: UInt8
        public var txRssi1: UInt8
        public var txSnr1: Int8
        public var rxRssi2: UInt8
        public var rxSnr2: Int8
        public var txRssi2: UInt8
        public var txSnr2: Int8
        public var frequency1: Float  // extension field
        public var frequency2: Float  // extension field

        public init(flags: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, rxLQRc: UInt8 = 0, rxLQSer: UInt8 = 0, rxRssi1: UInt8 = 0, rxSnr1: Int8 = 0, txLQSer: UInt8 = 0, txRssi1: UInt8 = 0, txSnr1: Int8 = 0, rxRssi2: UInt8 = 0, rxSnr2: Int8 = 0, txRssi2: UInt8 = 0, txSnr2: Int8 = 0, frequency1: Float = 0, frequency2: Float = 0) {
            self.flags = flags
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.rxLQRc = rxLQRc
            self.rxLQSer = rxLQSer
            self.rxRssi1 = rxRssi1
            self.rxSnr1 = rxSnr1
            self.txLQSer = txLQSer
            self.txRssi1 = txRssi1
            self.txSnr1 = txSnr1
            self.rxRssi2 = rxRssi2
            self.rxSnr2 = rxSnr2
            self.txRssi2 = txRssi2
            self.txSnr2 = txSnr2
            self.frequency1 = frequency1
            self.frequency2 = frequency2
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.flags = p.uint16(0)
            self.targetSystem = p.uint8(2)
            self.targetComponent = p.uint8(3)
            self.rxLQRc = p.uint8(4)
            self.rxLQSer = p.uint8(5)
            self.rxRssi1 = p.uint8(6)
            self.rxSnr1 = p.int8(7)
            self.txLQSer = p.uint8(8)
            self.txRssi1 = p.uint8(9)
            self.txSnr1 = p.int8(10)
            self.rxRssi2 = p.uint8(11)
            self.rxSnr2 = p.int8(12)
            self.txRssi2 = p.uint8(13)
            self.txSnr2 = p.int8(14)
            self.frequency1 = p.float(15)
            self.frequency2 = p.float(19)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.flags, 0)
            w.put(self.targetSystem, 2)
            w.put(self.targetComponent, 3)
            w.put(self.rxLQRc, 4)
            w.put(self.rxLQSer, 5)
            w.put(self.rxRssi1, 6)
            w.put(self.rxSnr1, 7)
            w.put(self.txLQSer, 8)
            w.put(self.txRssi1, 9)
            w.put(self.txSnr1, 10)
            w.put(self.rxRssi2, 11)
            w.put(self.rxSnr2, 12)
            w.put(self.txRssi2, 13)
            w.put(self.txSnr2, 14)
            w.put(self.frequency1, 15)
            w.put(self.frequency2, 19)
        }
    }
}

/// MLRS_RADIO_LINK_INFORMATION (#60046)
extension MAV {
    public struct MlrsRadioLinkInformation: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60046, name: "MLRS_RADIO_LINK_INFORMATION", crcExtra: 171, minLength: 28, length: 28)
        public var txFrameRate: UInt16
        public var rxFrameRate: UInt16
        public var txSerDataRate: UInt16
        public var rxSerDataRate: UInt16
        public var targetSystem: UInt8
        public var targetComponent: UInt8
        public var type: UInt8
        public var mode: UInt8
        public var txPower: Int8
        public var rxPower: Int8
        public var modeStr: [UInt8]
        public var bandStr: [UInt8]
        public var txReceiveSensitivity: UInt8
        public var rxReceiveSensitivity: UInt8

        public init(txFrameRate: UInt16 = 0, rxFrameRate: UInt16 = 0, txSerDataRate: UInt16 = 0, rxSerDataRate: UInt16 = 0, targetSystem: UInt8 = 0, targetComponent: UInt8 = 0, type: UInt8 = 0, mode: UInt8 = 0, txPower: Int8 = 0, rxPower: Int8 = 0, modeStr: [UInt8] = [UInt8](repeating: 0, count: 6), bandStr: [UInt8] = [UInt8](repeating: 0, count: 6), txReceiveSensitivity: UInt8 = 0, rxReceiveSensitivity: UInt8 = 0) {
            self.txFrameRate = txFrameRate
            self.rxFrameRate = rxFrameRate
            self.txSerDataRate = txSerDataRate
            self.rxSerDataRate = rxSerDataRate
            self.targetSystem = targetSystem
            self.targetComponent = targetComponent
            self.type = type
            self.mode = mode
            self.txPower = txPower
            self.rxPower = rxPower
            self.modeStr = modeStr
            self.bandStr = bandStr
            self.txReceiveSensitivity = txReceiveSensitivity
            self.rxReceiveSensitivity = rxReceiveSensitivity
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.txFrameRate = p.uint16(0)
            self.rxFrameRate = p.uint16(2)
            self.txSerDataRate = p.uint16(4)
            self.rxSerDataRate = p.uint16(6)
            self.targetSystem = p.uint8(8)
            self.targetComponent = p.uint8(9)
            self.type = p.uint8(10)
            self.mode = p.uint8(11)
            self.txPower = p.int8(12)
            self.rxPower = p.int8(13)
            self.modeStr = (0..<6).map { p.uint8(14 + $0 * 1) }
            self.bandStr = (0..<6).map { p.uint8(20 + $0 * 1) }
            self.txReceiveSensitivity = p.uint8(26)
            self.rxReceiveSensitivity = p.uint8(27)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.txFrameRate, 0)
            w.put(self.rxFrameRate, 2)
            w.put(self.txSerDataRate, 4)
            w.put(self.rxSerDataRate, 6)
            w.put(self.targetSystem, 8)
            w.put(self.targetComponent, 9)
            w.put(self.type, 10)
            w.put(self.mode, 11)
            w.put(self.txPower, 12)
            w.put(self.rxPower, 13)
            for k in 0..<Swift.min(6, self.modeStr.count) { w.put(self.modeStr[k], 14 + k * 1) }
            for k in 0..<Swift.min(6, self.bandStr.count) { w.put(self.bandStr[k], 20 + k * 1) }
            w.put(self.txReceiveSensitivity, 26)
            w.put(self.rxReceiveSensitivity, 27)
        }
    }
}

/// MLRS_RADIO_LINK_FLOW_CONTROL (#60047)
extension MAV {
    public struct MlrsRadioLinkFlowControl: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60047, name: "MLRS_RADIO_LINK_FLOW_CONTROL", crcExtra: 55, minLength: 7, length: 7)
        public var txSerRate: UInt16
        public var rxSerRate: UInt16
        public var txUsedSerBandwidth: UInt8
        public var rxUsedSerBandwidth: UInt8
        public var txbuf: UInt8

        public init(txSerRate: UInt16 = 0, rxSerRate: UInt16 = 0, txUsedSerBandwidth: UInt8 = 0, rxUsedSerBandwidth: UInt8 = 0, txbuf: UInt8 = 0) {
            self.txSerRate = txSerRate
            self.rxSerRate = rxSerRate
            self.txUsedSerBandwidth = txUsedSerBandwidth
            self.rxUsedSerBandwidth = rxUsedSerBandwidth
            self.txbuf = txbuf
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.txSerRate = p.uint16(0)
            self.rxSerRate = p.uint16(2)
            self.txUsedSerBandwidth = p.uint8(4)
            self.rxUsedSerBandwidth = p.uint8(5)
            self.txbuf = p.uint8(6)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.txSerRate, 0)
            w.put(self.rxSerRate, 2)
            w.put(self.txUsedSerBandwidth, 4)
            w.put(self.rxUsedSerBandwidth, 5)
            w.put(self.txbuf, 6)
        }
    }
}

/// AVSS_PRS_SYS_STATUS (#60050)
extension MAV {
    public struct AvssPrsSysStatus: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60050, name: "AVSS_PRS_SYS_STATUS", crcExtra: 220, minLength: 14, length: 14)
        public var timeBootMs: UInt32
        public var errorStatus: UInt32
        public var batteryStatus: UInt32
        public var armStatus: UInt8
        public var chargeStatus: UInt8

        public init(timeBootMs: UInt32 = 0, errorStatus: UInt32 = 0, batteryStatus: UInt32 = 0, armStatus: UInt8 = 0, chargeStatus: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.errorStatus = errorStatus
            self.batteryStatus = batteryStatus
            self.armStatus = armStatus
            self.chargeStatus = chargeStatus
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.errorStatus = p.uint32(4)
            self.batteryStatus = p.uint32(8)
            self.armStatus = p.uint8(12)
            self.chargeStatus = p.uint8(13)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.errorStatus, 4)
            w.put(self.batteryStatus, 8)
            w.put(self.armStatus, 12)
            w.put(self.chargeStatus, 13)
        }
    }
}

/// AVSS_DRONE_POSITION (#60051)
extension MAV {
    public struct AvssDronePosition: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60051, name: "AVSS_DRONE_POSITION", crcExtra: 245, minLength: 24, length: 24)
        public var timeBootMs: UInt32
        public var lat: Int32
        public var lon: Int32
        public var alt: Int32
        public var groundAlt: Float
        public var barometerAlt: Float

        public init(timeBootMs: UInt32 = 0, lat: Int32 = 0, lon: Int32 = 0, alt: Int32 = 0, groundAlt: Float = 0, barometerAlt: Float = 0) {
            self.timeBootMs = timeBootMs
            self.lat = lat
            self.lon = lon
            self.alt = alt
            self.groundAlt = groundAlt
            self.barometerAlt = barometerAlt
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.lat = p.int32(4)
            self.lon = p.int32(8)
            self.alt = p.int32(12)
            self.groundAlt = p.float(16)
            self.barometerAlt = p.float(20)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.lat, 4)
            w.put(self.lon, 8)
            w.put(self.alt, 12)
            w.put(self.groundAlt, 16)
            w.put(self.barometerAlt, 20)
        }
    }
}

/// AVSS_DRONE_IMU (#60052)
extension MAV {
    public struct AvssDroneImu: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60052, name: "AVSS_DRONE_IMU", crcExtra: 101, minLength: 44, length: 44)
        public var timeBootMs: UInt32
        public var q1: Float
        public var q2: Float
        public var q3: Float
        public var q4: Float
        public var xacc: Float
        public var yacc: Float
        public var zacc: Float
        public var xgyro: Float
        public var ygyro: Float
        public var zgyro: Float

        public init(timeBootMs: UInt32 = 0, q1: Float = 0, q2: Float = 0, q3: Float = 0, q4: Float = 0, xacc: Float = 0, yacc: Float = 0, zacc: Float = 0, xgyro: Float = 0, ygyro: Float = 0, zgyro: Float = 0) {
            self.timeBootMs = timeBootMs
            self.q1 = q1
            self.q2 = q2
            self.q3 = q3
            self.q4 = q4
            self.xacc = xacc
            self.yacc = yacc
            self.zacc = zacc
            self.xgyro = xgyro
            self.ygyro = ygyro
            self.zgyro = zgyro
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.q1 = p.float(4)
            self.q2 = p.float(8)
            self.q3 = p.float(12)
            self.q4 = p.float(16)
            self.xacc = p.float(20)
            self.yacc = p.float(24)
            self.zacc = p.float(28)
            self.xgyro = p.float(32)
            self.ygyro = p.float(36)
            self.zgyro = p.float(40)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.q1, 4)
            w.put(self.q2, 8)
            w.put(self.q3, 12)
            w.put(self.q4, 16)
            w.put(self.xacc, 20)
            w.put(self.yacc, 24)
            w.put(self.zacc, 28)
            w.put(self.xgyro, 32)
            w.put(self.ygyro, 36)
            w.put(self.zgyro, 40)
        }
    }
}

/// AVSS_DRONE_OPERATION_MODE (#60053)
extension MAV {
    public struct AvssDroneOperationMode: MAVLinkMessage, Equatable {
        public static let mavInfo = MAVMessageInfo(id: 60053, name: "AVSS_DRONE_OPERATION_MODE", crcExtra: 45, minLength: 6, length: 6)
        public var timeBootMs: UInt32
        public var M300OperationMode: UInt8
        public var horseflyOperationMode: UInt8

        public init(timeBootMs: UInt32 = 0, M300OperationMode: UInt8 = 0, horseflyOperationMode: UInt8 = 0) {
            self.timeBootMs = timeBootMs
            self.M300OperationMode = M300OperationMode
            self.horseflyOperationMode = horseflyOperationMode
        }

        public init(payload p: MAVLinkPayloadReader) {
            self.timeBootMs = p.uint32(0)
            self.M300OperationMode = p.uint8(4)
            self.horseflyOperationMode = p.uint8(5)
        }

        public func encode(into w: inout MAVLinkPayloadWriter) {
            w.put(self.timeBootMs, 0)
            w.put(self.M300OperationMode, 4)
            w.put(self.horseflyOperationMode, 5)
        }
    }
}
