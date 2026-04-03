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
  final String? counselorUid;

  // New Profile Fields
  final String? address;
  final DateTime? dateOfBirth;
  final String? collegeBranch;
  final String? year;
  final List<String>? interests;
  final List<String>? skills;

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
    this.counselorUid,
    this.address,
    this.dateOfBirth,
    this.collegeBranch,
    this.year,
    this.interests,
    this.skills,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime _parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] ?? '',
      role: data['role'] ?? 'student',
      status: data['status'] ?? 'pending',
      enrollmentDate: _parseDate(data['enrollmentDate']),
      fcmToken: data['fcmToken'] ?? '',
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      address: data['address'],
      dateOfBirth: data['dateOfBirth'] != null ? _parseDate(data['dateOfBirth']) : null,
      collegeBranch: data['collegeBranch'],
      year: data['year'],
      interests: data['interests'] != null ? List<String>.from(data['interests']) : null,
      skills: data['skills'] != null ? List<String>.from(data['skills']) : null,
      counselorUid: data['counselorUid'],
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
      if (counselorUid != null) 'counselorUid': counselorUid,
      if (address != null) 'address': address,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (collegeBranch != null) 'collegeBranch': collegeBranch,
      if (year != null) 'year': year,
      if (interests != null) 'interests': interests,
      if (skills != null) 'skills': skills,
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
    String? address,
    DateTime? dateOfBirth,
    String? collegeBranch,
    String? year,
    List<String>? interests,
    List<String>? skills,
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
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      collegeBranch: collegeBranch ?? this.collegeBranch,
      year: year ?? this.year,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
    );
  }
}
