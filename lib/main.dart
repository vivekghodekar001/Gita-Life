import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/japa_log.dart';
import 'models/audio_track.dart';
import 'providers/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'firebase_options.dart';
import 'app/router.dart';
import 'app/theme.dart';

late AppAudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  
  // Register Hive adapters here
  Hive.registerAdapter(JapaLogAdapter());
  Hive.registerAdapter(AudioTrackModelAdapter());
  
  await Hive.openBox<JapaLog>('japa_logs');
  await Hive.openBox<AudioTrackModel>('downloads');
  await Hive.openBox('settings');
  
  audioHandler = await AudioService.init(
    builder: () => AppAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.iskcon.gitalife.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(const ProviderScope(child: GitaLifeApp()));
}

class GitaLifeApp extends ConsumerWidget {
  const GitaLifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'GitaLife',
      theme: gitaLifeTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
