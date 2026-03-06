import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/audio_service.dart';
import '../../models/audio_track.dart';
import 'package:dio/dio.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ManageAudioScreen extends ConsumerWidget {
  const ManageAudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioAsync = ref.watch(adminAudioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Audio'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download, color: Color(0xFF1565C0)),
            tooltip: 'Bulk Import',
            onPressed: () => _showBulkImportDialog(context, ref),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE8F5F9),
      body: audioAsync.when(
        data: (tracks) {
          if (tracks.isEmpty) {
            return const Center(child: Text('No audio tracks found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return _buildAudioCard(context, ref, track);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0))),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditAudioDialog(context, ref),
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAudioCard(BuildContext context, WidgetRef ref, AudioTrackModel track) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
          backgroundImage: track.coverImageUrl != null ? NetworkImage(track.coverImageUrl!) : null,
          child: track.coverImageUrl == null
              ? const Icon(Icons.music_note, color: Color(0xFF1565C0))
              : null,
        ),
        title: Text(
          track.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(track.artist, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildTag(track.category.toUpperCase()),
                const SizedBox(width: 8),
                _buildTag(track.sourceType.toUpperCase(), color: Colors.blue),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: track.isActive,
              onChanged: (value) async {
                await ref.read(audioServiceProvider).toggleAudioActiveStatus(track.trackId, value);
              },
              activeColor: const Color(0xFF1565C0),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showAddEditAudioDialog(context, ref, track: track),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteAudioTrack(context, ref, track),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, {Color color = const Color(0xFF1565C0)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
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
    showDialog(
      context: context,
      builder: (context) => _BulkImportDialog(),
    );
  }

  Future<void> _deleteAudioTrack(BuildContext context, WidgetRef ref, AudioTrackModel track) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Audio Track'),
        content: Text('Are you sure you want to delete "${track.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(audioServiceProvider).deleteAudioTrack(track.trackId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio track deleted.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
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
      title: const Text('Bulk Audio Import'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Paste audio URLs (one per line). Each URL must start with https://. Titles will be auto-generated from file names.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'https://example.com/audio1.mp3\nhttps://example.com/audio2.mp3\nhttps://example.com/audio3.mp3',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _importBulk,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Import'),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    Text(
                      widget.track == null ? 'Add Audio Track' : 'Edit Audio Track',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Paste a YouTube, Google Drive, or MP3 link. Metadata will be fetched automatically.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 12),
                _buildTextField(_urlController, 'Audio Link / URL', Icons.link, required: true),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: _inputDecoration('Category', Icons.category),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  activeColor: const Color(0xFF1565C0),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.track == null ? 'Add Track' : 'Save Changes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool required = false, int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: required ? (value) {
        if (value == null || value.trim().isEmpty) return '$label is required';
        return null;
      } : null,
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
      ),
    );
  }
}

