import 'package:bloc_test/bloc_test.dart';
import 'package:cinemix_cert/core/error/failure.dart';
import 'package:cinemix_cert/features/catalog/domain/entities/catalog_result.dart';
import 'package:cinemix_cert/features/catalog/domain/entities/media_category.dart';
import 'package:cinemix_cert/features/catalog/domain/entities/media_item.dart';
import 'package:cinemix_cert/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:cinemix_cert/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  const category = MediaCategory.popularMovies;
  const items = <MediaItem>[
    MediaItem(id: 1, title: 'Film A', overview: 'Resume A'),
    MediaItem(id: 2, title: 'Film B', overview: 'Resume B'),
  ];

  late MockCatalogRepository repository;

  setUp(() {
    repository = MockCatalogRepository();
  });

  group('CatalogCubit.load', () {
    blocTest<CatalogCubit, CatalogState>(
      'émet le chargement puis les données en cas de succès',
      build: () {
        when(() => repository.getItems(category))
            .thenAnswer((_) async => const CatalogResult(items: items));
        return CatalogCubit(repository, category);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const CatalogState(),
        const CatalogState(status: CatalogStatus.success, items: items),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'signale les données issues du cache avec le message d\'erreur',
      build: () {
        when(() => repository.getItems(category)).thenAnswer(
          (_) async => const CatalogResult(
            items: items,
            failure: NetworkFailure(),
          ),
        );
        return CatalogCubit(repository, category);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const CatalogState(),
        const CatalogState(
          status: CatalogStatus.success,
          items: items,
          isFromCache: true,
          failure: NetworkFailure(),
        ),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'émet un échec avec le message de l\'erreur métier',
      build: () {
        when(() => repository.getItems(category)).thenAnswer(
          (_) async => throw const ServerFailure('Erreur serveur (code 500).'),
        );
        return CatalogCubit(repository, category);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const CatalogState(),
        const CatalogState(
          status: CatalogStatus.failure,
          failure: ServerFailure('Erreur serveur (code 500).'),
        ),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'conserve les éléments déjà affichés quand le rafraîchissement échoue',
      build: () {
        when(() => repository.getItems(category)).thenAnswer(
          (_) async => throw const NetworkFailure(),
        );
        return CatalogCubit(repository, category);
      },
      seed: () =>
          const CatalogState(status: CatalogStatus.success, items: items),
      act: (cubit) => cubit.load(),
      expect: () => [
        const CatalogState(status: CatalogStatus.loading, items: items),
        const CatalogState(
          status: CatalogStatus.failure,
          items: items,
          failure: NetworkFailure(),
        ),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'convertit une exception inattendue en message générique',
      build: () {
        when(() => repository.getItems(category))
            .thenAnswer((_) async => throw StateError('erreur imprévue'));
        return CatalogCubit(repository, category);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const CatalogState(),
        const CatalogState(
          status: CatalogStatus.failure,
          failure: UnknownFailure(),
        ),
      ],
    );
  });
}
