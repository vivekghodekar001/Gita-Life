import 'package:flutter/material.dart';

class AttendanceChip extends StatelessWidget {
  final String status; // 'present' | 'absent' | 'late'

  const AttendanceChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    return Chip(
      label: Text(
        config.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: config.color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none,
      avatar: Icon(config.icon, color: Colors.white, size: 16),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return _StatusConfig('Present', Colors.green, Icons.check_circle_outline);
      case 'late':
        return _StatusConfig('Late', const Color(0xFF1565C0), Icons.schedule);
      case 'absent':
        return _StatusConfig('Absent', Colors.red, Icons.cancel_outlined);
      default:
        return _StatusConfig('Unknown', Colors.grey, Icons.help_outline);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusConfig(this.label, this.color, this.icon);
}
