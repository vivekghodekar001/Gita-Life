import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FirebaseInitStatus { loading, initialized, failed }

final firebaseInitStatusProvider = StateProvider<FirebaseInitStatus>((ref) => FirebaseInitStatus.loading);
final firebaseInitErrorProvider = StateProvider<String?>((ref) => null);
