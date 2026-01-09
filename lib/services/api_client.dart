import 'package:dio/dio.dart';

import '../constants/urls.dart';

final Dio apiClient = Dio(
  BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ),
);

void setApiToken(String? token) {
  if (token != null && token.isNotEmpty) {
    apiClient.options.headers['token'] = token;
  } else {
    apiClient.options.headers.remove('token');
  }
}
