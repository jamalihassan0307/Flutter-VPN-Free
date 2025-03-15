/*
 * Copyright (c) 2020 Mochamad Nizwar Syafuan
 * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:open_nizvpn/core/models/dnsConfig.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/vpnStatus.dart';
import '../models/vpnConfig.dart';
// import 'package:package_info/package_info.dart';

class AliVpn {
  static final _eventChannel = EventChannel(_eventChannelVpnStage);
  static final _statusController = StreamController<String>.broadcast();

  static Stream<String> vpnStageSnapshot() {
    print('VPN Stage Snapshot requested');
    _eventChannel.receiveBroadcastStream().listen((event) {
      String status = event.toString();
      print('Native VPN Event: $status');

      // Parse OpenVPN status messages
      if (status.contains("CONNECTED") && status.contains("SUCCESS")) {
        _emitStatus("CONNECTED");
      } else if (status == "DISCONNECTED") {
        _emitStatus("DISCONNECTED");
      } else if (status == "CONNECTING") {
        _emitStatus("CONNECTING");
      } else if (status == "AUTHENTICATING") {
        _emitStatus("AUTHENTICATING");
      } else {
        _emitStatus(status);
      }
    });
    return _statusController.stream;
  }

  static void _emitStatus(String status) {
    print('Emitting VPN status: $status');
    _statusController.add(status);
  }

  ///Channel to native
  static final String _eventChannelVpnStage = "id.nizwar.nvpn/vpnstage";
  static final String _eventChannelVpnStatus = "id.nizwar.nvpn/vpnstatus";
  static final String _methodChannelVpnControl = "id.nizwar.nvpn/vpncontrol";

  ///Snapshot of VPN Connection Status
  static Stream<VpnStatus?> vpnStatusSnapshot() => EventChannel(_eventChannelVpnStatus)
      .receiveBroadcastStream()
      .map((event) => VpnStatus.fromJson(jsonDecode(event)))
      .cast();

  ///Start VPN easily
  static Future<void> startVpn(VpnConfig vpnConfig, {DnsConfig? dns}) async {
    try {
      final package = await PackageInfo.fromPlatform();

      return await MethodChannel(_methodChannelVpnControl).invokeMethod(
        "start",
        {
          "config": vpnConfig.config,
          "country": vpnConfig.name,
          "username": vpnConfig.username ?? "",
          "password": vpnConfig.password ?? "",
          "dns1": dns?.dns1,
          "dns2": dns?.dns2,
          "bypass_packages": [package.packageName],
        },
      );
    } catch (e) {
      print('Error starting VPN: $e');
      _emitStatus("DISCONNECTED");
      rethrow;
    }
  }

  ///Stop vpn
  static Future<void> stopVpn() => MethodChannel(_methodChannelVpnControl).invokeMethod("stop");

  ///Open VPN Settings
  static Future<void> openKillSwitch() => MethodChannel(_methodChannelVpnControl).invokeMethod("kill_switch");

  ///Trigger native to get stage connection
  static Future<void> refreshStage() => MethodChannel(_methodChannelVpnControl).invokeMethod("refresh");

  ///Get latest stage
  static Future<String?> stage() => MethodChannel(_methodChannelVpnControl).invokeMethod("stage");

  ///Check if vpn is connected
  static Future<bool> isConnected() => stage().then((value) => value?.toLowerCase() == "connected");

  ///All Stages of connection
  static const String vpnConnected = "connected";
  static const String vpnDisconnected = "disconnected";
  static const String vpnWaitConnection = "wait_connection";
  static const String vpnAuthenticating = "authenticating";
  static const String vpnReconnect = "reconnect";
  static const String vpnNoConnection = "no_connection";
  static const String vpnConnecting = "connecting";
  static const String vpnPrepare = "prepare";
  static const String vpnDenied = "denied";
}
