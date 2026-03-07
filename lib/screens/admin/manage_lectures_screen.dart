import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/lecture_provider.dart';
import '../../models/lecture_model.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';
import 'package:intl/intl.dart';

class ManageLecturesScreen extends ConsumerWidget {
  const ManageLecturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturesAsync = ref.watch(adminLecturesProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.5)),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    Text('MANAGE LECTURES', style: SacredTextStyles.sectionLabel(fontSize: 10)),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: lecturesAsync.when(
                  data: (lectures) {
                    if (lectures.isEmpty) {
                      return Center(child: Text('No lectures found.', style: SacredTextStyles.infoValue().copyWith(color: SacredColors.parchment.withOpacity(0.3))));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: lectures.length,
                      itemBuilder: (context, index) => _buildLectureCard(context, ref, lectures[index]),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: SacredColors.parchment)),
                  error: (error, stack) => Center(child: Text('Error: $error', style: TextStyle(color: SacredColors.parchment.withOpacity(0.5)))),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: SacredColors.parchment.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12)],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddEditLectureDialog(context, ref),
          backgroundColor: SacredColors.surface,
          child: Icon(Icons.add_rounded, color: SacredColors.parchment.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildLectureCard(BuildContext context, WidgetRef ref, LectureModel lecture) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: SacredDecorations.glassCard(radius: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            lecture.thumbnailUrl,
            width: 72, height: 52, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 72, height: 52,
              color: SacredColors.surface,
              child: Icon(Icons.video_library_rounded, color: SacredColors.parchment.withOpacity(0.2)),
            ),
          ),
        ),
        title: Text(lecture.title, style: GoogleFonts.cormorantGaramond(fontSize: 14, fontWeight: FontWeight.w600, color: SacredColors.parchmentLight.withOpacity(0.8)), maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(lecture.topic, style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.3))),
            Text('${lecture.durationMinutes} min • ${lecture.viewCount} views', style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.2))),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 28,
              child: Switch(
                value: lecture.isActive,
                onChanged: (value) async => await ref.read(lectureServiceProvider).toggleLectureActiveStatus(lecture.lectureId, value),
                activeColor: SacredColors.parchment,
                activeTrackColor: SacredColors.parchment.withOpacity(0.2),
                inactiveThumbColor: SacredColors.parchment.withOpacity(0.3),
                inactiveTrackColor: SacredColors.parchment.withOpacity(0.06),
              ),
            ),
            IconButton(icon: Icon(Icons.edit_rounded, size: 18, color: SacredColors.parchment.withOpacity(0.4)), onPressed: () => _showAddEditLectureDialog(context, ref, lecture: lecture)),
            IconButton(icon: Icon(Icons.delete_outline_rounded, size: 18, color: SacredColors.ember.withOpacity(0.5)), onPressed: () => _deleteLecture(context, ref, lecture)),
          ],
        ),
      ),
    );
  }

  void _showAddEditLectureDialog(BuildContext context, WidgetRef ref, {LectureModel? lecture}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEditLectureForm(lecture: lecture),
    );
  }

  Future<void> _deleteLecture(BuildContext context, WidgetRef ref, LectureModel lecture) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SacredColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Lecture', style: GoogleFonts.cormorantGaramond(color: SacredColors.parchmentLight.withOpacity(0.8))),
        content: Text('Delete "${lecture.title}"?', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.5))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: SacredColors.parchment.withOpacity(0.4)))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: SacredColors.ember.withOpacity(0.7)))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(lectureServiceProvider).deleteLecture(lecture.lectureId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Lecture deleted.'), backgroundColor: SacredColors.surface));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: SacredColors.surface));
        }
      }
    }
  }
}

class _AddEditLectureForm extends ConsumerStatefulWidget {
  final LectureModel? lecture;

  const _AddEditLectureForm({this.lecture});

  @override
  ConsumerState<_AddEditLectureForm> createState() => _AddEditLectureFormState();
}

