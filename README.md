# Cinemix

Application Flutter de consultation de films et de séries, construite autour de l'API publique TMDB. Elle combine une authentification Firebase, trois écrans de données, un cache local et un mode hors-ligne, au sein d'une architecture organisée par fonctionnalité.

## Sommaire

1. Fonctionnalités
2. Architecture
3. Choix techniques
4. Authentification et gestion du token
5. Réseau et gestion des erreurs
6. Cache et mode hors-ligne
7. Navigation
8. Configuration et lancement
9. Tests
10. Intégration continue
11. Sécurité
12. Limites connues et pistes d'amélioration

## 1. Fonctionnalités

- Inscription, connexion et déconnexion avec Firebase Authentication (email et mot de passe).
- Persistance de la session : l'utilisateur reste connecté après un redémarrage.
- Trois écrans de données : films populaires, séries populaires, films à venir.
- Appels réseau avec Dio, via un interceptor chargé d'ajouter le token d'authentification et de le renouveler en cas de réponse 401.
- Mise en cache locale avec Hive.
- Mode hors-ligne : sans réseau, les dernières données enregistrées sont affichées, avec une indication claire pour l'utilisateur.
- Messages d'erreur explicites (SnackBar, bandeau d'information, écran d'erreur avec bouton « Réessayer »).
- Rafraîchissement des listes par glissement vers le bas.

## 2. Architecture

### 2.1 Vue d'ensemble

Le projet suit une organisation par fonctionnalité (feature-first). Chaque fonctionnalité est découpée en trois couches, et l'accès aux données passe toujours par un repository.

```
lib/
  core/
    cache/        Service de cache Hive
    error/        Erreurs métier (Failure) et conversion des erreurs Dio
    network/      Client Dio, interceptor d'authentification, fournisseur de token
    router/       Configuration go_router et redirections selon la session
    ui/           Éléments d'interface partagés
  features/
    auth/
      domain/         Entité AppUser, contrat AuthRepository
      data/           AuthRepositoryImpl (Firebase Authentication)
      presentation/   AuthBloc, pages de connexion et d'inscription, validateurs
    catalog/
      domain/         MediaItem, MediaCategory, CatalogResult, contrat CatalogRepository
      data/           Modèle, sources de données distante et locale, repository
      presentation/   CatalogCubit, page du catalogue, widgets
    home/
      presentation/   Page principale avec navigation par onglets
  app.dart            Widget racine et injection des dépendances
  main.dart           Initialisation et assemblage
test/                 Tests miroirs de l'arborescence lib/
```

### 2.2 Les trois couches

| Couche       | Contenu                                                                         | Dépend de                       | Justification                                                                                                                     |
| ------------ | ------------------------------------------------------------------------------- | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| domain       | Entités et contrats (interfaces) des repositories                               | Rien (Dart pur, plus Equatable) | Représente les règles et le vocabulaire métier. Elle reste stable quand la technologie change.                                    |
| data         | Modèles JSON, sources de données (API, cache), implémentations des repositories | domain, core                    | Isole tout ce qui touche à l'extérieur (réseau, stockage, Firebase). Remplacer une source ne modifie ni le domaine ni les écrans. |
| presentation | Widgets, Bloc et Cubit                                                          | domain uniquement               | Les écrans ne connaissent que les contrats. Ils sont testables avec de faux repositories.                                         |

La règle de dépendance va toujours vers le domaine : la présentation et la data dépendent du domain, jamais l'inverse. Ainsi, `AuthBloc` et `CatalogCubit` ignorent l'existence de Firebase, de Dio et de Hive.

### 2.3 Pattern Repository

Chaque repository expose une interface dans `domain` et une implémentation dans `data`.

- `AuthRepository` / `AuthRepositoryImpl` : traduit les opérations Firebase et ses codes d'erreur en entités et en erreurs métier.
- `CatalogRepository` / `CatalogRepositoryImpl` : orchestre la source distante et la source locale (voir section 6).

### 2.4 Flux de données

```
Écran -> Cubit/Bloc -> Repository (contrat) -> RepositoryImpl
                                                 |-> Source distante (Dio -> TMDB)
                                                 |-> Source locale (Hive)
```

Les dépendances sont assemblées dans `main.dart` puis fournies à l'arbre de widgets par `app.dart` (`RepositoryProvider` et `BlocProvider`).

## 3. Choix techniques

