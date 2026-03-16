import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id;
  final String title;
  final String speaker;
  final String type;
  final DateTime date;

  const Session({
    required this.id,
    required this.title,
    required this.speaker,
    required this.type,
    required this.date,
  });

  factory Session.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Session(
      id: doc.id,
      title: data['title'] as String? ?? '',
      speaker: data['speaker'] as String? ?? '',
      type: data['type'] as String? ?? 'Sunday',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
