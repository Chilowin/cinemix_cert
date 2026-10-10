import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/media_item.dart';

class MediaTile extends StatelessWidget {
  const MediaTile({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = item.releaseDate ?? '';
    final year = date.length >= 4 ? date.substring(0, 4) : null;
    final details = [
      if (year != null) year,
      if (item.voteAverage > 0) 'Note ${item.voteAverage.toStringAsFixed(1)}/10',
    ].join(' - ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Poster(url: item.posterUrl),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(details, style: theme.textTheme.bodySmall),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    item.overview.isEmpty
                        ? 'Aucun résumé disponible.'
                        : item.overview,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 135,
      child: url == null
          ? const _PosterPlaceholder()
          : CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const _PosterPlaceholder(),
              errorWidget: (context, url, error) => const _PosterPlaceholder(),
            ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black12,
      child: Center(child: Icon(Icons.movie_outlined)),
    );
  }
}