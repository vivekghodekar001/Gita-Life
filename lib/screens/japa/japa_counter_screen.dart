import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:go_router/go_router.dart';
import '../../providers/japa_provider.dart';

class JapaCounterScreen extends ConsumerWidget {
  const JapaCounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final japaAsync = ref.watch(todayJapaLogProvider);
    final vibrationEnabled = ref.watch(japaVibrationProvider);
    final soundEnabled = ref.watch(japaSoundProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F9),
      appBar: AppBar(
        title: const Text('Japa Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing to Cloud...')));
               // In a real app we'd pass the actual UID
               await ref.read(japaServiceProvider).syncToFirestore('demo_user_id');
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync Complete!')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/japa/history');
            },
          )
        ],
      ),
      body: japaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: \$err')),
        data: (log) {
          if (log == null) return const Center(child: Text('Could not load Japa Log'));

          final progress = log.totalBeads / 108.0;
          final malaProgress = log.totalMalas / (log.targetMalas > 0 ? log.targetMalas : 1);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Top header stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Daily Goal', style: TextStyle(fontSize: 16, color: Colors.black54)),
                        Text('${log.totalMalas} / ${log.targetMalas} Malas', 
                             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: () => _showTargetDialog(context, ref, log.targetMalas),
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: log.targetMalas > 0 ? malaProgress : 0,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.green,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
                if (log.goalReached)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('🎉 Daily Goal Reached!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),

                // Center visualizer
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 15,
                        backgroundColor: const Color(0xFF1565C0).withOpacity(0.2),
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${log.totalBeads}', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                        const Text('/ 108 beads', style: TextStyle(fontSize: 18, color: Colors.black54)),
                      ],
                    )
                  ],
                ),

                // Main TAP button
                GestureDetector(
                  onTap: () async {
                    if (vibrationEnabled && await Vibration.hasVibrator() == true) {
                       Vibration.vibrate(duration: 50);
                    }
                    if (soundEnabled) {
                       SystemSound.play(SystemSoundType.click);
                    }
                    await ref.read(japaServiceProvider).recordBead(log.date);
                    ref.invalidate(todayJapaLogProvider);
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1565C0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('TAP', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),

                // Quick Settings (Vibration)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.vibration, color: Colors.blueGrey),
                    Switch(
                      value: vibrationEnabled,
                      activeColor: const Color(0xFF1565C0),
                      onChanged: (val) {
                        ref.read(japaVibrationProvider.notifier).toggle();
                      },
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.volume_up, color: Colors.blueGrey),
                    Switch(
                      value: soundEnabled,
                      activeColor: const Color(0xFF1565C0),
                      onChanged: (val) {
                        ref.read(japaSoundProvider.notifier).toggle();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTargetDialog(BuildContext context, WidgetRef ref, int current) {
    int target = current;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Daily Target'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: () => setState((){ if(target > 1) target--; }), icon: const Icon(Icons.remove)),
                  Text('\$target', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => setState((){ target++; }), icon: const Icon(Icons.add)),
                ],
              );
            }
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await ref.read(japaServiceProvider).setDailyTarget(target);
                ref.invalidate(todayJapaLogProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        );
      }
    );
  }
}
