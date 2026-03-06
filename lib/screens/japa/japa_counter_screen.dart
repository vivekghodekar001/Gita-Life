import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/japa_provider.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

class JapaCounterScreen extends ConsumerWidget {
  const JapaCounterScreen({super.key});

  static const int _totalMalaTarget = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final japaAsync = ref.watch(todayJapaLogProvider);
    final vibrationEnabled = ref.watch(japaVibrationProvider);
    final soundEnabled = ref.watch(japaSoundProvider);

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: japaAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: SacredColors.parchment)),
          error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: SacredColors.parchment.withOpacity(0.6)))),
          data: (log) {
            if (log == null) return Center(child: Text('Could not load Japa Log', style: SacredTextStyles.infoValue()));
=======
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                // Haptic feedback — skip Vibration on web
                if (vibrationEnabled && !kIsWeb) {
                  try {
                    if (await Vibration.hasVibrator() == true) {
                      Vibration.vibrate(duration: 40);
                    }
                  } catch (_) {}
                }
                // Sound feedback
                if (soundEnabled) {
                  HapticFeedback.lightImpact();
                  SystemSound.play(SystemSoundType.click);
                }
                await ref.read(japaServiceProvider).recordBead(log.date);
                ref.invalidate(todayJapaLogProvider);
              },
              child: SafeArea(
                child: Column(
                  children: [
<<<<<<< HEAD
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.5)),
                            onPressed: () => context.canPop() ? context.pop() : null,
                          ),
                          const Spacer(),
                          Text('JAPA MALA', style: SacredTextStyles.sectionLabel(fontSize: 10)),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.history_rounded, size: 20, color: SacredColors.parchment.withOpacity(0.5)),
                            onPressed: () => context.push('/japa/history'),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Mala count — large center display
                    Text(
                      '${log.totalMalas}',
                      style: GoogleFonts.cormorantSc(
                        fontSize: 96,
                        fontWeight: FontWeight.w300,
                        color: SacredColors.parchment.withOpacity(0.85),
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'OF $_totalMalaTarget MALAS',
                      style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(
                        letterSpacing: 6,
                        color: SacredColors.parchment.withOpacity(0.25),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Current bead within mala
                    Text(
                      '${log.totalBeads} / 108 beads',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: SacredColors.parchment.withOpacity(0.35),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Mala bead bar — 16 circles
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _MalaBeadBar(completedMalas: log.totalMalas, total: _totalMalaTarget),
                    ),

                    const Spacer(flex: 1),

                    // Bead progress ring
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CustomPaint(
                        painter: _BeadRingPainter(
                          beadProgress: log.totalBeads / 108.0,
                          malaProgress: log.totalMalas / _totalMalaTarget,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${log.totalBeads}',
                                style: GoogleFonts.cormorantSc(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w400,
                                  color: SacredColors.parchment.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                'BEADS',
                                style: SacredTextStyles.sectionLabel(fontSize: 7).copyWith(
                                  color: SacredColors.parchment.withOpacity(0.2),
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // "Tap anywhere" hint
                    Text(
                      'TAP ANYWHERE TO COUNT',
                      style: SacredTextStyles.sectionLabel(fontSize: 8).copyWith(
                        letterSpacing: 5,
                        color: SacredColors.parchment.withOpacity(0.15),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Settings toggles
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: SacredDecorations.glassCard(radius: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.vibration_rounded, size: 16, color: SacredColors.parchment.withOpacity(vibrationEnabled ? 0.6 : 0.2)),
                          const SizedBox(width: 4),
                          SizedBox(
                            height: 24,
                            child: Switch(
                              value: vibrationEnabled,
                              activeColor: SacredColors.parchment,
                              activeTrackColor: SacredColors.parchment.withOpacity(0.2),
                              inactiveThumbColor: SacredColors.parchment.withOpacity(0.3),
                              inactiveTrackColor: SacredColors.parchment.withOpacity(0.06),
                              onChanged: (_) => ref.read(japaVibrationProvider.notifier).toggle(),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Icon(Icons.volume_up_rounded, size: 16, color: SacredColors.parchment.withOpacity(soundEnabled ? 0.6 : 0.2)),
                          const SizedBox(width: 4),
                          SizedBox(
                            height: 24,
                            child: Switch(
                              value: soundEnabled,
                              activeColor: SacredColors.parchment,
                              activeTrackColor: SacredColors.parchment.withOpacity(0.2),
                              inactiveThumbColor: SacredColors.parchment.withOpacity(0.3),
                              inactiveTrackColor: SacredColors.parchment.withOpacity(0.06),
                              onChanged: (_) => ref.read(japaSoundProvider.notifier).toggle(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
=======
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Mala Bead Bar — 16 circles showing completed malas
// ═══════════════════════════════════════════════════════════════

class _MalaBeadBar extends StatelessWidget {
  final int completedMalas;
  final int total;

  const _MalaBeadBar({required this.completedMalas, required this.total});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(total, (i) {
        final isCompleted = i < completedMalas;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? SacredColors.parchment.withOpacity(0.25)
                : SacredColors.parchment.withOpacity(0.04),
            border: Border.all(
              color: isCompleted
                  ? SacredColors.parchment.withOpacity(0.5)
                  : SacredColors.parchment.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: isCompleted
                ? [BoxShadow(color: SacredColors.parchment.withOpacity(0.15), blurRadius: 8)]
                : null,
          ),
          child: isCompleted
              ? Center(
                  child: Icon(Icons.check_rounded, size: 14, color: SacredColors.parchment.withOpacity(0.7)),
                )
              : Center(
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.jost(
                      fontSize: 9,
                      fontWeight: FontWeight.w300,
                      color: SacredColors.parchment.withOpacity(0.15),
                    ),
                  ),
                ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Bead Ring Painter — Double ring for bead & mala progress
// ═══════════════════════════════════════════════════════════════

class _BeadRingPainter extends CustomPainter {
  final double beadProgress;
  final double malaProgress;

  _BeadRingPainter({required this.beadProgress, required this.malaProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 6;
    final innerRadius = outerRadius - 14;

    // Outer ring bg
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = SacredColors.parchment.withOpacity(0.06),
    );

    // Outer ring — mala progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -pi / 2,
      2 * pi * malaProgress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = SacredColors.parchment.withOpacity(0.35),
    );

    // Inner ring bg
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = SacredColors.parchment.withOpacity(0.04),
    );

    // Inner ring — bead progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -pi / 2,
      2 * pi * beadProgress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = SacredColors.ember.withOpacity(0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _BeadRingPainter old) =>
      old.beadProgress != beadProgress || old.malaProgress != malaProgress;
}
