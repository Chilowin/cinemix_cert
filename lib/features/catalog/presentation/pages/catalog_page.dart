import 'package:cinemix_cert/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ui/app_snackbar.dart';
import '../../../../core/ui/failure_text.dart';
import '../../domain/entities/media_category.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../cubit/catalog_cubit.dart';
import '../widgets/media_tile.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key, required this.category});

  final MediaCategory category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CatalogCubit(context.read<CatalogRepository>(), category)..load(),
      child: const _CatalogView(),
    );
  }
}

class _CatalogView extends StatelessWidget {
  const _CatalogView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CatalogCubit, CatalogState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status != CatalogStatus.loading &&
          current.failure != null,
      listener: (context, state) {
        final l10n = AppLocalizations.of(context);
        final text = state.failure!.localized(l10n);
        showErrorSnackBar(
          context,
          state.isFromCache ? l10n.cachedDataNotice(text) : text,
        );
      },
      builder: (context, state) {
        final cubit = context.read<CatalogCubit>();
        final l10n = AppLocalizations.of(context);

        if (state.items.isEmpty) {
          if (state.status == CatalogStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CatalogStatus.failure) {
            return _ErrorView(
              message: state.failure?.localized(l10n) ?? l10n.errorUnknown,
              onRetry: cubit.load,
            );
          }
        }

        return Column(
          children: [
            if (state.isFromCache) const _OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: cubit.load,
                child: state.items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          Center(child: Text(l10n.emptyList)),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) =>
                            MediaTile(item: state.items[index]),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: colors.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        AppLocalizations.of(context).offlineBanner,
        style: TextStyle(color: colors.onSecondaryContainer),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).retryButton),
            ),
          ],
        ),
      ),
    );
  }
}
