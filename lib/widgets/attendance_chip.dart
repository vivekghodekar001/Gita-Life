import 'package:flutter/material.dart';

class AttendanceChip extends StatelessWidget {
  final String status; // 'present' | 'absent' | 'late'

  const AttendanceChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement colored chip for attendance status
    return Chip(label: Text(status));
  }
}
