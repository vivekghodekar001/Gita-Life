import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../services/audio_service.dart';
import '../../models/audio_track.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';
import 'package:dio/dio.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ManageAudioScreen extends ConsumerWidget {
  const ManageAudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioAsync = ref.watch(adminAudioProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new, size: 16, color: SacredColors.parchment.withOpacity(0.4)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Manage Audio', style: SacredTextStyles.sectionLabel()),
                    ),
                    GestureDetector(
                      onTap: () => _showBulkImportDialog(context, ref),
                      child: Icon(Icons.cloud_download_outlined, size: 18, color: SacredColors.parchment.withOpacity(0.35)),
                    ),
                  ],
                ),
              ),
              // ── List ──
              Expanded(
                child: audioAsync.when(
                  data: (tracks) {
                    if (tracks.isEmpty) {
                      return Center(child: Text('No audio tracks found.', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w500, color: SacredColors.parchment.withOpacity(0.60))));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tracks.length,
                      itemBuilder: (_, i) => _buildAudioCard(context, ref, tracks[i]),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator(color: SacredColors.parchment.withOpacity(0.2), strokeWidth: 1.5)),
                  error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: SacredColors.parchment.withOpacity(0.3)))),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: SacredColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
        ),
        child: IconButton(
          icon: Icon(Icons.add, color: SacredColors.parchment.withOpacity(0.5), size: 20),
          onPressed: () => _showAddEditAudioDialog(context, ref),
        ),
      ),
    );
  }

  Widget _buildAudioCard(BuildContext context, WidgetRef ref, AudioTrackModel track) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: SacredDecorations.glassCard(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: SacredColors.parchment.withOpacity(0.06),
            backgroundImage: track.coverImageUrl != null ? NetworkImage(track.coverImageUrl!) : null,
            child: track.coverImageUrl == null ? Icon(Icons.music_note, color: SacredColors.parchment.withOpacity(0.3), size: 16) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cormorantGaramond(fontSize: 15, fontWeight: FontWeight.w600, color: SacredColors.parchmentLight.withOpacity(0.7))),
                const SizedBox(height: 2),
                Text(track.artist, style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500, color: SacredColors.parchment.withOpacity(0.65))),
                const SizedBox(height: 4),
                Row(children: [
                  _buildTag(track.category.toUpperCase()),
                  const SizedBox(width: 6),
                  _buildTag(track.sourceType.toUpperCase(), color: SacredColors.parchment),
                ]),
              ],
            ),
          ),
          Switch(
            value: track.isActive,
            onChanged: (v) => ref.read(audioServiceProvider).toggleAudioActiveStatus(track.trackId, v),
            activeColor: SacredColors.ember.withOpacity(0.7),
            activeTrackColor: SacredColors.ember.withOpacity(0.15),
            inactiveThumbColor: SacredColors.parchment.withOpacity(0.2),
            inactiveTrackColor: SacredColors.parchment.withOpacity(0.06),
          ),
          GestureDetector(
            onTap: () => _showAddEditAudioDialog(context, ref, track: track),
            child: Icon(Icons.edit_outlined, size: 16, color: SacredColors.parchment.withOpacity(0.3)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteAudioTrack(context, ref, track),
            child: Icon(Icons.delete_outline, size: 16, color: SacredColors.ember.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {Color? color}) {
    final c = color ?? SacredColors.ember;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: c.withOpacity(0.06),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: c.withOpacity(0.15)),
      ),
      child: Text(text, style: GoogleFonts.jost(fontSize: 8, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: c.withOpacity(0.5))),
    );
  }

  void _showAddEditAudioDialog(BuildContext context, WidgetRef ref, {AudioTrackModel? track}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEditAudioForm(track: track),
    );
  }

  void _showBulkImportDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => _BulkImportDialog());
  }

  Future<void> _deleteAudioTrack(BuildContext context, WidgetRef ref, AudioTrackModel track) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SacredColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Track', style: GoogleFonts.cormorantGaramond(color: SacredColors.parchmentLight.withOpacity(0.8))),
        content: Text('Delete "${track.title}"?', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w500, color: SacredColors.parchment.withOpacity(0.75))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: SacredColors.parchment.withOpacity(0.4)))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: SacredColors.ember.withOpacity(0.7)))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(audioServiceProvider).deleteAudioTrack(track.trackId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Audio track deleted.'), backgroundColor: SacredColors.surface));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: SacredColors.surface));
        }
      }
    }
  }
}

