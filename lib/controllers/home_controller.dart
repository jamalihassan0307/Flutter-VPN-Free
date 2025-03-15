// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_nizvpn/controllers/location_controller.dart';
import 'package:open_nizvpn/core/models/dnsConfig.dart';
import 'package:open_nizvpn/core/models/vpnConfig.dart';
import 'package:open_nizvpn/core/utils/nizvpn_engine.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/vpn.dart';

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
  final vpnState = AliVpn.vpnDisconnected.obs;

  void selectFirstVpn(List<Vpn> vpnList) {
    if (vpnList.isNotEmpty && vpn.value.vpnConfigPath.isEmpty) {
      vpn.value = vpnList[4];
      print('Auto-selected first VPN: ${vpn.value.hostname}');
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Listen to VPN status changes
    AliVpn.vpnStageSnapshot().listen((event) {
      print('VPN Status Update: $event');

      // Convert state to uppercase for comparison
      String state = event.toUpperCase();

      if (state.contains("CONNECTED")) {
        print('VPN Connected Successfully');
        vpnState.value = AliVpn.vpnConnected;
        Get.snackbar('Connected', 'VPN connection established', backgroundColor: Colors.green, colorText: Colors.white);
      } else if (state.contains("DISCONNECTED")) {
        print('VPN Disconnected');
        vpnState.value = AliVpn.vpnDisconnected;
        Get.snackbar('Disconnected', 'VPN connection terminated', backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        print('VPN State: $state');
        vpnState.value = event;
      }
    }, onError: (e) {
      print('VPN Status Error: $e');
    });
  }

  Future<void> connectToVpn() async {
    print('Start connectToVpn');
    if (vpn.value.vpnConfigPath.isEmpty) {
      print('No VPN Selected');
      Get.snackbar('Selection Required', 'Please select a VPN server first');
      return;
    }

    try {
      _selectedVpn =
          VpnConfig(config: await rootBundle.loadString(vpn.value.vpnConfigPath), name: vpn.value.countryLong);
      print('VPN Selected ${vpn.value.vpnConfigPath}');

      if (vpnState.value == AliVpn.vpnDisconnected) {
        print('Starting VPN connection');
        await AliVpn.startVpn(
          _selectedVpn!,
          dns: DnsConfig("23.253.163.53", "198.101.242.72"),
        );
      } else {
        print('Stopping VPN connection');
        await AliVpn.stopVpn();
      }
    } catch (e) {
      print('VPN Error: $e');
      Get.snackbar('Connection Failed', 'Error: ${e.toString()}');
    }
  }

  // vpn buttons color
  Color get getButtonColor {
    switch (vpnState.value) {
      case AliVpn.vpnDisconnected:
        return Colors.blue;

      case AliVpn.vpnConnected:
        return Colors.green;

      default:
        return Colors.orangeAccent;
    }
  }

  // vpn button text
  String get getButtonText {
    print('Current VPN State: ${vpnState.value}');
    if (vpnState.value.toUpperCase().contains("CONNECTED,SUCCESS")) return 'Disconnect VPN';
    if (vpnState.value == AliVpn.vpnDisconnected) return 'Connect VPN';
    return 'Connecting...';
  }

  VpnConfig? _selectedVpn;
  List<VpnConfig> _listVpn = [];

  void initVpn() async {
    for (var i in LocationController.to.vpnList) {
      _listVpn.add(VpnConfig(config: await rootBundle.loadString(i.vpnConfigPath), name: i.countryLong));
    }

    update();
  }
}
