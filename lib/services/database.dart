import 'package:drift/drift.dart';
import 'data/recordings.dart';

class DatabaseService {
  late RecordingDatabase _db;
  bool _initialized = false;

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<void> init() async {
    if (!_initialized) {
      _db = RecordingDatabase();
      _initialized = true;
    }
  }

  Future<int> save({
    required String meetingId,
    required String fileName,
    required String filePath,
    required int duration,
    required String status,
  }) async {
    await init();

    final recording = RecordingsCompanion.insert(
      meetingId: meetingId,
      fileName: fileName,
      filePath: filePath,
      duration: duration,
      status: Value(status),
      recordedAt: DateTime.now(),
    );

    return await _db.insertRecording(recording);
  }

  Future<Recording?> getRecordingById(String meetingId) async {
    await init();
    return await _db.getRecordingById(meetingId);
  }

  Future<List<Recording>> getAllRecordings() async {
    await init();
    return await _db.getAllRecording();
  }

  Future<bool> update(Recording recording) async {
    await init();
    return await _db.updateRecording(recording);
  }

  Future<int> deleteById(String meetingId) async {
    await init();
    final recording = await getRecordingById(meetingId);
    if (recording != null) {
      return await _db.deleteRecording(recording);
    }
    return 0;
  }
}
