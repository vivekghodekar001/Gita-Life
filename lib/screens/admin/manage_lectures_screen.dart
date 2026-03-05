import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../providers/lecture_provider.dart';
import '../../models/lecture_model.dart';
import 'package:intl/intl.dart';

class ManageLecturesScreen extends ConsumerWidget {
  const ManageLecturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturesAsync = ref.watch(adminLecturesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Lectures'),
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFF8F0),
      body: lecturesAsync.when(
        data: (lectures) {
          if (lectures.isEmpty) {
            return const Center(child: Text('No lectures found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lectures.length,
            itemBuilder: (context, index) {
              final lecture = lectures[index];
              return _buildLectureCard(context, ref, lecture);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE65100))),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditLectureDialog(context, ref),
        backgroundColor: const Color(0xFFE65100),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLectureCard(BuildContext context, WidgetRef ref, LectureModel lecture) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            lecture.thumbnailUrl,
            width: 80,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 60,
              color: Colors.grey[300],
              child: const Icon(Icons.video_library, color: Colors.grey),
            ),
          ),
        ),
        title: Text(
          lecture.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(lecture.topic, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text('${lecture.durationMinutes} min • ${lecture.viewCount} views', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: lecture.isActive,
              onChanged: (value) async {
                await ref.read(lectureServiceProvider).toggleLectureActiveStatus(lecture.lectureId, value);
              },
              activeColor: const Color(0xFFE65100),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showAddEditLectureDialog(context, ref, lecture: lecture),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteLecture(context, ref, lecture),
            ),
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
        title: const Text('Delete Lecture'),
        content: Text('Are you sure you want to delete "${lecture.title}"?'),
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
        await ref.read(lectureServiceProvider).deleteLecture(lecture.lectureId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lecture deleted.')),
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
      final cleanId = YoutubePlayer.convertUrlToId(inputId) ?? inputId;
      
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
                      widget.lecture == null ? 'Add Lecture' : 'Edit Lecture',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Enter a YouTube Video ID or full URL. The title will be fetched automatically.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 12),
                _buildTextField(_youtubeIdController, 'YouTube Video ID or URL', Icons.video_collection, required: true),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category, color: Color(0xFFE65100)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
                    ),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  activeColor: const Color(0xFFE65100),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.lecture == null ? 'Add Lecture' : 'Save Changes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE65100)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
        ),
      ),
    );
  }
}