// ── Internal data class for crawled tracks ───────────────────────
class _CrawledTrack {
  final String title;
  final String artist;
  final String folder;
  final String streamUrl;
  const _CrawledTrack({required this.title, required this.artist, required this.folder, required this.streamUrl});
}

// ── Bulk Import Dialog ────────────────────────────────────────────
class _BulkImportDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BulkImportDialog> createState() => _BulkImportDialogState();
}

class _BulkImportDialogState extends ConsumerState<_BulkImportDialog> {
  static const String _baseUrl = 'https://audio.iskcondesiretree.com';

  final _urlController = TextEditingController();
  bool _isCrawling = false;
  bool _isImporting = false;
  String _status = '';
  List<_CrawledTrack> _crawledTracks = [];
  String _selectedCategory = 'kirtan';

  final List<String> _categories = ['bhajan', 'kirtan', 'lecture_audio', 'meditation', 'other'];
  bool _isAddingCategory = false;
  final _newCatController = TextEditingController();

  bool get _isIskconFolderUrl {
    final t = _urlController.text.trim();
    return t.contains('iskcondesiretree.com') && (t.contains('q=f') || t.contains('q=d'));
  }

  String _getFolderLabel(String url) {
    try {
      final f = Uri.parse(url).queryParameters['f'] ?? '';
      final parts = Uri.decodeFull(f).split('/').where((s) => s.isNotEmpty).toList();
      return parts.isNotEmpty ? parts.last.replaceAll('_', ' ') : url;
    } catch (_) {
      return url;
    }
  }

  String _buildAbsoluteUrl(String href) {
    if (href.startsWith('http')) return href;
    if (href.startsWith('/')) return '$_baseUrl$href';
    return '$_baseUrl/$href';
  }

  String _toStreamUrl(String href) {
    // ISKCON uses q=d for download — swap to q=s for streaming
    if (href.contains('q=d&')) return href.replaceFirst('q=d', 'q=s');
    return href;
  }

  Future<void> _startCrawl() async {
    final startUrl = _urlController.text.trim();
    if (startUrl.isEmpty) return;

    setState(() {
      _isCrawling = true;
      _crawledTracks = [];
      _status = 'Starting crawl…';
    });

    try {
      final tracks = await _crawlRecursive(startUrl);
      if (mounted) {
        setState(() {
          _crawledTracks = tracks;
          _status = 'Done — found ${tracks.length} tracks.';
          _isCrawling = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Crawl failed: $e';
          _isCrawling = false;
        });
      }
    }
  }

  Future<List<_CrawledTrack>> _crawlRecursive(String startUrl) async {
    final visited = <String>{};
    final queue = Queue<String>();
    final tracks = <_CrawledTrack>[];
    final client = http.Client();

    queue.add(startUrl);
    visited.add(startUrl);

    try {
      while (queue.isNotEmpty) {
        final url = queue.removeFirst();

        if (mounted) {
          setState(() => _status = 'Scanning: ${_getFolderLabel(url)}…  Found ${tracks.length} tracks');
        }

        try {
          final response = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
          if (response.statusCode != 200) continue;

          final document = html_parser.parse(response.body);
          final links = document.querySelectorAll('a[href]');

          for (final link in links) {
            final rawHref = link.attributes['href'] ?? '';
            if (rawHref.isEmpty || rawHref.startsWith('#') || rawHref.startsWith('mailto:')) continue;

            final absHref = _buildAbsoluteUrl(rawHref);

            // ── Sub-folder ──
            if (rawHref.contains('q=f&') && !visited.contains(absHref)) {
              visited.add(absHref);
              queue.add(absHref);
              continue;
            }

            // ── Audio file ──
            final isDownloadLink = rawHref.contains('q=d&');
            final isDirectAudio = rawHref.toLowerCase().endsWith('.mp3') || rawHref.toLowerCase().endsWith('.ogg');

            if (isDownloadLink || isDirectAudio) {
              final streamUrl = _buildAbsoluteUrl(_toStreamUrl(rawHref));
              if (tracks.any((t) => t.streamUrl == streamUrl)) continue;

              // Extract file path for metadata
              String filePath;
              if (isDownloadLink) {
                filePath = Uri.parse(rawHref).queryParameters['f'] ?? rawHref;
              } else {
                filePath = rawHref;
              }

              final segments = Uri.decodeFull(filePath).split('/').where((s) => s.isNotEmpty).toList();
              final filename = segments.isNotEmpty ? segments.last : filePath;
              final artist = segments.length >= 2 ? segments[segments.length - 2].replaceAll('_', ' ').trim() : 'ISKCON';
              final folder = artist;
              final title = filename
                  .replaceAll(RegExp(r'\.(mp3|ogg)$', caseSensitive: false), '')
                  .replaceAll('_', ' ')
                  .trim();

              tracks.add(_CrawledTrack(
                title: title.isEmpty ? 'Audio Track' : title,
                artist: artist,
                folder: folder,
                streamUrl: streamUrl,
              ));
            }
          }
        } catch (e) {
          // Log and skip failing folders
          debugPrint('[Crawler] Skip $url — $e');
        }

        await Future.delayed(const Duration(milliseconds: 300));
      }
    } finally {
      client.close();
    }

    return tracks;
  }

