import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gita_life/models/audio_track.dart';
import 'package:gita_life/models/user_model.dart';
import 'package:gita_life/services/audio_service.dart';

void main() {
  test('editing a user preserves the assigned counselor', () {
    final date = DateTime(2026, 1, 1);
    final user = UserModel(
      uid: 'student', fullName: 'Student', rollNumber: '1', email: 'test@example.com',
      phoneNumber: '', profilePhotoUrl: '', role: 'student', status: 'active',
      enrollmentDate: date, fcmToken: '', createdAt: date, updatedAt: date,
      counselorUid: 'counselor',
    );
    final edited = user.copyWith(fullName: 'Updated');
    expect(edited.fullName, 'Updated');
    expect(edited.counselorUid, 'counselor');
  });

  group('audio source URLs', () {
    late Directory temp;
    setUp(() async {
      temp = await Directory.systemTemp.createTemp('gita_audio_test');
      Hive.init(temp.path);
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AudioTrackModelAdapter());
      await Hive.openBox<AudioTrackModel>('downloads');
    });
    tearDown(() async {
      await Hive.close();
      await temp.delete(recursive: true);
    });
    AudioTrackModel track({String source = 'google_drive', String? id = 'drive-file_123'}) => AudioTrackModel(
      trackId: 'track', title: 'Test Track', artist: 'Artist', category: 'kirtan',
      sourceType: source, driveFileId: id, durationSeconds: 0, fileSizeBytes: 0,
      isActive: true, playCount: 0, addedBy: 'admin', createdAt: '2026-01-01',
    );
    test('Google Drive URL contains the actual file ID', () async {
      final url = Uri.parse(await AudioService().buildStreamUrl(track()));
      expect(url.host, 'drive.google.com');
      expect(url.queryParameters['id'], 'drive-file_123');
      expect(url.queryParameters['export'], 'download');
    });
    test('missing source reports the actual track title', () async {
      expect(AudioService().buildStreamUrl(track(source: 'unknown', id: null)),
        throwsA(predicate((error) => error.toString().contains('Test Track'))));
    });
  });
}
