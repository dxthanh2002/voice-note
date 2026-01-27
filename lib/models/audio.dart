class AudioPresigned {
  final String audioId;
  final String url;
  final String method; // "PUT" or "POST"
  final String bucket;
  final String key;
  final int expiresIn; // in seconds

  const AudioPresigned({
    required this.audioId,
    required this.url,
    required this.method,
    required this.bucket,
    required this.key,
    required this.expiresIn,
  });

  factory AudioPresigned.fromJson(Map<String, dynamic> json) {
    return AudioPresigned(
      audioId: json['audioId'] ?? '',
      url: json['url'] ?? '',
      method: json['method'] ?? 'PUT',
      bucket: json['bucket'] ?? '',
      key: json['key'] ?? '',
      expiresIn: json['expiresIn'] ?? 300,
    );
  }

  // Helper to get the filename from the key
  String get fileName {
    final parts = key.split('/');
    return parts.isNotEmpty ? parts.last : '';
  }

  // Helper to get expiration time
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));

  // Get formatted expiration time
}

class AudioUploadResponse {
  final String id;
  final String meetingId;
  final String s3Key;
  final String bucket;
  final String contentType;
  final int size; // in bytes
  final String status; // "UPLOADED", "PROCESSING", etc.
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  const AudioUploadResponse({
    required this.id,
    required this.meetingId,
    required this.s3Key,
    required this.bucket,
    required this.contentType,
    required this.size,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory AudioUploadResponse.fromJson(Map<String, dynamic> json) {
    return AudioUploadResponse(
      id: json['_id'] ?? '',
      meetingId: json['meetingId'] ?? '',
      s3Key: json['s3Key'] ?? '',
      bucket: json['bucket'] ?? '',
      contentType: json['contentType'] ?? 'audio/mpeg',
      size: json['size'] ?? 0,
      status: json['status'] ?? 'UPLOADED',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'] ?? 0,
    );
  }

  Duration get duration {
    if (size <= 0) return Duration.zero;

    // Formula: Duration (seconds) = File Size (bytes) * 8 / (Bitrate (kbps) * 1000)
    // For AAC-LC at 128 kbps
    final bitrate = 128000; // 128 kbps in bits per second
    final seconds = (size * 8) / bitrate;
    return Duration(seconds: seconds.floor());
  }
}

class AudioInfo {
  final String id;
  final String playUrl;
  final int size;
  final int duration;

  const AudioInfo({
    required this.id,
    required this.playUrl,
    required this.size,
    required this.duration,
  });

  factory AudioInfo.fromJson(Map<String, dynamic> json) {
    return AudioInfo(
      id: json['id'] ?? '',
      playUrl: json['playUrl'] ?? '',
      size: json['size'] ?? 0,
      duration: json['duration'] ?? 0,
    );
  }

  Duration get durationObj => Duration(microseconds: duration);
}
