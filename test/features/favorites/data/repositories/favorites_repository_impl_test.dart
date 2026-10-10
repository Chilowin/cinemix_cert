import 'package:cinemix_cert/core/cache/cache_service.dart';
import 'package:cinemix_cert/features/catalog/data/models/media_item_model.dart';
import 'package:cinemix_cert/features/catalog/domain/entities/media_item.dart';
import 'package:cinemix_cert/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheService extends Mock implements CacheService {}

void main() {
  const key = 'favorites';
  const first = MediaItem(id: 1, title: 'Film A', overview: 'Résumé A');
  const second = MediaItem(id: 2, title: 'Film B', overview: 'Résumé B');

  final firstJson = MediaItemModel.fromEntity(first).toJson();
  final secondJson = MediaItemModel.fromEntity(second).toJson();

  late MockCacheService cache;
  late FavoritesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(Object());
  });

  setUp(() {
    cache = MockCacheService();
    repository = FavoritesRepositoryImpl(cache);
  });

  group('getAll', () {
    test('renvoie une liste vide quand rien n\'est enregistré', () async {
      when(() => cache.read(key)).thenReturn(null);

      expect(await repository.getAll(), isEmpty);
    });

    test('renvoie les favoris enregistrés', () async {
      when(() => cache.read(key)).thenReturn([firstJson, secondJson]);

      final result = await repository.getAll();

      expect(result.map((e) => e.id), [1, 2]);
      expect(result.map((e) => e.title), ['Film A', 'Film B']);
    });

    test('renvoie une liste vide quand le contenu est corrompu', () async {
      when(() => cache.read(key)).thenReturn([
        {'title': 'sans identifiant'},
      ]);

      expect(await repository.getAll(), isEmpty);
    });
  });

  group('add', () {
    test('place le nouveau favori en tête de liste', () async {
      final expected = [secondJson, firstJson];
      when(() => cache.read(key)).thenReturn([firstJson]);
      when(() => cache.write(key, expected)).thenAnswer((_) async {});

      await repository.add(second);

      verify(() => cache.write(key, expected)).called(1);
    });

    test('n\'enregistre pas deux fois le même favori', () async {
      when(() => cache.read(key)).thenReturn([firstJson]);

      await repository.add(first);

      verifyNever(() => cache.write(any(), any()));
    });
  });

  group('remove', () {
    test('retire le favori demandé', () async {
      final expected = [secondJson];
      when(() => cache.read(key)).thenReturn([firstJson, secondJson]);
      when(() => cache.write(key, expected)).thenAnswer((_) async {});

      await repository.remove(1);

      verify(() => cache.write(key, expected)).called(1);
    });
  });
}
