// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Cinemix';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get emailLabel => 'Adresse email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get signUpButton => 'S\'inscrire';

  @override
  String get createAccountLink => 'Créer un compte';

  @override
  String get alreadyHaveAccountLink => 'J\'ai déjà un compte';

  @override
  String get logoutTooltip => 'Se déconnecter';

  @override
  String get settingsTooltip => 'Paramètres';

  @override
  String get validationEmailRequired => 'Saisissez votre adresse email.';

  @override
  String get validationEmailInvalid => 'Adresse email invalide.';

  @override
  String get validationPasswordRequired => 'Saisissez votre mot de passe.';

  @override
  String get validationPasswordTooShort => 'Au moins 6 caractères.';

  @override
  String get validationPasswordMismatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get titlePopularMovies => 'Films populaires';

  @override
  String get titlePopularSeries => 'Séries populaires';

  @override
  String get titleUpcomingMovies => 'Films à venir';

  @override
  String get tabMovies => 'Films';

  @override
  String get tabSeries => 'Séries';

  @override
  String get tabUpcoming => 'À venir';

  @override
  String get emptyList => 'Aucun contenu à afficher.';

  @override
  String get noOverview => 'Aucun résumé disponible.';

  @override
  String ratingLabel(String rating) {
    return 'Note $rating/10';
  }

  @override
  String get offlineBanner =>
      'Données enregistrées : actualisation impossible pour le moment.';

  @override
  String cachedDataNotice(String message) {
    return '$message Affichage des données enregistrées.';
  }

  @override
  String get retryButton => 'Réessayer';

  @override
  String get errorNoConnection => 'Aucune connexion réseau.';

  @override
  String get errorTimeout => 'Le délai de connexion a été dépassé.';

  @override
  String errorServer(int code) {
    return 'Erreur serveur (code $code).';
  }

  @override
  String get errorNotFound => 'Ressource introuvable.';

  @override
  String get errorSessionExpired => 'Session expirée, reconnectez-vous.';

  @override
  String get errorAuthFailed => 'Authentification impossible.';

  @override
  String get errorInvalidCredentials => 'Email ou mot de passe incorrect.';

  @override
  String get errorInvalidEmail => 'Adresse email invalide.';

  @override
  String get errorEmailInUse => 'Cette adresse email est déjà utilisée.';

  @override
  String get errorWeakPassword =>
      'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get errorTooManyRequests => 'Trop de tentatives, réessayez plus tard.';

  @override
  String get errorNoCache => 'Aucune donnée disponible hors ligne.';

  @override
  String get errorUnknown => 'Une erreur inattendue est survenue.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';
}
