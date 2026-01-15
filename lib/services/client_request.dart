import 'package:dio/dio.dart';

import '../constants/urls.dart';

final Dio clientRequest = Dio(
  BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'x-app-code': 'audio_note_1', // add your app code here
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2OTVlMmE2NTQ3N2E5ZmU1ZTBjOWNhMzciLCJhcHBJZCI6IjY5NWUxZGFhNGNmY2FhMzMyNjIwY2Q2ZSIsImRldmljZUlkIjoiMTIzMjMiLCJpYXQiOjE3Njg0NjgyNTUsImV4cCI6MTc2OTA3MzA1NX0.x2ZpxMuIRleXUmmqysoB5vIVkCrOkYJwqK9frYLZQxI',
    },
  ),
);

void setAuthToken(String? token) {
  if (token != null && token.isNotEmpty) {
    print("hi");
    clientRequest.options.headers['Authorization'] = 'Bearer $token';
  }

  print('=== Current Headers ===');
  clientRequest.options.headers.forEach((key, value) {
    print('$key: $value');
  });
  print('=======================');
}
