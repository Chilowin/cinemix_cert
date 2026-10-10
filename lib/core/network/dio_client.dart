import 'package:dio/dio.dart';

import 'token_provider.dart';

const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
const String tokenHeader = 'X-Firebase-Token';

typedef SessionExpiredCallback = Future<void> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenProvider,
    required this.dio,
    this.onSessionExpired,
  });

  final TokenProvider tokenProvider;
  final Dio dio;
  final SessionExpiredCallback? onSessionExpired;

  static const String _retryKey = 'auth_retried';

  Future<String?> _readToken({bool forceRefresh = false}) async {
    try {
      return await tokenProvider.getToken(forceRefresh: forceRefresh);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _readToken();
    if (token != null) {
      options.headers[tokenHeader] = token;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final alreadyRetried = request.extra[_retryKey] == true;

    if (err.response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    final token = await _readToken(forceRefresh: true);
    if (token == null) {
      await onSessionExpired?.call();
      handler.next(err);
      return;
    }

    request.extra[_retryKey] = true;
    request.headers[tokenHeader] = token;

    try {
      final response = await dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

Dio createDio({
  required TokenProvider tokenProvider,
  required String apiKey,
  bool attachToken = true,
  SessionExpiredCallback? onSessionExpired,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: tmdbBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      queryParameters: {'api_key': apiKey, 'language': 'fr-FR'},
    ),
  );
  if (attachToken) {
    dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: tokenProvider,
        dio: dio,
        onSessionExpired: onSessionExpired,
      ),
    );
  }
  return dio;
}
/*
Dio createDio({
  required TokenProvider tokenProvider,
  required String apiKey,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: tmdbBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      queryParameters: {'api_key': apiKey, 'language': 'fr-FR'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(tokenProvider: tokenProvider, dio: dio));
  return dio;
}*/
