// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_nizvpn/controllers/location_controller.dart';
import 'package:open_nizvpn/core/models/dnsConfig.dart';
import 'package:open_nizvpn/core/models/vpnConfig.dart';
import 'package:open_nizvpn/core/utils/nizvpn_engine.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/vpn.dart';
import '../services/vpn_engine.dart';

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
    if (vpnList.isNotEmpty && vpn.value.vpnConfigPath.isEmpty) {
      vpn.value = vpnList[4];
      print('Auto-selected first VPN: ${vpn.value.hostname}');
    }
  }

  void connectToVpn() async {
    if (vpn.value.vpnConfigPath.isEmpty) {
      print('No VPN Selected');
      Get.snackbar('Selection Required', 'Please select a VPN server first');
      return;
    }
    try {
      if (_selectedVpn == null) return;

      if (vpnState.value == VpnEngine.vpnDisconnected) {
        ///Start if stage is disconnected
        AliVpn.startVpn(
          _selectedVpn!,
          dns: DnsConfig("23.253.163.53", "198.101.242.72"),
        );
        Get.snackbar('Connection Successful', 'Connected to ${vpn.value.countryLong}',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Connection Stopped', 'Disconnected from ${vpn.value.countryLong}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }

      ///Stop if stage is "not" disconnected
      AliVpn.stopVpn();
    } catch (e) {
      Get.snackbar('Connection Failed', 'Error: ${e.toString()}');
    }

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

  VpnConfig? _selectedVpn;
  List<VpnConfig> _listVpn = [];
  void connectClick() {
    ///Stop right here if user not select a vpn
    if (_selectedVpn == null) return;

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      ///Start if stage is disconnected
      AliVpn.startVpn(
        _selectedVpn!,
        dns: DnsConfig("23.253.163.53", "198.101.242.72"),
      );
    } else {
      ///Stop if stage is "not" disconnected
      AliVpn.stopVpn();
    }
  }

  void initVpn() async {
    for (var i in LocationController.to.vpnList) {
      _listVpn.add(VpnConfig(config: await rootBundle.loadString(i.vpnConfigPath), name: i.countryLong));
    }

    update();
  }
}
