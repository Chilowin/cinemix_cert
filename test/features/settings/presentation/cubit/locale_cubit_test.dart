import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:cinemix_cert/core/cache/cache_service.dart';
import 'package:cinemix_cert/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheService extends Mock implements CacheService {}

void main() {
  const key = 'settings_locale';

  late MockCacheService cache;

  setUp(() {
    cache = MockCacheService();
  });

  group('état initial', () {
    test('restaure la langue enregistrée', () {
      when(() => cache.read(key)).thenReturn('en');

      expect(LocaleCubit(cache).state, const Locale('en'));
    });

    test('utilise la langue du système quand rien n\'est enregistré', () {
      when(() => cache.read(key)).thenReturn(null);

      expect(LocaleCubit(cache).state, isNull);
    });

    test('interprète la valeur system comme la langue du système', () {
      when(() => cache.read(key)).thenReturn('system');

      expect(LocaleCubit(cache).state, isNull);
    });
  });

  group('select', () {
    blocTest<LocaleCubit, Locale?>(
      'émet la langue choisie et l\'enregistre',
      build: () {
        when(() => cache.read(key)).thenReturn(null);
        when(() => cache.write(key, 'fr')).thenAnswer((_) async {});
        return LocaleCubit(cache);
      },
      act: (cubit) => cubit.select(const Locale('fr')),
      expect: () => [const Locale('fr')],
      verify: (_) {
        verify(() => cache.write(key, 'fr')).called(1);
      },
    );

    blocTest<LocaleCubit, Locale?>(
      'revient à la langue du système et l\'enregistre',
      build: () {
        when(() => cache.read(key)).thenReturn('en');
        when(() => cache.write(key, 'system')).thenAnswer((_) async {});
        return LocaleCubit(cache);
      },
      act: (cubit) => cubit.select(null),
      expect: () => [isNull],
      verify: (_) {
        verify(() => cache.write(key, 'system')).called(1);
      },
    );
  });
}
