import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
                      return Center(child: Text('No audio tracks found.', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.3))));
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
                Text(track.artist, style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.35))),
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
        content: Text('Delete "${track.title}"?', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.5))),
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

class _BulkImportDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BulkImportDialog> createState() => _BulkImportDialogState();
}

class _BulkImportDialogState extends ConsumerState<_BulkImportDialog> {
  final _urlController = TextEditingController();
  bool _isLoading = false;

  Future<void> _importBulk() async {
    final input = _urlController.text.trim();
    if (input.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      int count = 0;
      final audioService = ref.read(audioServiceProvider);
      
      // Split input into individual URL lines
      final lines = input.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      
      if (lines.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No valid URLs found. Please paste one URL per line.')),
          );
        }
        return;
      }

      final invalidLines = lines.where((l) => !l.startsWith('http')).toList();
      if (invalidLines.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid URL(s) found. Each line must start with https://')),
          );
        }
        return;
      }

      // Direct URL list mode: each line is a direct audio URL
      for (final url in lines) {
        final pathSegment = url.split('/').last.split('?').first;
        final fileName = Uri.decodeFull(pathSegment);
        var title = fileName
            .replaceAll(RegExp(r'\.mp3$', caseSensitive: false), '')
            .replaceAll('_', ' ');
        
        // Automatic Title Cleaning
        final prefixes = [
          'LNS Bhajans - ',
          'LNS - ',
          'Lecture - ',
          'Radhe Radhe - ',
          'HH Lokanath Swami - ',
          '16 Hours Kirtan-',
          'Hare Krishna Kirtan-'
        ];
        for (var p in prefixes) {
          if (title.toLowerCase().startsWith(p.toLowerCase())) {
            title = title.substring(p.length);
          }
        }
        title = title.trim();
        if (title.isEmpty) title = 'Audio Track';
        
        final track = AudioTrackModel(
          trackId: DateTime.now().millisecondsSinceEpoch.toString() + count.toString(),
          title: title,
          artist: 'Lokanath Swami',
          category: 'kirtan',
          sourceType: 'direct_url',
          streamUrl: url,
          durationSeconds: 0,
          fileSizeBytes: 0,
          coverImageUrl: 'https://iskcondesiretree.com/wp-content/uploads/2018/06/Lokanath-Swami-Maharaja.jpg',
          isActive: true,
          playCount: 0,
          addedBy: 'admin',
          createdAt: DateTime.now().toIso8601String(),
        );
        
        await audioService.addAudioTrack(track);
        count++;
        // Small delay to ensure unique trackIds
        await Future.delayed(const Duration(milliseconds: 10));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bulk Import Complete: Added $count tracks')),
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
    return AlertDialog(
      backgroundColor: SacredColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text('Bulk Audio Import', style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600, color: SacredColors.parchmentLight.withOpacity(0.8))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Paste audio URLs (one per line). Titles will be auto-generated from file names.',
              style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.35))),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            maxLines: 5,
            style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w300, color: SacredColors.parchmentLight.withOpacity(0.7)),
            decoration: InputDecoration(
              hintText: 'https://example.com/audio1.mp3\nhttps://example.com/audio2.mp3',
              hintStyle: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.2)),
              filled: true,
              fillColor: SacredColors.parchment.withOpacity(0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.2))),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: SacredColors.parchment.withOpacity(0.4)))),
        GestureDetector(
          onTap: _isLoading ? null : _importBulk,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: SacredColors.parchment.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
            ),
            child: _isLoading
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: SacredColors.parchment.withOpacity(0.4)))
                : Text('IMPORT', style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1, color: SacredColors.parchmentLight.withOpacity(0.6))),
          ),
        ),
      ],
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

  final List<String> _categories = ['bhajan', 'kirtan', 'lecture_audio', 'other'];

  @override
  void initState() {
    super.initState();
    _isActive = widget.track?.isActive ?? true;
    _category = widget.track?.category ?? 'kirtan';

    String initialUrl = '';
    if (widget.track != null) {
      initialUrl = widget.track!.streamUrl ?? widget.track!.driveFileId ?? widget.track!.storageRef ?? '';
    }
    _urlController = TextEditingController(text: initialUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
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
      String title = isEditing ? widget.track!.title : 'Loading...';
      String? coverUrl = isEditing ? widget.track!.coverImageUrl : null;
      String artist = isEditing ? widget.track!.artist : 'Unknown';

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
                Text('Paste a YouTube, Google Drive, or MP3 link. Metadata will be fetched automatically.',
                    style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.35))),
                const SizedBox(height: 16),
                _buildSacredField(_urlController, 'Audio Link / URL', Icons.link, required: true),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  dropdownColor: SacredColors.surface,
                  style: GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w300, color: SacredColors.parchmentLight.withOpacity(0.7)),
                  decoration: _sacredInputDecoration('Category', Icons.category),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
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

