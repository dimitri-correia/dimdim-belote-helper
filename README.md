# Dimdim Belote Helper

Une application Flutter pour aider à gérer vos parties de Belote Contrée.

## Fonctionnalités

### Phases du jeu

1. **Paramètres** : Configurez votre partie
   - Choisissez la condition de fin (points ou nombre de plis)
   - Définissez votre position à la table (Nord, Sud, Est, Ouest)
   - Sélectionnez le sens de rotation (horaire ou anti-horaire)

2. **Distribution** : Sélectionnez vos cartes
   - Interface intuitive pour choisir vos 8 cartes
   - Cartes organisées par couleur
   - Validation automatique (exactement 8 cartes requises)

3. **Enchères** : Gérez les annonces
   - Suivi automatique du tour de parole
   - Possibilité d'annoncer, passer, contrer ou surcontrer
   - Historique complet des enchères
   - Détection intelligente des options disponibles

4. **Jeu** : Phase de jeu (à implémenter)

## Plateformes supportées

- Android
- Web
- macOS
- Linux

## Installation et lancement

### Prérequis

- Flutter SDK (version 3.0.0 ou supérieure)

### Installation

```bash
flutter pub get
```

### Lancement

#### Web
```bash
flutter run -d chrome
```

#### Linux
```bash
flutter run -d linux
```

#### Android
```bash
flutter run -d android
```

## Règles de la Belote Contrée

Pour plus d'informations sur les règles du jeu, consultez :
https://fr.wikipedia.org/wiki/Belote_contrée

## Structure du projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── carte.dart           # Cartes et couleurs
│   ├── position.dart        # Positions des joueurs
│   ├── annonce.dart         # Annonces (enchères)
│   └── etat_jeu.dart        # État global du jeu
├── screens/                  # Écrans de l'application
│   ├── parametres_screen.dart    # Configuration de la partie
│   ├── distribution_screen.dart  # Sélection des cartes
│   └── encheres_screen.dart      # Gestion des enchères
└── widgets/                  # Composants réutilisables
```

## Développement

### Analyse du code

```bash
flutter analyze
```

### Tests

```bash
flutter test
```

## Licence

Ce projet est open source.
