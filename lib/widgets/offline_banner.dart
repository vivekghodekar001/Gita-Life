import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement banner shown when device is offline
    return Container(
      color: Colors.red,
      padding: const EdgeInsets.all(8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'You are offline',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
