import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:FastVPN/controllers/location_controller.dart';
import 'package:FastVPN/core/utils/nizvpn_engine.dart';

import '../controllers/home_controller.dart';
import '../helpers/pref.dart';
// import '../main.dart';

import '../models/vpn_status.dart';
import '../widgets/count_down_timer.dart';
// import '../widgets/home_card.dart';
import 'location_screen.dart';
import 'network_test_screen.dart';
import '../models/vpn.dart';
// import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final HomeController _controller = Get.put(HomeController());
  final LocationController _locationController = Get.put(LocationController());

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _controller.initVpn();
    AliVpn.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background animated circles
            ..._buildBackgroundCircles(),

            // Main content
            Column(
              children: [
                Expanded(
                  child: _buildMainContent(),
                ),
                _buildChangeLocation(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundCircles() {
    return [
      Positioned(
        top: -100,
        right: -100,
        child: _buildAnimatedCircle(200, Colors.blue.withOpacity(0.1)),
      ),
      Positioned(
        bottom: -50,
        left: -50,
        child: _buildAnimatedCircle(150, Colors.purple.withOpacity(0.1)),
      ),
    ];
  }

  Widget _buildAnimatedCircle(double size, Color color) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: 15),
      builder: (context, double value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, color.withOpacity(0)],
              ),
            ),
          ),
        );
      },
      // repeat: true,
    );
  }

  Widget _buildMainContent() {
    return FutureBuilder<List<Vpn>>(
      future: _loadVpnList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _controller.selectFirstVpn(snapshot.data!);
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Obx(() => _buildVpnStatusCard(context)),
                  SizedBox(height: 25),
                  Obx(() => _buildLocationAndPingInfo(context)),
                  SizedBox(height: 25),
                  _buildNetworkStats(context),
                ],
              ),
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: Icon(Icons.home),
      title: Text(
        'Free OpenVPN',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        IconButton(
          onPressed: () {
            Get.changeThemeMode(Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
            Pref.isDarkMode = !Pref.isDarkMode;
          },
          icon: Icon(
            Pref.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        IconButton(
          padding: EdgeInsets.only(right: 8),
          onPressed: () => Get.to(() => NetworkTestScreen()),
          icon: Icon(Icons.info),
        ),
      ],
    );
  }

  Widget _buildVpnStatusCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _controller.getButtonColor.withOpacity(0.9),
            _controller.getButtonColor,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _controller.getButtonColor.withOpacity(0.3),
            blurRadius: 30,
            offset: Offset(0, 15),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: _controller.getButtonColor.withOpacity(0.2),
            blurRadius: 60,
            offset: Offset(0, 30),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildConnectButton(context),
          SizedBox(height: 25),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.white, Colors.white70],
            ).createShader(bounds),
            child: Text(
              _controller.getButtonText.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(height: 15),
          _buildStatusIndicator(context),
          if (_controller.connectionStatus.value.isNotEmpty) ...[
            SizedBox(height: 15),
            Text(
              _controller.connectionStatus.value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
          SizedBox(height: 15),
          CountDownTimer(startTimer: _controller.vpnState.value == AliVpn.vpnConnected),
        ],
      ),
    );
  }

  Widget _buildLocationAndPingInfo(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoColumn(
            context,
            icon: _controller.vpn.value.countryLong.isEmpty
                ? Icon(Icons.vpn_lock_rounded, size: 30, color: Colors.white)
                : null,
            image: _controller.vpn.value.countryLong.isEmpty
                ? null
                : 'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png',
            title: _controller.vpn.value.countryLong.isEmpty ? 'Country' : _controller.vpn.value.countryLong,
            subtitle: 'FREE',
            color: Theme.of(context).primaryColor,
          ),
          _buildInfoColumn(
            context,
            icon: Icon(Icons.equalizer_rounded, size: 30, color: Colors.white),
            title: _controller.vpn.value.countryLong.isEmpty ? '100 ms' : '${_controller.vpn.value.ping} ms',
            subtitle: 'PING',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context, {
    Widget? icon,
    String? image,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(isLight ? 0.1 : 1),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.transparent,
            backgroundImage: image != null ? AssetImage(image) : null,
            child: icon,
          ),
        ),
        SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            color: isLight ? Color(0xFF1F1F1F) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: isLight ? Color(0xFF757575) : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkStats(BuildContext context) {
    return StreamBuilder<VpnStatus?>(
      initialData: VpnStatus(),
      stream: AliVpn.vpnStatusSnapshot()
          .map((event) => event != null ? VpnStatus.fromJson(event as Map<String, dynamic>) : null),
      builder: (context, snapshot) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Network Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAnimatedStatItem(
                    icon: Icons.arrow_downward_rounded,
                    value: '${snapshot.data?.byteIn ?? '0 kbps'}',
                    label: 'DOWNLOAD',
                    color: Colors.green,
                  ),
                  _buildAnimatedStatItem(
                    icon: Icons.arrow_upward_rounded,
                    value: '${snapshot.data?.byteOut ?? '0 kbps'}',
                    label: 'UPLOAD',
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                SizedBox(height: 10),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Vpn>> _loadVpnList() async {
    return _locationController.vpnList;
  }

  Widget _buildChangeLocation(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.to(() => LocationScreen()),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'Select your preferred server',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context) {
    return InkWell(
      onTap: () => _controller.connectToVpn(),
      child: Container(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _controller.getButtonColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // Rotating circles
            TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(seconds: 10),
              builder: (context, double value, child) {
                return Transform.rotate(
                  angle: value * 2 * 3.14159,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Main button container
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _controller.getButtonColor.withOpacity(0.9),
                    _controller.getButtonColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing circles
                  ..._buildPulsingCircles(),
                  // Center icon with container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        _controller.vpnState.value == "connected" ? Icons.power_settings_new : Icons.power_off_outlined,
                        key: ValueKey<String>(_controller.vpnState.value),
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Connection status indicator
            if (_controller.vpnState.value == "connecting") _buildConnectingIndicator(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPulsingCircles() {
    return List.generate(3, (index) {
      return TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(seconds: 1),
        builder: (context, double value, child) {
          return Container(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              value: _controller.vpnState.value == "connecting" ? null : 1,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.2 - (index * 0.05)),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildConnectingIndicator() {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1500),
      builder: (context, double value, child) {
        return Container(
          width: 180 * value,
          height: 180 * value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2 * (1 - value)),
              width: 15 * (1 - value),
            ),
          ),
        );
      },
      // repeats: true,
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _controller.vpnState.value.toUpperCase(),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
