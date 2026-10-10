import 'dart:ui';

import 'package:cinemix_cert/features/auth/presentation/validators.dart';
import 'package:cinemix_cert/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('validateEmail', () {
    test('refuse une valeur vide', () {
      expect(validateEmail('  ', l10n), l10n.validationEmailRequired);
    });

    test('refuse une adresse mal formée', () {
      expect(validateEmail('alice', l10n), l10n.validationEmailInvalid);
    });

    test('accepte une adresse valide', () {
      expect(validateEmail('alice@example.com', l10n), isNull);
    });
  });

  group('validatePassword', () {
    test('refuse une valeur vide', () {
      expect(validatePassword('', l10n), l10n.validationPasswordRequired);
    });

    test('refuse un mot de passe trop court', () {
      expect(validatePassword('12345', l10n), l10n.validationPasswordTooShort);
    });

    test('accepte un mot de passe de 6 caractères', () {
      expect(validatePassword('123456', l10n), isNull);
    });
  });
}
