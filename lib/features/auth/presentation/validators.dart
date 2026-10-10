import 'package:cinemix_cert/l10n/app_localizations.dart';

String? validateEmail(String? value, AppLocalizations l10n) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return l10n.validationEmailRequired;
  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(text)) return l10n.validationEmailInvalid;
  return null;
}

String? validatePassword(String? value, AppLocalizations l10n) {
  if (value == null || value.isEmpty) return l10n.validationPasswordRequired;
  if (value.length < 6) return l10n.validationPasswordTooShort;
  return null;
}
