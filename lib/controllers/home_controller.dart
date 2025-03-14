// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

// import '../helpers/ad_helper.dart';
// import '../helpers/my_dialogs.dart';
// import '../helpers/pref.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/vpn_service.dart';

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

  final vpnState = VpnService.vpnDisconnected.obs;
  final List<VpnConfig> _vpnConfigs = [];

  @override
  void onInit() {
    super.onInit();
    _loadVpnConfigs();
    _initVpnService();
  }

  Future<void> _loadVpnConfigs() async {
    // Load VPN configs from assets
    final configFiles = [
      'Ecuador',
      'Indonesia',
      'Korea Republic of',
      'Romania',
      'Russian Federation',
      'Taiwan',
      'United States',
      'Viet Nam'
    ];

    for (var country in configFiles) {
      final config = await rootBundle.loadString('assets/vpn/$country.ovpn');
      _vpnConfigs.add(VpnConfig(name: country, config: config));
    }
  }

  Future<void> _initVpnService() async {
    await VpnService.initialize();
    VpnService.vpnStageSnapshot().listen((state) {
      vpnState.value = state;
    });
  }

  Future<void> connectToVpn() async {
    if (vpn.value.config.isEmpty) {
      Get.snackbar('Error', 'Please select a VPN server first');
      return;
    }

    try {
      if (vpnState.value == VpnService.vpnDisconnected) {
        await VpnService.startVpn(vpn.value.config);
      } else {
        await VpnService.stopVpn();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // vpn buttons color
  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnService.vpnDisconnected:
        return Colors.blue;

      case VpnService.vpnConnected:
        return Colors.green;

      default:
        return Colors.orangeAccent;
    }
  }

  // vpn button text
  String get getButtonText {
    if (vpnState.value == VpnService.vpnDisconnected) return 'Connect VPN';
    if (vpnState.value == VpnService.vpnConnected) return 'Disconnect VPN';
    return 'Connecting...';
  }

  void selectFirstVpn(List<Vpn> vpnList) {
    if (vpnList.isNotEmpty && vpn.value.config.isEmpty) {
      vpn.value = vpnList[0];
    }
  }
}
