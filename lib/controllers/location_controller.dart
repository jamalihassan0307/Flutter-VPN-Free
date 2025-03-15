import 'dart:math';

import 'package:get/get.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';

class LocationController extends GetxController {
  static LocationController get to => Get.find();
  List<Vpn> vpnList = Pref.vpnList;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getVpnData(); // Load VPN data when the controller is initialized
  }

  Future<void> getVpnData() async {
    isLoading.value = true;
    vpnList.clear();
    vpnList = generateVpnList();
    isLoading.value = false;
  }

  List<Vpn> generateVpnList() {
    final List<Map<String, String>> countryData = [
      {
        'ipAddress': '219.100.37.126',
        'hostname': 'public-vpn-163.opengw.net',
        'country': 'Japan',
        'short': 'japan',
        'image': 'assets/flags/japan.png',
        'config': 'assets/vpn/japan.ovpn'
      },
      {
        'ipAddress': '122.99.21.46',
        'hostname': 'jayporeonvpn4.opengw.net',
        'country': 'Taiwan',
        'short': 'TW',
        'image': 'assets/flags/tw.png',
        'config': 'assets/vpn/Taiwan.ovpn'
      },
      {
        'ipAddress': '24.18.52.249',
        'hostname': 'vpn116260047.opengw.net',
        'country': 'United States',
        'short': 'US',
        'image': 'assets/flags/us.png',
        'config': 'assets/vpn/United States.ovpn'
      },
      {
        'ipAddress': '210.245.29.220',
        'hostname': 'vpn358564424.opengw.net',
        'country': 'Viet Nam',
        'short': 'VN',
        'image': 'assets/flags/vn.png',
        'config': 'assets/vpn/Viet Nam.ovpn'
      },
      {
        'ipAddress': '217.138.212.58',
        'hostname': 'popengw.opengw.net',
        'country': 'Romania',
        'short': 'RO',
        'image': 'assets/flags/ro.png',
        'config': 'assets/vpn/Romania.ovpn'
      },
      {
        'ipAddress': '2.63.127.91',
        'hostname': 'vpn994575990.opengw.net',
        'country': 'Russian Federation',
        'short': 'RU',
        'image': 'assets/flags/ru.png',
        'config': 'assets/vpn/Russian Federation.ovpn'
      },
      {
        'ipAddress': '14.36.22.137',
        'hostname': 'vpn692884786.opengw.net',
        'country': 'Korea Republic of',
        'short': 'KR',
        'image': 'assets/flags/kr.png',
        'config': 'assets/vpn/korea.ovpn'
      },
      {
        'ipAddress': '180.243.51.72',
        'hostname': 'vpn491572721.opengw.net',
        'country': 'Indonesia',
        'short': 'ID',
        'image': 'assets/flags/id.png',
        'config': 'assets/vpn/Indonesia.ovpn'
      },
    ];

    List<Vpn> vpnList = [];
    for (int i = 0; i < countryData.length; i++) {
      final country = countryData[i];
      vpnList.add(Vpn(
        hostname: country['hostname']!,
        ip: country['ipAddress']!,
        countryLong: country['country']!,
        countryShort: country['short']!,
        imagePath: country['image']!,
        vpnConfigPath: country['config']!,
        ping: '${Random().nextInt(50) + 10}',
        speed: '${(Random().nextDouble() * 2000000000).toInt()}',
      ));
    }
    return vpnList;
  }
}
