// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../helpers/ad_helper.dart';
// import '../helpers/my_dialogs.dart';
// import '../helpers/pref.dart';
import '../models/vpn.dart';
// import '../models/vpn_config.dart';
import '../services/vpn_engine.dart';
import '../services/vpn_service.dart';

class HomeController extends GetxController {
  final vpn = Vpn(
    hostname: '',
    ip: '',
    ping: '',
    speed: '',
    countryLong: '',
    countryShort: '',
    imagePath: '',
    vpnConfigPath: '',
  ).obs;
  final vpnState = VpnEngine.vpnDisconnected.obs;

  void selectFirstVpn(List<Vpn> vpnList) {
    // if (vpnList.isNotEmpty && vpn.value.config.isEmpty) {
    //   vpn.value = vpnList[0];
    //   print('Auto-selected first VPN: ${vpn.value.hostname}');
    // }
  }

  void connectToVpn() async {
    // if (vpn.value.config.isEmpty) {
    //   print('No VPN Selected');
    //   Get.snackbar('Selection Required', 'Please select a VPN server first');
    //   return;
    // }

    // if (vpnState.value == VpnEngine.vpnDisconnected) {
    //   try {
    //     await VpnService.startVpn(vpn.value.config);
    //     Get.snackbar('Connection Successful', 'Connected to ${vpn.value.countryLong}',
    //         backgroundColor: Colors.green, colorText: Colors.white);
    //   } catch (e) {
    //     Get.snackbar('Connection Failed', 'Error: ${e.toString()}');
    //   }
    // } else {
    //   await VpnService.stopVpn();
    // }
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
