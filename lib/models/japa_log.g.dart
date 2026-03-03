// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'japa_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JapaLogAdapter extends TypeAdapter<JapaLog> {
  @override
  final int typeId = 0;

  @override
  JapaLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JapaLog(
      date: fields[0] as String,
      totalMalas: fields[1] as int,
      totalBeads: fields[2] as int,
      targetMalas: fields[3] as int,
      goalReached: fields[4] as bool,
      lastUpdated: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JapaLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.totalMalas)
      ..writeByte(2)
      ..write(obj.totalBeads)
      ..writeByte(3)
      ..write(obj.targetMalas)
      ..writeByte(4)
      ..write(obj.goalReached)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JapaLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
