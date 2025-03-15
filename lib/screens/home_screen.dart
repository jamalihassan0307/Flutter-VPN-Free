import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:open_nizvpn/controllers/location_controller.dart';
import 'package:open_nizvpn/core/utils/nizvpn_engine.dart';

import '../controllers/home_controller.dart';
import '../helpers/pref.dart';
import '../main.dart';

import '../models/vpn_status.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/home_card.dart';
import 'location_screen.dart';
import 'network_test_screen.dart';
import '../models/vpn.dart';

class HomeScreen extends StatelessWidget {
  final HomeController _controller = Get.put(HomeController());
  final LocationController _locationController = Get.put(LocationController());

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // _locationController = Get.put(LocationController());
    _controller.initVpn();
    AliVpn.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      //app bar
      appBar: AppBar(
        leading: Icon(Icons.home),
        title: Text('Free OpenVPN'),
        actions: [
          IconButton(
              onPressed: () {
                Get.changeThemeMode(Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                Pref.isDarkMode = !Pref.isDarkMode;
                return;
              },
              icon: Icon(
                Icons.brightness_medium,
                size: 26,
              )),
          IconButton(
              padding: EdgeInsets.only(right: 8),
              onPressed: () => Get.to(() => NetworkTestScreen()),
              icon: Icon(
                Icons.info,
                size: 27,
              )),
        ],
      ),

      bottomNavigationBar: _changeLocation(context),

      //body
      body: FutureBuilder<List<Vpn>>(
        future: _loadVpnList(), // Your VPN list loading function
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Auto-select first VPN when list is loaded
            _controller.selectFirstVpn(snapshot.data!);

            return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              //vpn button
              Obx(() => _vpnButton()),

              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //country flag
                    HomeCard(
                        title:
                            _controller.vpn.value.countryLong.isEmpty ? 'Country' : _controller.vpn.value.countryLong,
                        subtitle: 'FREE',
                        icon: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          child: _controller.vpn.value.countryLong.isEmpty
                              ? Icon(Icons.vpn_lock_rounded, size: 30, color: Colors.white)
                              : null,
                          backgroundImage: _controller.vpn.value.countryLong.isEmpty
                              ? null
                              : AssetImage('assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png'),
                        )),

                    //ping time
                    HomeCard(
                        title:
                            _controller.vpn.value.countryLong.isEmpty ? '100 ms' : '${_controller.vpn.value.ping} ms',
                        subtitle: 'PING',
                        icon: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.equalizer_rounded, size: 30, color: Colors.white),
                        )),
                  ],
                ),
              ),

              StreamBuilder<VpnStatus?>(
                  initialData: VpnStatus(),
                  stream: AliVpn.vpnStatusSnapshot()
                      .map((event) => event != null ? VpnStatus.fromJson(event as Map<String, dynamic>) : null),
                  builder: (context, snapshot) {
                    print('VPN Status Data: ${snapshot.data?.toJson()}');
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //download
                        HomeCard(
                            title: '${snapshot.data?.byteIn ?? '0 kbps'}',
                            subtitle: 'DOWNLOAD',
                            icon: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.lightGreen,
                              child: Icon(Icons.arrow_downward_rounded, size: 30, color: Colors.white),
                            )),

                        //upload
                        HomeCard(
                            title: '${snapshot.data?.byteOut ?? '0 kbps'}',
                            subtitle: 'UPLOAD',
                            icon: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.arrow_upward_rounded, size: 30, color: Colors.white),
                            )),
                      ],
                    );
                  })
            ]);
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List<Vpn>> _loadVpnList() async {
    return _locationController.vpnList;
  }

  //vpn button
  Widget _vpnButton() => Column(
        children: [
          //button
          Semantics(
            button: true,
            child: InkWell(
              onTap: () {
                _controller.connectToVpn();
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(shape: BoxShape.circle, color: _controller.getButtonColor.withOpacity(.1)),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _controller.getButtonColor.withOpacity(.3)),
                  child: Container(
                    width: mq.height * .14,
                    height: mq.height * .14,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _controller.getButtonColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //icon
                        Icon(
                          Icons.power_settings_new,
                          size: 28,
                          color: Colors.white,
                        ),

                        SizedBox(height: 4),

                        //text
                        Text(
                          _controller.getButtonText,
                          style: TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          //connection status label
          Container(
            margin: EdgeInsets.only(top: mq.height * .015, bottom: mq.height * .02),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(15)),
            child: Text(
              _controller.vpnState.value == AliVpn.vpnDisconnected
                  ? 'Not Connected'
                  : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(fontSize: 12.5, color: Colors.white),
            ),
          ),

          //count down timer
          Obx(() => CountDownTimer(startTimer: _controller.vpnState.value == AliVpn.vpnConnected)),
        ],
      );

  //bottom nav to change location
  Widget _changeLocation(BuildContext context) => SafeArea(
          child: Semantics(
        button: true,
        child: InkWell(
          onTap: () => Get.to(() => LocationScreen()),
          child: Container(
              color: Theme.of(context).bottomNav,
              padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
              height: 60,
              child: Row(
                children: [
                  //icon
                  Icon(Icons.public, color: Colors.white, size: 28),

                  //for adding some space
                  SizedBox(width: 10),

                  //text
                  Text(
                    'Change Location',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),

                  //for covering available spacing
                  Spacer(),

                  //icon
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.keyboard_arrow_right_rounded, color: Colors.blue, size: 26),
                  )
                ],
              )),
        ),
      ));
}
