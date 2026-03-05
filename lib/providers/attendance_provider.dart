import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/attendance_service.dart';
import '../models/attendance_session.dart';
import '../models/attendance_record.dart';

final attendanceServiceProvider = Provider<AttendanceService>((ref) => AttendanceService());

final sessionListProvider = FutureProvider<List<AttendanceSession>>((ref) {
  return ref.watch(attendanceServiceProvider).getSessionList();
});

final studentAttendanceProvider = StreamProvider.family<List<AttendanceRecord>, String>((ref, studentUid) {
  return ref.watch(attendanceServiceProvider).streamStudentAttendance(studentUid);
});

final createSessionProvider = FutureProvider.family<AttendanceSession, Map<String, dynamic>>((ref, sessionData) {
  return ref.read(attendanceServiceProvider).createSession(sessionData);
});

