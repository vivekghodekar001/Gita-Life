import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/attendance_service.dart';
import '../models/attendance_session.dart';
import '../models/attendance_record.dart';

final attendanceServiceProvider = Provider<AttendanceService>((ref) => AttendanceService());

final sessionListProvider = FutureProvider<List<AttendanceSession>>((ref) {
  return ref.watch(attendanceServiceProvider).getSessionList();
});

final studentAttendanceProvider = FutureProvider.family<List<AttendanceRecord>, String>((ref, studentUid) {
  return ref.watch(attendanceServiceProvider).getStudentAttendance(studentUid);
});
