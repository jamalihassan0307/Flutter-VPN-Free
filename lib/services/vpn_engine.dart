import 'dart:async';
import 'package:flutter/services.dart';
import '../models/vpn_status.dart';

class VpnEngine {
  static const MethodChannel _channel = MethodChannel('vpn_engine');
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
  static Future<void> startVpn() async {
    print('Starting VPN');
    try {
      await _channel.invokeMethod('start');
      print('VPN start command sent successfully');
      _emitStatus(vpnConnecting);
    } on PlatformException catch (e) {
      print('Error starting VPN: ${e.message}');
      _emitStatus(vpnDisconnected);
    }
  }

  ///Stop vpn
  static Future<void> stopVpn() async {
    print('Stopping VPN');
    try {
      await _channel.invokeMethod('stop');
      print('VPN stop command sent successfully');
      _emitStatus(vpnDisconnected);
    } on PlatformException catch (e) {
      print('Error stopping VPN: ${e.message}');
    }
  }

  ///Open VPN Settings
  static Future<void> openKillSwitch() {
    print('Opening kill switch settings');
    return _channel.invokeMethod("kill_switch");
  }

  ///Trigger native to get stage connection
  static Future<void> refreshStage() {
    print('Refreshing VPN stage');
    return _channel.invokeMethod("refresh");
  }

  ///Get latest stage
  static Future<String?> stage() async {
    print('Getting current VPN stage');
    final result = await _channel.invokeMethod("stage");
    print('Current stage: $result');
    return result;
  }

  ///Check if vpn is connected
  static Future<bool> isConnected() async {
    print('Checking if VPN is connected');
    final result = await _channel.invokeMethod<bool>("check") ?? false;
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
  static Future<bool> initialize() async {
    print('Initializing VPN engine');
    if (!_prepared) {
      try {
        final bool prepared = await _channel.invokeMethod('prepare');
        _prepared = true;
        print('VPN engine initialized successfully');
        _setupMethodCallHandler();
        return prepared;
      } on PlatformException catch (e) {
        print('Error initializing VPN engine: ${e.message}');
        return false;
      }
    } else {
      print('VPN engine already initialized');
      return true;
    }
  }

  // Helper method to emit status updates
  static void _emitStatus(String status) {
    print('Emitting VPN status: $status');
    _statusController.add(status);
  }

  static void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
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
