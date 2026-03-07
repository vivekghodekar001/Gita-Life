import 'dart:math';
import 'package:flutter/material.dart';
import '../app/sacred_theme.dart';

// ═══════════════════════════════════════════════════════════════
//  Glass Info Card — Translucent glass-morphism info row
// ═══════════════════════════════════════════════════════════════

class GlassInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const GlassInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = const Color(0xB3C8A96E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(13),
      decoration: SacredDecorations.glassCard(),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: SacredDecorations.iconBox(),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: SacredTextStyles.infoKey(),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: SacredTextStyles.infoValue(),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Sacred Chip — Interest / tag chip
// ═══════════════════════════════════════════════════════════════

class SacredChip extends StatelessWidget {
  final String label;

  const SacredChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: SacredDecorations.chipDecoration(),
      child: Center(
        child: Text(label, style: SacredTextStyles.chip()),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Sacred Progress Ring — Circular progress with ornamental style
// ═══════════════════════════════════════════════════════════════

class SacredProgressRing extends StatelessWidget {
  final double percent; // 0.0 to 1.0
  final Color color;
  final String label;
  final String sublabel;
  final String bottomLabel;
  final IconData? icon;

  const SacredProgressRing({
    super.key,
    required this.percent,
    required this.color,
    required this.label,
    this.sublabel = '',
    this.bottomLabel = '',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: SacredColors.glassBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SacredColors.parchment.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 66,
              height: 66,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: percent,
                  color: color,
                  bgColor: SacredColors.parchment.withOpacity(0.08),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(percent * 100).round()}%',
                        style: SacredTextStyles.ringPercent().copyWith(color: color.withOpacity(0.8)),
                      ),
                      if (sublabel.isNotEmpty)
                        Text(
                          sublabel.toUpperCase(),
                          style: SacredTextStyles.progressLabel(fontSize: 6).copyWith(
                            color: color.withOpacity(0.4),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (icon != null) ...[
              Icon(icon, size: 11, color: color.withOpacity(0.4)),
              const SizedBox(height: 4),
            ],
            Text(
              bottomLabel,
              style: SacredTextStyles.progressLabel(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _RingPainter({required this.progress, required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = bgColor;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(0.7);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// ═══════════════════════════════════════════════════════════════
//  Sacred Divider — Gradient gold line
// ═══════════════════════════════════════════════════════════════

class SacredDivider extends StatelessWidget {
  final double width;
  final EdgeInsetsGeometry margin;

  const SacredDivider({
    super.key,
    this.width = double.infinity,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            SacredColors.parchment.withOpacity(0.35),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Section Label — "SADHAKA INFO" style label with trailing line
// ═══════════════════════════════════════════════════════════════

class SacredSectionLabel extends StatelessWidget {
  final String text;

  const SacredSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: SacredTextStyles.sectionLabel(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SacredColors.parchment.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Ambient Background — The dark vignette background
// ═══════════════════════════════════════════════════════════════

class SacredBackground extends StatelessWidget {
  final Widget child;

  const SacredBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEDE3CC), // light cream top-left
            Color(0xFFE0D0B0), // warm tan center
            Color(0xFFD4C49A), // deeper tan bottom-right
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // All static background layers isolated in one RepaintBoundary
          // so they never repaint when the child rebuilds
          RepaintBoundary(
            child: Stack(
              children: [
                // Radial glow overlays
                Positioned(
                  top: -80,
                  left: -60,
                  child: _ParchmentGlowBlob(
                    color: const Color(0xFFF5EDD8).withOpacity(0.6),
                    size: 350,
                  ),
                ),
                Positioned(
                  top: 180,
                  right: -80,
                  child: _ParchmentGlowBlob(
                    color: const Color(0xFFDCC898).withOpacity(0.35),
                    size: 280,
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: 20,
                  child: _ParchmentGlowBlob(
                    color: const Color(0xFFF0E6C8).withOpacity(0.45),
                    size: 320,
                  ),
                ),
                Positioned(
                  bottom: -60,
                  right: 30,
                  child: _ParchmentGlowBlob(
                    color: const Color(0xFFD4B878).withOpacity(0.25),
                    size: 260,
                  ),
                ),
                // Scratch texture lines
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ParchmentScratchPainter(),
                  ),
                ),
                // Vignette edges
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.transparent,
                          const Color(0xFFA08040).withOpacity(0.18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ParchmentGlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _ParchmentGlowBlob({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );
}

class _ParchmentScratchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B6914).withOpacity(0.22)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    final lines = [
      [0.10, 0.05, 0.25, 0.12],
      [0.60, 0.03, 0.80, 0.08],
      [0.05, 0.22, 0.18, 0.28],
      [0.70, 0.18, 0.90, 0.23],
      [0.15, 0.45, 0.30, 0.50],
      [0.55, 0.40, 0.75, 0.44],
      [0.08, 0.65, 0.22, 0.70],
      [0.65, 0.60, 0.88, 0.66],
      [0.20, 0.80, 0.38, 0.85],
      [0.50, 0.75, 0.72, 0.80],
      [0.10, 0.92, 0.28, 0.96],
      [0.62, 0.88, 0.82, 0.93],
    ];
    for (final l in lines) {
      canvas.drawLine(
        Offset(l[0] * size.width, l[1] * size.height),
        Offset(l[2] * size.width, l[3] * size.height),
        paint,
      );
    }

    final arcPaint = Paint()
      ..color = const Color(0xFF7A5C10).withOpacity(0.16)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    final arcs = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.05, size.width * 0.25, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.65, size.height * 0.02, size.width * 0.28, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.02, size.height * 0.35, size.width * 0.22, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.10, size.height * 0.60, size.width * 0.24, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.60, size.height * 0.55, size.width * 0.30, size.height * 0.22),
    ];
    for (final rect in arcs) {
      canvas.drawArc(rect, 0.3, 1.2, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(_ParchmentScratchPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
//  Sacred Bottom Nav Bar
// ═══════════════════════════════════════════════════════════════

class SacredBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SacredBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.auto_stories_rounded, label: 'Gita'),
    _NavItem(icon: Icons.radio_button_checked, label: 'Japa'),
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.headphones_rounded, label: 'Audio'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: SacredDecorations.navPill(),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            final isActive = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: isActive
                    ? BoxDecoration(
                        color: SacredColors.parchment.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SacredColors.parchment.withOpacity(0.2)),
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: SacredColors.parchment.withOpacity(isActive ? 0.9 : 0.4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label.toUpperCase(),
                      style: isActive
                          ? SacredTextStyles.navLabelActive()
                          : SacredTextStyles.navLabel(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ═══════════════════════════════════════════════════════════════
//  Sacred Feature Card — Dark glass-morphism feature card
// ═══════════════════════════════════════════════════════════════

class SacredFeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SacredFeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.15)),
              ),
              child: Icon(icon, size: 26, color: color.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: SacredTextStyles.sectionLabel(fontSize: 7.5).copyWith(
                color: color.withOpacity(0.7),
                letterSpacing: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
