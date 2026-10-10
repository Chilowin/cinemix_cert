import 'package:cinemix_cert/core/error/failure.dart';
import 'package:cinemix_cert/features/catalog/domain/entities/catalog_result.dart';
import 'package:cinemix_cert/features/catalog/domain/entities/media_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const item = MediaItem(id: 1, title: 'Film A', overview: 'Résumé A');

  group('CatalogResult', () {
    test('n\'est pas issu du cache quand aucune erreur n\'est associée', () {
      const result = CatalogResult(items: [item]);

      expect(result.isFromCache, isFalse);
    });

    test('est issu du cache quand une erreur est associée', () {
      const result = CatalogResult(items: [item], failure: NetworkFailure());

      expect(result.isFromCache, isTrue);
    });
  });

  group('MediaItem', () {
    test('n\'a pas d\'adresse d\'affiche sans chemin', () {
      expect(item.posterUrl, isNull);
    });

    test('construit l\'adresse de l\'affiche à partir du chemin', () {
      const withPoster = MediaItem(
        id: 2,
        title: 'Film B',
        overview: 'Résumé B',
        posterPath: '/b.jpg',
      );

      expect(withPoster.posterUrl, 'https://image.tmdb.org/t/p/w342/b.jpg');
    });

    test('compare deux éléments par leurs valeurs', () {
      const same = MediaItem(id: 1, title: 'Film A', overview: 'Résumé A');

      expect(item, same);
      expect(item, isNot(const MediaItem(id: 9, title: 'X', overview: 'Y')));
    });
  });

  group('Failure', () {
    test('deux erreurs identiques sont égales', () {
      expect(const NetworkFailure(), const NetworkFailure());
    });

    test('deux types d\'erreur différents ne sont pas égaux', () {
      expect(const NetworkFailure('x'), isNot(const ServerFailure('x')));
    });
  });
}
