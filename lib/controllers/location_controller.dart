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
      {'country': 'Ecuador', 'short': 'EC', 'image': 'assets/flags/ec.png', 'config': 'assets/vpn/Ecuador.ovpn'},
      {'country': 'Romania', 'short': 'RO', 'image': 'assets/flags/ro.png', 'config': 'assets/vpn/Romania.ovpn'},
      {
        'country': 'Russian Federation',
        'short': 'RU',
        'image': 'assets/flags/ru.png',
        'config': 'assets/vpn/Russian Federation.ovpn'
      },
      {'country': 'Taiwan', 'short': 'TW', 'image': 'assets/flags/tw.png', 'config': 'assets/vpn/Taiwan.ovpn'},
      {
        'country': 'United States',
        'short': 'US',
        'image': 'assets/flags/us.png',
        'config': 'assets/vpn/United States.ovpn'
      },
      {'country': 'Viet Nam', 'short': 'VN', 'image': 'assets/flags/vn.png', 'config': 'assets/vpn/Viet Nam.ovpn'},
      {
        'country': 'Korea Republic of',
        'short': 'KR',
        'image': 'assets/flags/kr.png',
        'config': 'assets/vpn/Korea Republic of.ovpn'
      },
      {'country': 'Indonesia', 'short': 'ID', 'image': 'assets/flags/id.png', 'config': 'assets/vpn/Indonesia.ovpn'},
    ];

    final List<String> ipAddresses = [
      '219.100.37.56',
      '203.160.64.70',
      '178.32.221.21',
      '45.77.56.114',
      '139.162.123.45',
      '108.61.201.119',
      '185.162.235.3',
      '103.86.99.10'
    ];

    final List<String> hostnames = [
      'public-vpn-94',
      'public-vpn-95',
      'public-vpn-96',
      'public-vpn-97',
      'public-vpn-98',
      'public-vpn-99',
      'public-vpn-100',
      'public-vpn-101'
    ];

    List<Vpn> vpnList = [];
    for (int i = 0; i < countryData.length; i++) {
      final country = countryData[i];
      vpnList.add(Vpn(
        hostname: hostnames[i],
        ip: ipAddresses[i],
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
