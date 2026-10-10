import 'dart:typed_data';

import 'package:cinemix_cert/core/network/dio_client.dart';
import 'package:cinemix_cert/core/network/token_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.statusCodes);

  final List<int> statusCodes;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final status = statusCodes[requests.length - 1];
    return ResponseBody.fromString(
      '{}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class FakeTokenProvider implements TokenProvider {
  FakeTokenProvider({String? refreshed = 'new-token'}) : _refreshed = refreshed;

  final String? _refreshed;
  String? _current = 'old-token';
  int refreshCalls = 0;

  @override
  Future<String?> getToken({bool forceRefresh = false}) async {
    if (forceRefresh) {
      refreshCalls++;
      _current = _refreshed;
    }
    return _current;
  }
}

Dio buildDio(
  FakeAdapter adapter,
  TokenProvider provider, {
  SessionExpiredCallback? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    AuthInterceptor(
      tokenProvider: provider,
      dio: dio,
      onSessionExpired: onSessionExpired,
    ),
  );
  return dio;
}

void main() {
  group('AuthInterceptor', () {
    test('ajoute le token à chaque requête', () async {
      final adapter = FakeAdapter([200]);
      final dio = buildDio(adapter, FakeTokenProvider());

      await dio.get<dynamic>('/items');

      expect(adapter.requests.single.headers[tokenHeader], 'old-token');
    });

    test('renouvelle le token et rejoue la requête après un 401', () async {
      final adapter = FakeAdapter([401, 200]);
      final provider = FakeTokenProvider();
      final dio = buildDio(adapter, provider);

      final response = await dio.get<dynamic>('/items');

      expect(response.statusCode, 200);
      expect(provider.refreshCalls, 1);
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests.last.headers[tokenHeader], 'new-token');
    });

    test('ne rejoue la requête qu\'une seule fois', () async {
      final adapter = FakeAdapter([401, 401]);
      final provider = FakeTokenProvider();
      final dio = buildDio(adapter, provider);

      await expectLater(
        dio.get<dynamic>('/items'),
        throwsA(isA<DioException>()),
      );

      expect(adapter.requests, hasLength(2));
      expect(provider.refreshCalls, 1);
    });

    test('déclenche la fin de session si le renouvellement est impossible',
        () async {
      final adapter = FakeAdapter([401]);
      final provider = FakeTokenProvider(refreshed: null);
      var expiredCalls = 0;
      final dio = buildDio(
        adapter,
        provider,
        onSessionExpired: () async => expiredCalls++,
      );

      await expectLater(
        dio.get<dynamic>('/items'),
        throwsA(isA<DioException>()),
      );

      expect(expiredCalls, 1);
      expect(adapter.requests, hasLength(1));
    });

    test('ne tente pas de renouvellement pour une erreur autre que 401',
        () async {
      final adapter = FakeAdapter([500]);
      final provider = FakeTokenProvider();
      final dio = buildDio(adapter, provider);

      await expectLater(
        dio.get<dynamic>('/items'),
        throwsA(isA<DioException>()),
      );

      expect(provider.refreshCalls, 0);
    });
  });
}
