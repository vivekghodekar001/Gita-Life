import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/session.dart';

// Current logged-in user's role (read once from Firestore)
final userRoleProvider = FutureProvider<String>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 'devotee';
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc.data()?['role'] as String? ?? 'devotee';
});

// Current active session (latest session by date)
final activeSessionProvider = StreamProvider<Session?>((ref) {
  return FirebaseFirestore.instance
      .collection('sessions')
      .orderBy('date', descending: true)
      .limit(1)
      .snapshots()
      .map((s) => s.docs.isEmpty ? null : Session.fromDoc(s.docs.first));
});

// Devotees assigned to current counselor, sorted by attendanceScore descending
final myDevoteesProvider = StreamProvider<List<AppUser>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users')
      .where('counselorUid', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list = s.docs.map(AppUser.fromDoc).toList();
        list.sort((a, b) => b.attendanceScore.compareTo(a.attendanceScore));
        return list;
      });
});

// Attendance records for a specific session (keyed by devoteeId → status)
final sessionAttendanceProvider =
    StreamProvider.family<Map<String, String>, String>((ref, sessionId) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('attendance')
      .where('sessionId', isEqualTo: sessionId)
      .where('markedBy', isEqualTo: uid)
      .snapshots()
      .map((s) => {
            for (final doc in s.docs)
              doc.data()['devoteeId'] as String: doc.data()['status'] as String
          });
});

// Last 4 sessions ordered by date descending
final recentSessionsProvider = FutureProvider<List<Session>>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection('sessions')
      .orderBy('date', descending: true)
      .limit(4)
      .get();
  return snap.docs.map(Session.fromDoc).toList();
});

  // All attendance records across last 4 sessions, keyed by devoteeId → {sessionId → status}
  // Note: uses whereIn which supports up to 10 values; limit(4) in recentSessionsProvider
  // ensures we never exceed that limit.
  final recentAttendanceMapProvider =
    FutureProvider<Map<String, Map<String, String>>>((ref) async {
  final sessions = await ref.watch(recentSessionsProvider.future);
  if (sessions.isEmpty) return {};
  final sessionIds = sessions.map((s) => s.id).toList();

  // Use whereIn to fetch all attendance docs for those sessions in one query
  final attendanceSnap = await FirebaseFirestore.instance
      .collection('attendance')
      .where('sessionId', whereIn: sessionIds)
      .get();

  final result = <String, Map<String, String>>{};
  for (final doc in attendanceSnap.docs) {
    final data = doc.data();
    final devoteeId = data['devoteeId'] as String? ?? '';
    final sessionId = data['sessionId'] as String? ?? '';
    final status = data['status'] as String? ?? '';
    result.putIfAbsent(devoteeId, () => {})[sessionId] = status;
  }
  return result;
});

// Selected filter pill in the preaching screen
final preachingFilterProvider = StateProvider<String>((ref) => 'All');
