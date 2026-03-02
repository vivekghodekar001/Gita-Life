import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/japa_service.dart';
import '../models/japa_log.dart';

final japaServiceProvider = Provider<JapaService>((ref) => JapaService());

final todayJapaLogProvider = FutureProvider<JapaLog?>((ref) {
  return ref.watch(japaServiceProvider).getTodayLog();
});

final weekHistoryProvider = FutureProvider<List<JapaLog>>((ref) {
  return ref.watch(japaServiceProvider).getWeekHistory();
});

final monthHistoryProvider = FutureProvider<List<JapaLog>>((ref) {
  return ref.watch(japaServiceProvider).getMonthHistory();
});
