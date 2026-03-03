// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioTrackModelAdapter extends TypeAdapter<AudioTrackModel> {
  @override
  final int typeId = 1;

  @override
  AudioTrackModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioTrackModel(
      trackId: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      category: fields[3] as String,
      sourceType: fields[4] as String,
      driveFileId: fields[5] as String?,
      storageRef: fields[6] as String?,
      streamUrl: fields[7] as String?,
      durationSeconds: fields[8] as int,
      fileSizeBytes: fields[9] as int,
      coverImageUrl: fields[10] as String?,
      isActive: fields[11] as bool,
      playCount: fields[12] as int,
      addedBy: fields[13] as String,
      createdAt: fields[14] as String,
      localFilePath: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AudioTrackModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.trackId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.sourceType)
      ..writeByte(5)
      ..write(obj.driveFileId)
      ..writeByte(6)
      ..write(obj.storageRef)
      ..writeByte(7)
      ..write(obj.streamUrl)
      ..writeByte(8)
      ..write(obj.durationSeconds)
      ..writeByte(9)
      ..write(obj.fileSizeBytes)
      ..writeByte(10)
      ..write(obj.coverImageUrl)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.playCount)
      ..writeByte(13)
      ..write(obj.addedBy)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.localFilePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTrackModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
