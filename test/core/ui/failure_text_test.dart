import 'dart:ui';

import 'package:cinemix_cert/core/error/failure.dart';
import 'package:cinemix_cert/core/ui/failure_text.dart';
import 'package:cinemix_cert/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('chaque code d\'erreur a un texte en français et en anglais', () {
    for (final code in FailureCode.values) {
      final failure = AuthFailure('technique', code);

      expect(failure.localized(fr), isNotEmpty);
      expect(failure.localized(en), isNotEmpty);
    }
  });

  test('une même erreur est traduite selon la langue', () {
    const failure = NetworkFailure();

    expect(failure.localized(fr), 'Aucune connexion réseau.');
    expect(failure.localized(en), 'No network connection.');
  });

  test('le texte d\'une erreur serveur contient le code HTTP', () {
    const failure = ServerFailure(
      'Erreur serveur (code 500).',
      FailureCode.serverError,
      500,
    );

    expect(failure.localized(fr), 'Erreur serveur (code 500).');
    expect(failure.localized(en), 'Server error (code 500).');
  });
}
