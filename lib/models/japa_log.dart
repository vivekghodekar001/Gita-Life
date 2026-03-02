import 'package:hive_flutter/hive_flutter.dart';

part 'japa_log.g.dart';

@HiveType(typeId: 0)
class JapaLog extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  int totalMalas;

  @HiveField(2)
  int totalBeads;

  @HiveField(3)
  int targetMalas;

  @HiveField(4)
  bool goalReached;

  @HiveField(5)
  String lastUpdated;

  JapaLog({
    required this.date,
    required this.totalMalas,
    required this.totalBeads,
    required this.targetMalas,
    required this.goalReached,
    required this.lastUpdated,
  });

  JapaLog copyWith({
    String? date,
    int? totalMalas,
    int? totalBeads,
    int? targetMalas,
    bool? goalReached,
    String? lastUpdated,
  }) {
    return JapaLog(
      date: date ?? this.date,
      totalMalas: totalMalas ?? this.totalMalas,
      totalBeads: totalBeads ?? this.totalBeads,
      targetMalas: targetMalas ?? this.targetMalas,
      goalReached: goalReached ?? this.goalReached,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
