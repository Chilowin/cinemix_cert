import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cinemix'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPasswordLabel;

  /// No description provided for @signInButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signInButton;

  /// No description provided for @signUpButton.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signUpButton;

  /// No description provided for @createAccountLink.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccountLink;

  /// No description provided for @alreadyHaveAccountLink.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un compte'**
  String get alreadyHaveAccountLink;

  /// No description provided for @logoutTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logoutTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTooltip;

  /// No description provided for @validationEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre adresse email.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email invalide.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre mot de passe.'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 6 caractères.'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas.'**
  String get validationPasswordMismatch;

  /// No description provided for @titlePopularMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films populaires'**
  String get titlePopularMovies;

  /// No description provided for @titlePopularSeries.
  ///
  /// In fr, this message translates to:
  /// **'Séries populaires'**
  String get titlePopularSeries;

  /// No description provided for @titleUpcomingMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films à venir'**
  String get titleUpcomingMovies;

  /// No description provided for @tabMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films'**
  String get tabMovies;

  /// No description provided for @tabSeries.
  ///
  /// In fr, this message translates to:
  /// **'Séries'**
  String get tabSeries;

  /// No description provided for @tabUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get tabUpcoming;

  /// No description provided for @emptyList.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contenu à afficher.'**
  String get emptyList;

  /// No description provided for @noOverview.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résumé disponible.'**
  String get noOverview;

  /// No description provided for @ratingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Note {rating}/10'**
  String ratingLabel(String rating);

  /// No description provided for @offlineBanner.
  ///
  /// In fr, this message translates to:
  /// **'Données enregistrées : actualisation impossible pour le moment.'**
  String get offlineBanner;

  /// No description provided for @cachedDataNotice.
  ///
  /// In fr, this message translates to:
  /// **'{message} Affichage des données enregistrées.'**
  String cachedDataNotice(String message);

  /// No description provided for @retryButton.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retryButton;

  /// No description provided for @errorNoConnection.
  ///
  /// In fr, this message translates to:
  /// **'Aucune connexion réseau.'**
  String get errorNoConnection;

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le délai de connexion a été dépassé.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In fr, this message translates to:
  /// **'Erreur serveur (code {code}).'**
  String errorServer(int code);

  /// No description provided for @errorNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ressource introuvable.'**
  String get errorNotFound;

  /// No description provided for @errorSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée, reconnectez-vous.'**
  String get errorSessionExpired;

  /// No description provided for @errorAuthFailed.
  ///
  /// In fr, this message translates to:
  /// **'Authentification impossible.'**
  String get errorAuthFailed;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Email ou mot de passe incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email invalide.'**
  String get errorInvalidEmail;

  /// No description provided for @errorEmailInUse.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse email est déjà utilisée.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 6 caractères.'**
  String get errorWeakPassword;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives, réessayez plus tard.'**
  String get errorTooManyRequests;

  /// No description provided for @errorNoCache.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée disponible hors ligne.'**
  String get errorNoCache;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue est survenue.'**
  String get errorUnknown;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Langue du système'**
  String get languageSystem;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @tabFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get tabFavorites;

  /// No description provided for @titleFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get titleFavorites;

  /// No description provided for @emptyFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori pour le moment. Touchez le cœur d\'un titre pour l\'ajouter.'**
  String get emptyFavorites;

  /// No description provided for @addFavoriteTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get addFavoriteTooltip;

  /// No description provided for @removeFavoriteTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get removeFavoriteTooltip;

  /// No description provided for @overviewLabel.
  ///
  /// In fr, this message translates to:
  /// **'Résumé'**
  String get overviewLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
