import 'dart:ui';

import 'package:cinemix_cert/features/catalog/domain/entities/media_item.dart';
import 'package:cinemix_cert/features/catalog/presentation/widgets/media_formatting.dart';
import 'package:cinemix_cert/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  test('affiche l\'année et la note', () {
    const item = MediaItem(
      id: 1,
      title: 'Film A',
      overview: 'Résumé',
      releaseDate: '2026-05-01',
      voteAverage: 7.5,
    );

    expect(mediaSubtitle(item, en), '2026 - Rating 7.5/10');
  });

  test('n\'affiche que l\'année quand il n\'y a pas de note', () {
    const item = MediaItem(
      id: 1,
      title: 'Film A',
      overview: 'Résumé',
      releaseDate: '2026-05-01',
    );

    expect(mediaSubtitle(item, en), '2026');
  });

  test('renvoie un texte vide sans date ni note', () {
    const item = MediaItem(id: 1, title: 'Film A', overview: 'Résumé');

    expect(mediaSubtitle(item, en), isEmpty);
  });
}
