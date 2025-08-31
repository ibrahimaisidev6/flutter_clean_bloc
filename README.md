# Payment App (Flutter Front-End)

Ce projet est le frontend de l'application de gestion de paiements, développé avec Flutter. Il interagit avec le backend Laravel pour l'authentification, la gestion des paiements et l'affichage des statistiques.

## Table des Matières

- [Technologies Utilisées](#technologies-utilisées)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Exécution de l'Application](#exécution-de-lapplication)
- [Structure du Projet](#structure-du-projet)
- [Tests](#tests)
- [Déploiement](#déploiement)

## Technologies Utilisées

- **Flutter**: Stable channel (version 3.35.2 ou supérieure)
- **Dart**: (version compatible avec Flutter)
- **BLoC**: Pour la gestion d'état
- **GetIt**: Pour l'injection de dépendances
- **Dio**: Pour les requêtes HTTP vers l'API Laravel
- **shared_preferences**: Pour le stockage local des tokens d'authentification

## Prérequis

Assurez-vous d'avoir les éléments suivants installés sur votre machine :

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Un éditeur de code (VS Code, Android Studio) avec les plugins Flutter et Dart installés.
- Un appareil Android/iOS, un émulateur/simulateur, ou un navigateur web pour exécuter l'application.

## Installation

1.  **Cloner le dépôt :**
    ```bash
    git clone <URL_DU_DEPOT_FRONTEND>
    cd payment_app
    ```

2.  **Installer les dépendances Flutter :**
    ```bash
    flutter pub get
    ```

## Configuration

1.  **Configuration de l'API URL :**
    Ouvrez le fichier `lib/core/constants/api_constants.dart` et assurez-vous que `baseUrl` pointe vers l'URL de votre backend Laravel (par défaut `http://localhost:8000/api`).

    ```dart
    class ApiConstants {
      static const String baseUrl = 'http://localhost:8000/api';
      // ... autres constantes
    }
    ```

2.  **Initialisation de l'injection de dépendances :**
    Le fichier `lib/injection_container.dart` contient la configuration de GetIt. Assurez-vous que toutes les dépendances sont correctement enregistrées.

## Exécution de l'Application

1.  **Démarrer le serveur backend Laravel :**
    Assurez-vous que votre backend Laravel est en cours d'exécution et accessible à l'URL configurée dans `api_constants.dart`.
    ```bash
    cd ../payment_backend
    php artisan serve
    ```

2.  **Exécuter l'application Flutter :**
    Depuis le répertoire `payment_app` :

    - **Pour le Web :**
      ```bash
      flutter run -d chrome
      ```
      (ou un autre navigateur de votre choix)

    - **Pour Android/iOS (appareil ou émulateur) :**
      ```bash
      flutter run
      ```

    - **Pour Desktop (Linux, macOS, Windows) :**
      ```bash
      flutter run -d linux
      ```
      (ou `windows`, `macos`)

## Structure du Projet

La structure détaillée du projet est décrite dans le fichier `project_structure.md`.

## Tests

Pour exécuter les tests unitaires et de widgets :

```bash
flutter test
```

## Déploiement

### Déploiement Web (Flutter Web)

1.  **Construire l'application web :**
    ```bash
    flutter build web
    ```
    Les fichiers statiques seront générés dans le répertoire `build/web`.

2.  **Hébergement :**
    Vous pouvez héberger le contenu du répertoire `build/web` sur un serveur web statique (ex: Nginx, Apache) ou un service de stockage cloud comme AWS S3 + CloudFront.

### Déploiement Mobile (Android)

1.  **Construire l'APK Android :**
    ```bash
    flutter build apk --release
    ```
    Le fichier APK sera généré dans `build/app/outputs/flutter-apk/app-release.apk`.

2.  **Distribution :**
    Vous pouvez distribuer cet APK manuellement ou via des plateformes comme Google Play Console. Pour le test technique, vous pouvez le partager via un service de partage de fichiers ou GitHub Releases.

### Déploiement Mobile (iOS)

1.  **Construire l'IPA iOS (nécessite macOS) :**
    ```bash
    flutter build ipa --release
    ```

2.  **Distribution :**
    La distribution iOS se fait généralement via TestFlight ou l'App Store Connect.