# Guide d'utilisation - Belote Contrée Helper

## Vue d'ensemble

Cette application Flutter aide à gérer les parties de Belote Contrée en suivant les règles officielles. L'application est entièrement en français et fonctionne sur Android, Web, macOS et Linux.

## Architecture de l'application

### Modèles de données

#### 1. Carte (carte.dart)
- **Couleur** : Pique (♠), Cœur (♥), Carreau (♦), Trèfle (♣)
- **Valeur** : 7, 8, 9, Valet, Dame, Roi, 10, As
- Affichage avec symboles Unicode pour les couleurs

#### 2. Position (position.dart)
- 4 positions : Nord, Sud, Est, Ouest
- Navigation entre positions (suivant/précédent) pour gérer la rotation

#### 3. Annonce (annonce.dart)
- Types d'annonces :
  - **Passe** : Le joueur ne fait pas d'annonce
  - **Prise** : Annonce avec valeur (80-160) et couleur
  - **Capot** : Annonce de prendre tous les plis (la plus haute enchère)
  - **Contre** : Doubler le contrat de l'équipe adverse
  - **Surcontré** : Re-doubler après un contre

#### 4. État du jeu (etat_jeu.dart)
- Gestion centralisée de l'état avec Provider
- Paramètres de jeu (incluant position du donneur)
- Cartes du joueur
- Historique des annonces
- Suivi du joueur actuel (basé sur la position du donneur)

### Écrans

#### 1. Écran d'accueil (main.dart)
- Bienvenue et présentation
- Bouton pour démarrer une nouvelle partie
- Accès aux règles du jeu

#### 2. Paramètres (parametres_screen.dart)
Configuration de la partie avec :
- **Condition de fin** :
  - Points (généralement 1000)
  - Nombre de plis (généralement 10)
- **Position du joueur** : Nord, Sud, Est, Ouest
- **Sens de rotation** : Horaire ou Anti-horaire

Ces paramètres sont essentiels pour :
- Déterminer qui parle en premier aux enchères
- Gérer l'ordre de jeu
- Savoir quand la partie se termine

#### 3. Distribution (distribution_screen.dart)
Sélection des cartes du joueur et du donneur :
- Affichage de toutes les cartes par couleur
- Sélection interactive avec FilterChips
- Validation : exactement 8 cartes requises
- Code couleur : rouge pour ♥♦, noir pour ♠♣
- Cartes sélectionnées mises en évidence
- **Sélection du donneur** : Détermine qui parle en premier

#### 4. Enchères (encheres_screen.dart)
Gestion des annonces :

**Interface intelligente** :
- Affichage du joueur actuel dont on saisit l'enchère
- L'utilisateur peut saisir les enchères pour tous les joueurs
- Le premier à parler est à la droite du donneur (selon le sens de rotation)
- Historique complet des annonces avec nom du joueur

**Options disponibles** :
1. **Passe** : Toujours disponible
2. **Annonce** : Choix de la valeur et de la couleur
   - Sélection de la valeur (80, 90, 100, etc.)
   - Sélection de la couleur (♠♥♦♣, SA, TA)
   - Option **Capot** : Annonce de prendre tous les plis (plus haute enchère)
   - Validation automatique des valeurs minimales
3. **Contre** : Disponible si annonce adverse active
4. **Surcontré** : Disponible après un contre

**Logique des enchères** :
- Ordre de parole basé sur la position du donneur
- Suivi automatique du tour de parole
- Les valeurs minimales augmentent par paliers de 10
- Le Capot bloque toute enchère supérieure
- Détection des équipes (Nord-Sud vs Est-Ouest)
- Le contre n'est possible que contre l'équipe adverse
- Possibilité de réinitialiser les enchères

## Flux de l'application

```
Écran d'accueil
    ↓
Paramètres (configuration)
    ↓
Distribution (sélection des cartes et du donneur)
    ↓
Enchères (annonces pour tous les joueurs)
    ↓
Jeu (à implémenter)
```

## Fonctionnalités techniques

### Gestion de l'état
- Utilisation de Provider pour la gestion d'état réactive
- ChangeNotifier pour notifier les changements
- État global accessible depuis tous les écrans

### Navigation
- Routes standards Flutter avec Navigator.push
- Passage de contexte pour accéder à l'état

### Interface utilisateur
- Material Design 3
- Responsive design
- Cards pour regrouper les éléments
- ElevatedButton, RadioListTile, FilterChip, etc.
- Code couleur intuitif

### Validation
- Validation du nombre de cartes (8 exactes)
- Validation des annonces (valeur minimale)
- Désactivation des boutons si conditions non remplies

## Règles implémentées

### Distribution
- Chaque joueur a 8 cartes
- 32 cartes au total (4 couleurs × 8 valeurs)

### Enchères
Selon les règles de la Belote Contrée :
- Annonces de 80 à 160 points
- Possibilité de passer
- Contre et surcontré
- Rotation des joueurs
- Équipes : Nord-Sud vs Est-Ouest

## Extensions possibles

### Phase "Jeu" (à implémenter)
- Affichage du tapis (cartes jouées)
- Suivi des plis
- Calcul des points
- Annonces de belote, rebelote
- Déclaration des atouts

### Fonctionnalités additionnelles
- Historique des parties
- Statistiques
- Mode multijoueur en ligne
- Sauvegarde automatique
- Thèmes personnalisables
- Support de plusieurs langues

## Tests suggérés

1. **Paramètres** :
   - Modifier chaque option
   - Vérifier la persistance

2. **Distribution** :
   - Sélectionner moins/plus de 8 cartes
   - Désélectionner des cartes
   - Vérifier le compteur

3. **Enchères** :
   - Tester la rotation des joueurs
   - Essayer de contrer sa propre équipe
   - Vérifier les valeurs minimales
   - Tester l'historique

## Déploiement

### Web
L'application est prête pour le déploiement web avec :
- index.html configuré
- manifest.json pour PWA
- Support du service worker

### Android
Nécessite la configuration de :
- android/app/build.gradle
- AndroidManifest.xml
- Permissions

### Linux/macOS
Configurations natives disponibles via Flutter

## Conclusion

Cette application implémente les phases essentielles de la Belote Contrée :
- ✅ Configuration de la partie
- ✅ Distribution des cartes
- ✅ Gestion des enchères
- ⏳ Phase de jeu (à venir)

Le code est modulaire, bien structuré et facilement extensible pour ajouter de nouvelles fonctionnalités.