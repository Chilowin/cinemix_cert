import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemix_cert/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/media_item.dart';
import '../widgets/media_formatting.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isFavorite = context.select(
      (FavoritesCubit cubit) => cubit.state.any((e) => e.id == item.id),
    );
    final subtitle = mediaSubtitle(item, l10n);
    final posterUrl = item.posterUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: isFavorite
                ? l10n.removeFavoriteTooltip
                : l10n.addFavoriteTooltip,
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => context.read<FavoritesCubit>().toggle(item),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (posterUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 220,
                    child: CachedNetworkImage(
                      imageUrl: posterUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const SizedBox(
                        height: 330,
                        child: Center(child: Icon(Icons.movie_outlined)),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(item.title, style: theme.textTheme.headlineSmall),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(subtitle, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            Text(l10n.overviewLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              item.overview.isEmpty ? l10n.noOverview : item.overview,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
