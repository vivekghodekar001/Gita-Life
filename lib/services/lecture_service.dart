import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lecture_model.dart';

class LectureService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LectureModel>> getLectures({String? topic}) async {
    // TODO: Fetch active lectures from Firestore, optionally filtered by topic
    throw UnimplementedError();
  }

  Future<LectureModel?> getLectureById(String lectureId) async {
    // TODO: Fetch a single lecture document by ID
    throw UnimplementedError();
  }

  Future<void> addLecture(LectureModel lecture) async {
    // TODO: Add a new lecture document to /lectures collection
    throw UnimplementedError();
  }

  Future<void> updateLecture(String lectureId, Map<String, dynamic> data) async {
    // TODO: Update lecture document fields
    throw UnimplementedError();
  }

  Future<void> deleteLecture(String lectureId) async {
    // TODO: Soft-delete lecture by setting isActive = false
    throw UnimplementedError();
  }

  Future<void> incrementViewCount(String lectureId) async {
    // TODO: Increment viewCount field for given lectureId
    throw UnimplementedError();
  }
}