| Besoin           | Choix                             | Justification                                                                                                                                                 |
| ---------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Authentification | Firebase Authentication           | Sessions, persistance et renouvellement du token pris en charge par le SDK, ce qui évite d'implémenter un stockage de secrets à la main                       |
| Réseau           | Dio                               | Interceptors, délais d'attente configurables, erreurs typées                                                                                                  |
| Gestion d'état   | flutter_bloc                      | `Bloc` pour l'authentification (plusieurs événements), `Cubit` pour le catalogue (chargement simple). Les états sont immuables et comparables avec Equatable. |
| Navigation       | go_router                         | Redirections déclaratives en fonction de l'état de connexion                                                                                                  |
| Cache            | Hive                              | Stockage clé-valeur léger et rapide. Les données sont stockées en JSON texte, ce qui évite la génération de code et les adaptateurs.                          |
| Tests            | flutter_test, mocktail, bloc_test | Faux objets sans génération de code, et vérification de la séquence exacte des états émis                                                                     |
| Images           | cached_network_image              | Mise en cache des affiches                                                                                                                                    |
| Configuration    | flutter_dotenv                    | Clé d'API hors du code source                                                                                                                                 |
| API de données   | TMDB                              | API publique, documentée, avec des contenus riches                                                                                                            |

## 4. Authentification et gestion du token

### 4.1 Session

`AuthBloc` écoute en permanence le flux de session de Firebase. Un changement de session (connexion, déconnexion, expiration) produit un nouvel état, et le routeur redirige automatiquement l'utilisateur :

- non connecté : accès limité aux pages de connexion et d'inscription ;
- connecté : accès aux écrans de données, les pages de connexion étant inaccessibles ;
- état inconnu (démarrage) : écran d'attente, ce qui évite d'afficher brièvement la page de connexion à un utilisateur déjà connecté.

### 4.2 Token et renouvellement

Firebase délivre un token d'identité de courte durée, et conserve un refresh token que le SDK utilise pour obtenir un nouveau token. L'application s'appuie sur ce mécanisme à deux niveaux.

1. **Avant chaque requête** : l'interceptor demande le token au `TokenProvider`. Firebase renvoie le token en cache, ou en obtient automatiquement un nouveau s'il est expiré.
2. **Après une réponse 401** : l'interceptor force le renouvellement (`forceRefresh`), puis rejoue la requête une seule fois avec le nouveau token.

Cas limites traités :

- Si le renouvellement est impossible (session révoquée ou compte désactivé), l'interceptor déclenche une déconnexion. `AuthBloc` détecte le changement de session et l'utilisateur est renvoyé vers la page de connexion.
- Une réponse 401 qui persiste après un renouvellement réussi ne déconnecte pas l'utilisateur (elle peut venir d'une clé d'API invalide) et l'erreur est affichée normalement.
- Une erreur lors de la lecture du token n'interrompt pas la requête.
- Une requête n'est jamais rejouée plus d'une fois, ce qui évite les boucles.

### 4.3 Particularité de la plateforme web

L'interceptor est désactivé sur le web : l'en-tête personnalisé `X-Firebase-Token` déclenche une vérification préalable du navigateur (CORS) que l'API TMDB n'autorise pas, ce qui bloquerait toutes les requêtes. Il reste actif sur Android et iOS. L'API TMDB elle-même est authentifiée par la clé d'API.

## 5. Réseau et gestion des erreurs

Les erreurs techniques sont converties en erreurs métier dont le message est directement affichable.

| Erreur         | Cause                                                             | Message                                                                 |
| -------------- | ----------------------------------------------------------------- | ----------------------------------------------------------------------- |
| NetworkFailure | Absence de connexion, délai dépassé                               | « Aucune connexion réseau. » / « Le délai de connexion a été dépassé. » |
| ServerFailure  | Réponse HTTP en erreur                                            | « Erreur serveur (code N). » / « Ressource introuvable. »               |
| AuthFailure    | Identifiants invalides, email déjà utilisé, session expirée, etc. | Message adapté à la cause                                               |
| CacheFailure   | Cache indisponible                                                | « Aucune donnée disponible hors ligne. »                                |
| UnknownFailure | Toute autre exception                                             | « Une erreur inattendue est survenue. »                                 |

La conversion est centralisée : `mapDioException` pour Dio, et la traduction des codes d'erreur Firebase dans `AuthRepositoryImpl`. Les erreurs sont présentées à l'utilisateur par une SnackBar, un bandeau, ou un écran d'erreur avec un bouton « Réessayer ».

## 6. Cache et mode hors-ligne

Stratégie : réseau d'abord, cache en secours.

1. `CatalogRepositoryImpl` interroge TMDB.
2. En cas de succès, la réponse est enregistrée dans Hive (une entrée par catégorie) puis renvoyée.
3. En cas d'échec, le repository lit le cache. S'il contient des données, elles sont renvoyées avec l'erreur d'origine dans un `CatalogResult`.
4. Sans cache, l'erreur est propagée à l'écran.

Indication à l'utilisateur lorsque les données proviennent du cache :

- un bandeau permanent en haut de la liste ;
- une SnackBar indiquant la cause (par exemple « Aucune connexion réseau. Affichage des données enregistrées. ») ;
- lors d'un rafraîchissement qui échoue, les éléments déjà affichés sont conservés.

