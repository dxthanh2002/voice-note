import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import '../utils/console.dart';
import 'api.dart';
import '../models/login.dart';
import '../models/audio.dart';
import '../models/meeting.dart';
import '../models/transcript.dart';

class Repository {
  static Future<LoginResponse> login(
    String deviceId,
    String platform,
    String appCode,
  ) async {
    final response = await api.post(
      'auth/device',
      data: {"deviceId": deviceId, "platform": platform, "appCode": appCode},
    );

    return LoginResponse.fromJson(response.data['data']);
  }

  static Future<MeetingResponse> createMeeting(String title) async {
    final response = await api.post(
      'app-audio-note/meetings',
      data: {"title": title},
    );

    Console.log("CREATINGGGG");

    return MeetingResponse.fromJson(response.data['data']);
  }

  static Future<List<MeetingResponse>> getMeetings(String? title) async {
    final query = (title != null && title.trim().isNotEmpty)
        ? '?title=${Uri.encodeQueryComponent(title)}'
        : '';
    final response = await api.get('app-audio-note/meetings$query');
    final List data = response.data['data'];
    return data.map((item) => MeetingResponse.fromJson(item)).toList();
  }

  static Future<MeetingDetail> getMeetingbyId(String meetingId) async {
    final response = await api.get('app-audio-note/meetings/$meetingId');

    return MeetingDetail.fromJson(response.data['data']);
  }

  static Future<AudioPresigned> getPresignedUrl(
    String meetingId,
    String title,
    int duration,
  ) async {
    final response = await api.post(
      'app-audio-note/meetings/$meetingId/audio/upload-url',
      data: {
        "fileName": title,
        "contentType": "audio/mp4",
        "duration": duration,
      },
    );

    return AudioPresigned.fromJson(response.data['data']);
  }

  static Future<int?> uploadAudioToServer(String url, String filePath) async {
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

    return response.statusCode;
  }

  static Future<AudioUploadResponse> confirm(String audioId) async {
    final response = await api.post('app-audio-note/audios/$audioId/confirm');

    return AudioUploadResponse.fromJson(response.data['data']);
  }

  static Future<bool> deleteMeeting(String id) async {
    final response = await api.delete('app-audio-note/meetings/$id');

    return response.data['success'];
  }

  static Future<MeetingResponse> rename(String id, String name) async {
    final response = await api.patch(
      'app-audio-note/meetings/$id',
      data: {"title": name},
    );

    return MeetingResponse.fromJson(response.data['data']);
  }

  // static Future<void> processTranscript(String id) async {
  //   await api.post('app-audio-note/meetings/$id/transcript');
  // }

  static Future<String> status(String id) async {
    final response = await api.get('app-audio-note/meetings/$id/status');

    return response.data['data']['status'];
  }

  static Future<SummaryTranscriptionResponse> getSummary(String id) async {
    final response = await api.get('app-audio-note/meetings/$id/summary');

    return SummaryTranscriptionResponse.fromJson(response.data['data']);
  }
}
