import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerseListScreen extends ConsumerWidget {
  final String chapterId;

  const VerseListScreen({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Chapter $chapterId')),
      backgroundColor: const Color(0xFFFFF8F0),
      body: const Center(
        child: Text('TODO: Implement VerseListScreen'),
      ),
    );
  }
}
