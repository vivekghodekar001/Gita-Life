import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audio_provider.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadedTracksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F9),
      appBar: AppBar(title: const Text('Downloads')),
      body: downloads.isEmpty
          ? const Center(child: Text('No downloaded tracks yet.', style: TextStyle(color: Colors.blueGrey, fontSize: 16)))
          : ListView.builder(
              itemCount: downloads.length,
              itemBuilder: (context, index) {
                final track = downloads[index];
                final sizeMB = (track.fileSizeBytes / (1024 * 1024)).toStringAsFixed(2);
                
                return ListTile(
                  leading: const Icon(Icons.music_note, color: Color(0xFF1565C0), size: 40),
                  title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('\${track.artist} • \$sizeMB MB\nPath: \${track.localFilePath}', 
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteDialog(context, ref, track.trackId);
                    },
                  ),
                  onTap: () {
                     ref.read(audioPlayerControllerProvider).playTrack(track, downloads);
                  },
                );
              },
            ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String trackId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Download'),
        content: const Text('Are you sure you want to delete this track from your device?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(downloadedTracksProvider.notifier).deleteDownload(trackId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
