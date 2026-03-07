import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final adminStatsProvider = StreamProvider<Map<String, dynamic>>((ref) async* {
  final status = ref.watch(firebaseInitStatusProvider);
  if (status != FirebaseInitStatus.initialized) {
    yield {
      'totalStudents': 0,
      'pendingApprovals': 0,
      'activeToday': 0,
      'sessionsThisWeek': 0,
    };
    return;
  }

  if (Firebase.apps.isEmpty) return;
  final firestore = FirebaseFirestore.instanceFor(app: Firebase.app());

  // Real-time listener on users collection — re-emits stats on every change
  await for (final usersSnap in firestore.collection('users').snapshots()) {
    final totalStudents = usersSnap.docs.length;
    final pendingApprovals =
        usersSnap.docs.where((d) => (d.data()['status'] ?? '') == 'pending').length;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    int activeToday = 0;
    int sessionsThisWeek = 0;

    try {
      // japa logs are stored at /japa_logs/{uid}/logs/{docId} — use collectionGroup
      final japaSnap = await firestore
          .collectionGroup('logs')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .get();
      activeToday = japaSnap.docs.map((d) => d.reference.parent.parent?.id).toSet().length;
    } catch (_) {}

    try {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final sessSnap = await firestore
          .collection('attendance_sessions')
          .where('lectureDate', isGreaterThanOrEqualTo: startOfWeek)
          .get();
      sessionsThisWeek = sessSnap.docs.length;
    } catch (_) {}

    yield {
      'totalStudents': totalStudents,
      'pendingApprovals': pendingApprovals,
      'activeToday': activeToday,
      'sessionsThisWeek': sessionsThisWeek,
    };
  }
});

final usersProvider = StreamProvider.family<List<UserModel>, String>((ref, statusFilter) {
  final status = ref.watch(firebaseInitStatusProvider);
  if (status != FirebaseInitStatus.initialized) {
    return const Stream.empty();
  }
  
  if (Firebase.apps.isEmpty) return const Stream.empty();
  final firestore = FirebaseFirestore.instanceFor(app: Firebase.app());
  Query query = firestore.collection('users');
  
  if (statusFilter != 'all') {
    query = query.where('status', isEqualTo: statusFilter);
  }
  
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  });
});

final userActionsProvider = Provider((ref) => UserActions());

class UserActions {
  FirebaseFirestore get _firestore {
    if (Firebase.apps.isEmpty) throw Exception('[UserActions] Firebase not initialized. Cannot access Firestore.');
    return FirebaseFirestore.instanceFor(app: Firebase.app());
  }

  Future<void> updateUserStatus(String uid, String newStatus) async {
    await _firestore.collection('users').doc(uid).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> exportUsersCsv(List<UserModel> users) async {
    List<List<dynamic>> rows = [];
    rows.add([
      'Roll Number',
      'Full Name',
      'Email',
      'Phone Number',
      'Role',
      'Status',
      'Enrollment Date',
    ]);

    for (var user in users) {
      rows.add([
        user.rollNumber,
        user.fullName,
        user.email,
        user.phoneNumber,
        user.role,
        user.status,
        user.enrollmentDate.toIso8601String(),
      ]);
    }

    String csvData = const CsvEncoder().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/students_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csvData);
    
    await Share.shareXFiles([XFile(path)], text: 'Student Export CSV');
  }
}

