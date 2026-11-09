// lib/features/admin_web/shared/data/api_client.dart
// Dio-based HTTP client with:
//   - Authorization Bearer token injection
//   - Automatic token refresh on 401
//   - Typed exception mapping
//   - Configurable timeout and retry
//
// Web note: flutter_secure_storage uses localStorage on web (not keystore).
// This is a known limitation. See docs/backend/BACKEND_HANDOFF.md for details.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../../../app_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient._({required this.dio, required this.tokenStorage});

  final Dio dio;
  final TokenStorage tokenStorage;

  static ApiClient? _instance;

  static ApiClient get instance {
    _instance ??= _create();
    return _instance!;
  }

  static ApiClient _create() {
    final storage = TokenStorage(const FlutterSecureStorage());
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final client = ApiClient._(dio: dio, tokenStorage: storage);

    dio.interceptors.addAll([
      _AuthInterceptor(client),
      _ErrorInterceptor(),
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => debugPrint('[ApiClient] $obj'),
      ),
    ]);

    return client;
  }

  /// Resets the singleton — useful for testing
  static void reset() => _instance = null;
}

// ─── Auth Interceptor ───────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._client);

  final ApiClient _client;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _client.tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _client.tokenStorage.getRefreshToken();
        if (refreshToken == null) {
          _isRefreshing = false;
          handler.next(err);
          return;
        }

        // Attempt token refresh
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout:
                Duration(seconds: AppConfig.connectTimeoutSeconds),
          ),
        );
        final res = await refreshDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = res.data['data']['access_token'] as String;
        final newRefreshToken = res.data['data']['refresh_token'] as String;
        await _client.tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Retry original request
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryRes = await _client.dio.fetch(opts);
        _isRefreshing = false;
        handler.resolve(retryRes);
      } catch (_) {
        _isRefreshing = false;
        await _client.tokenStorage.clearTokens();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}

// ─── Error Interceptor ──────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) {
      final errorBody = response.data;
      if (errorBody is Map && errorBody.containsKey('error')) {
        final e = errorBody['error'] as Map;
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: response,
            error: ApiException(
              code: e['code']?.toString() ?? 'UNKNOWN',
              message: e['message']?.toString() ?? 'Terjadi kesalahan',
              fields: (e['fields'] as Map<String, dynamic>?) ?? {},
              statusCode: response.statusCode ?? 0,
            ),
          ),
        );
        return;
      }
    }

    final mapped = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        ApiException(
          code: 'TIMEOUT',
          message: 'Koneksi timeout. Periksa jaringan Anda.',
          statusCode: 0,
        ),
      DioExceptionType.connectionError => ApiException(
          code: 'NETWORK_ERROR',
          message: 'Tidak dapat terhubung ke server.',
          statusCode: 0,
        ),
      _ => ApiException(
          code: 'UNKNOWN',
          message: err.message ?? 'Terjadi kesalahan',
          statusCode: response?.statusCode ?? 0,
        ),
    };

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: response,
        error: mapped,
      ),
    );
  }
}
