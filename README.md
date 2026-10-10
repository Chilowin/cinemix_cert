# Cinemix

Application Flutter qui affiche des films et des séries à partir de l'API TMDB. L'utilisateur crée un compte ou se connecte (Firebase Authentication), puis consulte trois listes : films populaires, séries populaires et films à venir. Les données sont gardées en cache avec Hive, ce qui permet de les consulter sans connexion.

Ce document reprend les exigences du sujet une par une et indique, pour chacune, les fichiers où elle est réalisée.

## 1. Exigences du sujet

### Authentification complète (login, register, logout)

Firebase Authentication, avec email et mot de passe. La session et les tokens sont gérés par le SDK Firebase : l'application ne les écrit nulle part elle-même.

- `lib/features/auth/domain/repositories/auth_repository.dart` : contrat `AuthRepository`
- `lib/features/auth/data/repositories/auth_repository_impl.dart` : méthodes `login`, `register` et `logout`, et traduction des codes d'erreur Firebase en messages en français
- `lib/features/auth/presentation/bloc/auth_bloc.dart` (avec `auth_event.dart` et `auth_state.dart`) : `AuthBloc`, qui suit l'état de la session
- `lib/features/auth/presentation/pages/login_page.dart` et `register_page.dart` : les deux formulaires
- `lib/features/auth/presentation/validators.dart` : validation de l'email et du mot de passe
- `lib/core/router/app_router.dart` : fonction `createRouter`, qui renvoie vers `/login` si l'utilisateur n'est pas connecté et vers `/` s'il l'est
- `lib/features/home/presentation/pages/home_page.dart` : bouton de déconnexion dans la barre du haut

### Trois écrans de données issus d'une API REST

Les trois écrans utilisent l'API TMDB : films populaires (`/movie/popular`), séries populaires (`/tv/popular`) et films à venir (`/movie/upcoming`). Ils partagent le même code et ne diffèrent que par leur catégorie.

- `lib/features/catalog/domain/entities/media_category.dart` : l'énumération `MediaCategory` (les trois catégories)
- `lib/features/catalog/data/datasources/catalog_remote_data_source.dart` : classe `CatalogRemoteDataSource`, qui choisit la route selon la catégorie
- `lib/features/home/presentation/pages/home_page.dart` : classe `_HomePageState`, trois onglets
- `lib/features/catalog/presentation/pages/catalog_page.dart` : l'écran d'une catégorie (liste, rafraîchissement par glissement)
- `lib/features/catalog/presentation/widgets/media_tile.dart` : une ligne de la liste (affiche, titre, année, note, résumé)
- `lib/features/catalog/presentation/cubit/catalog_cubit.dart` (avec `catalog_state.dart`) : `CatalogCubit`, un par écran

### Dio pour les appels réseau

- `lib/core/network/dio_client.dart` : fonction `createDio`. Elle fixe l'adresse de base de TMDB, les délais d'attente (10 s pour la connexion, 15 s pour la réponse), ainsi que la clé d'API et la langue (`fr-FR`) en paramètres de requête.

### Intercepteur pour l'injection du token d'authentification

- `lib/core/network/dio_client.dart` : classe `AuthInterceptor`, méthode `onRequest`. Elle ajoute à chaque requête le token de l'utilisateur dans l'en-tête `X-Firebase-Token`.
- `lib/core/network/token_provider.dart` : interface `TokenProvider` et implémentation `FirebaseTokenProvider`. L'intercepteur ne dépend pas directement de Firebase, ce qui permet de le tester avec un faux fournisseur.

### Gestion du refresh token

Firebase conserve un refresh token et s'en sert pour fabriquer un nouveau token d'identité quand l'ancien expire. L'application s'appuie là-dessus à deux endroits :

- avant chaque requête, `getToken()` renvoie le token en cache ou en obtient un nouveau s'il a expiré ;
- quand le serveur répond 401, `AuthInterceptor.onError` force le renouvellement (`getToken(forceRefresh: true)`) puis rejoue la requête une seule fois ;
- si le renouvellement est impossible (session révoquée, compte désactivé), l'intercepteur appelle `onSessionExpired`, qui déconnecte l'utilisateur. `AuthBloc` voit la session disparaître et le routeur renvoie vers la page de connexion. Le branchement est dans `lib/main.dart` (`onSessionExpired: auth.signOut`).

Un 401 qui persiste après un renouvellement réussi ne déconnecte pas l'utilisateur : il peut venir d'une clé TMDB invalide, et l'erreur est alors simplement affichée.

Fichiers : `lib/core/network/dio_client.dart` (`AuthInterceptor.onError`), `lib/core/network/token_provider.dart`, `lib/main.dart`.