class _AddEditLectureFormState extends ConsumerState<_AddEditLectureForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _youtubeIdController;
  bool _isActive = true;
  bool _isLoading = false;
  String _selectedCategory = 'Other';

  final List<String> _categories = [
    'Bhagavad Gita',
    'Srimad Bhagavatam',
    'Chaitanya Charitamrita',
    'Seminars',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _youtubeIdController = TextEditingController(text: widget.lecture?.youtubeVideoId ?? '');
    _isActive = widget.lecture?.isActive ?? true;
    _selectedCategory = widget.lecture?.topic ?? 'Other';
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'Other';
    }
  }

  @override
  void dispose() {
    _youtubeIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final isEditing = widget.lecture != null;
      final lectureId = isEditing ? widget.lecture!.lectureId : DateTime.now().millisecondsSinceEpoch.toString();
      
      final inputId = _youtubeIdController.text.trim();
      final cleanId = YoutubePlayerController.convertUrlToId(inputId) ?? inputId;
      
      // Improved Thumbnail URL generation
      final thumbnailUrl = 'https://i.ytimg.com/vi/$cleanId/hqdefault.jpg';

      // Fetch Title from YouTube oEmbed API
      String fetchedTitle = 'Title Unavailable';
      try {
        final response = await Dio().get('https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$cleanId&format=json');
        if (response.data != null && response.data['title'] != null) {
          fetchedTitle = response.data['title'];
          
          // Automatic Title Cleaning
          final prefixes = [
            'LNS Bhajans - ',
            'LNS - ',
            'Lecture - ',
            'Radhe Radhe - ',
            'HH Lokanath Swami - ',
            'Hare Krishna Kirtan - '
          ];
          for (var p in prefixes) {
            if (fetchedTitle.toLowerCase().startsWith(p.toLowerCase())) {
              fetchedTitle = fetchedTitle.substring(p.length);
            }
          }
          fetchedTitle = fetchedTitle.trim();
        }
      } catch (e) {
        if (isEditing) fetchedTitle = widget.lecture!.title;
      }

      final newLecture = LectureModel(
        lectureId: lectureId,
        title: fetchedTitle,
        description: isEditing ? widget.lecture!.description : '',
        youtubeVideoId: cleanId,
        thumbnailUrl: thumbnailUrl,
        topic: _selectedCategory,
        durationMinutes: isEditing ? widget.lecture!.durationMinutes : 0,
        viewCount: isEditing ? widget.lecture!.viewCount : 0,
        isActive: _isActive,
        addedBy: isEditing ? widget.lecture!.addedBy : 'admin',
        createdAt: isEditing ? widget.lecture!.createdAt : DateTime.now(),
      );

      final lectureService = ref.read(lectureServiceProvider);
      if (isEditing) {
        await lectureService.updateLecture(lectureId, newLecture.toFirestore());
      } else {
        await lectureService.addLecture(newLecture);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Lecture updated' : 'Lecture added')),
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
                    Text(
                      widget.lecture == null ? 'Add Lecture' : 'Edit Lecture',
                      style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w600, color: SacredColors.parchmentLight.withOpacity(0.8)),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: SacredColors.parchment.withOpacity(0.4), size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Enter a YouTube Video ID or full URL. The title will be fetched automatically.',
                    style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.35))),
                const SizedBox(height: 16),
                _buildSacredField(_youtubeIdController, 'YouTube Video ID or URL', Icons.video_collection, required: true),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: SacredColors.surface,
                  style: GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w300, color: SacredColors.parchmentLight.withOpacity(0.7)),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.35)),
                    prefixIcon: Icon(Icons.category, color: SacredColors.parchment.withOpacity(0.3), size: 18),
                    filled: true,
                    fillColor: SacredColors.parchment.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.2))),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) setState(() => _selectedCategory = newValue);
                  },
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
                        : Text(widget.lecture == null ? 'ADD LECTURE' : 'SAVE CHANGES',
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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.35)),
        prefixIcon: Icon(icon, color: SacredColors.parchment.withOpacity(0.3), size: 18),
        filled: true,
        fillColor: SacredColors.parchment.withOpacity(0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.2))),
      ),
    );
  }
}

