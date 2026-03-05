import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_session.dart';
import '../models/attendance_record.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AttendanceService {
  void _ensureFirebase() {
    if (Firebase.apps.isEmpty) {
      throw Exception('[AttendanceService] Firebase not initialized. Ensure Firebase.initializeApp() is called and verified before accessing this service.');
    }
  }

  FirebaseFirestore get _firestore {
    _ensureFirebase();
    return FirebaseFirestore.instanceFor(app: Firebase.app());
  }

  FirebaseAuth get _auth {
    _ensureFirebase();
    return FirebaseAuth.instanceFor(app: Firebase.app());
  }

  Future<AttendanceSession> createSession(Map<String, dynamic> sessionData) async {
    final docRef = _firestore.collection('attendance_sessions').doc();
    
    final session = AttendanceSession(
      sessionId: docRef.id,
      title: sessionData['title'] ?? 'New Session',
      topic: sessionData['topic'] ?? '',
      lectureDate: sessionData['date'] ?? DateTime.now(),
      createdBy: _auth.currentUser?.uid ?? 'unknown',
      isLocked: false,
      totalStudents: 0,
      presentCount: 0,
      absentCount: 0,
      lateCount: 0,
      createdAt: DateTime.now(),
    );

    await docRef.set(session.toFirestore());
    return session;
  }

  Future<void> markAttendance(
    String sessionId,
    String studentUid,
    String status,
    {String? studentName, String? rollNumber}
  ) async {
    // Determine a record ID based on sessionId and studentUid to ensure one record per student per session
    final recordId = '${sessionId}_$studentUid';
    final docRef = _firestore.collection('attendance_records').doc(recordId);
    
    final record = AttendanceRecord(
      recordId: recordId,
      sessionId: sessionId,
      studentUid: studentUid,
      studentName: studentName ?? 'Unknown',
      rollNumber: rollNumber ?? 'N/A',
      status: status,
      markedBy: _auth.currentUser?.uid ?? 'unknown',
      markedAt: DateTime.now(),
    );

    await docRef.set(record.toFirestore(), SetOptions(merge: true));
  }

  Future<void> submitSession(String sessionId) async {
    final recordsQuery = await _firestore
        .collection('attendance_records')
        .where('sessionId', isEqualTo: sessionId)
        .get();

    int present = 0;
    int absent = 0;
    int late = 0;

    for (var doc in recordsQuery.docs) {
      final status = doc.data()['status'] as String?;
      if (status == 'present') present++;
      if (status == 'absent') absent++;
      if (status == 'late') late++;
    }

    await _firestore.collection('attendance_sessions').doc(sessionId).update({
      'isLocked': true,
      'presentCount': present,
      'absentCount': absent,
      'lateCount': late,
      'totalStudents': present + absent + late,
    });
  }

  Stream<List<AttendanceRecord>> streamStudentAttendance(String studentUid) {
    return _firestore
        .collection('attendance_records')
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map((snapshot) {
            final records = snapshot.docs
                .map((doc) => AttendanceRecord.fromFirestore(doc))
                .toList();
            records.sort((a, b) => b.markedAt.compareTo(a.markedAt));
            return records;
        });
  }

  Future<List<AttendanceRecord>> getStudentAttendance(String studentUid) async {
    final querySnapshot = await _firestore
        .collection('attendance_records')
        .where('studentUid', isEqualTo: studentUid)
        .get();

    final records = querySnapshot.docs.map((doc) => AttendanceRecord.fromFirestore(doc)).toList();
    records.sort((a, b) => b.markedAt.compareTo(a.markedAt));
    return records;
  }

  Future<double> getAttendancePercentage(String studentUid) async {
    final records = await getStudentAttendance(studentUid);
    if (records.isEmpty) return 0.0;

    int attended = 0;
    for (var record in records) {
      if (record.status == 'present' || record.status == 'late') {
        attended++;
      }
    }
    
    // To get a true percentage, we should idealistically divide by total sessions.
    // For now, we'll just return the percentage of marked sessions. 
    return (attended / records.length) * 100;
  }

  Future<String> exportSessionCsv(String sessionId) async {
    final sessionDoc = await _firestore.collection('attendance_sessions').doc(sessionId).get();
    if (!sessionDoc.exists) return '';
    
    final session = AttendanceSession.fromFirestore(sessionDoc);
    
    final recordsQuery = await _firestore
        .collection('attendance_records')
        .where('sessionId', isEqualTo: sessionId)
        .get();

    final buffer = StringBuffer();
    buffer.writeln('Session: ${session.title}');
    buffer.writeln('Topic: ${session.topic}');
    buffer.writeln('Date: ${session.lectureDate.toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('Roll Number,Student Name,Status,Marked At');

    for (var doc in recordsQuery.docs) {
      final record = AttendanceRecord.fromFirestore(doc);
      final formattedTime = record.markedAt.toIso8601String();
      buffer.writeln('${record.rollNumber},${record.studentName},${record.status},$formattedTime');
    }

    return buffer.toString();
  }

  Future<List<AttendanceSession>> getSessionList() async {
    final querySnapshot = await _firestore
        .collection('attendance_sessions')
        .orderBy('lectureDate', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => AttendanceSession.fromFirestore(doc)).toList();
  }

  Future<void> unlockSession(String sessionId) async {
    await _firestore
        .collection('attendance_sessions')
        .doc(sessionId)
        .update({'isLocked': false});
  }

  Future<void> deleteSession(String sessionId) async {
    // Delete all attendance records for this session
    final recordsQuery = await _firestore
        .collection('attendance_records')
        .where('sessionId', isEqualTo: sessionId)
        .get();
    for (final doc in recordsQuery.docs) {
      await doc.reference.delete();
    }
    // Delete the session itself
    await _firestore.collection('attendance_sessions').doc(sessionId).delete();
  }

  // Helper Methods to replace raw UI calls
  Future<QuerySnapshot> getStudentsRaw() {
    return _firestore.collection('users').get();
  }

  Future<QuerySnapshot> getRecordsBySessionRaw(String sessionId) {
    return _firestore
        .collection('attendance_records')
        .where('sessionId', isEqualTo: sessionId)
        .get();
  }
}
