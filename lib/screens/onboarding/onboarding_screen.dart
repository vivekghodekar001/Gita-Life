import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

// ── Page data ─────────────────────────────────────────────────
class _PageData {
  final String sanskritSymbol;
  final String badge;
  final String title;
  final String subtitle;
  final String verse;
  final String verseRef;
  final IconData icon;

  const _PageData({
    required this.sanskritSymbol,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.verse,
    required this.verseRef,
    required this.icon,
  });
}

const List<_PageData> _kPages = [
  _PageData(
    sanskritSymbol: 'ॐ',
    badge: 'BHAGAVAD GITA',
    title: 'The Song Divine',
    subtitle: 'Study all 18 chapters with Sanskrit shlokas, transliteration, and translations. Carry the wisdom of the Gita wherever you go.',
    verse: 'यदा यदा हि धर्मस्य ग्लानिर्भवति भारत।\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम् ॥',
    verseRef: 'BHAGAVAD GITA · 4.7',
    icon: Icons.auto_stories_rounded,
  ),
  _PageData(
    sanskritSymbol: '🪬',
    badge: 'JAPA SADHANA',
    title: 'Count Your Rounds',
    subtitle: 'Use the digital mala counter to count your daily chanting rounds. Build a streak, track your progress, and deepen your practice.',
    verse: 'हरे कृष्ण हरे कृष्ण\nकृष्ण कृष्ण हरे हरे ॥\nहरे राम हरे राम\nराम राम हरे हरे ॥',
    verseRef: 'MAHĀ-MANTRA',
    icon: Icons.radio_button_checked_rounded,
  ),
  _PageData(
    sanskritSymbol: '॥',
    badge: 'YOUR JOURNEY',
    title: 'Begin Your Sadhana',
    subtitle: 'Attend lectures, listen to kirtans, mark attendance, and grow alongside your spiritual community every single day.',
    verse: 'संयोगो वियोगान्तः कालः कालस्य कारणम्।\nसत्सङ्गस्तु सदा श्रेयान् मोक्षमार्गप्रकाशकः ॥',
    verseRef: 'SPIRITUAL WISDOM',
    icon: Icons.self_improvement_rounded,
  ),
];

// ── State ──────────────────────────────────────────────────────
class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _fadeCtrl.forward(from: 0);
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) context.go('/login');
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip row ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Om mark
                    Text(
                      'ॐ',
                      style: GoogleFonts.getFont(
                        'Tiro Devanagari Sanskrit',
                        fontSize: 22,
                        color: const Color(0xFF8B4513).withOpacity(0.55),
                      ),
                    ),
                    GestureDetector(
                      onTap: _completeOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.3)),
                          color: const Color(0xFF8B6914).withOpacity(0.07),
                        ),
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.jost(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.5,
                            color: const Color(0xFF8B4513).withOpacity(0.65),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── PageView ──────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _kPages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: index == _currentPage ? _fadeAnim : const AlwaysStoppedAnimation(1.0),
                      child: _OnboardingPage(data: _kPages[index]),
                    );
                  },
                ),
              ),

              // ── Bottom nav ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dots
                    Row(
                      children: List.generate(_kPages.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: isActive ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: isActive
                                ? const LinearGradient(colors: [Color(0xFF8B4513), Color(0xFFC8722A)])
                                : null,
                            color: isActive ? null : const Color(0xFF8B6914).withOpacity(0.22),
                          ),
                        );
                      }),
                    ),

                    // Next / Get Started
                    _currentPage == _kPages.length - 1
                        ? GestureDetector(
                            onTap: _completeOnboarding,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B4513), Color(0xFFC8722A)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8B4513).withOpacity(0.3),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Begin',
                                    style: GoogleFonts.cormorantSc(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFF5E8D0),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFFF5E8D0)),
                                ],
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: _nextPage,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B4513), Color(0xFFC8722A)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8B4513).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFF5E8D0), size: 22),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single Page Widget ─────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          // Sanskrit symbol / Om
          Text(
            data.sanskritSymbol,
            style: GoogleFonts.getFont(
              'Tiro Devanagari Sanskrit',
              fontSize: 44,
              color: const Color(0xFF8B4513).withOpacity(0.35),
            ),
          ),
          const SizedBox(height: 8),

          // Badge pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8B4513), Color(0xFFC8722A)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFF8B4513).withOpacity(0.28), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Text(
              data.badge,
              style: GoogleFonts.jost(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF5E8D0),
                letterSpacing: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantSc(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3A2010),
              letterSpacing: 1.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5C3A1E),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),

          // Verse card
          _VerseCard(verse: data.verse, verseRef: data.verseRef, icon: data.icon),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Verse Card ─────────────────────────────────────────────────
class _VerseCard extends StatelessWidget {
  final String verse;
  final String verseRef;
  final IconData icon;

  const _VerseCard({required this.verse, required this.verseRef, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5EDDA), Color(0xFFEDE0C4), Color(0xFFE4D4B0)],
        ),
        border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.28), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A2C0A).withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: Color(0x28FFFFFF),
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top ornament
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _OrnamentLine(),
              const SizedBox(width: 10),
              Icon(icon, size: 16, color: const Color(0xFF8B4513).withOpacity(0.55)),
              const SizedBox(width: 10),
              _OrnamentLine(),
            ],
          ),
          const SizedBox(height: 14),

          // Sanskrit verse
          Text(
            verse,
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont(
              'Tiro Devanagari Sanskrit',
              fontSize: 14,
              color: const Color(0xFF3A2010),
              height: 2.0,
            ),
          ),

          const SizedBox(height: 12),

          // Bottom separator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _OrnamentLine(),
              const SizedBox(width: 8),
              Text('✦', style: TextStyle(fontSize: 9, color: const Color(0xFF8B6914).withOpacity(0.5))),
              const SizedBox(width: 8),
              _OrnamentLine(),
            ],
          ),
          const SizedBox(height: 10),

          // Reference
          Text(
            verseRef,
            style: GoogleFonts.jost(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: const Color(0xFF8B6914).withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrnamentLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, const Color(0xFF8B6914).withOpacity(0.35), Colors.transparent],
        ),
      ),
    );
  }
}
