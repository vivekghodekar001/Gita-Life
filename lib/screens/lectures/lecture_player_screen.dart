import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
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
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  LectureModel? _lecture;
  bool _isLoading = true;
  bool _isYouTube = false;

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

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || 
           url.contains('youtu.be') || 
           (!url.startsWith('http') && !url.contains('.'));
  }

  Future<void> _initPlayer(String videoUrl) async {
    if (_isYouTubeUrl(videoUrl)) {
      // YouTube video
      _isYouTube = true;
      final cleanId = YoutubePlayerController.convertUrlToId(videoUrl) ?? videoUrl;
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: cleanId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
          mute: false,
          playsInline: false,
          enableJavaScript: true,
          strictRelatedVideos: false,
        ),
      );
    } else {
      // Direct video URL (Google Drive, Firebase Storage, etc.)
      _isYouTube = false;
      String videoUrlToPlay = videoUrl;
      
      // Convert Google Drive share links to direct download links
      if (videoUrl.contains('drive.google.com')) {
        final fileIdMatch = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(videoUrl);
        if (fileIdMatch != null) {
          final fileId = fileIdMatch.group(1);
          videoUrlToPlay = 'https://drive.google.com/uc?export=download&id=$fileId';
        }
      }
      
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrlToPlay));
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF1565C0),
          handleColor: const Color(0xFF1565C0),
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade400,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading video',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _youtubeController?.close();
    _chewieController?.dispose();
    _videoController?.dispose();
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

    if (_lecture == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lecture Not Found')),
        body: const Center(child: Text('Could not load this lecture. Please try again.')),
      );
    }

    final lecture = _lecture!;

    return Scaffold(
      backgroundColor: SacredColors.ink,
      appBar: AppBar(
        title: const Text('Multimedia Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(
                'Watch this lecture on GitaLife: ${lecture.title}'),
          )
        ],
      ),
      body: ListView(
        children: [
          // Video Player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _isYouTube
                  ? (_youtubeController != null
                      ? YoutubePlayer(controller: _youtubeController!)
                      : const Center(child: CircularProgressIndicator()))
                  : (_chewieController != null
                      ? Chewie(controller: _chewieController!)
                      : const Center(child: CircularProgressIndicator())),
            ),
          ),
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
  }
}
