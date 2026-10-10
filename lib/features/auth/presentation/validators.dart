String? validateEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Saisissez votre adresse email.';
  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(text)) return 'Adresse email invalide.';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Saisissez votre mot de passe.';
  if (value.length < 6) return 'Au moins 6 caractères.';
  return null;
}
