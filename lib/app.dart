import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/catalog/domain/repositories/catalog_repository.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.authBloc,
    required this.catalogRepository,
    required this.router,
  });

  final AuthBloc authBloc;
  final CatalogRepository catalogRepository;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<CatalogRepository>.value(
      value: catalogRepository,
      child: BlocProvider.value(
        value: authBloc,
        child: MaterialApp.router(
          title: 'Cinemix',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}
