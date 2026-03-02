import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/lecture_service.dart';
import '../models/lecture_model.dart';

final lectureServiceProvider = Provider<LectureService>((ref) => LectureService());

final lecturesProvider = FutureProvider.family<List<LectureModel>, String?>((ref, topic) {
  return ref.watch(lectureServiceProvider).getLectures(topic: topic);
});

final lectureByIdProvider = FutureProvider.family<LectureModel?, String>((ref, lectureId) {
  return ref.watch(lectureServiceProvider).getLectureById(lectureId);
});
