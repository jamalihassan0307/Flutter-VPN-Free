import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:FastVPN/controllers/home_controller.dart';
import 'package:FastVPN/controllers/location_controller.dart';
import 'package:animations/animations.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// import '../helpers/ad_helper.dart';
import '../main.dart';
import 'package:get/get.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen();

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    Get.put(HomeController());
    Get.put(LocationController());

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      Get.off(
        () => OpenContainer(
          transitionDuration: Duration(milliseconds: 1000),
          openBuilder: (context, _) => HomeScreen(),
          closedBuilder: (context, VoidCallback openContainer) => Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Image.asset('assets/images/logo.jpeg'),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated Logo
            Positioned(
              left: mq.width * .3,
              top: mq.height * .2,
              width: mq.width * .4,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset('assets/images/logo.jpeg'),
                  ),
                ),
              ),
            ),

            // Animated Text
            Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: Theme.of(context).lightText,
                    fontSize: 16,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        'MADE IN PAKISTAN',
                        duration: Duration(seconds: 2),
                      ),
                      FadeAnimatedText(
                        'WITH ❤️ BY ALI',
                        duration: Duration(seconds: 2),
                      ),
                    ],
                    repeatForever: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
