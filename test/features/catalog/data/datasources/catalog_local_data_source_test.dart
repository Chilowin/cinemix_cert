import 'package:cinemix_cert/core/cache/cache_service.dart';
import 'package:cinemix_cert/features/catalog/data/datasources/catalog_local_data_source.dart';
import 'package:cinemix_cert/features/catalog/data/models/media_item_model.dart';
import 'package:cinemix_cert/features/catalog/domain/entities/media_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheService extends Mock implements CacheService {}

void main() {
  const category = MediaCategory.popularMovies;
  const key = 'catalog_popularMovies';
  const item = MediaItemModel(id: 1, title: 'Film A', overview: 'Résumé A');

  late MockCacheService cache;
  late CatalogLocalDataSource dataSource;

  setUp(() {
    cache = MockCacheService();
    dataSource = CatalogLocalDataSource(cache);
  });

  group('save', () {
    test('écrit la liste au format JSON sous la clé de la catégorie', () async {
      final expected = [item.toJson()];
      when(() => cache.write(key, expected)).thenAnswer((_) async {});

      await dataSource.save(category, const [item]);

      verify(() => cache.write(key, expected)).called(1);
    });
  });

  group('read', () {
    test('reconstruit les éléments enregistrés', () {
      when(() => cache.read(key)).thenReturn([item.toJson()]);

      expect(dataSource.read(category), const [item]);
    });

    test('renvoie null quand rien n\'est enregistré', () {
      when(() => cache.read(key)).thenReturn(null);

      expect(dataSource.read(category), isNull);
    });

    test('renvoie null quand la valeur n\'est pas une liste', () {
      when(() => cache.read(key)).thenReturn('texte');

      expect(dataSource.read(category), isNull);
    });

    test('renvoie null quand le contenu est corrompu', () {
      when(() => cache.read(key)).thenReturn([
        {'title': 'sans identifiant'},
      ]);

      expect(dataSource.read(category), isNull);
    });
  });
}
