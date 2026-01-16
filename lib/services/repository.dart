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

    return LoginResponse.fromJson(response.data['data']);
  }

  static Future<MeetingResponse> createMeeting(String title) async {
    final response = await clientRequest.post(
      'app-audio-note/meetings',
      data: {"title": title},
    );
    print(response);

    return MeetingResponse.fromJson(response.data['data']);
  }

  static Future<List<MeetingResponse>> getMeetings() async {
    final response = await clientRequest.get('app-audio-note/meetings');
    final List data = response.data['data'];
    return data.map((item) => MeetingResponse.fromJson(item)).toList();
  }

  static Future<MeetingDetail> getMeetingDetail(String meetingId) async {
    final response = await clientRequest.get(
      'app-audio-note/meetings/$meetingId',
    );

    print(response);

    return MeetingDetail.fromJson(response.data['data']);
  }

  static Future<AudioPresignedResponse> getPresignedUrl(
    String meetingId,
    String title,
    int fileSize,
  ) async {
    final response = await clientRequest.post(
      'app-audio-note/meetings/$meetingId/audio/upload-url',
      data: {
        "fileName": title,
        "contentType": "audio/mp4",
        "fileSize": fileSize,
      },
    );

    return AudioPresignedResponse.fromJson(response.data['data']);
  }

  static Future<int?> uploadAudio(String url, String filePath) async {
    final dio = Dio();
    final file = File(filePath);

    if (!await file.exists()) {
      print('File not found: $filePath');
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

    print('Upload response: ${response.statusCode}');
    return response.statusCode;
  }

  static Future<AudioUploadResponse> confirm(String audioId) async {
    final response = await clientRequest.post(
      'app-audio-note/audios/$audioId/confirm',
    );

    print(response);
    return AudioUploadResponse.fromJson(response.data['data']);
  }

  static Future<bool> delete(String id) async {
    final response = await clientRequest.delete('app-audio-note/meetings/$id');

    print(response.data['success']);
    return response.data['success'];
  }

  static Future<MeetingResponse> rename(String id, String name) async {
    final response = await clientRequest.patch(
      'app-audio-note/meetings/$id',
      data: {"title": name},
    );

    print(response.data);
    return MeetingResponse.fromJson(response.data['data']);
  }

  static Future<void> processTranscript(String id) async {
    print("Here is id: $id");
    final response = await clientRequest.post(
      'app-audio-note/meetings/$id/transcript',
    );

    print(response.data);
  }

  static Future<String> status(String id) async {
    final response = await clientRequest.get(
      'app-audio-note/meetings/$id/status',
    );
    print(response);

    return response.data['data']['status'];
  }

  static Future<List<TranscriptItem>> getTranscript(String id) async {
    final response = await clientRequest.get(
      'app-audio-note/meetings/$id/transcript',
    );

    final List data = response.data['data'];
    return data.map((item) => TranscriptItem.fromJson(item)).toList();
  }
}
