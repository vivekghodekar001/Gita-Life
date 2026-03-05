import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  // Initialize all services
  await _initializeServices(container);

  runApp(UncontrolledProviderScope(container: container, child: const GitaLifeApp()));
}

/// Initializes Firebase, Hive, and AudioService.
/// Firebase init failures are isolated from Firestore/Hive so we can
/// properly diagnose the real cause.
Future<void> _initializeServices(ProviderContainer container) async {
  // ── Step 1: Firebase Core ──────────────────────────────────────────
  bool firebaseOk = false;
  try {
    debugPrint('🔥 [INIT]: Starting Firebase initialization...');

    if (Firebase.apps.isNotEmpty) {
      debugPrint('🔥 [INIT]: Firebase already has ${Firebase.apps.length} app(s).');
      firebaseOk = true;
    } else {
      debugPrint('🔥 [INIT]: No Firebase apps found. Calling initializeApp...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseOk = true;
    }

    // Verify it's accessible
    final app = Firebase.app();
    debugPrint('🔥 [INIT]: Firebase OK — project: ${app.options.projectId}');
  } catch (e, stack) {
    // If error says "already exists", the app was initialized natively
    if (e.toString().contains('already exists')) {
      debugPrint('🔥 [INIT]: App exists natively, recovering...');
      try {
        Firebase.app();
        firebaseOk = true;
      } catch (_) {
        // truly broken
      }
    }

    if (!firebaseOk) {
      debugPrint('❌ [INIT]: Firebase initialization failed: $e');
      debugPrint('❌ [INIT]: Stack: $stack');
      container.read(firebaseInitStatusProvider.notifier).state = FirebaseInitStatus.failed;
      container.read(firebaseInitErrorProvider.notifier).state = e.toString();
      // Don't return — still initialize Hive so offline features work
    }
  }

  // ── Step 2: Firestore Persistence (separate try/catch!) ────────────
  if (firebaseOk) {
    try {
      // Only set persistence on mobile — web handles it differently
      if (!kIsWeb) {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        debugPrint('🔥 [INIT]: Firestore offline persistence enabled.');
      }
    } catch (e) {
      // This can fail on hot restart or if Firestore was already configured.
      // It's NOT a fatal error — Firebase is still working.
      debugPrint('⚠️ [INIT]: Firestore persistence config warning (non-fatal): $e');
    }

    // Mark Firebase as successfully initialized
    container.read(firebaseInitStatusProvider.notifier).state = FirebaseInitStatus.initialized;
  }

  // ── Step 3: Hive ───────────────────────────────────────────────────
  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(JapaLogAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AudioTrackModelAdapter());
    await Hive.openBox<JapaLog>('japa_logs');
    await Hive.openBox<AudioTrackModel>('downloads');
    await Hive.openBox('settings');
    debugPrint('📦 [INIT]: Hive initialized successfully.');
  } catch (e) {
    debugPrint('❌ [INIT]: Hive initialization failed: $e');
  }

  // ── Step 4: AudioService ──────────────────────────────────────────
  try {
    audioHandler = await audio_service.AudioService.init(
      builder: () => AppAudioHandler(),
      config: const audio_service.AudioServiceConfig(
        androidNotificationChannelId: 'com.iskcon.gitalife.audio',
        androidNotificationChannelName: 'Audio Playback',
        androidNotificationOngoing: true,
      ),
    );
    debugPrint('🎵 [INIT]: AudioService initialized successfully.');
  } catch (e) {
    debugPrint('⚠️ [INIT]: AudioService init failed (non-fatal): $e');
  }
}

// ══════════════════════════════════════════════════════════════════
//  Root App Widget
// ══════════════════════════════════════════════════════════════════

class GitaLifeApp extends ConsumerWidget {
  const GitaLifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(firebaseInitStatusProvider);
    final error = ref.watch(firebaseInitErrorProvider);

    if (status == FirebaseInitStatus.loading) {
      return MaterialApp(
        theme: gitaLifeTheme,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          backgroundColor: Color(0xFFFFF8F0),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFFF6600)),
                SizedBox(height: 16),
                Text('Initializing...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    if (status == FirebaseInitStatus.failed) {
      return MaterialApp(
        theme: gitaLifeTheme,
        debugShowCheckedModeBanner: false,
        home: _FirebaseErrorScreen(error: error),
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

// ══════════════════════════════════════════════════════════════════
//  Firebase Error Screen — with REAL retry logic
// ══════════════════════════════════════════════════════════════════

class _FirebaseErrorScreen extends ConsumerWidget {
  final String? error;
  const _FirebaseErrorScreen({this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Firebase Initialization Failed',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'An unknown error occurred during setup.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('RETRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6600),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                // Reset status to loading
                ref.read(firebaseInitStatusProvider.notifier).state = FirebaseInitStatus.loading;
                ref.read(firebaseInitErrorProvider.notifier).state = null;

                // Actually retry Firebase initialization
                try {
                  debugPrint('🔄 [RETRY]: Retrying Firebase initialization...');

                  if (Firebase.apps.isEmpty) {
                    await Firebase.initializeApp(
                      options: DefaultFirebaseOptions.currentPlatform,
                    );
                  }

                  // Verify
                  final app = Firebase.app();
                  debugPrint('🔄 [RETRY]: Firebase OK — project: ${app.options.projectId}');

                  // Set Firestore persistence
                  if (!kIsWeb) {
                    try {
                      FirebaseFirestore.instance.settings = const Settings(
                        persistenceEnabled: true,
                        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
                      );
                    } catch (_) {}
                  }

                  ref.read(firebaseInitStatusProvider.notifier).state = FirebaseInitStatus.initialized;
                  debugPrint('🔄 [RETRY]: Firebase retry successful!');
                } catch (e) {
                  debugPrint('❌ [RETRY]: Firebase retry failed: $e');
                  ref.read(firebaseInitStatusProvider.notifier).state = FirebaseInitStatus.failed;
                  ref.read(firebaseInitErrorProvider.notifier).state = e.toString();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Data Importer (bulk audio sync)
// ══════════════════════════════════════════════════════════════════

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
      _syncStartedThisSession = false;
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
}
