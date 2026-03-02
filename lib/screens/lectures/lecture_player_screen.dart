import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LecturePlayerScreen extends ConsumerWidget {
  final String lectureId;

  const LecturePlayerScreen({super.key, required this.lectureId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecture Player')),
      backgroundColor: const Color(0xFFFFF8F0),
      body: const Center(
        child: Text('TODO: Implement LecturePlayerScreen'),
      ),
    );
  }
}
