import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WatchAdDialog extends StatelessWidget {
  final VoidCallback onComplete;

  const WatchAdDialog({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Change Theme'),
      content: const Text('Watch an Ad to Change App Theme.'),
      actions: [
        CupertinoDialogAction(
            isDefaultAction: true,
            textStyle: const TextStyle(color: Colors.green),
            child: const Text('OK'),
            onPressed: () {
              Get.back();
              onComplete();
            }),
      ],
    );
  }
}