Un cache illisible ou corrompu est traité comme un cache absent.

## 7. Navigation

go_router gère les routes `/splash`, `/login`, `/register` et `/`. Un `GoRouterRefreshStream` réévalue les redirections à chaque changement d'état de `AuthBloc`. La page principale propose trois onglets (films, séries, à venir) conservés en mémoire pour éviter les rechargements.

## 8. Configuration et lancement

### 8.1 Prérequis

- Flutter (SDK stable récent)
- Un compte Firebase
- Une clé d'API TMDB v3 (gratuite, créée dans les paramètres du compte themoviedb.org)
- Node.js, pour l'outil Firebase en ligne de commande

### 8.2 Installation

1. Installer les dépendances :

```
   flutter pub get
```

2. Créer un projet dans la console Firebase, puis activer **Authentication > Sign-in method > Email/Password**.
3. Générer la configuration Firebase :

```
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
```

Selon l'installation, il peut être nécessaire d'ajouter `~/.pub-cache/bin` au PATH. La commande crée `lib/firebase_options.dart`. 4. Créer le fichier d'environnement à partir du modèle :

```
   cp .env.example .env
```

Puis renseigner la clé dans `.env` :

```
   TMDB_API_KEY=votre_cle_api_tmdb
```

Le fichier `.env` est ignoré par Git. Il est déclaré comme asset : son absence empêche la compilation.

### 8.3 Configuration Android

- Dans `android/app/src/main/AndroidManifest.xml`, vérifier la présence de la permission réseau (nécessaire en mode release) :

```xml
  <uses-permission android:name="android.permission.INTERNET"/>
```

- Si la compilation indique que `minSdkVersion` doit être supérieur, fixer `minSdk = 23` dans `android/app/build.gradle`.

### 8.4 Lancement

| Cible              | Commande                                                                        |
| ------------------ | ------------------------------------------------------------------------------- |
| Android ou iOS     | `flutter run`                                                                   |
| Web                | `flutter run -d chrome`                                                         |
| Web sans débogueur | `flutter run -d web-server --web-port 5000` puis ouvrir `http://localhost:5000` |

Firebase Authentication n'est pas disponible sur Linux desktop : il faut utiliser Android, iOS ou le web.

## 9. Tests

```
flutter test
```

Les tests sont organisés comme l'arborescence de `lib/`.

| Fichier                                                                | Ce qui est vérifié                                                                                                                                                  |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `core/network/auth_interceptor_test.dart`                              | Ajout du token, renouvellement puis rejeu après un 401, un seul rejeu, fin de session si le renouvellement est impossible, aucune tentative pour les autres erreurs |
| `features/catalog/data/repositories/catalog_repository_impl_test.dart` | Données distantes et mise en cache, repli sur le cache avec l'erreur d'origine, erreur sans cache, erreur avec cache vide                                           |
| `features/catalog/presentation/cubit/catalog_cubit_test.dart`          | Séquence d'états en cas de succès, de données issues du cache, d'échec, d'exception inattendue, et conservation des éléments lors d'un rafraîchissement raté        |
| `features/auth/presentation/bloc/auth_bloc_test.dart`                  | Passage à authentifié ou non authentifié selon la session, connexion, inscription et déconnexion, exposition des messages d'erreur                                  |

Les tests utilisent de faux repositories et un faux adaptateur HTTP : ils ne nécessitent ni réseau, ni Firebase, ni navigateur.

## 10. Intégration continue

Le workflow `.github/workflows/ci.yml` s'exécute à chaque push et pull request. Il installe Flutter, récupère les dépendances, lance `flutter analyze` puis `flutter test`.

## 11. Sécurité

- La clé d'API TMDB est lue depuis `.env`, qui n'est pas versionné. Seul `.env.example`, sans valeur, figure dans le dépôt.
- Une clé embarquée dans une application cliente reste extractible du binaire. TMDB fournit une clé gratuite à faible enjeu, mais pour un déploiement public, la bonne pratique consiste à passer par un serveur intermédiaire qui détient la clé.
- Les identifiants de `firebase_options.dart` ne sont pas des secrets : l'accès aux données est protégé par l'authentification et par les règles de sécurité Firebase.
- Les messages d'erreur d'authentification ne distinguent pas « utilisateur inconnu » de « mot de passe erroné » (même message), pour ne pas révéler quels comptes existent.
- Les tokens sont gérés par le SDK Firebase et ne sont jamais écrits dans le cache applicatif.

## 12. Limites connues et pistes d'amélioration

- Seule la première page de résultats de chaque catégorie est chargée (pas de pagination).
- Le cache n'a pas de durée de validité : il est remplacé à chaque chargement réussi.
- L'interceptor de token est inactif sur le web (voir section 4.3).
- Pistes : pagination, recherche, écran de détail, durée de validité du cache, serveur intermédiaire pour la clé d'API, tests de widgets.
