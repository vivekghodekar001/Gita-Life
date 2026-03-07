import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: japaAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: SacredColors.parchment)),
          error: (err, stack) => Center(
            child: Text(
              err.toString().contains('permission-denied')
                  ? 'Your account is pending approval.'
                  : 'Could not load Japa counter. Please restart.',
              style: TextStyle(color: SacredColors.parchment.withOpacity(0.6)),
            ),
          ),
          data: (log) {
            if (log == null) return Center(child: Text('Could not load Japa Log', style: SacredTextStyles.infoValue()));

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
                ref.invalidate(weekHistoryProvider);
                ref.invalidate(monthHistoryProvider);
                // Sync to Firestore
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  ref.read(japaServiceProvider).syncToFirestore(user.uid);
                }
              },
              child: SafeArea(
                child: Column(
                  children: [
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
                        fontWeight: FontWeight.w400,
                        color: SacredColors.parchment.withOpacity(0.90),
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'OF $_totalMalaTarget MALAS',
                      style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(
                        letterSpacing: 6,
                        color: SacredColors.parchment.withOpacity(0.62),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Current bead within mala
                    Text(
                      '${log.totalBeads} / 108 beads',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: SacredColors.parchment.withOpacity(0.70),
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
                      fontWeight: FontWeight.w500,
                      color: SacredColors.parchment.withOpacity(0.55),
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
