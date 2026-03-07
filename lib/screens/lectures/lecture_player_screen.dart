import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../models/lecture_model.dart';
import '../../providers/lecture_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/sacred_theme.dart';

class LecturePlayerScreen extends ConsumerStatefulWidget {
  final String lectureId;
  final LectureModel? lecture;

  const LecturePlayerScreen({super.key, required this.lectureId, this.lecture});

  @override
  ConsumerState<LecturePlayerScreen> createState() => _LecturePlayerScreenState();
}

class _LecturePlayerScreenState extends ConsumerState<LecturePlayerScreen> {
  YoutubePlayerController? _controller;
  LectureModel? _lecture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.lecture != null) {
      _lecture = widget.lecture;
      _initPlayer(_lecture!.youtubeVideoId);
      setState(() => _isLoading = false);
    } else {
      _fetchLecture();
    }
  }

  Future<void> _fetchLecture() async {
    try {
      final service = ref.read(lectureServiceProvider);
      final lecture = await service.getLectureById(widget.lectureId);
      if (mounted) {
        setState(() {
          _lecture = lecture;
          _isLoading = false;
        });
        if (lecture != null) {
          _initPlayer(lecture.youtubeVideoId);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initPlayer(String videoId) {
    // Extract just the ID if a full URL was entered
    final cleanId = YoutubePlayerController.convertUrlToId(videoId) ?? videoId;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: cleanId,
      autoPlay: true,
      params: YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        mute: false,
        playsInline: true,
        enableJavaScript: true,
        origin: kIsWeb ? Uri.base.origin : 'https://www.youtube.com',
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0))),
      );
    }

    if (_lecture == null || _controller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lecture Not Found')),
        body: const Center(child: Text('Could not load this lecture. Please try again.')),
      );
    }

    final lecture = _lecture!;

    return YoutubePlayerScaffold(
      controller: _controller!,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Scaffold(
          backgroundColor: SacredColors.ink,
          appBar: AppBar(
            title: const Text('Multimedia Player'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => Share.share(
                    'Watch this lecture on GitaLife: ${lecture.title}\nhttps://youtu.be/${lecture.youtubeVideoId}'),
              )
            ],
          ),
          body: ListView(
            children: [
              player,
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      lecture.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
