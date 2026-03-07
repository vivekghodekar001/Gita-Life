import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/japa_log.dart';

class JapaService {
  void _ensureFirebase() {
    if (Firebase.apps.isEmpty) {
      throw Exception('[JapaService] Firebase not initialized. Ensure Firebase.initializeApp() is called and verified before accessing this service.');
    }
  }

  FirebaseFirestore get _firestore {
    _ensureFirebase();
    return FirebaseFirestore.instanceFor(app: Firebase.app());
  }
  final Box<JapaLog> _japaBox = Hive.box<JapaLog>('japa_logs');
  final Box _settingsBox = Hive.box('settings');

  String _getTodayDateStr() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  int getDailyTarget() {
    return _settingsBox.get('daily_target', defaultValue: 16) as int;
  }

  Future<void> setDailyTarget(int targetMalas) async {
    await _settingsBox.put('daily_target', targetMalas);
    final log = await getTodayLog();
    if (log != null) {
      log.targetMalas = targetMalas;
      log.goalReached = log.totalMalas >= log.targetMalas;
      await log.save();
    }
  }

  Future<JapaLog?> getTodayLog() async {
    final todayStr = _getTodayDateStr();
    JapaLog? todayLog = _japaBox.get(todayStr);

    if (todayLog == null) {
      todayLog = JapaLog(
        date: todayStr,
        totalMalas: 0,
        totalBeads: 0,
        targetMalas: getDailyTarget(),
        goalReached: false,
        lastUpdated: DateTime.now().toIso8601String(),
      );
      await _japaBox.put(todayStr, todayLog);
    }
    return todayLog;
  }

  Future<void> recordBead(String date) async {
    final log = _japaBox.get(date);
    if (log != null) {
      log.totalBeads += 1;
      log.lastUpdated = DateTime.now().toIso8601String();
      
      if (log.totalBeads >= 108) {
        log.totalBeads = 0;
        await completeMala(date); // This will save the changes within
      } else {
        await log.save();
      }
    }
  }

  Future<void> completeMala(String date) async {
    final log = _japaBox.get(date);
    if (log != null) {
      log.totalMalas += 1;
      log.goalReached = log.totalMalas >= log.targetMalas;
      log.lastUpdated = DateTime.now().toIso8601String();
      await log.save();
    }
  }

  Future<List<JapaLog>> getWeekHistory() async {
    final now = DateTime.now();
    final weekLogs = <JapaLog>[];
    for (int i = 6; i >= 0; i--) {
      final dateStr = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      JapaLog? log = _japaBox.get(dateStr);
      if (log == null) {
        log = JapaLog(
          date: dateStr,
          totalMalas: 0,
          totalBeads: 0,
          targetMalas: getDailyTarget(),
          goalReached: false,
          lastUpdated: now.toIso8601String(),
        );
      }
      weekLogs.add(log);
    }
    return weekLogs;
  }

  Future<List<JapaLog>> getMonthHistory() async {
    final now = DateTime.now();
    final monthLogs = <JapaLog>[];
    for (int i = 29; i >= 0; i--) {
      final dateStr = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      JapaLog? log = _japaBox.get(dateStr);
      if (log != null) {
        monthLogs.add(log);
      }
    }
    return monthLogs;
  }

  Future<void> syncToFirestore(String userId) async {
    if (userId.isEmpty) return;
    
    final firestore = _firestore;
    final batch = firestore.batch();
    
    final collection = firestore.collection('japa_logs').doc(userId).collection('logs');
    
    for (var log in _japaBox.values) {
       final docRef = collection.doc(log.date);
       batch.set(docRef, {
         'date': log.date,
         'totalMalas': log.totalMalas,
         'totalBeads': log.totalBeads,
         'targetMalas': log.targetMalas,
         'goalReached': log.goalReached,
         'lastUpdated': log.lastUpdated,
       }, SetOptions(merge: true));
    }
    
    await batch.commit();
  }

  /// Pull japa history from Firestore into local Hive (two-way sync)
  Future<void> syncFromFirestore(String userId) async {
    if (userId.isEmpty) return;

    try {
      final firestore = _firestore;
      final snapshot = await firestore
          .collection('japa_logs')
          .doc(userId)
          .collection('logs')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final date = data['date'] as String? ?? doc.id;
        final existing = _japaBox.get(date);

        // If local doesn't have it, or Firestore has a newer version, overwrite
        final remoteMalas = data['totalMalas'] as int? ?? 0;
        final remoteBeads = data['totalBeads'] as int? ?? 0;

        if (existing == null || remoteMalas > existing.totalMalas ||
            (remoteMalas == existing.totalMalas && remoteBeads > existing.totalBeads)) {
          final log = JapaLog(
            date: date,
            totalMalas: remoteMalas,
            totalBeads: remoteBeads,
            targetMalas: data['targetMalas'] as int? ?? getDailyTarget(),
            goalReached: data['goalReached'] as bool? ?? false,
            lastUpdated: data['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
          );
          await _japaBox.put(date, log);
        }
      }
    } catch (e) {
      // Silently fail — local data still available
    }
  }
}
