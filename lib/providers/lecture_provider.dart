import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/lecture_service.dart';
import '../models/lecture_model.dart';

final lectureServiceProvider = Provider<LectureService>((ref) {
  return LectureService();
});

final lectureSearchQueryProvider = StateProvider<String>((ref) => '');
final lectureTopicProvider = StateProvider<String>((ref) => 'All');

final lecturesStreamProvider = StreamProvider<List<LectureModel>>((ref) {
  final service = ref.watch(lectureServiceProvider);
  final topic = ref.watch(lectureTopicProvider);
  return service.watchLectures(topic: topic == 'All' ? null : topic);
});

final filteredLecturesProvider = Provider<AsyncValue<List<LectureModel>>>((ref) {
  final lecturesAsync = ref.watch(lecturesStreamProvider);
  final query = ref.watch(lectureSearchQueryProvider).toLowerCase();

  return lecturesAsync.whenData((lectures) {
    if (query.isEmpty) return lectures;
    return lectures.where((l) => 
      l.title.toLowerCase().contains(query) || 
      l.topic.toLowerCase().contains(query)
    ).toList();
  });
});

final topicsProvider = Provider<List<String>>((ref) {
  return ['All', 'Bhagavad Gita', 'Srimad Bhagavatam', 'Chaitanya Charitamrita', 'Seminars', 'Other'];
});

final adminLecturesProvider = StreamProvider<List<LectureModel>>((ref) {
  return ref.watch(lectureServiceProvider).watchAllLecturesAdmin();
});
