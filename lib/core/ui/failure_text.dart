import 'package:cinemix_cert/l10n/app_localizations.dart';

import '../error/failure.dart';

extension FailureText on Failure {
  String localized(AppLocalizations l10n) {
    return switch (code) {
      FailureCode.noConnection => l10n.errorNoConnection,
      FailureCode.timeout => l10n.errorTimeout,
      FailureCode.serverError => l10n.errorServer(statusCode ?? 0),
      FailureCode.notFound => l10n.errorNotFound,
      FailureCode.sessionExpired => l10n.errorSessionExpired,
      FailureCode.authFailed => l10n.errorAuthFailed,
      FailureCode.invalidCredentials => l10n.errorInvalidCredentials,
      FailureCode.invalidEmail => l10n.errorInvalidEmail,
      FailureCode.emailInUse => l10n.errorEmailInUse,
      FailureCode.weakPassword => l10n.errorWeakPassword,
      FailureCode.tooManyRequests => l10n.errorTooManyRequests,
      FailureCode.noCache => l10n.errorNoCache,
      FailureCode.unknown => l10n.errorUnknown,
    };
  }
}
