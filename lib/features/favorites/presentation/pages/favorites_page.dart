import 'package:cinemix_cert/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../catalog/domain/entities/media_item.dart';
import '../../../catalog/presentation/widgets/media_tile.dart';
import '../cubit/favorites_cubit.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<FavoritesCubit, List<MediaItem>>(
      builder: (context, items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 48),
                  const SizedBox(height: 16),
                  Text(l10n.emptyFavorites, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: items.length,
          itemBuilder: (context, index) => MediaTile(item: items[index]),
        );
      },
    );
  }
}
