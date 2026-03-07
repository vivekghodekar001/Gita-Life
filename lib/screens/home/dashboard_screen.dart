import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/sacred_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/sacred_widgets.dart';
import '../../widgets/ancient_book_widget.dart';
import '../../widgets/offline_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _navIndex = -1; // No active tab — dashboard is separate

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final isAdmin = userProfile?.role == 'admin';
    final firstName = (userProfile?.fullName.isNotEmpty == true)
        ? userProfile!.fullName.split(' ').first
        : 'Devotee';
    final initials = (userProfile?.fullName.isNotEmpty == true)
        ? userProfile!.fullName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              // ── Header: Greeting + Avatar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hare Krishna,', style: SacredTextStyles.greeting()),
                        const SizedBox(height: 1),
                        Text(firstName, style: SacredTextStyles.userName()),
                      ],
                    ),
                    Row(
                      children: [
                        // Admin button
                        if (isAdmin)
                          GestureDetector(
                            onTap: () => context.push('/admin'),
                            child: Container(
                              width: 40, height: 40,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: SacredColors.ember.withOpacity(0.08),
                                border: Border.all(color: SacredColors.ember.withOpacity(0.2)),
                              ),
                              child: Icon(Icons.admin_panel_settings, size: 18, color: SacredColors.ember.withOpacity(0.7)),
                            ),
                          ),
                        // Profile avatar
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF2A1A0A), Color(0xFF1A0E06)],
                              ),
                              border: Border.all(color: SacredColors.glassBorder),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      center: const Alignment(-0.3, -0.3),
                                      colors: [
                                        SacredColors.parchment.withOpacity(0.15),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  initials,
                                  style: GoogleFonts.cormorantSc(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: SacredColors.parchment,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Book fills remaining space ──
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    child: AncientBookWidget(
                      width: 270,
                      height: 365,
                      onTap: () => context.push('/gita'),
                    ),
                  ),
                ),
              ),

              // ── Pill Bottom Bar ──
              _GlassBottomBar(
                currentIndex: _navIndex,
                onTap: (index) {
                  setState(() => _navIndex = index);
                  switch (index) {
                    case 0: context.push('/japa'); break;
                    case 1: context.push('/lectures'); break;
                    case 2: context.push('/audio'); break;
                    case 3: context.push('/assignments'); break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Warm Parchment Pill Bottom Bar
// ═══════════════════════════════════════════════════════════════

class _GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassBottomBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _BarItem(icon: Icons.radio_button_checked_rounded, label: 'Japa'),
    _BarItem(icon: Icons.play_circle_outline_rounded, label: 'Video'),
    _BarItem(icon: Icons.headphones_rounded, label: 'Audio'),
    _BarItem(icon: Icons.assignment_rounded, label: 'Assignment'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.7, -1),
            end: Alignment(0.7, 1),
            colors: [Color(0xD9F0E4C3), Color(0xE6DCD5A5)],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0x80B48C28), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 28, offset: const Offset(0, 8)),
            BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.18), blurRadius: 10, spreadRadius: 1),
            const BoxShadow(color: Color(0x55FFE678), blurRadius: 1, offset: Offset(0, -1)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length * 2 - 1, (idx) {
              if (idx.isOdd) {
                // Vertical gold divider
                return Container(
                  width: 1,
                  height: 26,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x408B6914),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              }
              final i = idx ~/ 2;
              final item = _items[i];
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: const Cubic(0.34, 1.56, 0.64, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: isActive
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0x40D4AF37), Color(0x26B48C1E)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0x66B48C28), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA07814).withOpacity(0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            item.icon,
                            size: 19,
                            color: isActive
                                ? const Color(0xFF8B5E0A)
                                : const Color(0xFF64461A).withOpacity(0.42),
                          ),
                          if (isActive)
                            Positioned(
                              bottom: -5,
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFD4AF37), Color(0xFFF0C040)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4AF37).withOpacity(0.8),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.label.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: 8,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                          color: isActive
                              ? const Color(0xFF7A5008)
                              : const Color(0xFF64461A).withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BarItem {
  final IconData icon;
  final String label;
  const _BarItem({required this.icon, required this.label});
}
