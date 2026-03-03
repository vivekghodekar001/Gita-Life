import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  // Register Hive adapters here
  await Hive.openBox('japa_logs');
  await Hive.openBox('settings');
  await Hive.openBox('downloads');
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
