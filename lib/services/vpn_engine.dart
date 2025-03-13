import 'dart:async';
import 'package:flutter/services.dart';
import '../models/vpn_status.dart';

class VpnEngine {
  static const _platform = MethodChannel('vpn_engine');
  static final _statusController = StreamController<String>.broadcast();
  static bool _prepared = false;

  ///Snapshot of VPN Connection Stage
  static Stream<String> vpnStageSnapshot() => _statusController.stream;

  ///Snapshot of VPN Connection Status
  static Stream<VpnStatus?> vpnStatusSnapshot() {
    return _statusController.stream.map((event) => VpnStatus(byteIn: event, byteOut: event));
  }

  ///Start VPN easily
  static Future<void> startVpn(String config) async {
    await _platform.invokeMethod('startVpn', {'config': config});
  }

  ///Stop vpn
  static Future<void> stopVpn() async {
    await _platform.invokeMethod('stopVpn');
  }

  ///Open VPN Settings
  static Future<void> openKillSwitch() => _platform.invokeMethod("kill_switch");

  ///Trigger native to get stage connection
  static Future<void> refreshStage() => _platform.invokeMethod("refresh");

  ///Get latest stage
  static Future<String?> stage() => _platform.invokeMethod("stage");

  ///Check if vpn is connected
  static Future<bool> isConnected() => stage().then((value) => value?.toLowerCase() == "connected");

  ///All Stages of connection
  static const String vpnConnected = "CONNECTED";
  static const String vpnDisconnected = "DISCONNECTED";
  static const String vpnWaitConnection = "WAIT";
  static const String vpnAuthenticating = "AUTH";
  static const String vpnReconnect = "RECONNECT";
  static const String vpnNoConnection = "NO_CONNECTION";
  static const String vpnConnecting = "CONNECTING";
  static const String vpnPreparing = "PREPARING";
  static const String vpnDenied = "DENIED";

  static Future<void> initialize() async {
    if (!_prepared) {
      await _platform.invokeMethod('prepare');
      _prepared = true;
    }
  }
}
