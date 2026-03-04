import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/lecture_model.dart';

class LectureService {
  void _ensureFirebase() {
    if (Firebase.apps.isEmpty) {
      throw Exception('[LectureService] Firebase not initialized. Ensure Firebase.initializeApp() is called and verified before accessing this service.');
    }
  }

  FirebaseFirestore get _firestore {
    _ensureFirebase();
    return FirebaseFirestore.instanceFor(app: Firebase.app());
  }

  Future<List<LectureModel>> getLectures({String? topic}) async {
    Query query = _firestore.collection('lectures').where('isActive', isEqualTo: true);

    if (topic != null && topic.isNotEmpty && topic != 'All') {
      query = query.where('topic', isEqualTo: topic);
    }

    final snapshot = await query.get();
    final lectures = snapshot.docs.map((doc) => LectureModel.fromFirestore(doc)).toList();
    // Sort in-memory to avoid requiring a Firestore composite index
    lectures.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return lectures;
  }

  Future<LectureModel?> getLectureById(String lectureId) async {
    final doc = await _firestore.collection('lectures').doc(lectureId).get();
    if (!doc.exists) return null;
    return LectureModel.fromFirestore(doc);
  }

  Future<void> addLecture(LectureModel lecture) async {
    await _firestore.collection('lectures').doc(lecture.lectureId).set(lecture.toFirestore());
  }

  Future<void> updateLecture(String id, Map<String, dynamic> data) async {
    await _firestore.collection('lectures').doc(id).update(data);
  }

  Future<void> deleteLecture(String id) async {
    await _firestore.collection('lectures').doc(id).update({'isActive': false});
  }

  Future<void> incrementViewCount(String id) async {
    await _firestore.collection('lectures').doc(id).update({
      'viewCount': FieldValue.increment(1)
    });
  }

  Stream<List<LectureModel>> watchLectures({String? topic}) {
    Query query = _firestore.collection('lectures').where('isActive', isEqualTo: true);

    if (topic != null && topic.isNotEmpty && topic != 'All') {
      query = query.where('topic', isEqualTo: topic);
    }

    return query.snapshots().map((snapshot) {
      final lectures = snapshot.docs.map((doc) => LectureModel.fromFirestore(doc)).toList();
      // Sort in-memory to avoid requiring a Firestore composite index
      lectures.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return lectures;
    });
  }

  Stream<List<LectureModel>> watchAllLecturesAdmin() {
    return _firestore.collection('lectures')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LectureModel.fromFirestore(doc)).toList());
  }

  Future<void> toggleLectureActiveStatus(String id, bool isActive) async {
    await _firestore.collection('lectures').doc(id).update({'isActive': isActive});
  }
}
