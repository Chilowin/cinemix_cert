import 'package:cinemix_cert/l10n/app_localizations.dart';

import '../../domain/entities/media_item.dart';

String mediaSubtitle(MediaItem item, AppLocalizations l10n) {
  final date = item.releaseDate ?? '';
  final year = date.length >= 4 ? date.substring(0, 4) : null;
  return [
    if (year != null) year,
    if (item.voteAverage > 0)
      l10n.ratingLabel(item.voteAverage.toStringAsFixed(1)),
  ].join(' - ');
}
