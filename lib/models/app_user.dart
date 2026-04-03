import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String mobile;
  final String role;
  final String year;
  final String category;
  final String staying;
  final String? counselorUid;
  final int chanting;
  final int attendanceScore;

  const AppUser({
    required this.uid,
    required this.name,
    required this.mobile,
    required this.role,
    required this.year,
    required this.category,
    required this.staying,
    this.counselorUid,
    required this.chanting,
    required this.attendanceScore,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['fullName'] as String? ?? data['name'] as String? ?? '',
      mobile: data['phoneNumber'] as String? ?? data['mobile'] as String? ?? '',
      role: data['role'] as String? ?? 'student',
      year: data['year'] as String? ?? '',
      category: data['category'] as String? ?? 'Not Sincere',
      staying: data['staying'] as String? ?? 'Local Youth',
      counselorUid: data['counselorUid'] as String?,
      chanting: (data['chanting'] as num?)?.toInt() ?? 0,
      attendanceScore: (data['attendanceScore'] as num?)?.toInt() ?? 0,
    );
  }
}
