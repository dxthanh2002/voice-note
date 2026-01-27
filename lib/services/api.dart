import 'package:dio/dio.dart';

import '../utils/constants.dart';
import '../utils/console.dart';
import 'device.dart';
import 'storage.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Console.log('''
        🚀 REQUEST:
        ${options.method} ${options.uri}
        --Headers: ${options.headers}
        --Data: ${options.data}
        --Query: ${options.queryParameters}
  ''');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Console.log('''
        ✅ RESPONSE:
        --Status: ${response.statusCode}
        --Data: ${response.data}
    ''');
    // JsonEncoder.withIndent('  ').convert

    // Headers: ${response.headers}
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    Console.error('''
        ❌ API ERROR:
        --Status: ${err.response?.statusCode}
        --Error: ${err.message}
    ''', err.stackTrace);

    if (err.response?.statusCode == 401) {
      Console.log("HII");
      Console.log("HII");
      Console.log("HII");
      try {
        final response = await DeviceService.login(APP_CODE);

        await StorageService.set(
          AppStorageKeys.accessToken,
          response.accessToken,
        );

        // set token header
        api.options.headers['Authorization'] = 'Bearer ${response.accessToken}';

        // 🔁 retry original request
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] =
            'Bearer ${response.accessToken}';
        // set for retry ?

        final resp = await api.fetch(requestOptions);
        return handler.resolve(resp);
      } catch (_) {
        await StorageService.remove(AppStorageKeys.accessToken);
      }
    }

    handler.next(err);
  }
}

final api = Dio(
  BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ),
)..interceptors.add(LoggingInterceptor());
