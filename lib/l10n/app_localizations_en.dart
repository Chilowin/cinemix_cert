// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cinemix';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signUpButton => 'Sign up';

  @override
  String get createAccountLink => 'Create an account';

  @override
  String get alreadyHaveAccountLink => 'I already have an account';

  @override
  String get logoutTooltip => 'Sign out';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get validationEmailRequired => 'Enter your email address.';

  @override
  String get validationEmailInvalid => 'Invalid email address.';

  @override
  String get validationPasswordRequired => 'Enter your password.';

  @override
  String get validationPasswordTooShort => 'At least 6 characters.';

  @override
  String get validationPasswordMismatch => 'Passwords do not match.';

  @override
  String get titlePopularMovies => 'Popular movies';

  @override
  String get titlePopularSeries => 'Popular series';

  @override
  String get titleUpcomingMovies => 'Upcoming movies';

  @override
  String get tabMovies => 'Movies';

  @override
  String get tabSeries => 'Series';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get emptyList => 'Nothing to show.';

  @override
  String get noOverview => 'No overview available.';

  @override
  String ratingLabel(String rating) {
    return 'Rating $rating/10';
  }

  @override
  String get offlineBanner =>
      'Showing saved data: refreshing is not possible right now.';

  @override
  String cachedDataNotice(String message) {
    return '$message Showing saved data.';
  }

  @override
  String get retryButton => 'Retry';

  @override
  String get errorNoConnection => 'No network connection.';

  @override
  String get errorTimeout => 'The connection timed out.';

  @override
  String errorServer(int code) {
    return 'Server error (code $code).';
  }

  @override
  String get errorNotFound => 'Resource not found.';

  @override
  String get errorSessionExpired => 'Session expired, please sign in again.';

  @override
  String get errorAuthFailed => 'Authentication failed.';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorInvalidEmail => 'Invalid email address.';

  @override
  String get errorEmailInUse => 'This email address is already in use.';

  @override
  String get errorWeakPassword =>
      'The password must be at least 6 characters long.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts, please try again later.';

  @override
  String get errorNoCache => 'No data available offline.';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';
}
