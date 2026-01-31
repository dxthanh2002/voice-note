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
    required String title,
    required String filePath,
    required int duration,
    required String status,
    bool isTranscriptActivated = false, // New parameter with default
    bool isSummaryActivated = false, // New parameter with default
  }) async {
    final db = await _database;

    final recording = RecordingsCompanion(
      meetingId: Value(meetingId),
      title: Value(title),
      filePath: Value(filePath),
      duration: Value(duration),
      status: Value(status),
      isTranscriptActivated: Value(isTranscriptActivated), // Add this
      isSummaryActivated: Value(isSummaryActivated),
      recordedAt: Value(DateTime.now()),
    );

    return await db.into(db.recordings).insert(recording);
  }

  Future<Recording?> getRecording(String meetingId) async {
    // only return 1 or null
    final db = await _database;
    return await db.getRecordingById(meetingId);
  }

  Future<List<Recording>> getAllRecordings({
    String orderBy = 'recordedAt',
    bool descending = true,
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
        break;
      case 'title':
        query.orderBy([
          (t) => OrderingTerm(
            expression: t.title,
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

  Future<bool> updateRecordingTitle({
    required String meetingId,
    required String newTitle,
  }) async {
    final db = await _database;

    // First get the current recording
    final recording = await db.getRecordingById(meetingId);
    if (recording == null) return false;

    // Create updated recording with new title
    final updatedRecording = recording.copyWith(title: newTitle);

    return await db.updateRecording(updatedRecording);
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

  Future<bool> updateTranscriptActivation({
    required String meetingId,
    required bool isActivated,
  }) async {
    final db = await _database;
    try {
      await db.updateTranscriptActivation(meetingId, isActivated);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSummaryActivation({
    required String meetingId,
    required bool isActivated,
  }) async {
    final db = await _database;
    try {
      await db.updateSummaryActivation(meetingId, isActivated);
      return true;
    } catch (e) {
      return false;
    }
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
