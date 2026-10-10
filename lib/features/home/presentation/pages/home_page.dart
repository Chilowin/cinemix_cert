import 'package:cinemix_cert/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../catalog/domain/entities/media_category.dart';
import '../../../catalog/presentation/pages/catalog_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titles = [
      l10n.titlePopularMovies,
      l10n.titlePopularSeries,
      l10n.titleUpcomingMovies,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            tooltip: l10n.logoutTooltip,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          CatalogPage(category: MediaCategory.popularMovies),
          CatalogPage(category: MediaCategory.popularSeries),
          CatalogPage(category: MediaCategory.upcomingMovies),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.movie_outlined),
            selectedIcon: const Icon(Icons.movie),
            label: l10n.tabMovies,
          ),
          NavigationDestination(
            icon: const Icon(Icons.tv_outlined),
            selectedIcon: const Icon(Icons.tv),
            label: l10n.tabSeries,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: l10n.tabUpcoming,
          ),
        ],
      ),
    );
  }
}
