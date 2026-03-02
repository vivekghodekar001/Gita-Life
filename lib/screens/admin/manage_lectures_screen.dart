import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageLecturesScreen extends ConsumerWidget {
  const ManageLecturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Lectures')),
      backgroundColor: const Color(0xFFFFF8F0),
      body: const Center(
        child: Text('TODO: Implement ManageLecturesScreen'),
      ),
    );
  }
}
