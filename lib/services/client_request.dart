import 'package:dio/dio.dart';

import '../constants/urls.dart';
import 'storage.dart';
import 'device.dart';


final Dio clientRequest = Dio(
  BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'x-app-code': 'audio_note_1', // add your app code here
    }
  )
)..interceptors.add(
  InterceptorsWrapper(
    onError: (DioException e, handler) async {
      if (e.response?.statusCode == 401) {
        try {      

  final response = await DeviceService.login();


  await StorageService.set(
    AppStorageKeys.accessToken,
    response.accessToken,
  );

  setAuthToken(response.accessToken);
          

          // 🔁 retry original request
          final requestOptions = e.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $response.accessToken';

          final resp = await clientRequest.fetch(requestOptions);
          return handler.resolve(resp);
        } catch (_) {
           await StorageService.remove(AppStorageKeys.accessToken);
        }
      }
    }
  )
);


void setAuthToken(String token) {
    clientRequest.options.headers['Authorization'] = 'Bearer $token';
}

