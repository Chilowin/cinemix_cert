import 'package:dio/dio.dart';

import 'token_provider.dart';

const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
const String tokenHeader = 'X-Firebase-Token';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenProvider, required this.dio});

  final TokenProvider tokenProvider;
  final Dio dio;

  static const String _retryKey = 'auth_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider.getToken();
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

    final token = await tokenProvider.getToken(forceRefresh: true);
    if (token == null) {
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
Dio createDio({
  required TokenProvider tokenProvider,
  required String apiKey,
  bool attachToken = true,
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
      AuthInterceptor(tokenProvider: tokenProvider, dio: dio),
    );
  }
  return dio;
}
