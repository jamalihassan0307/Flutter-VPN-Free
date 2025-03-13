import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/ad_helper.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/vpn_engine.dart';

class HomeController extends GetxController {
  final vpn = Vpn(
    hostname: '',
    ip: '',
    ping: '',
    speed: '',
    countryLong: '',
    countryShort: '',
    numVpnSessions: 0,
    config: '',
  ).obs;
  final vpnState = VpnEngine.vpnDisconnected.obs;

  void connectToVpn() async {
    if (vpn.value.config.isEmpty) {
      Get.snackbar('Selection Required', 'Please select a VPN configuration first!');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      try {
        await VpnEngine.startVpn(vpn.value.config);
      } catch (e) {
        Get.snackbar('Connection Failed', 'Error: ${e.toString()}');
      }
    } else {
      await VpnEngine.stopVpn();
    }
  }

  // vpn buttons color
  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Colors.blue;

      case VpnEngine.vpnConnected:
        return Colors.green;

      default:
        return Colors.orangeAccent;
    }
  }

  // vpn button text
  String get getButtonText {
    if (vpnState.value == VpnEngine.vpnDisconnected) return 'Connect VPN';
    if (vpnState.value == VpnEngine.vpnConnected) return 'Disconnect VPN';
    return 'Connecting...';
  }
}
