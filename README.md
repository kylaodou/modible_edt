# EDT Mobile — Emplois du temps sur téléphone

Application mobile Flutter de consultation des emplois du temps universitaires, avec un espace
pour les enseignants et un espace pour les étudiants.

Elle fait partie du même projet que l'application web [`edtweb`](https://github.com/kylaodou/edtweb)
et l'API [`apiEDT`](https://github.com/kylaodou/apiEDT).

## Fonctionnalités

### Commun
- Écran de démarrage et présentation (onboarding).
- Inscription, connexion et vérification par code ; connexion Google et Facebook.
- Notifications.

### Enseignants
- Tableau de bord et accueil.
- Emploi du temps personnel.
- Saisie de ses disponibilités.
- Suivi des séances effectuées.
- Profil.

### Étudiants
- Tableau de bord et accueil.
- Emploi du temps de sa classe.
- Profil détaillé, changement de photo (recadrage), changement de mot de passe.
- Paramètres de notification.

## Stack technique

- Flutter (Dart 3.5+)
- Firebase Core, Auth et Storage
- Google Sign-In, Facebook Auth
- http, shared_preferences
- Lottie, google_nav_bar, image_picker, image_cropper

## Prérequis

- Flutter SDK 3.24 ou plus
- Android Studio ou Xcode, avec un émulateur ou un téléphone connecté
- Un projet Firebase configuré pour l'application (fichier `lib/firebase_options.dart`)

## Installation et lancement

```bash
git clone https://github.com/kylaodou/modible_edt.git
cd modible_edt
flutter pub get
flutter run
```

L'adresse de l'API se règle dans `lib/core/constants.dart`. Sur un émulateur Android, utilisez
`http://10.0.2.2:8080/api` pour joindre l'API lancée sur l'ordinateur.

Pour reconfigurer Firebase avec votre propre projet :

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

## Build

```bash
flutter build apk --release
```

## Auteur

[@kylaodou](https://github.com/kylaodou)
