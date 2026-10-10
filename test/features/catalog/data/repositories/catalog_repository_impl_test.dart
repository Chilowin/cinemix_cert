import 'package:cinemix_cert/core/error/failure.dart';
import 'package:cinemix_cert/features/catalog/data/datasources/catalog_local_data_source.dart';
import 'package:cinemix_cert/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:cinemix_cert/features/catalog/data/models/media_item_model.dart';
import 'package:cinemix_cert/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:cinemix_cert/features/catalog/domain/entities/media_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock implements CatalogRemoteDataSource {}

class MockLocalDataSource extends Mock implements CatalogLocalDataSource {}

void main() {
  const category = MediaCategory.popularMovies;
  const items = <MediaItemModel>[
    MediaItemModel(id: 1, title: 'Film A', overview: 'Resume A'),
    MediaItemModel(id: 2, title: 'Film B', overview: 'Resume B'),
  ];

  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late CatalogRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(MediaCategory.popularMovies);
    registerFallbackValue(<MediaItemModel>[]);
  });

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    repository = CatalogRepositoryImpl(remote: remote, local: local);
  });

  group('CatalogRepositoryImpl.getItems', () {
    test('retourne les données distantes et les enregistre en cache', () async {
      when(() => remote.fetch(category)).thenAnswer((_) async => items);
      when(() => local.save(category, items)).thenAnswer((_) async {});

      final result = await repository.getItems(category);

      expect(result.items, items);
      expect(result.isFromCache, isFalse);
      expect(result.failure, isNull);
      verify(() => local.save(category, items)).called(1);
    });

    test('retourne le cache avec l\'erreur quand le réseau échoue', () async {
      const failure = NetworkFailure();
      when(() => remote.fetch(category)).thenAnswer((_) async => throw failure);
      when(() => local.read(category)).thenReturn(items);

      final result = await repository.getItems(category);

      expect(result.items, items);
      expect(result.isFromCache, isTrue);
      expect(result.failure, failure);
      verifyNever(() => local.save(any(), any()));
    });

    test('propage l\'erreur quand le réseau échoue et que le cache est absent',
        () async {
      const failure = ServerFailure('Erreur serveur (code 500).');
      when(() => remote.fetch(category)).thenAnswer((_) async => throw failure);
      when(() => local.read(category)).thenReturn(null);

      expect(repository.getItems(category), throwsA(failure));
    });

    test('propage l\'erreur quand le cache est vide', () async {
      const failure = NetworkFailure();
      when(() => remote.fetch(category)).thenAnswer((_) async => throw failure);
      when(() => local.read(category)).thenReturn(<MediaItemModel>[]);

      expect(repository.getItems(category), throwsA(failure));
    });
  });
}
