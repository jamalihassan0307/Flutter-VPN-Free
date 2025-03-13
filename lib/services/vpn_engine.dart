import 'dart:async';
import 'package:flutter/services.dart';
import '../models/vpn_status.dart';

class VpnEngine {
  static const _platform = MethodChannel('vpn_engine');
  static final _statusController = StreamController<String>.broadcast();
  static bool _prepared = false;

  ///Snapshot of VPN Connection Stage
  static Stream<String> vpnStageSnapshot() {
    print('VPN Stage Snapshot requested');
    return _statusController.stream;
  }

  ///Snapshot of VPN Connection Status
  static Stream<VpnStatus?> vpnStatusSnapshot() {
    print('VPN Status Snapshot requested');
    return _statusController.stream.map((event) {
      print('VPN Status update: $event');
      return VpnStatus(byteIn: event, byteOut: event);
    });
  }

  ///Start VPN easily
  static Future<void> startVpn(String config) async {
    print('Starting VPN with config: ${config.substring(0, 20)}...');
    try {
      await _platform.invokeMethod('startVpn', {'config': config});
      print('VPN start command sent successfully');
      _emitStatus(vpnConnecting);
    } catch (e) {
      print('Error starting VPN: $e');
      _emitStatus(vpnDisconnected);
      throw e;
    }
  }

  ///Stop vpn
  static Future<void> stopVpn() async {
    print('Stopping VPN');
    try {
      await _platform.invokeMethod('stopVpn');
      print('VPN stop command sent successfully');
      _emitStatus(vpnDisconnected);
    } catch (e) {
      print('Error stopping VPN: $e');
      throw e;
    }
  }

  ///Open VPN Settings
  static Future<void> openKillSwitch() {
    print('Opening kill switch settings');
    return _platform.invokeMethod("kill_switch");
  }

  ///Trigger native to get stage connection
  static Future<void> refreshStage() {
    print('Refreshing VPN stage');
    return _platform.invokeMethod("refresh");
  }

  ///Get latest stage
  static Future<String?> stage() async {
    print('Getting current VPN stage');
    final result = await _platform.invokeMethod("stage");
    print('Current stage: $result');
    return result;
  }

  ///Check if vpn is connected
  static Future<bool> isConnected() async {
    print('Checking if VPN is connected');
    final result = await _platform.invokeMethod<bool>("check") ?? false;
    print('VPN connected: $result');
    return result;
  }

  ///All Stages of connection
  static const String vpnConnected = "CONNECTED";
  static const String vpnDisconnected = "DISCONNECTED";
  static const String vpnWaiting = "WAITING";
  static const String vpnAuthenticating = "AUTHENTICATING";
  static const String vpnReconnect = "RECONNECT";
  static const String vpnNoConnection = "NO_CONNECTION";
  static const String vpnConnecting = "CONNECTING";
  static const String vpnPrepare = "PREPARE";
  static const String vpnDenied = "DENIED";

  ///Initialize VPN Engine
  static Future<void> initialize() async {
    print('Initializing VPN engine');
    if (!_prepared) {
      try {
        await _platform.invokeMethod('prepare');
        _prepared = true;
        print('VPN engine initialized successfully');
        _setupMethodCallHandler();
      } catch (e) {
        print('Error initializing VPN engine: $e');
        throw e;
      }
    } else {
      print('VPN engine already initialized');
    }
  }

  // Helper method to emit status updates
  static void _emitStatus(String status) {
    print('Emitting VPN status: $status');
    _statusController.add(status);
  }

  static void _setupMethodCallHandler() {
    _platform.setMethodCallHandler((call) async {
      print('Received method call: ${call.method}');
      switch (call.method) {
        case 'onVpnPermissionGranted':
          print('VPN permission granted');
          _emitStatus(vpnPrepare);
          break;
        case 'onVpnPermissionDenied':
          print('VPN permission denied');
          _emitStatus(vpnDenied);
          break;
        case 'updateStatus':
          final status = call.arguments as String;
          print('VPN status update: $status');
          _emitStatus(status);
          break;
      }
    });
  }
}
