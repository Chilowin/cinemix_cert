import 'package:bloc_test/bloc_test.dart';
import 'package:cinemix_cert/features/catalog/domain/entities/media_item.dart';
import 'package:cinemix_cert/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:cinemix_cert/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  const item = MediaItem(id: 1, title: 'Film A', overview: 'Résumé A');

  late MockFavoritesRepository repository;

  setUp(() {
    repository = MockFavoritesRepository();
  });

  blocTest<FavoritesCubit, List<MediaItem>>(
    'load émet les favoris enregistrés',
    build: () {
      when(() => repository.getAll()).thenAnswer((_) async => [item]);
      return FavoritesCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      [item],
    ],
  );

  blocTest<FavoritesCubit, List<MediaItem>>(
    'toggle ajoute un titre absent des favoris',
    build: () {
      when(() => repository.add(item)).thenAnswer((_) async {});
      when(() => repository.getAll()).thenAnswer((_) async => [item]);
      return FavoritesCubit(repository);
    },
    act: (cubit) => cubit.toggle(item),
    expect: () => [
      [item],
    ],
    verify: (_) {
      verify(() => repository.add(item)).called(1);
      verifyNever(() => repository.remove(any()));
    },
  );

  blocTest<FavoritesCubit, List<MediaItem>>(
    'toggle retire un titre déjà présent',
    build: () {
      when(() => repository.remove(1)).thenAnswer((_) async {});
      when(() => repository.getAll()).thenAnswer((_) async => []);
      return FavoritesCubit(repository);
    },
    seed: () => [item],
    act: (cubit) => cubit.toggle(item),
    expect: () => [isEmpty],
    verify: (_) {
      verify(() => repository.remove(1)).called(1);
    },
  );
}
