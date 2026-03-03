import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/japa_service.dart';
import '../models/japa_log.dart';

final japaServiceProvider = Provider<JapaService>((ref) => JapaService());

// Providers that re-fetch logs instantly when invalidated.
final todayJapaLogProvider = FutureProvider<JapaLog?>((ref) {
  return ref.watch(japaServiceProvider).getTodayLog();
});

final weekHistoryProvider = FutureProvider<List<JapaLog>>((ref) {
  return ref.watch(japaServiceProvider).getWeekHistory();
});

final monthHistoryProvider = FutureProvider<List<JapaLog>>((ref) {
  return ref.watch(japaServiceProvider).getMonthHistory();
});

// Settings Providers from Hive
final settingsBoxProvider = Provider<Box>((ref) => Hive.box('settings'));

final japaVibrationProvider = StateNotifierProvider<JapaVibrationNotifier, bool>((ref) {
  return JapaVibrationNotifier(ref.watch(settingsBoxProvider));
});

class JapaVibrationNotifier extends StateNotifier<bool> {
  final Box box;
  JapaVibrationNotifier(this.box) : super(box.get('japa_vibration', defaultValue: true));

  void toggle() {
    state = !state;
    box.put('japa_vibration', state);
  }
}

final japaSoundProvider = StateNotifierProvider<JapaSoundNotifier, bool>((ref) {
  return JapaSoundNotifier(ref.watch(settingsBoxProvider));
});

class JapaSoundNotifier extends StateNotifier<bool> {
  final Box box;
  JapaSoundNotifier(this.box) : super(box.get('japa_sound', defaultValue: true));

  void toggle() {
    state = !state;
    box.put('japa_sound', state);
  }
}
