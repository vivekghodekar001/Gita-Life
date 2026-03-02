import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String rollNumber;
  final String email;
  final String phoneNumber;
  final String profilePhotoUrl;
  final String role; // 'student' | 'admin'
  final String status; // 'pending' | 'active' | 'suspended'
  final DateTime enrollmentDate;
  final String fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.rollNumber,
    required this.email,
    required this.phoneNumber,
    required this.profilePhotoUrl,
    required this.role,
    required this.status,
    required this.enrollmentDate,
    required this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] ?? '',
      role: data['role'] ?? 'student',
      status: data['status'] ?? 'pending',
      enrollmentDate: (data['enrollmentDate'] as Timestamp).toDate(),
      fcmToken: data['fcmToken'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'rollNumber': rollNumber,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': profilePhotoUrl,
      'role': role,
      'status': status,
      'enrollmentDate': Timestamp.fromDate(enrollmentDate),
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? rollNumber,
    String? email,
    String? phoneNumber,
    String? profilePhotoUrl,
    String? role,
    String? status,
    DateTime? enrollmentDate,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      rollNumber: rollNumber ?? this.rollNumber,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
