import 'dart:math';

import 'package:FastVPN/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FastVPN/core/utils/nizvpn_engine.dart';
import 'package:FastVPN/helpers/my_dialogs.dart';

import '../controllers/home_controller.dart';
import '../helpers/pref.dart';
import '../main.dart';
import '../models/vpn.dart';

class VpnCard extends StatelessWidget {
  final Vpn vpn;

  const VpnCard({required this.vpn});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isSelected = controller.vpn.value.countryLong == vpn.countryLong;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _handleVpnSelection(controller),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFlagContainer(),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vpn.countryLong,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildSpeedInfo(context),
                    ],
                  ),
                ),
                _buildSignalStrength(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlagContainer() {
    return Container(
      width: 60,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          vpn.imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSpeedInfo(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.speed_rounded,
                color: Colors.blue,
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                _formatBytes(vpn.speed, 1),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignalStrength(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            CupertinoIcons.wifi,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          if (int.parse(vpn.ping) < 100)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleVpnSelection(HomeController controller) {
    controller.vpn.value = vpn;
    Pref.vpn = vpn;
    Get.back();
    MyDialogs.info(msg: 'Connecting VPN Location...');
    
    if (controller.vpnState.value == AliVpn.vpnConnected) {
      AliVpn.stopVpn();
      Future.delayed(Duration(seconds: 2), () {
        controller.connectToVpn();
        Get.back(result: true);
      });
    } else {
      controller.connectToVpn();
      Get.back(result: true);
    }
  }

  String _formatBytes(String speed, int decimals) {
    try {
      final bytes = int.parse(speed);
      if (bytes <= 0) return "0 B";
      const suffixes = ['Bps', "Kbps", "Mbps", "Gbps", "Tbps"];
      var i = (log(bytes) / log(1024)).floor();
      return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
    } catch (e) {
      return '0 B';
    }
  }
}
