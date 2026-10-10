import 'package:cinemix_cert/features/catalog/data/models/media_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaItemModel.fromJson', () {
    test('lit les champs d\'un film', () {
      final model = MediaItemModel.fromJson(const {
        'id': 10,
        'title': 'Film A',
        'overview': 'Résumé',
        'poster_path': '/a.jpg',
        'release_date': '2026-05-01',
        'vote_average': 7.5,
      });

      expect(model.id, 10);
      expect(model.title, 'Film A');
      expect(model.overview, 'Résumé');
      expect(model.posterPath, '/a.jpg');
      expect(model.releaseDate, '2026-05-01');
      expect(model.voteAverage, 7.5);
    });

    test('lit les champs d\'une série (name et first_air_date)', () {
      final model = MediaItemModel.fromJson(const {
        'id': 20,
        'name': 'Série A',
        'overview': 'Résumé',
        'first_air_date': '2025-01-10',
      });

      expect(model.title, 'Série A');
      expect(model.releaseDate, '2025-01-10');
    });

    test('applique des valeurs par défaut aux champs absents', () {
      final model = MediaItemModel.fromJson(const {'id': 3});

      expect(model.title, '');
      expect(model.overview, '');
      expect(model.posterPath, isNull);
      expect(model.releaseDate, isNull);
      expect(model.voteAverage, 0);
    });

    test('accepte une note entière', () {
      final model = MediaItemModel.fromJson(const {'id': 4, 'vote_average': 8});

      expect(model.voteAverage, 8.0);
    });
  });

  group('MediaItemModel.toJson', () {
    test('produit un JSON qui redonne le même objet', () {
      const model = MediaItemModel(
        id: 5,
        title: 'Film B',
        overview: 'Résumé B',
        posterPath: '/b.jpg',
        releaseDate: '2026-07-14',
        voteAverage: 6.1,
      );

      expect(MediaItemModel.fromJson(model.toJson()), model);
    });
  });
}
