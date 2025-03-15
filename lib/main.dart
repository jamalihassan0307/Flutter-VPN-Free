import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'screens/splash_screen.dart';

import 'helpers/pref.dart';
import 'theme/app_theme.dart';

//global object for accessing dev ice screen size
late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //enter full-screen
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  await Pref.initializeHive();

  // Initialize VPN
  // await VpnEngine.initialize();

  // await AdHelper.initAds();

  //for setting orientation to portrait only
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((v) {
  runApp(MyApp());
  // });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fast VPN',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(),
    );
  }
}

// extension AppTheme on ThemeData {
//   Color get lightText => Pref.isDarkMode ? Colors.white70 : Colors.black54;
//   Color get bottomNav => Pref.isDarkMode ? Colors.white12 : Colors.blue;
// }
