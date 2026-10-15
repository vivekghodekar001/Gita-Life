import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final notificationHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(notificationServiceProvider).getNotificationHistory().map(
    (snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList(),
  );
});
