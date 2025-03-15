import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:open_nizvpn/controllers/home_controller.dart';
import 'package:open_nizvpn/controllers/location_controller.dart';

// import '../helpers/ad_helper.dart';
import '../main.dart';
import 'package:get/get.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen();

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Get.put(HomeController());
    Get.put(LocationController());
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.off(() => HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          //app logo
          Positioned(
              left: mq.width * .3,
              top: mq.height * .2,
              width: mq.width * .4,
              child: Image.asset('assets/images/logo.jpeg')),

          //label
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: Text(
                'MADE IN Pakistan WITH ❤️ALI',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).lightText, letterSpacing: 1),
              ))
        ],
      ),
    );
  }
}
