import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'client_request.dart';
import '../models/login.dart';
import '../models/audio.dart';
import '../models/meeting.dart';
import '../models/transcript.dart';
class Repository {
  static Future<LoginResponse> login(String deviceId, String platform) async {
    final response = await clientRequest.post(
      'auth/device',
      data: {"deviceId": deviceId, "platform": platform},
    );

    print(response.data);

    return LoginResponse.fromJson(response.data['data']);
  }

  static Future<MeetingResponse> createMeeting(String title) async {
    final response = await clientRequest.post(
      'app-audio-note/meetings',
      data: {"title": title},
    );
    debugPrint(response.toString());

    return MeetingResponse.fromJson(response.data['data']);
  }

  static Future<List<MeetingResponse>> getMeetings(String? title) async {
      final query = (title != null && title.trim().isNotEmpty)
      ? '?title=${Uri.encodeQueryComponent(title)}'
      : '';
    final response = await clientRequest.get('app-audio-note/meetings$query');
    final List data = response.data['data'];
    return data.map((item) => MeetingResponse.fromJson(item)).toList();
  } 

  static Future<MeetingDetail> getMeetingDetail(String meetingId) async {
    final response = await clientRequest.get(
      'app-audio-note/meetings/$meetingId',
    );

    debugPrint(response.toString());

    return MeetingDetail.fromJson(response.data['data']);
  }

  static Future<AudioPresignedResponse> getPresignedUrl(
    String meetingId,
    String title,
    int duration,
  ) async {
    final response = await clientRequest.post(
      'app-audio-note/meetings/$meetingId/audio/upload-url',
      data: {
        "fileName": title,
        "contentType": "audio/mp4",
        "duration": duration,
      },
    );

    return AudioPresignedResponse.fromJson(response.data['data']);
  }

  static Future<int?> uploadAudio(String url, String filePath) async {
    final dio = Dio();
    final file = File(filePath);

    if (!await file.exists()) {
      debugPrint('File not found: $filePath');
      return null;
    }

    final fileBytes = await file.readAsBytes();
    final fileSize = fileBytes.length;

    final response = await dio.put(
      url,
      data: fileBytes, // Add the file data here!
      options: Options(
        headers: {
          'Content-Type': 'audio/mp4', // M4A files use audio/mp4
          'Content-Length': fileSize.toString(),
        },
      ),
    );

    debugPrint('Upload response: ${response.statusCode}');
    return response.statusCode;
  }

  static Future<AudioUploadResponse> confirm(String audioId) async {
    final response = await clientRequest.post(
      'app-audio-note/audios/$audioId/confirm',
    );

    debugPrint(response.toString());
    return AudioUploadResponse.fromJson(response.data['data']);
  }

  static Future<bool> delete(String id) async {
    final response = await clientRequest.delete('app-audio-note/meetings/$id');

    debugPrint(response.data['success'].toString());
    return response.data['success'];
  }

  static Future<MeetingResponse> rename(String id, String name) async {
    final response = await clientRequest.patch(
      'app-audio-note/meetings/$id',
      data: {"title": name},
    );

    debugPrint(response.data.toString());
    return MeetingResponse.fromJson(response.data['data']);
  }

  static Future<void> processTranscript(String id) async {
    debugPrint("Here is id: $id");
    final response = await clientRequest.post(
      'app-audio-note/meetings/$id/transcript',
    );

    debugPrint("processTranscript");
    debugPrint(response.data.toString());
  }

  static Future<String> status(String id) async {
    final response = await clientRequest.get(
      'app-audio-note/meetings/$id/status',
    );
    debugPrint(response.toString());

    return response.data['data']['status'];
  }

  static Future<SummaryTranscriptionResponse> getSummary(String id) async {
    final response = await clientRequest.get(
      'app-audio-note/meetings/$id/summary',
    );

  return SummaryTranscriptionResponse.fromJson(response.data['data']);
}
}
