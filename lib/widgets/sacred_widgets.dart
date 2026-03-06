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
            SacredColors.parchment.withOpacity(0.12),
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
        color: Color(0xFF080604),
      ),
      child: Stack(
        children: [
          // Ambient warm radial gradients
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, 0.2),
                  radius: 1.0,
                  colors: [
                    const Color(0xFF783C0A).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.5, -0.4),
                  radius: 1.2,
                  colors: [
                    const Color(0xFF50280A).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
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
