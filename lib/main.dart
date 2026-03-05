import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/japa_log.dart';
import 'models/audio_track.dart';
import 'providers/audio_handler.dart';
import 'package:audio_service/audio_service.dart' as audio_service;
import 'firebase_options.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'providers/firebase_provider.dart';
import 'services/audio_service.dart';
import 'data/bulk_audio_data.dart';
import 'providers/auth_provider.dart';
import 'widgets/offline_banner.dart';

AppAudioHandler? audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();

  // Global error handlers
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('\u274c [FLUTTER_ERROR]: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('\u274c [UNCAUGHT_ERROR]: $error');
    debugPrint('\u274c [UNCAUGHT_STACK]: $stack');
    return true;
  };

  // 1. Initialize Services (Firebase, Hive)
  await _initializeServices(container);

  runApp(UncontrolledProviderScope(container: container, child: const GitaLifeApp()));
}

Future<void> _initializeServices(ProviderContainer container) async {
  // 1. Firebase Initialization
  try {
    debugPrint('🔥 [FIREBASE_STATUS]: Starting pre-flight check...');
    
    // Check for existing app or initialize
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint('🔥 [FIREBASE_STATUS]: No apps found. Calling initializeApp...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        debugPrint('🔥 [FIREBASE_STATUS]: Found ${Firebase.apps.length} existing apps.');
      }
    } catch (e) {
      debugPrint('🔥 [FIREBASE_STATUS]: Exception during initialization check: $e');
      if (e.toString().contains('already exists')) {
        debugPrint('🔥 [FIREBASE_STATUS]: App already exists natively. Reading existing instance...');
        try {
          Firebase.app(); // Read existing native instance
        } catch (inner) {
          debugPrint('🔥 [FIREBASE_STATUS]: Could not read existing instance: $inner');
        }
      } else {
        rethrow;
      }
    }

    // Final verification dump
    final app = Firebase.app();
    debugPrint('🔥 [FIREBASE_STATUS]: FINAL VERIFICATION - App Name: ${app.name}');
    debugPrint('🔥 [FIREBASE_STATUS]: Project ID: ${app.options.projectId}');
    
    debugPrint('🔥 [FIREBASE_STATUS]: Initialization Sequence Complete.');

    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint('🔥 [FIREBASE_STATUS]: Firestore offline persistence enabled.');

    container.read(firebaseInitStatusProvider.notifier).state = FirebaseInitStatus.initialized;
  } catch (e, stack) {
    debugPrint('❌ [FIREBASE_ERROR]: $e');
    debugPrint('❌ [FIREBASE_STACK]: $stack');
    container.read(firebaseInitStatusProvider.notifier).state = FirebaseInitStatus.failed;
    container.read(firebaseInitErrorProvider.notifier).state = e.toString();
  }

  // 2. Initialize Hive
  try {
    await Hive.initFlutter();
    
    // Register Hive adapters here
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(JapaLogAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AudioTrackModelAdapter());
    
    await Hive.openBox<JapaLog>('japa_logs');
    await Hive.openBox<AudioTrackModel>('downloads');
    await Hive.openBox('settings');
  } catch (e) {
    debugPrint('Hive initialization failed: $e');
  }

  // Run the app with UncontrolledProviderScope to use our container
  // Removed from here to move to main()

  // Initialize AudioService after the app has started
  try {
    audioHandler = await audio_service.AudioService.init(
      builder: () => AppAudioHandler(),
      config: const audio_service.AudioServiceConfig(
        androidNotificationChannelId: 'com.iskcon.gitalife.audio',
        androidNotificationChannelName: 'Audio Playback',
        androidNotificationOngoing: true,
      ),
    );
  } catch (e) {
    debugPrint('AudioService init failed: $e');
  }
}

class GitaLifeApp extends ConsumerWidget {
  const GitaLifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(firebaseInitStatusProvider);
    final error = ref.watch(firebaseInitErrorProvider);

    if (status == FirebaseInitStatus.loading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (status == FirebaseInitStatus.failed) {
      return MaterialApp(
        theme: gitaLifeTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Firebase Initialization Failed',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  error ?? 'An unknown error occurred during setup.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // In a real scenario, we might want to restart the app or retry
                    // For now, we just print a message
                    debugPrint('User requested retry');
                  },
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'GitaLife',
      theme: gitaLifeTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: OfflineBanner(),
            ),
            const DataImporter(),
          ],
        );
      },
    );
  }
}

class DataImporter extends ConsumerStatefulWidget {
  const DataImporter({super.key});

  @override
  ConsumerState<DataImporter> createState() => _DataImporterState();
}

class _DataImporterState extends ConsumerState<DataImporter> {
  bool _isSyncing = false;
  static bool _syncStartedThisSession = false;

  @override
  Widget build(BuildContext context) {
    // Listen for auth changes to trigger sync
    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null && !_syncStartedThisSession) {
        _startBulkSync();
      }
    });

    if (!_isSyncing) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: LinearProgressIndicator(
          minHeight: 3,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  void _startBulkSync() async {
    final box = Hive.box('settings');
    if (box.get('bulk_import_done_v2', defaultValue: false)) return;

    if (_syncStartedThisSession) return;
    _syncStartedThisSession = true;

    if (!mounted) return;
    setState(() => _isSyncing = true);

    final audioService = ref.read(audioServiceProvider);
    final user = ref.read(authStateProvider).value;
    final userId = user?.uid ?? 'admin_sync';

    debugPrint('Starting Premium Bulk Sync of ${bulkAudioData.length} tracks...');

    try {
      for (var data in bulkAudioData) {
        final track = AudioTrackModel(
          trackId: 'bulk_${data['title'].hashCode}_${data['url'].hashCode}',
          title: data['title']!,
          artist: 'HH Lokanath Swami',
          category: 'kirtan',
          sourceType: 'direct_url',
          streamUrl: data['url']!,
          durationSeconds: 0,
          fileSizeBytes: 0,
          isActive: true,
          playCount: 0,
          addedBy: userId,
          createdAt: DateTime.now().toIso8601String(),
        );
        await audioService.addAudioTrack(track);
        // Small delay to avoid hitting firestore quote too fast in a single burst
        await Future.delayed(const Duration(milliseconds: 50));
      }

      await box.put('bulk_import_done_v2', true);
      debugPrint('Bulk Sync Complete! 🎉');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio library synchronized successfully! 🎉'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Bulk Sync Failed: $e');
      _syncStartedThisSession = false; // Allow retry on next auth/rebuild if failed
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
}
