# Cinemix

Application Flutter de consultation de films et de séries, construite autour de l'API publique TMDB. Elle propose une authentification Firebase, trois écrans de données, un cache local et un mode hors-ligne.

## Fonctionnalités

- Inscription, connexion et déconnexion avec Firebase Authentication (email et mot de passe).
- Trois écrans de données : films populaires, séries populaires, films à venir.
- Appels réseau avec Dio, via un interceptor chargé d'ajouter le token d'authentification et de le renouveler en cas de réponse 401.
- Mise en cache locale des données avec Hive.
- Mode hors-ligne : si le réseau est indisponible, les dernières données enregistrées sont affichées.
- Messages d'erreur clairs (SnackBar, bandeau d'information et écran d'erreur avec bouton de nouvel essai).
- Tests unitaires de la couche repository.

## Architecture

Le projet suit une organisation par fonctionnalité (feature-first). Chaque fonctionnalité est découpée en trois couches, avec le pattern Repository entre la logique applicative et les sources de données.

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
      data/           Implémentation AuthRepositoryImpl (Firebase Auth)
      presentation/   AuthBloc, pages de connexion et d'inscription
    catalog/
      domain/         Entités, contrat CatalogRepository
      data/           Modèle, sources de données distante et locale, repository
      presentation/   CatalogCubit, page et widgets
    home/
      presentation/   Page principale avec navigation par onglets
  app.dart
  main.dart
test/
  features/catalog/data/repositories/
```

### Responsabilité des couches

- **domain** : entités et contrats (interfaces des repositories). Cette couche ne dépend ni de Firebase, ni de Dio, ni de Hive.
- **data** : implémentation des contrats, accès au réseau et au stockage local, conversion entre JSON et objets.
- **presentation** : widgets et gestion d'état. Elle ne connaît que les contrats du domaine.

Cette séparation permet de remplacer une source de données sans toucher aux écrans, et de tester les repositories avec de faux objets.

## Choix techniques

| Besoin           | Choix         | Justification                                                                                |
| ---------------- | ------------- | -------------------------------------------------------------------------------------------- |
| Authentification | Firebase Auth | Gestion de session, renouvellement du token et persistance fournis par le SDK                |
| Réseau           | Dio           | Interceptors, délais d'attente, gestion fine des erreurs                                     |
| Gestion d'état   | flutter_bloc  | Bloc pour l'authentification (événements), Cubit pour le catalogue (chargement simple)       |
| Navigation       | go_router     | Redirections déclaratives selon l'état de connexion                                          |
| Cache            | Hive          | Stockage clé-valeur léger ; les données sont stockées en JSON texte, sans génération de code |
| Tests            | mocktail      | Faux objets sans génération de code                                                          |
| API de données   | TMDB          | API publique documentée, riche en contenus                                                   |

## Fonctionnement du réseau et du cache

1. Le `CatalogRepositoryImpl` interroge d'abord l'API TMDB.
2. En cas de succès, la réponse est enregistrée dans Hive et renvoyée.
3. En cas d'échec (réseau, délai dépassé, erreur serveur), le repository lit le cache. S'il contient des données, elles sont renvoyées avec l'erreur d'origine ; l'interface affiche alors un bandeau et une SnackBar.
4. S'il n'y a pas de cache, l'erreur est propagée et l'écran affiche un message avec un bouton « Réessayer ».

Les erreurs techniques (`DioException`) sont converties en erreurs métier (`NetworkFailure`, `ServerFailure`, `AuthFailure`, etc.) dont le message est directement affichable.

### Interceptor d'authentification

`AuthInterceptor` ajoute le token d'identité Firebase à chaque requête dans l'en-tête `X-Firebase-Token`. Lorsqu'une réponse 401 est reçue, il demande un nouveau token à Firebase, puis rejoue la requête une seule fois.

Sur la plateforme web, cet interceptor est désactivé : un en-tête personnalisé déclenche une vérification préalable du navigateur (CORS) que l'API TMDB n'autorise pas, ce qui bloquerait toutes les requêtes. Il reste actif sur Android et iOS. L'API TMDB elle-même est authentifiée par la clé d'API.

## Configuration

### Prérequis

- Flutter (SDK stable récent)
- Un compte Firebase
- Une clé d'API TMDB (gratuite, v3)
- Node.js, pour l'outil Firebase en ligne de commande

### Installation

1. Cloner le dépôt puis installer les dépendances :

```
   flutter pub get
```

2. Créer un projet dans la console Firebase et activer **Authentication > Email/Password**.
3. Générer la configuration Firebase :

```
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
```

Cette commande crée le fichier `lib/firebase_options.dart`. 4. Créer un fichier `.env` à la racine du projet :

```
   TMDB_API_KEY=votre_cle_api_tmdb
```

Ce fichier est ignoré par Git. Un fichier `.env.example` sert de modèle.

### Lancement

- Android ou iOS :

```
  flutter run
```

- Web :

```
  flutter run -d chrome
```

ou, sans débogueur :

```
  flutter run -d web-server --web-port 5000
```

Firebase Authentication n'est pas disponible sur Linux desktop : il faut lancer l'application sur Android, iOS ou le web.

## Tests

```
flutter test
```

Les tests de `CatalogRepositoryImpl` vérifient :

- le retour des données distantes et leur enregistrement en cache ;
- le repli sur le cache, avec l'erreur d'origine, quand le réseau échoue ;
- la propagation de l'erreur quand le réseau échoue et que le cache est absent ;
- la propagation de l'erreur quand le cache est vide.

## Limites connues

- Seule la première page de résultats de chaque catégorie est chargée (pas de pagination).
- Le cache n'a pas de durée de validité : il est remplacé à chaque chargement réussi.
- La clé d'API TMDB est embarquée dans l'application. Pour un déploiement public, il faudrait passer par un serveur intermédiaire.
