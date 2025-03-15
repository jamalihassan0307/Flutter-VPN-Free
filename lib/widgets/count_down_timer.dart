import 'dart:async';

import 'package:flutter/material.dart';

class CountDownTimer extends StatefulWidget {
  final bool startTimer;

  const CountDownTimer({required this.startTimer});

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  Duration _duration = Duration();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.startTimer) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(CountDownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startTimer != oldWidget.startTimer) {
      if (widget.startTimer) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = Duration(seconds: _duration.inSeconds + 1);
      });
    });
  }

  _stopTimer() {
    setState(() {
      _timer?.cancel();
      _timer = null;
      _duration = Duration();
    });
  }

  @override
  Widget build(BuildContext context) {
    String twoDigit(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigit(_duration.inHours);
    final minutes = twoDigit(_duration.inMinutes.remainder(60));
    final seconds = twoDigit(_duration.inSeconds.remainder(60));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            '$hours:$minutes:$seconds',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
