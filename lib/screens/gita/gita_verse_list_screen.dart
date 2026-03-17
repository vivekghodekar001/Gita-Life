import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../app/sacred_theme.dart';
import '../../providers/gita_provider.dart';
import '../../services/gita_service.dart';
import '../../models/gita_verse.dart';
import '../../widgets/sacred_widgets.dart';

class GitaVerseListScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final String chapterName;
  final int versesCount;

  const GitaVerseListScreen({
    super.key,
    required this.chapterNumber,
    required this.chapterName,
    required this.versesCount,
  });

  @override
  ConsumerState<GitaVerseListScreen> createState() => _GitaVerseListScreenState();
}

class _GitaVerseListScreenState extends ConsumerState<GitaVerseListScreen> {
  final List<GitaVerse> _verses = [];
  bool _loading = true;
  String? _error;
  int _currentIndex = 0;
  late CardSwiperController _swiperController;

  @override
  void initState() {
    super.initState();
    _swiperController = CardSwiperController();
    _loadAllVerses();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadAllVerses() async {
    try {
      final futures = <Future<GitaVerse>>[];
      for (int i = 1; i <= widget.versesCount; i++) {
        futures.add(GitaService.getVerse(widget.chapterNumber, i));
      }
      final results = await Future.wait(futures);
      if (mounted) {
        setState(() {
          _verses.addAll(results);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translator = ref.watch(translatorProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8B6914).withOpacity(0.1),
                          border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF4A2C0A)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHAPTER ${widget.chapterNumber}',
                            style: GoogleFonts.jost(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8B6914).withOpacity(0.5),
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.chapterName,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3A2010),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Translator switcher
                    _TranslatorDropdown(
                      value: translator,
                      onChanged: (val) => ref.read(translatorProvider.notifier).state = val,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // ── Verse counter ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        gradient: LinearGradient(
                          colors: [const Color(0xFF8B6914).withOpacity(0.3), Colors.transparent],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _loading
                          ? 'LOADING...'
                          : 'VERSE ${_currentIndex + 1} OF ${widget.versesCount}',
                      style: GoogleFonts.jost(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8B6914).withOpacity(0.45),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          gradient: LinearGradient(
                            colors: [const Color(0xFF8B6914).withOpacity(0.3), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // ── Main content ──
              Expanded(
                child: _loading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF8B4513),
                              strokeWidth: 2,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading verses...',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 16,
                                color: const Color(0xFF8B6914).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, size: 40, color: const Color(0xFF8B4513).withOpacity(0.5)),
                                const SizedBox(height: 12),
                                Text(
                                  'Failed to load verses',
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 18,
                                    color: const Color(0xFF4A2C0A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    _error!.contains('SocketException') || _error!.contains('Failed host lookup')
                                        ? 'No internet connection'
                                        : _error!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.jost(
                                      fontSize: 12,
                                      color: const Color(0xFF8B6914).withOpacity(0.4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _loading = true;
                                      _error = null;
                                      _verses.clear();
                                    });
                                    _loadAllVerses();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF8B4513), Color(0xFFC8722A)],
                                      ),
                                    ),
                                    child: Text(
                                      'Retry',
                                      style: GoogleFonts.jost(fontSize: 14, color: const Color(0xFFF5E8D0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : CardSwiper(
                            controller: _swiperController,
                            cardsCount: _verses.length,
                            numberOfCardsDisplayed: _verses.length >= 3 ? 3 : _verses.length,
                            backCardOffset: const Offset(0, -30),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            onSwipe: (prevIndex, currentIndex, direction) {
                              setState(() {
                                _currentIndex = currentIndex ?? 0;
                              });
                              return true;
                            },
                            cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                              return _GitaSwipeCard(
                                verse: _verses[index],
                                translator: translator,
                              );
                            },
                          ),
              ),
              // ── Swipe hint ──
              if (!_loading && _error == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe, size: 16, color: const Color(0xFF8B6914).withOpacity(0.25)),
                      const SizedBox(width: 6),
                      Text(
                        'SWIPE TO NAVIGATE',
                        style: GoogleFonts.jost(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8B6914).withOpacity(0.25),
                          letterSpacing: 3,
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

// ═══════════════════════════════════════════════════════════════
//  Translator Dropdown
// ═══════════════════════════════════════════════════════════════

class _TranslatorDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _TranslatorDropdown({required this.value, required this.onChanged});

  static const _options = {
    'sivananda': 'Sivananda EN',
    'purohit': 'Purohit EN',
    'hindi': 'Hindi',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF8B6914).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, size: 18, color: const Color(0xFF8B6914).withOpacity(0.5)),
          dropdownColor: const Color(0xFFF5EDDA),
          style: GoogleFonts.jost(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3A2010),
          ),
          items: _options.entries.map((e) {
            return DropdownMenuItem(value: e.key, child: Text(e.value));
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Swipe Card — Parchment styled verse card
// ═══════════════════════════════════════════════════════════════

class _GitaSwipeCard extends StatelessWidget {
  final GitaVerse verse;
  final String translator;

  const _GitaSwipeCard({
    required this.verse,
    required this.translator,
  });

  String get _translation {
    switch (translator) {
      case 'purohit':
        return verse.purohitTranslation.isNotEmpty
            ? verse.purohitTranslation
            : 'Translation not available';
      case 'hindi':
        return verse.hindiTranslation.isNotEmpty
            ? verse.hindiTranslation
            : 'Translation not available';
      case 'sivananda':
      default:
        return verse.sivanandaTranslation.isNotEmpty
            ? verse.sivanandaTranslation
            : 'Translation not available';
    }
  }

  String get _translationLabel {
    switch (translator) {
      case 'purohit':
        return 'TRANSLATION (PUROHIT)';
      case 'hindi':
        return 'अनुवाद';
      case 'sivananda':
      default:
        return 'TRANSLATION (SIVANANDA)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5EDDA), Color(0xFFEDE0C4), Color(0xFFE4D4B0)],
        ),
        border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A2C0A).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verse number header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 30, height: 1, color: const Color(0xFF8B6914).withOpacity(0.2)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B4513), Color(0xFFC8722A)],
                      ),
                    ),
                    child: Text(
                      '${verse.chapter}.${verse.verse}',
                      style: GoogleFonts.cormorantSc(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF5E8D0),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 30, height: 1, color: const Color(0xFF8B6914).withOpacity(0.2)),
                ],
              ),
              const SizedBox(height: 20),

              // Sanskrit shlok
              Text(
                verse.slok,
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont(
                  'Tiro Devanagari Sanskrit',
                  fontSize: 19,
                  height: 2.0,
                  color: const Color(0xFF3A2010),
                ),
              ),
              const SizedBox(height: 16),

              // Divider ornament
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 50, height: 1, color: const Color(0xFF8B6914).withOpacity(0.15)),
                  const SizedBox(width: 8),
                  Icon(Icons.auto_awesome, size: 10, color: const Color(0xFF8B6914).withOpacity(0.3)),
                  const SizedBox(width: 8),
                  Container(width: 50, height: 1, color: const Color(0xFF8B6914).withOpacity(0.15)),
                ],
              ),
              const SizedBox(height: 14),

              // Transliteration
              if (verse.transliteration.isNotEmpty)
                Text(
                  verse.transliteration,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jost(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: const Color(0xFF8B6914).withOpacity(0.45),
                    height: 1.6,
                  ),
                ),
              if (verse.transliteration.isNotEmpty) const SizedBox(height: 14),

              // Second divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: const Color(0xFF8B6914).withOpacity(0.1),
              ),
              const SizedBox(height: 14),

              // Translation label
              Text(
                _translationLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.jost(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B6914).withOpacity(0.35),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),

              // Translation text
              Text(
                _translation,
                textAlign: TextAlign.center,
                style: GoogleFonts.jost(
                  fontSize: 15,
                  color: const Color(0xFF4A2C0A).withOpacity(0.7),
                  height: 1.7,
                ),
              ),

              // Commentary (Sivananda only)
              if (translator == 'sivananda' && verse.sivanandaCommentary.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: const Color(0xFF8B6914).withOpacity(0.1),
                ),
                const SizedBox(height: 14),
                Text(
                  'COMMENTARY',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jost(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B6914).withOpacity(0.35),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  verse.sivanandaCommentary,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jost(
                    fontSize: 13,
                    color: const Color(0xFF4A2C0A).withOpacity(0.55),
                    height: 1.7,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
