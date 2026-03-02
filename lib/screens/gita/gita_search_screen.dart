import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GitaSearchScreen extends ConsumerWidget {
  const GitaSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Gita')),
      backgroundColor: const Color(0xFFFFF8F0),
      body: const Center(
        child: Text('TODO: Implement GitaSearchScreen'),
      ),
    );
  }
}