### Mise en cache locale (Hive)

Les listes sont stockées dans une boîte Hive, au format JSON texte, une entrée par catégorie. Il n'y a ni adaptateur ni génération de code.

- `lib/core/cache/cache_service.dart` : classe `CacheService` (ouverture de la boîte, `write`, `read`, `clear`)
- `lib/features/catalog/data/datasources/catalog_local_data_source.dart` : classe `CatalogLocalDataSource` (`save` et `read`). Un cache absent ou illisible est traité comme un cache vide.

### Mode hors-ligne

Le repository essaie d'abord le réseau. S'il y arrive, il enregistre la réponse dans le cache. Sinon, il renvoie les données du cache accompagnées de l'erreur d'origine, et l'écran prévient l'utilisateur. S'il n'y a pas de cache non plus, l'erreur remonte et l'écran propose de réessayer.

- `lib/features/catalog/data/repositories/catalog_repository_impl.dart` : méthode `getItems`
- `lib/features/catalog/domain/entities/catalog_result.dart` : classe `CatalogResult` (`items`, `failure`, `isFromCache`)
- `lib/features/catalog/presentation/pages/catalog_page.dart` : classe `_OfflineBanner` (bandeau affiché quand les données viennent du cache) et SnackBar donnant la cause
- `lib/features/catalog/presentation/cubit/catalog_cubit.dart` : pendant un rafraîchissement, les éléments déjà affichés sont conservés

Pour l'essayer : charger une liste en ligne, puis couper le réseau et tirer la liste vers le bas. Sur le web, on peut utiliser F12, onglet Network, option Offline.

### Gestion des erreurs réseau avec messages clairs

Les erreurs techniques sont converties en erreurs de l'application, dont le message est directement lisible par l'utilisateur.

- `lib/core/error/failure.dart` : classe `Failure` et ses variantes (`NetworkFailure`, `ServerFailure`, `AuthFailure`, `CacheFailure`, `UnknownFailure`)
- `lib/core/error/failure_mapper.dart` : fonction `mapDioException` (délais dépassés, absence de connexion, 401, 404, autres codes HTTP)
- `lib/features/auth/data/repositories/auth_repository_impl.dart` : méthode `_mapError` pour les erreurs Firebase
- `lib/core/ui/app_snackbar.dart` : fonction `showErrorSnackBar`
- `lib/features/catalog/presentation/pages/catalog_page.dart` : classe `_ErrorView` (message et bouton « Réessayer »)

### Architecture feature-first (data, domain, presentation)

```
lib/
  core/
    cache/        cache_service.dart
    error/        failure.dart, failure_mapper.dart
    network/      dio_client.dart, token_provider.dart
    router/       app_router.dart, go_router_refresh_stream.dart
    ui/           app_snackbar.dart
  features/
    auth/
      domain/         entities/app_user.dart, repositories/auth_repository.dart
      data/           repositories/auth_repository_impl.dart
      presentation/   bloc/, pages/, validators.dart
    catalog/
      domain/         entities/, repositories/catalog_repository.dart
      data/           models/, datasources/, repositories/
      presentation/   cubit/, pages/, widgets/
    home/
      presentation/   pages/home_page.dart
  app.dart
  main.dart
```

La couche `domain` ne dépend d'aucune bibliothèque externe, à part Equatable pour comparer les objets. `data` implémente les contrats du domaine et s'occupe de Firebase, de Dio et de Hive. `presentation` ne connaît que les contrats : `AuthBloc` et `CatalogCubit` ignorent tout de Firebase, de Dio et de Hive.

### Pattern Repository

Chaque repository a une interface dans `domain` et une implémentation dans `data`.

- `lib/features/catalog/domain/repositories/catalog_repository.dart` : `CatalogRepository`
- `lib/features/catalog/data/repositories/catalog_repository_impl.dart` : `CatalogRepositoryImpl`, qui combine `CatalogRemoteDataSource` et `CatalogLocalDataSource`
- `lib/features/auth/domain/repositories/auth_repository.dart` : `AuthRepository`
- `lib/features/auth/data/repositories/auth_repository_impl.dart` : `AuthRepositoryImpl`

Les dépendances sont assemblées dans `lib/main.dart` puis fournies aux écrans par `lib/app.dart`.

### Tests unitaires sur la couche repository

Les tests du repository du catalogue sont dans `test/features/catalog/data/repositories/catalog_repository_impl_test.dart`. Ils remplacent les deux sources de données par de faux objets (mocktail) :

- retourne les données distantes et les enregistre en cache
- retourne le cache avec l'erreur quand le réseau échoue
- propage l'erreur quand le réseau échoue et que le cache est absent
- propage l'erreur quand le cache est vide