  Future<void> _importTracks() async {
    if (_crawledTracks.isEmpty) return;
    setState(() => _isImporting = true);

    try {
      final audioService = ref.read(audioServiceProvider);
      int count = 0;

      for (final t in _crawledTracks) {
        if (mounted) {
          setState(() => _status = 'Saving ${count + 1} / ${_crawledTracks.length}…');
        }
        final track = AudioTrackModel(
          trackId: '${DateTime.now().millisecondsSinceEpoch}$count',
          title: t.title,
          artist: t.artist,
          category: _selectedCategory,
          sourceType: 'direct_url',
          streamUrl: t.streamUrl,
          durationSeconds: 0,
          fileSizeBytes: 0,
          coverImageUrl: null,
          isActive: true,
          playCount: 0,
          addedBy: 'admin',
          createdAt: DateTime.now().toIso8601String(),
        );
        await audioService.addAudioTrack(track);
        count++;
        await Future.delayed(const Duration(milliseconds: 20));
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() { _status = 'Import error: $e'; _isImporting = false; });
    }
  }

  Future<void> _importDirectUrls() async {
    final lines = _urlController.text.trim().split('\n').map((l) => l.trim()).where((l) => l.startsWith('http')).toList();
    if (lines.isEmpty) return;
    setState(() => _isImporting = true);

    try {
      final audioService = ref.read(audioServiceProvider);
      int count = 0;
      for (final url in lines) {
        final filename = Uri.decodeFull(url.split('/').last.split('?').first);
        final title = filename.replaceAll(RegExp(r'\.(mp3|ogg)$', caseSensitive: false), '').replaceAll('_', ' ').trim();
        final track = AudioTrackModel(
          trackId: '${DateTime.now().millisecondsSinceEpoch}$count',
          title: title.isEmpty ? 'Audio Track' : title,
          artist: 'Unknown',
          category: _selectedCategory,
          sourceType: 'direct_url',
          streamUrl: url,
          durationSeconds: 0, fileSizeBytes: 0,
          coverImageUrl: null, isActive: true, playCount: 0,
          addedBy: 'admin', createdAt: DateTime.now().toIso8601String(),
        );
        await audioService.addAudioTrack(track);
        count++;
        await Future.delayed(const Duration(milliseconds: 20));
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() { _status = 'Error: $e'; _isImporting = false; });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _newCatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isCrawling || _isImporting;
    final hasCrawledResults = _crawledTracks.isNotEmpty;
    final isIskcon = _isIskconFolderUrl;

    return AlertDialog(
      backgroundColor: SacredColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text('Bulk Audio Import', style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600, color: SacredColors.parchmentLight.withOpacity(0.85))),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isIskcon
                  ? 'ISKCON Desire Tree folder URL detected. Tap "Scan Folders" to recursively find all audio files.'
                  : 'Paste one audio URL per line for direct import, or paste an ISKCON Desire Tree folder URL for recursive crawl.',
              style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: SacredColors.parchment.withOpacity(0.65)),
            ),
            const SizedBox(height: 14),
            // URL input
            TextField(
              controller: _urlController,
              maxLines: 3,
              enabled: !isBusy,
              style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: SacredColors.parchmentLight.withOpacity(0.85)),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'https://audio.iskcondesiretree.com/index.php?q=f&f=...\nor paste direct MP3 URLs (one per line)',
                hintStyle: GoogleFonts.jost(fontSize: 11, color: SacredColors.parchment.withOpacity(0.35)),
                filled: true,
                fillColor: SacredColors.parchment.withOpacity(0.06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.20))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.20))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.45))),
              ),
            ),
            const SizedBox(height: 14),
            // Category picker + Add new
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _categories.contains(_selectedCategory) ? _selectedCategory : _categories.first,
                    dropdownColor: SacredColors.surface,
                    style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w500, color: SacredColors.parchmentLight.withOpacity(0.85)),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: GoogleFonts.jost(fontSize: 11, color: SacredColors.parchment.withOpacity(0.55)),
                      filled: true,
                      fillColor: SacredColors.parchment.withOpacity(0.06),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.20))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.20))),
                    ),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                    onChanged: isBusy ? null : (val) => setState(() => _selectedCategory = val!),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: isBusy ? null : () => setState(() => _isAddingCategory = !_isAddingCategory),
                  child: Container(
                    width: 40, height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SacredColors.parchment.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SacredColors.parchment.withOpacity(0.20)),
                    ),
                    child: Icon(_isAddingCategory ? Icons.close : Icons.add, size: 18, color: SacredColors.parchment.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
            if (_isAddingCategory) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newCatController,
                      style: GoogleFonts.jost(fontSize: 13, color: SacredColors.parchmentLight.withOpacity(0.85)),
                      decoration: InputDecoration(
                        hintText: 'New category name',
                        hintStyle: GoogleFonts.jost(fontSize: 11, color: SacredColors.parchment.withOpacity(0.35)),
                        filled: true,
                        fillColor: SacredColors.parchment.withOpacity(0.06),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.20))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.20))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final cat = _newCatController.text.trim().toLowerCase().replaceAll(' ', '_');
                      if (cat.isNotEmpty && !_categories.contains(cat)) {
                        setState(() {
                          _categories.add(cat);
                          _selectedCategory = cat;
                          _isAddingCategory = false;
                          _newCatController.clear();
                        });
                      }
                    },
                    child: Container(
                      width: 40, height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF8B4513), Color(0xFFC8722A)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.check, size: 18, color: Colors.white.withOpacity(0.9)),
                    ),
                  ),
                ],
              ),
            ],
            // Progress / status
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SacredColors.parchment.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    if (isBusy) ...[
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: SacredColors.parchment.withOpacity(0.5))),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(_status, style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500, color: SacredColors.parchment.withOpacity(0.75))),
                    ),
                  ],
                ),
              ),
            ],
            if (hasCrawledResults) ...[
              const SizedBox(height: 8),
              Text(
                '${_crawledTracks.length} tracks ready to import',
                style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w600, color: SacredColors.gold.withOpacity(0.85)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isBusy ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: SacredColors.parchment.withOpacity(0.45))),
        ),
        if (isIskcon && !hasCrawledResults)
          _actionButton(
            label: 'SCAN FOLDERS',
            icon: Icons.folder_open_rounded,
            loading: _isCrawling,
            onTap: isBusy ? null : _startCrawl,
          ),
        if (hasCrawledResults)
          _actionButton(
            label: 'IMPORT ${_crawledTracks.length}',
            icon: Icons.download_done_rounded,
            loading: _isImporting,
            onTap: isBusy ? null : _importTracks,
          ),
        if (!isIskcon && !hasCrawledResults)
          _actionButton(
            label: 'IMPORT',
            icon: Icons.add_rounded,
            loading: _isImporting,
            onTap: isBusy ? null : _importDirectUrls,
          ),
      ],
    );
  }

  Widget _actionButton({required String label, required IconData icon, required bool loading, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: onTap != null
              ? const LinearGradient(colors: [Color(0xFF8B4513), Color(0xFFC8722A)])
              : null,
          color: onTap == null ? SacredColors.parchment.withOpacity(0.08) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: loading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white70))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: onTap != null ? Colors.white : SacredColors.parchment.withOpacity(0.35)),
                  const SizedBox(width: 6),
                  Text(label, style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: onTap != null ? Colors.white : SacredColors.parchment.withOpacity(0.35))),
                ],
              ),
      ),
    );
  }
}

