import 'dart:async';
import 'package:flutter/services.dart';
import '../models/vpn_status.dart';

class VpnService {
  static const platform = MethodChannel('vpn_channel');
  static const eventChannel = EventChannel('vpn_status');
  static final _statusController = StreamController<String>.broadcast();
  static bool _prepared = false;

  static Stream<String> vpnStageSnapshot() => _statusController.stream;
  
  static Stream<VpnStatus?> vpnStatusSnapshot() {
    return _statusController.stream.map((event) => 
      VpnStatus(byteIn: event, byteOut: event)
    );
  }

  static Future<void> initialize() async {
    if (!_prepared) {
      await platform.invokeMethod('prepare');
      _prepared = true;
      _setupEventListener();
    }
  }

  static void _setupEventListener() {
    eventChannel.receiveBroadcastStream().listen((event) {
      _statusController.add(event.toString());
    });
  }

  static Future<void> startVpn(String config) async {
    try {
      await platform.invokeMethod('startVpn', {'config': config});
    } catch (e) {
      print('Error starting VPN: $e');
      rethrow;
    }
  }

  static Future<void> stopVpn() async {
    try {
      await platform.invokeMethod('stopVpn');
    } catch (e) {
      print('Error stopping VPN: $e');
      rethrow;
    }
  }
} 