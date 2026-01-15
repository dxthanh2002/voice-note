import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'audio.dart';

class Recording {
  final String id;
  final String title;
  final String filePath;
  final DateTime date;
  final Duration duration;
  final bool hasSummary;

  const Recording({
    required this.id,
    required this.title,
    required this.filePath,
    required this.date,
    required this.duration,
    this.hasSummary = false,
  });

  /// Create Recording from file
  static Future<Recording?> fromFile(File file) async {
    try {
      final stat = await file.stat();
      final fileName = p.basenameWithoutExtension(file.path);

      // Extract timestamp from filename (recording_1234567890)
      final timestampStr = fileName.replaceFirst('recording_', '');
      final timestamp = int.tryParse(timestampStr);
      final date = timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : stat.modified;

      // Estimate duration based on file size and format
      // M4A (AAC 128kbps): ~16KB/s
      // WAV (44100Hz, 16-bit, mono): ~176KB/s
      final fileSizeBytes = stat.size;
      final ext = p.extension(file.path).toLowerCase();

      int estimatedSeconds;
      if (ext == '.m4a' || ext == '.mp3') {
        // Compressed audio: ~16KB/s at 128kbps
        estimatedSeconds = (fileSizeBytes / 16000).round();
      } else {
        // WAV: ~176KB/s
        estimatedSeconds = (fileSizeBytes / 176000).round();
      }

      debugPrint('  File: ${file.path}');
      debugPrint(
        '  Size: $fileSizeBytes bytes, Duration: ~${estimatedSeconds}s',
      );

      return Recording(
        id: fileName,
        title: _generateTitle(date),
        filePath: file.path,
        date: date,
        duration: Duration(
          seconds: estimatedSeconds > 0 ? estimatedSeconds : 1,
        ),
        hasSummary: false,
      );
    } catch (e) {
      debugPrint('Error creating Recording from file: $e');
      return null;
    }
  }

  static String _generateTitle(DateTime date) {
    final hour = date.hour;
    String timeOfDay;
    if (hour < 12) {
      timeOfDay = 'Buổi sáng';
    } else if (hour < 18) {
      timeOfDay = 'Buổi chiều';
    } else {
      timeOfDay = 'Buổi tối';
    }
    return 'Ghi âm $timeOfDay ${date.day}/${date.month}';
  }
}

class RecordingsRepository extends ChangeNotifier {
  List<Recording> _recordings = [];
  List<Recording> get recordings => List.unmodifiable(_recordings);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Load all recordings from storage
  Future<void> loadRecordings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Always get fresh path from AudioRecorderService
      final dirPath = await AudioService.getRecordingsDirectory();
      debugPrint('=== Loading Recordings ===');
      debugPrint('Directory: $dirPath');

      final dir = Directory(dirPath);

      // Check if directory exists
      final dirExists = await dir.exists();
      debugPrint('Directory exists: $dirExists');

      if (!dirExists) {
        debugPrint('Creating directory...');
        await dir.create(recursive: true);
        _recordings = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // List all files in directory
      final allEntities = await dir.list().toList();
      debugPrint('Total entities in directory: ${allEntities.length}');

      for (final entity in allEntities) {
        debugPrint('  Entity: ${entity.path} (${entity.runtimeType})');
      }

      // Filter audio files
      final files = <File>[];
      for (final entity in allEntities) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (ext == '.wav' || ext == '.mp3' || ext == '.m4a') {
            files.add(entity);
            debugPrint('  Audio file found: ${entity.path}');
          }
        }
      }

      debugPrint('Audio files found: ${files.length}');

      if (files.isEmpty) {
        _recordings = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Create Recording objects from files
      final recordingFutures = files.map((file) => Recording.fromFile(file));
      final recordings = await Future.wait(recordingFutures);

      _recordings = recordings.whereType<Recording>().toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Newest first

      debugPrint('Loaded ${_recordings.length} recordings');
      debugPrint('=== End Loading ===');

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error loading recordings: $e');
      debugPrint('Stack trace: $stackTrace');
      _recordings = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new recording after saving
  Future<Recording?> addRecording(String filePath, Duration duration) async {
    try {
      debugPrint('Adding recording: $filePath');

      final file = File(filePath);
      final exists = await file.exists();
      debugPrint('File exists: $exists');

      if (!exists) {
        debugPrint('Recording file does not exist: $filePath');
        return null;
      }

      final fileName = p.basenameWithoutExtension(filePath);
      final timestampStr = fileName.replaceFirst('recording_', '');
      final timestamp = int.tryParse(timestampStr);
      final date = timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : DateTime.now();

      final recording = Recording(
        id: fileName,
        title: Recording._generateTitle(date),
        filePath: filePath,
        date: date,
        duration: duration,
        hasSummary: false,
      );

      _recordings.insert(0, recording); // Add to top
      debugPrint('Added recording: ${recording.title}');
      debugPrint('Total recordings: ${_recordings.length}');
      notifyListeners();
      return recording;
    } catch (e) {
      debugPrint('Error adding recording: $e');
      return null;
    }
  }

  /// Delete a recording
  Future<bool> deleteRecording(String id) async {
    try {
      final recording = _recordings.firstWhere(
        (r) => r.id == id,
        orElse: () => throw Exception('Recording not found'),
      );

      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted file: ${recording.filePath}');
      }

      _recordings.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting recording: $e');
      return false;
    }
  }

  /// Get recording by ID
  Recording? getRecording(String id) {
    try {
      return _recordings.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Refresh recordings list
  Future<void> refresh() async {
    await loadRecordings();
  }
}
