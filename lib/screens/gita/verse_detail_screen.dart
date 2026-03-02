import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerseDetailScreen extends ConsumerWidget {
  final String chapterId;
  final String verseId;

  const VerseDetailScreen({
    super.key,
    required this.chapterId,
    required this.verseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Verse $chapterId.$verseId')),
      backgroundColor: const Color(0xFFFFF8F0),
      body: const Center(
        child: Text('TODO: Implement VerseDetailScreen'),
      ),
    );
  }
}
