import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarkAttendanceScreen extends ConsumerWidget {
  final String sessionId;

  const MarkAttendanceScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      backgroundColor: const Color(0xFFFFF8F0),
      body: const Center(
        child: Text('TODO: Implement MarkAttendanceScreen'),
      ),
    );
  }
}
