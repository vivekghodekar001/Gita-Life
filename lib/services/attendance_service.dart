import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_session.dart';
import '../models/attendance_record.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AttendanceSession> createSession(Map<String, dynamic> sessionData) async {
    // TODO: Create a new attendance session document in /attendance_sessions
    throw UnimplementedError();
  }

  Future<void> markAttendance(
    String sessionId,
    String studentUid,
    String status,
  ) async {
    // TODO: Create/update attendance record in /attendance_records
    throw UnimplementedError();
  }

  Future<void> submitSession(String sessionId) async {
    // TODO: Lock the session (isLocked = true) and update counts
    throw UnimplementedError();
  }

  Future<List<AttendanceRecord>> getStudentAttendance(String studentUid) async {
    // TODO: Fetch all attendance records for a student
    throw UnimplementedError();
  }

  Future<double> getAttendancePercentage(String studentUid) async {
    // TODO: Calculate attendance percentage for a student
    throw UnimplementedError();
  }

  Future<String> exportSessionCsv(String sessionId) async {
    // TODO: Generate CSV string from attendance records for a session
    throw UnimplementedError();
  }

  Future<List<AttendanceSession>> getSessionList() async {
    // TODO: Fetch all attendance sessions, ordered by date
    throw UnimplementedError();
  }
}