class _AddEditAudioForm extends ConsumerStatefulWidget {
  final AudioTrackModel? track;
  const _AddEditAudioForm({this.track});

  @override
  ConsumerState<_AddEditAudioForm> createState() => _AddEditAudioFormState();
}

class _AddEditAudioFormState extends ConsumerState<_AddEditAudioForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  
  String _category = 'kirtan';
  bool _isActive = true;
  bool _isLoading = false;
  bool _isAddingCategory = false;
  final _newCatController = TextEditingController();

  final List<String> _categories = ['bhajan', 'kirtan', 'lecture_audio', 'meditation', 'other'];
  late TextEditingController _titleController;
  late TextEditingController _artistController;

  @override
  void initState() {
    super.initState();
    _isActive = widget.track?.isActive ?? true;
    _category = widget.track?.category ?? 'kirtan';
    _titleController = TextEditingController(text: widget.track?.title ?? '');
    _artistController = TextEditingController(text: widget.track?.artist ?? '');

    String initialUrl = '';
    if (widget.track != null) {
      initialUrl = widget.track!.streamUrl ?? widget.track!.driveFileId ?? widget.track!.storageRef ?? '';
    }
    _urlController = TextEditingController(text: initialUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _artistController.dispose();
    _newCatController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final isEditing = widget.track != null;
      final trackId = isEditing ? widget.track!.trackId : DateTime.now().millisecondsSinceEpoch.toString();
      final url = _urlController.text.trim();

      String sourceType = 'direct_url';
      String? streamUrl;
      String? driveId;
      String? storageRef;
      String title = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : (isEditing ? widget.track!.title : 'Loading...');
      String? coverUrl = isEditing ? widget.track!.coverImageUrl : null;
      String artist = _artistController.text.trim().isNotEmpty
          ? _artistController.text.trim()
          : (isEditing ? widget.track!.artist : 'Unknown');

      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        sourceType = 'youtube';
        final id = YoutubePlayer.convertUrlToId(url) ?? url;
        streamUrl = id;
        coverUrl = 'https://img.youtube.com/vi/$id/hqdefault.jpg';
        
        // Fetch Metadata
        try {
          final response = await Dio().get('https://www.youtube.com/oembed?url=$url&format=json');
          if (response.data != null) {
            title = response.data['title'] ?? title;
            artist = response.data['author_name'] ?? artist;
            
            // Automatic Title Cleaning for YouTube
            final prefixes = [
              'LNS Bhajans - ',
              'LNS - ',
              'Lecture - ',
              'Radhe Radhe - ',
              'HH Lokanath Swami - ',
              'Hare Krishna Kirtan - '
            ];
            for (var p in prefixes) {
              if (title.toLowerCase().startsWith(p.toLowerCase())) {
                title = title.substring(p.length);
              }
            }
            title = title.trim();
          }
        } catch (_) {}
      } else if (url.contains('drive.google.com')) {
        sourceType = 'google_drive';
        // Simple regex for drive ID
        final regExp = RegExp(r'/d/([^/]+)');
        driveId = regExp.firstMatch(url)?.group(1) ?? url;
        title = isEditing ? title : 'Google Drive Audio';
      } else {
        streamUrl = url;
        if (!isEditing) {
          var cleanTitle = Uri.decodeFull(url.split('/').last).replaceAll('.mp3', '').replaceAll('_', ' ');
          final prefixes = [
            'LNS Bhajans - ',
            'LNS - ',
            'Lecture - ',
            'Radhe Radhe - ',
            'HH Lokanath Swami - ',
            'Hare Krishna Kirtan - '
          ];
          for (var p in prefixes) {
            if (cleanTitle.toLowerCase().startsWith(p.toLowerCase())) {
              cleanTitle = cleanTitle.substring(p.length);
            }
          }
          title = cleanTitle.trim();
        }
      }

      final newTrack = AudioTrackModel(
        trackId: trackId,
        title: title,
        artist: artist,
        category: _category,
        sourceType: sourceType,
        driveFileId: driveId,
        storageRef: storageRef,
        streamUrl: streamUrl,
        durationSeconds: isEditing ? widget.track!.durationSeconds : 0,
        fileSizeBytes: isEditing ? widget.track!.fileSizeBytes : 0,
        coverImageUrl: coverUrl,
        isActive: _isActive,
        playCount: isEditing ? widget.track!.playCount : 0,
        addedBy: isEditing ? widget.track!.addedBy : 'admin',
        createdAt: isEditing ? widget.track!.createdAt : DateTime.now().toIso8601String(),
      );

      final audioService = ref.read(audioServiceProvider);
      if (isEditing) {
        await audioService.updateAudioTrack(trackId, newTrack.toFirestore());
      } else {
        await audioService.addAudioTrack(newTrack);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Audio track updated' : 'Audio track added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: SacredColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.track == null ? 'Add Audio Track' : 'Edit Audio Track',
                        style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w600, color: SacredColors.parchmentLight.withOpacity(0.8))),
                    IconButton(icon: Icon(Icons.close, color: SacredColors.parchment.withOpacity(0.4), size: 20), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Paste a YouTube, Google Drive, or MP3 link. Title/artist auto-detected but can be overridden.',
                    style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.35))),
                const SizedBox(height: 16),
                _buildSacredField(_urlController, 'Audio Link / URL', Icons.link, required: true),
                const SizedBox(height: 12),
                _buildSacredField(_titleController, 'Title (optional override)', Icons.title_rounded),
                const SizedBox(height: 12),
                _buildSacredField(_artistController, 'Artist (optional override)', Icons.person_outline_rounded),
                const SizedBox(height: 16),
                // Category row with + new category button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _categories.contains(_category) ? _category : _categories.first,
                        dropdownColor: SacredColors.surface,
                        style: GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w300, color: SacredColors.parchmentLight.withOpacity(0.7)),
                        decoration: _sacredInputDecoration('Category', Icons.category),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                        onChanged: (val) => setState(() => _category = val!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _isAddingCategory = !_isAddingCategory),
                      child: Container(
                        width: 40, height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: SacredColors.parchment.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
                        ),
                        child: Icon(_isAddingCategory ? Icons.close : Icons.add,
                            size: 18, color: SacredColors.parchment.withOpacity(0.4)),
                      ),
                    ),
                  ],
                ),
                if (_isAddingCategory) ...[  
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _newCatController,
                          style: GoogleFonts.jost(fontSize: 13, color: SacredColors.parchmentLight.withOpacity(0.8)),
                          decoration: _sacredInputDecoration('New category name', Icons.label_outline_rounded),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          final cat = _newCatController.text.trim().toLowerCase().replaceAll(' ', '_');
                          if (cat.isNotEmpty && !_categories.contains(cat)) {
                            setState(() {
                              _categories.add(cat);
                              _category = cat;
                              _isAddingCategory = false;
                              _newCatController.clear();
                            });
                          }
                        },
                        child: Container(
                          width: 40, height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF8B4513), Color(0xFFC8722A)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.check, size: 18, color: Colors.white.withOpacity(0.9)),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Active', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.5))),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  activeColor: SacredColors.ember.withOpacity(0.7),
                  activeTrackColor: SacredColors.ember.withOpacity(0.15),
                  inactiveThumbColor: SacredColors.parchment.withOpacity(0.2),
                  inactiveTrackColor: SacredColors.parchment.withOpacity(0.06),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _isLoading ? null : _submit,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SacredColors.parchment.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
                    ),
                    child: _isLoading
                        ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: SacredColors.parchment.withOpacity(0.4), strokeWidth: 1.5))
                        : Text(widget.track == null ? 'ADD TRACK' : 'SAVE CHANGES',
                            style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.5, color: SacredColors.parchmentLight.withOpacity(0.6))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSacredField(TextEditingController controller, String label, IconData icon, {bool required = false, int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w300, color: SacredColors.parchmentLight.withOpacity(0.7)),
      validator: required ? (value) {
        if (value == null || value.trim().isEmpty) return '$label is required';
        return null;
      } : null,
      decoration: _sacredInputDecoration(label, icon),
    );
  }

  InputDecoration _sacredInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.35)),
      prefixIcon: Icon(icon, color: SacredColors.parchment.withOpacity(0.3), size: 18),
      filled: true,
      fillColor: SacredColors.parchment.withOpacity(0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.2))),
    );
  }
}

