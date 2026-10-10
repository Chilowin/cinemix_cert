import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/cache/cache_service.dart';
import 'core/network/dio_client.dart';
import 'core/network/token_provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/catalog/data/datasources/catalog_local_data_source.dart';
import 'features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'features/catalog/data/repositories/catalog_repository_impl.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/settings/presentation/cubit/locale_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final cache = await CacheService.init();

  final auth = FirebaseAuth.instance;
  final dio = createDio(
    tokenProvider: FirebaseTokenProvider(auth),
    apiKey: dotenv.get('TMDB_API_KEY'),
    attachToken: !kIsWeb,
    onSessionExpired: auth.signOut,
  );

  final authBloc = AuthBloc(AuthRepositoryImpl(auth));
  final catalogRepository = CatalogRepositoryImpl(
    remote: CatalogRemoteDataSource(dio),
    local: CatalogLocalDataSource(cache),
  );
  final favoritesCubit = FavoritesCubit(FavoritesRepositoryImpl(cache))..load();

  runApp(
    App(
      authBloc: authBloc,
      catalogRepository: catalogRepository,
      favoritesCubit: favoritesCubit,
      localeCubit: LocaleCubit(cache),
      router: createRouter(authBloc),
    ),
  );
}
