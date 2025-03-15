import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:FastVPN/controllers/home_controller.dart';
import 'package:FastVPN/controllers/location_controller.dart';
import 'package:animations/animations.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';

// import '../helpers/ad_helper.dart';
import '../main.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'walkthrough_screen.dart';
import '../helpers/pref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen();

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    Get.put(HomeController());
    Get.put(LocationController());

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.2, 0.7, curve: Curves.elasticOut),
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.4, 0.8, curve: Curves.easeInOut),
    ));

    _controller.forward();

    _navigateToNextScreen();
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50, // Light blue background
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background animated circles
            ...List.generate(20, (index) {
              return Positioned(
                left: (index * 20.0) % mq.width,
                top: (index * 30.0) % mq.height,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value * 0.3,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // Centered Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotateAnimation.value,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Hero(
                              tag: 'logo',
                              child: Container(
                                width: mq.width * 0.5,
                                height: mq.width * 0.5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/logo-removebg.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 50),

                  // Animated Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700, // Darker blue for text
                        letterSpacing: 2,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'FAST VPN',
                            speed: Duration(milliseconds: 200),
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Subtitle
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Secure • Fast • Reliable',
                      style: TextStyle(
                        color: Colors.blue.shade600, // Slightly lighter blue
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom text
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 14,
                      letterSpacing: 1,
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 2));

    // if (Pref.isFirstTime) {
    Get.off(() => WalkthroughScreen());
    // } else {
    //   Get.off(() => HomeScreen());
    // }
  }
}
