class TranscriptItem {
  final String id;
  final String meetingId;
  final String transcriptId;
  final String speaker;
  final String text;
  final double startTime;
  final double endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TranscriptItem({
    required this.id,
    required this.meetingId,
    required this.transcriptId,
    required this.speaker,
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TranscriptItem.fromJson(Map<String, dynamic> json) {
    return TranscriptItem(
      id: json['_id'] ?? '',
      meetingId: json['meetingId'] ?? '',
      transcriptId: json['transcriptId'] ?? '',
      speaker: json['speaker'] ?? 'Unknown',
      text: json['text'] ?? '',
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Duration get startDuration =>
      Duration(milliseconds: (startTime * 1000).toInt());
  Duration get endDuration => Duration(milliseconds: (endTime * 1000).toInt());
  Duration get duration =>
      Duration(milliseconds: ((endTime - startTime) * 1000).toInt());

  // For formatted time display
  String get formattedStartTime {
    final minutes = (startTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (startTime % 60).toStringAsFixed(0).padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedEndTime {
    final minutes = (endTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (endTime % 60).toStringAsFixed(0).padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

// models/summary.dart
class SummaryTranscriptionResponse {
  final String id;
  final String meetingId;
  final String transcriptId;
  final String content;
  final String type; // "bullets", "paragraph", etc.
  final String model; // "assemblyai", "gpt", etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  const SummaryTranscriptionResponse({
    required this.id,
    required this.meetingId,
    required this.transcriptId,
    required this.content,
    required this.type,
    required this.model,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SummaryTranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SummaryTranscriptionResponse(
      id: json['_id'] ?? '',
      meetingId: json['meetingId'] ?? '',
      transcriptId: json['transcriptId'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'bullets',
      model: json['model'] ?? 'assemblyai',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
