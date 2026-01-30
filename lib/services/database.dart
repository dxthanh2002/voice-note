import 'package:drift/drift.dart';
import 'data/recordings.dart';

class DatabaseService {
  late RecordingDatabase _db;
  bool _initialized = false;

  DatabaseService._internal();
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  Future<void> _init() async {
    if (!_initialized) {
      _db = RecordingDatabase();
      _initialized = true;
    }
  }

  Future<RecordingDatabase> get _database async {
    await _init();
    return _db;
  }

  Future<int> save({
    required String meetingId,
    required String fileName,
    required String filePath,
    required int duration,
    required String status,
  }) async {
    final db = await _database;

    final recording = RecordingsCompanion.insert(
      meetingId: meetingId,
      fileName: fileName,
      filePath: filePath,
      duration: duration,
      status: status,
      recordedAt: Value(DateTime.now()),
    );

    return await db.insertRecording(recording);
  }

  Future<Recording?> getRecording(String meetingId) async {
    final db = await _database;
    return await db.getRecordingById(meetingId);
  }

  Future<List<Recording>> getAllRecordings({
    String orderBy = 'recordedAt',
    bool descending = false,
  }) async {
    final db = await _database;
    final query = db.select(db.recordings);

    switch (orderBy.toLowerCase()) {
      case 'recordedat':
        query.orderBy([
          (t) => OrderingTerm(
            expression: t.recordedAt,
            mode: descending ? OrderingMode.desc : OrderingMode.asc,
          ),
        ]);
        break;
      case 'duration':
        query.orderBy([
          (t) => OrderingTerm(
            expression: t.duration,
            mode: descending ? OrderingMode.desc : OrderingMode.asc,
          ),
        ]);
      case 'filename':
        query.orderBy([
          (t) => OrderingTerm(
            expression: t.fileName,
            mode: descending ? OrderingMode.desc : OrderingMode.asc,
          ),
        ]);
        break;
    }

    // no default

    return await query.get();
  }

  Future<bool> updateRecording(Recording recording) async {
    final db = await _database;
    return await db.updateRecording(recording);
  }

  Future<bool> updateRecordingStatus({
    required String meetingId,
    required String status,
  }) async {
    final db = await _database;

    // First get the current recording
    final recording = await db.getRecordingById(meetingId);
    if (recording == null) return false;

    // Create updated recording with new status
    final updatedRecording = recording.copyWith(
      status: status,
      // Optionally update a "modifiedAt" timestamp if you add that field
    );

    return await db.updateRecording(updatedRecording);
  }

  Future<int> deleteRecording(String meetingId) async {
    final db = await _database;
    final recording = await db.getRecordingById(meetingId);
    if (recording != null) {
      return await db.deleteRecording(recording);
    }
    return 0;
  }

  Future<List<Recording>> searchRecordings(String query) async {
    final db = await _database;
    return await db.searchRecordings(query);
  }

  Future<int> deleteAllRecordings() async {
    final db = await _database;
    return await db.customUpdate('DELETE FROM recordings');
  }
}
