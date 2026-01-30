import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'recordings.g.dart';

@DataClassName("Recording")
class Recordings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get meetingId => text()();
  TextColumn get status => text()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  IntColumn get duration => integer()();
  DateTimeColumn get recordedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {meetingId},
  ];
}

@DriftDatabase(tables: [Recordings])
class RecordingDatabase extends _$RecordingDatabase {
  RecordingDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertRecording(RecordingsCompanion recording) =>
      into(recordings).insert(recording);

  Future<Recording?> getRecordingById(String meetingId) => (select(
    recordings,
  )..where((r) => r.meetingId.equals(meetingId))).getSingleOrNull();

  Future<List<Recording>> getAllRecordings() => select(recordings).get();

  Future<List<Recording>> searchRecordings(String query) {
    if (query.isEmpty) {
      // Return all recordings sorted by newest first
      return (select(recordings)..orderBy([
            (t) =>
                OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc),
          ]))
          .get();
    }

    final searchTerm = '%$query%';

    // Search only in fileName
    return (select(recordings)
          ..where((item) => item.fileName.like(searchTerm))
          // Default: newest first
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<bool> updateRecording(Recording recording) =>
      update(recordings).replace(recording);

  Future<int> deleteRecording(Recording recording) =>
      delete(recordings).delete(recording);

  Future<int> deleteRecordingsByIds(List<String> meetingIds) =>
      (delete(recordings)..where((r) => r.meetingId.isIn(meetingIds))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Store database in documents directory
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'recordings_db.sqlite'));

    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}