Les tests du repository d'authentification sont dans `test/features/auth/data/repositories/auth_repository_impl_test.dart` : connexion, inscription, déconnexion, flux de session et traduction des codes d'erreur Firebase.

La liste complète des tests est dans la section 3.

## 2. Installation et lancement

Prérequis : Flutter, un compte Firebase, une clé d'API TMDB (v3, gratuite) et Node.js pour l'outil Firebase.

1. Installer les dépendances :

```
   flutter pub get
```

2. Dans la console Firebase, créer un projet et activer Authentication, méthode Email/Password.
3. Générer la configuration Firebase :

```
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
```

Cela crée `lib/firebase_options.dart`. Si la commande `flutterfire` n'est pas reconnue, ajouter `~/.pub-cache/bin` au PATH. 4. Créer le fichier d'environnement :

```
   cp .env.example .env
```

puis y écrire la clé : `TMDB_API_KEY=votre_cle`. Le fichier `.env` n'est pas versionné, mais il est déclaré comme asset : sans lui, le projet ne compile pas. 5. Lancer l'application :

- Android ou iOS : `flutter run`
- web : `flutter run -d chrome`, ou `flutter run -d web-server --web-port 5000` puis ouvrir `http://localhost:5000`

Firebase Authentication ne fonctionne pas sur Linux desktop. Sur Android, la permission `android.permission.INTERNET` doit figurer dans `android/app/src/main/AndroidManifest.xml` pour que l'application release accède au réseau, et `minSdk` doit valoir au moins 23 dans `android/app/build.gradle`.

## 3. Tests

```
flutter test
```

Un seul fichier : `flutter test test/core/network/auth_interceptor_test.dart`

Aucun test n'a besoin du réseau, de Firebase ou d'un navigateur.

| Fichier                                                                      | Ce qui est vérifié                                                                                                                                                |
| ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `test/core/error/failure_mapper_test.dart`                                   | Conversion des erreurs Dio (délais, connexion, 401, 404, 500, autres) en erreurs de l'application                                                                 |
| `test/core/network/auth_interceptor_test.dart`                               | Ajout du token, renouvellement et rejeu après un 401, un seul rejeu, fin de session si le renouvellement est impossible, aucune tentative pour les autres erreurs |
| `test/features/auth/data/repositories/auth_repository_impl_test.dart`        | Connexion, inscription, déconnexion, flux de session, traduction des codes d'erreur Firebase                                                                      |
| `test/features/auth/presentation/bloc/auth_bloc_test.dart`                   | États de `AuthBloc` selon la session, la connexion, l'inscription et la déconnexion                                                                               |
| `test/features/catalog/data/datasources/catalog_local_data_source_test.dart` | Écriture et lecture du cache, cache absent ou corrompu                                                                                                            |
| `test/features/catalog/data/models/media_item_model_test.dart`               | Lecture du JSON des films et des séries, valeurs par défaut, aller-retour JSON                                                                                    |
| `test/features/catalog/data/repositories/catalog_repository_impl_test.dart`  | Données distantes et mise en cache, repli sur le cache, erreur sans cache, erreur avec cache vide                                                                 |
| `test/features/catalog/domain/entities/catalog_entities_test.dart`           | `CatalogResult`, adresse d'affiche de `MediaItem`, égalité des entités et des erreurs                                                                             |
| `test/features/catalog/presentation/cubit/catalog_cubit_test.dart`           | Séquence d'états de `CatalogCubit` : succès, données du cache, échec, exception inattendue, éléments conservés lors d'un rafraîchissement raté                    |

## 4. Intégration continue

Le fichier `.github/workflows/ci.yml` lance l'analyse et les tests à chaque push et à chaque pull request :

```yaml
name: CI

on:
  push:
  pull_request:

jobs:
  checks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - name: Préparer le fichier d'environnement
        run: cp .env.example .env
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

## 5. Limites et choix

- Sur le web, l'intercepteur de token est désactivé (`attachToken: !kIsWeb` dans `lib/main.dart`). L'en-tête personnalisé déclenche une vérification CORS du navigateur que TMDB n'autorise pas, ce qui bloquait toutes les requêtes. Sur Android et iOS, il est actif.
- Seule la première page de résultats de chaque catégorie est chargée.
- Le cache n'a pas de durée de validité : il est remplacé à chaque chargement réussi.
- La clé TMDB est lue depuis `.env`, qui n'est pas versionné, mais une clé placée dans une application cliente reste récupérable dans le binaire. Pour une mise en production, il faudrait passer par un serveur intermédiaire.
