import 'package:cinemix_cert/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/catalog/domain/repositories/catalog_repository.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/settings/presentation/cubit/locale_cubit.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.authBloc,
    required this.catalogRepository,
    required this.favoritesCubit,
    required this.localeCubit,
    required this.router,
  });

  final AuthBloc authBloc;
  final CatalogRepository catalogRepository;
  final FavoritesCubit favoritesCubit;
  final LocaleCubit localeCubit;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<CatalogRepository>.value(
      value: catalogRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: favoritesCubit),
          BlocProvider.value(value: localeCubit),
        ],
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) {
            return MaterialApp.router(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorSchemeSeed: Colors.indigo,
                useMaterial3: true,
              ),
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
