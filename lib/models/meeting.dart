import 'audio.dart';
import 'transcript.dart';

class MeetingResponse {
  final String id;
  final String userId;
  final String appId;
  final String title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String status;
  final String transcriptStatus;
  final String summaryStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AudioMeetingResponse? audio;

  const MeetingResponse({
    required this.id,
    required this.userId,
    required this.appId,
    required this.title,
    required this.startedAt,
    this.endedAt,
    required this.status,
    required this.transcriptStatus,
    required this.summaryStatus,
    required this.createdAt,
    required this.updatedAt,
    this.audio,
  });

  factory MeetingResponse.fromJson(Map<String, dynamic> json) {
    return MeetingResponse(
      id: json['_id'],
      userId: json['userId'],
      appId: json['appId'],
      title: json['title'],
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      status: json['status'],
      transcriptStatus: json['transcriptStatus'],
      summaryStatus: json['summaryStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      audio: json['audio'] != null
          ? AudioMeetingResponse.fromJson(json['audio'] as Map<String, dynamic>)
          : null,
    );
  }

  Duration? get duration {
    if (endedAt == null) return null;
    return endedAt!.difference(startedAt);
  }

  bool get isRecording => status == 'RECORDING';

  bool get hasSummary => summaryStatus == 'DONE';
}

class AudioMeetingResponse {
  final String id;
  final int size; // in bytes
  final int? duration; // optional format (m4a, mp3, etc.)

  const AudioMeetingResponse({
    required this.id,
    required this.size,
    this.duration,
  });

  factory AudioMeetingResponse.fromJson(Map<String, dynamic> json) {
    return AudioMeetingResponse(
      id: json['_id'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      duration: json['duration'] as int?,
    );
  }

  Duration? get durationObject {
    if (duration == null) return null;
    return Duration(seconds: duration!);
  }
}

class MeetingDetail {
  final MeetingResponse meeting;
  final AudioInfo? audio;
  final List<TranscriptItem> transcripts;

  const MeetingDetail({
    required this.meeting,
    this.audio,
    required this.transcripts,
  });

  factory MeetingDetail.fromJson(Map<String, dynamic> json) {
    return MeetingDetail(
      meeting: MeetingResponse.fromJson(json['meeting']),
      // Use the SEPARATE audio object (not the one inside meeting)
      audio: json['audio'] != null ? AudioInfo.fromJson(json['audio']!) : null,
      transcripts:
          (json['transcripts'] as List?)
              ?.map((item) => TranscriptItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}
