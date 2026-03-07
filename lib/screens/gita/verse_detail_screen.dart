import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/sacred_theme.dart';
import '../../providers/gita_provider.dart';
import '../../widgets/sacred_widgets.dart';

// Provides local state for adjustable font sizing
final fontSizeProvider = StateProvider<double>((ref) => 18.0);

class VerseDetailScreen extends ConsumerWidget {
  final String chapterId;
  final String verseId;

  const VerseDetailScreen({
    super.key,
    required this.chapterId,
    required this.verseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterNum = int.tryParse(chapterId) ?? 1;
    final verseNum = int.tryParse(verseId) ?? 1;

    final versesAsync = ref.watch(versesByChapterProvider(chapterNum));
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: versesAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: SacredColors.parchment.withOpacity(0.4),
            ),
          ),
          error: (err, stack) => Center(
            child: Text('Error: $err', style: SacredTextStyles.infoValue()),
          ),
          data: (verses) {
            if (verses.isEmpty) {
              return Center(
                child: Text('Verse not found.', style: SacredTextStyles.infoValue()),
              );
            }

            final index = verses.indexWhere((v) => v.verseNumber == verseNum);
            if (index == -1) {
              return Center(
                child: Text('Verse not found in chapter.', style: SacredTextStyles.infoValue()),
              );
            }

            final verse = verses[index];
            final hasNext = index < verses.length - 1;
            final hasPrev = index > 0;

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
                            'CHAPTER $chapterNum · VERSE $verseNum',
                            style: SacredTextStyles.verseRef(),
                          ),
                          const SizedBox(height: 20),
                          SacredDivider(width: 40, margin: EdgeInsets.zero),
                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await ref.read(gitaServiceProvider).toggleBookmark(verse.id);
                                  ref.invalidate(versesByChapterProvider(chapterNum));
                                  ref.invalidate(bookmarkedVersesProvider);
                                },
                                child: Container(
                                  width: 38, height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0x08FFFFFF),
                                    border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
                                  ),
                                  child: Icon(
                                    verse.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    size: 16,
                                    color: SacredColors.parchment.withOpacity(verse.isBookmarked ? 0.8 : 0.4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  Share.share(
                                    'Bhagavad Gita ${verse.chapterNumber}.${verse.verseNumber}\n\n${verse.textDevanagari}\n\n${verse.textEnglish}\n\nShared via GitaLife App',
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

                          // Devanagari
                          Text(
                            verse.textDevanagari.replaceAll('\\r\\n', '\n'),
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
                            verse.textTransliteration.replaceAll('\\r\\n', '\n'),
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
                              'TRANSLATION',
                              style: SacredTextStyles.sectionLabel(fontSize: 10),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            verse.textEnglish,
                            style: SacredTextStyles.verseTranslation(fontSize: fontSize),
                          ),
                          const SizedBox(height: 24),

                          // Purport
                          if (verse.purport.isNotEmpty) ...[
                            SacredDivider(margin: EdgeInsets.zero),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'PURPORT',
                                style: SacredTextStyles.sectionLabel(fontSize: 10),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              verse.purport,
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
                            onTap: () => context.pushReplacement('/gita/chapter/$chapterNum/verse/${verseNum - 1}'),
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
                          '${index + 1} / ${verses.length}',
                          style: SacredTextStyles.shloka(fontSize: 12).copyWith(
                            color: SacredColors.parchment.withOpacity(0.25),
                            letterSpacing: 2,
                          ),
                        ),

                        if (hasNext)
                          GestureDetector(
                            onTap: () => context.pushReplacement('/gita/chapter/$chapterNum/verse/${verseNum + 1}'),
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
          },
        ),
      ),
    );
  }
}
