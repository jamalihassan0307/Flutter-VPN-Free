// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FastVPN/controllers/location_controller.dart';
import 'package:FastVPN/core/models/dnsConfig.dart';
import 'package:FastVPN/core/models/vpnConfig.dart';
import 'package:FastVPN/core/utils/nizvpn_engine.dart';
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
  final vpnState = ''.obs;
  final connectionStatus = ''.obs;
  final isConnected = false.obs;

  void selectFirstVpn(List<Vpn> vpnList) {
    if (vpnList.isNotEmpty && vpn.value.vpnConfigPath.isEmpty) {
      vpn.value = vpnList[4];
      print('Auto-selected first VPN: ${vpn.value.hostname}');
    }
  }

  @override
  void onInit() {
    super.onInit();
    vpnState.value = 'disconnected';

    AliVpn.vpnStageSnapshot().listen((event) {
      print('VPN Status Update: $event');

      switch (event.toUpperCase()) {
        case "DISCONNECTED":
          vpnState.value = 'disconnected';
          isConnected.value = false;
          connectionStatus.value = 'VPN Disconnected';
          Get.snackbar('Disconnected', 'VPN connection terminated',
              backgroundColor: Colors.red, colorText: Colors.white);
          break;
        case "CONNECTED":
          vpnState.value = 'connected';
          isConnected.value = true;
          connectionStatus.value = 'VPN Connected Successfully';
          Get.snackbar('Connected', 'VPN connection established',
              backgroundColor: Colors.green, colorText: Colors.white);
          break;
        case "CONNECTING":
          vpnState.value = 'connecting';
          isConnected.value = false;
          connectionStatus.value = 'Connecting to VPN...';
          break;

        case "AUTHENTICATING":
          vpnState.value = 'authenticating';
          isConnected.value = false;
          connectionStatus.value = 'Authenticating...';
          break;

        default:
          vpnState.value = event.toLowerCase();
          connectionStatus.value = 'VPN Status: $event';
      }
      update();
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
      print("vpnState.value: ${vpnState.value}");
      if (vpnState.value == AliVpn.vpnDisconnected) {
        print('Starting VPN connection');
        await AliVpn.startVpn(
          _selectedVpn!,
          dns: DnsConfig("23.253.163.53", "198.101.242.72"),
        ).then((value) {
          print('VPN Connected Successfully');
          vpnState.value = AliVpn.vpnConnected;
          Get.snackbar('Connected', 'VPN connection established',
              backgroundColor: Colors.green, colorText: Colors.white);
        });
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
    if (vpnState.value.toLowerCase().contains("disconnected")) return 'Connect VPN';
    if (vpnState.value.toLowerCase().contains("connected")) return 'Disconnect VPN';
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
