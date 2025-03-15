import 'dart:math';

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

    return Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: mq.height * .01),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {
            controller.vpn.value = vpn;
            Pref.vpn = vpn;
            Get.back();

            MyDialogs.info(msg: 'Connecting VPN Location...');

            if (controller.vpnState.value == AliVpn.vpnConnected) {
              AliVpn.stopVpn();
              Future.delayed(Duration(seconds: 2), () => controller.connectToVpn());
            } else {
              controller.connectToVpn();
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

            //flag
            leading: Container(
              padding: EdgeInsets.all(.5),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(5)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(vpn.imagePath, height: 40, width: mq.width * .15, fit: BoxFit.cover),
              ),
            ),

            //title
            title: Text(vpn.countryLong),

            //subtitle
            subtitle: Row(
              children: [
                Icon(Icons.speed_rounded, color: Colors.blue, size: 20),
                SizedBox(width: 4),
                Text(_formatBytes(vpn.speed, 1), style: TextStyle(fontSize: 13))
              ],
            ),

            //trailing
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(vpn.countryLong.toString(),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).lightText)),
                SizedBox(width: 4),
                Icon(CupertinoIcons.person_3, color: Colors.blue),
              ],
            ),
          ),
        ));
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
