import 'dart:async';

import 'package:dio/dio.dart';

import '../utils/constants.dart';
import '../utils/console.dart';
import 'device.dart';
import 'repository.dart';
import 'storage.dart';

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  final Completer<void> completer;

  _PendingRequest({
    required this.options,
    required this.handler,
    required this.completer,
  });
}

class LoggingInterceptor extends Interceptor {
  bool _refreshing = false;
  final List<Completer<void>> _refreshCompleters = [];
  final List<_PendingRequest> _pendingRequests = [];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    Console.error('''
        ❌ API ERROR:
        --Status: ${err.response?.statusCode}
        --Error: ${err.message}
    ''', err.stackTrace);

    if (err.response?.statusCode == 401) {
      Console.log("🔐 TOKEN EXPIRED FOR: ${err.requestOptions.uri}");

      final completer = Completer<void>();
      _pendingRequests.add(
        _PendingRequest(
          options: err.requestOptions,
          handler: handler,
          completer: completer,
        ),
      );

      if (!_refreshing) {
        _refreshing = true;
        _refreshToken();
      }

      // pause
      await completer.future;

      return;
    }
    handler.next(err);
  }

  Future<void> _refreshToken() async {
    try {
      await StorageService.remove(AppStorageKeys.accessToken);

      final deviceId = await DeviceService.getId();
      final platform = DeviceService.getPlatform();

      final response = await Repository.login(deviceId, platform, APP_CODE);
      final newToken = response.accessToken;

      if (newToken.isNotEmpty) {
        Console.log("NEWWWW $newToken");

        await StorageService.set(AppStorageKeys.accessToken, newToken);
        api.options.headers['Authorization'] = "Bearer $newToken";

        await _retryPendingRequests(newToken);
      }
    } catch (e) {
      Console.log("ERROR WHEN REFRESH TOKEN");
    } finally {
      _pendingRequests.clear();
      _refreshCompleters.clear();
      _refreshing = false;
    }
  }

  Future<void> _retryPendingRequests(String newToken) async {
    Console.log("🔄 Retrying ${_pendingRequests.length} pending requests...");

    final List<Future<void>> retryFutures = [];

    for (final pending in _pendingRequests) {
      retryFutures.add(_retryRequest(pending, newToken));
    }

    await Future.wait(retryFutures);
  }

  Future<void> _retryRequest(_PendingRequest pending, String newToken) async {
    final options = pending.options.copyWith(
      headers: {
        ...pending.options.headers,
        'Authorization': 'Bearer $newToken',
      },
    );
    final retryResponse = await api.fetch(options);

    // Complete the completer
    pending.completer.complete();

    // Resolve the original handler with successful response
    pending.handler.resolve(retryResponse);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Console.log(
      "🚀 ${response.requestOptions.method} ${response.requestOptions.path}  ✅ ${response.statusCode}",
    );

    Console.logPreview('REQUEST', response.requestOptions.data);
    Console.logPreview('RESPONSE', response.data);

    handler.next(response);
  }
}

final api = Dio(
  BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ),
)..interceptors.add(LoggingInterceptor());
