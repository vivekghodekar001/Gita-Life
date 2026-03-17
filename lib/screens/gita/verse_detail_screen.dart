import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/sacred_theme.dart';
import '../../providers/gita_provider.dart';
import '../../services/gita_service.dart';
import '../../models/gita_verse.dart';
import '../../widgets/sacred_widgets.dart';

final fontSizeProvider = StateProvider<double>((ref) => 18.0);

class VerseDetailScreen extends ConsumerStatefulWidget {
  final String chapterId;
  final String verseId;

  const VerseDetailScreen({
    super.key,
    required this.chapterId,
    required this.verseId,
  });

  @override
  ConsumerState<VerseDetailScreen> createState() => _VerseDetailScreenState();
}

class _VerseDetailScreenState extends ConsumerState<VerseDetailScreen> {
  GitaVerse? _verse;
  int? _totalVerses;
  bool _loading = true;
  String? _error;

  int get _chapterNum => int.tryParse(widget.chapterId) ?? 1;
  int get _verseNum => int.tryParse(widget.verseId) ?? 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        GitaService.getVerse(_chapterNum, _verseNum),
        GitaService.getChapter(_chapterNum),
      ]);
      if (mounted) {
        setState(() {
          _verse = results[0] as GitaVerse;
          _totalVerses = (results[1] as GitaChapter).versesCount;
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
    final fontSize = ref.watch(fontSizeProvider);
    final translator = ref.watch(translatorProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: SacredColors.parchment.withOpacity(0.4),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 40, color: SacredColors.parchment.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(
                          _error!.contains('SocketException') || _error!.contains('Failed host lookup')
                              ? 'No internet connection'
                              : 'Failed to load verse',
                          style: SacredTextStyles.infoValue(),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _loading = true;
                              _error = null;
                            });
                            _loadData();
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
                : _buildContent(fontSize, translator),
      ),
    );
  }

  Widget _buildContent(double fontSize, String translator) {
    final verse = _verse!;
    final hasNext = _verseNum < (_totalVerses ?? 0);
    final hasPrev = _verseNum > 1;

    String translation;
    String translationLabel;
    switch (translator) {
      case 'purohit':
        translation = verse.purohitTranslation.isNotEmpty
            ? verse.purohitTranslation
            : 'Translation not available';
        translationLabel = 'TRANSLATION (PUROHIT)';
        break;
      case 'hindi':
        translation = verse.hindiTranslation.isNotEmpty
            ? verse.hindiTranslation
            : 'Translation not available';
        translationLabel = 'अनुवाद';
        break;
      case 'sivananda':
      default:
        translation = verse.sivanandaTranslation.isNotEmpty
            ? verse.sivanandaTranslation
            : 'Translation not available';
        translationLabel = 'TRANSLATION (SIVANANDA)';
    }

    return SafeArea(
      child: Column(
        children: [
          // ── Top Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x08FFFFFF),
                      border: Border.all(color: SacredColors.parchment.withOpacity(0.12)),
                    ),
                    child: Icon(Icons.arrow_back_ios_new, size: 12, color: SacredColors.parchment.withOpacity(0.5)),
                  ),
                ),
                const Spacer(),
                // Translator switcher
                _TranslatorDropdown(
                  value: translator,
                  onChanged: (val) => ref.read(translatorProvider.notifier).state = val,
                ),
                const SizedBox(width: 8),
                // Font size controls
                GestureDetector(
                  onTap: () {
                    if (fontSize > 12) ref.read(fontSizeProvider.notifier).state -= 2;
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x08FFFFFF),
                      border: Border.all(color: SacredColors.parchment.withOpacity(0.12)),
                    ),
                    child: Icon(Icons.remove, size: 12, color: SacredColors.parchment.withOpacity(0.4)),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Aa',
                  style: SacredTextStyles.infoValue(fontSize: 12).copyWith(
                    color: SacredColors.parchment.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    if (fontSize < 36) ref.read(fontSizeProvider.notifier).state += 2;
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x08FFFFFF),
                      border: Border.all(color: SacredColors.parchment.withOpacity(0.12)),
                    ),
                    child: Icon(Icons.add, size: 12, color: SacredColors.parchment.withOpacity(0.4)),
                  ),
                ),
              ],
            ),
          ),

          // ── Verse Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Verse Reference
                  Text(
                    'CHAPTER $_chapterNum · VERSE $_verseNum',
                    style: SacredTextStyles.verseRef(),
                  ),
                  const SizedBox(height: 20),
                  SacredDivider(width: 40, margin: EdgeInsets.zero),
                  const SizedBox(height: 20),

                  // Share button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Share.share(
                            'Bhagavad Gita ${verse.chapter}.${verse.verse}\n\n${verse.slok}\n\n$translation\n\nShared via GitaLife App',
                          );
                        },
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0x08FFFFFF),
                            border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
                          ),
                          child: Icon(Icons.share_outlined, size: 14, color: SacredColors.parchment.withOpacity(0.4)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Sanskrit (Devanagari)
                  Text(
                    verse.slok,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize + 6,
                      color: SacredColors.parchment.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSerifDevanagari',
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SacredDivider(width: 40, margin: EdgeInsets.zero),
                  const SizedBox(height: 24),

                  // Transliteration
                  Text(
                    verse.transliteration,
                    textAlign: TextAlign.center,
                    style: SacredTextStyles.verseDevanagari(fontSize: fontSize).copyWith(
                      fontStyle: FontStyle.italic,
                      color: SacredColors.parchmentLight.withOpacity(0.5),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SacredDivider(width: 40, margin: EdgeInsets.zero),
                  const SizedBox(height: 24),

                  // Translation label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      translationLabel,
                      style: SacredTextStyles.sectionLabel(fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    translation,
                    style: SacredTextStyles.verseTranslation(fontSize: fontSize),
                  ),
                  const SizedBox(height: 24),

                  // Commentary (Sivananda)
                  if (translator == 'sivananda' && verse.sivanandaCommentary.isNotEmpty) ...[
                    SacredDivider(margin: EdgeInsets.zero),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'COMMENTARY',
                        style: SacredTextStyles.sectionLabel(fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      verse.sivanandaCommentary,
                      style: SacredTextStyles.verseTranslation(fontSize: fontSize - 1).copyWith(
                        color: SacredColors.parchmentLight.withOpacity(0.5),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // ── Bottom Navigation ──
          Container(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasPrev)
                  GestureDetector(
                    onTap: () => context.pushReplacement('/gita/chapter/$_chapterNum/verse/${_verseNum - 1}'),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      decoration: BoxDecoration(
                        color: const Color(0x08FFFFFF),
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
                      ),
                      child: Center(
                        child: Text(
                          '← PREV',
                          style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(
                            color: SacredColors.parchment.withOpacity(0.6),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                Text(
                  '$_verseNum / ${_totalVerses ?? '?'}',
                  style: SacredTextStyles.shloka(fontSize: 12).copyWith(
                    color: SacredColors.parchment.withOpacity(0.25),
                    letterSpacing: 2,
                  ),
                ),

                if (hasNext)
                  GestureDetector(
                    onTap: () => context.pushReplacement('/gita/chapter/$_chapterNum/verse/${_verseNum + 1}'),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      decoration: BoxDecoration(
                        color: const Color(0x08FFFFFF),
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
                      ),
                      child: Center(
                        child: Text(
                          'NEXT →',
                          style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(
                            color: SacredColors.parchment.withOpacity(0.6),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
        color: SacredColors.parchment.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, size: 18, color: SacredColors.parchment.withOpacity(0.5)),
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
