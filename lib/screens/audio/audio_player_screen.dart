import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioPlayerScreen extends ConsumerWidget {
  final String trackId;

  const AudioPlayerScreen({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Player')),
      backgroundColor: const Color(0xFFFFF8F0),
      body: const Center(
        child: Text('TODO: Implement AudioPlayerScreen'),
      ),
    );
  }
}
