# Guide de Test - Améliorations des Enchères

## Changements Implémentés

### 1. Support du Capot
Le Capot est maintenant disponible comme option d'enchère (la plus haute possible).

**Test :**
1. Lancer l'application
2. Configurer une partie (Paramètres → Distribution → Enchères)
3. Dans l'écran des enchères, cocher la case "Capot (prendre tous les plis)"
4. Sélectionner une couleur
5. Cliquer sur "Annoncer Capot"
6. Vérifier que l'historique affiche "Capot [couleur]"
7. Vérifier que plus aucune valeur numérique n'est disponible pour les enchères suivantes

### 2. Position du Donneur
Le donneur doit être sélectionné dans l'écran de distribution.

**Test :**
1. Lancer l'application
2. Aller à Paramètres → Distribution
3. Sélectionner vos 8 cartes
4. Un nouveau champ apparaît : "Qui a distribué les cartes ?"
5. Sélectionner une position (Nord, Sud, Est, Ouest)
6. Le bouton "Continuer vers les enchères" est désactivé jusqu'à ce qu'un donneur soit sélectionné
7. Cliquer sur "Continuer vers les enchères"

### 3. Ordre de Parole Correct
Le premier à parler est maintenant à la droite du donneur.

**Test avec rotation horaire :**
1. Dans Paramètres, choisir "Horaire" pour le sens de rotation
2. Dans Paramètres, choisir votre position (par exemple "Sud")
3. Dans Distribution, choisir le donneur (par exemple "Nord")
4. Continuer vers les Enchères
5. **Vérifier que le premier joueur affiché est "Est"** (à la droite de Nord en horaire)

**Test avec rotation anti-horaire :**
1. Dans Paramètres, choisir "Anti-horaire" pour le sens de rotation
2. Dans Paramètres, choisir votre position (par exemple "Sud")
3. Dans Distribution, choisir le donneur (par exemple "Nord")
4. Continuer vers les Enchères
5. **Vérifier que le premier joueur affiché est "Ouest"** (à la droite de Nord en anti-horaire)

### 4. Saisie des Enchères pour Tous les Joueurs
L'utilisateur peut maintenant saisir les enchères pour n'importe quel joueur.

**Test :**
1. Lancer une partie complète jusqu'aux enchères
2. Observer que le tour du joueur actuel est affiché (par exemple "Tour de Est")
3. Observer le texte "(C'est vous)" si c'est votre tour, sinon "(Sélectionnez l'enchère pour ce joueur)"
4. **Tous les boutons sont activés** (Passe, Annoncer, etc.)
5. Faire une annonce (par exemple "Passe")
6. Vérifier que le tour passe au joueur suivant
7. Faire une autre annonce pour ce nouveau joueur
8. Continuer et vérifier que l'historique enregistre correctement les annonces de chaque joueur

### 5. Logique des Enchères
Vérifier que les règles sont respectées.

**Test des valeurs minimales :**
1. Premier joueur annonce "80 ♠ Pique"
2. Vérifier que seules les valeurs ≥ 90 sont disponibles pour le joueur suivant
3. Deuxième joueur annonce "100 ♥ Cœur"
4. Vérifier que seules les valeurs ≥ 110 sont disponibles

**Test du Contre :**
1. Joueur équipe Nord-Sud annonce "80 ♠ Pique"
2. Vérifier que le bouton "Contre" apparaît pour un joueur Est-Ouest
3. Joueur Est-Ouest clique sur "Contre"
4. Vérifier que le bouton "Surcontré" apparaît pour un joueur Nord-Sud

**Test après Capot :**
1. Un joueur annonce "Capot ♠ Pique"
2. Vérifier qu'aucune valeur numérique n'est plus disponible
3. Seules les options "Passe", "Contre" (si applicable) sont disponibles

### 6. Réinitialisation
Tester la réinitialisation des enchères.

**Test :**
1. Faire plusieurs annonces
2. Cliquer sur l'icône de rafraîchissement (en haut à droite)
3. Vérifier que l'historique est vidé
4. Vérifier que le tour revient au premier joueur (à la droite du donneur)

## Cas d'Usage Complet

### Scénario 1 : Partie Standard
1. **Paramètres** : Position = Sud, Rotation = Horaire, Points = 1000
2. **Distribution** : Sélectionner 8 cartes, Donneur = Ouest
3. **Enchères** :
   - Premier joueur = Nord (à droite de Ouest en horaire)
   - Nord : "Passe"
   - Est : "80 ♣ Trèfle"
   - Sud (vous) : "90 ♠ Pique"
   - Ouest : "Passe"
   - Nord : "Contre"
   - Est : "Passe"
   - Sud : "Surcontré"

### Scénario 2 : Capot
1. **Paramètres** : Position = Nord, Rotation = Anti-horaire, Plis = 10
2. **Distribution** : Sélectionner 8 cartes, Donneur = Sud
3. **Enchères** :
   - Premier joueur = Est (à droite de Sud en anti-horaire)
   - Est : "Passe"
   - Nord (vous) : "Passe"
   - Ouest : "80 ♥ Cœur"
   - Sud : Cocher "Capot", Sélectionner "♥ Cœur", "Annoncer Capot"
   - Vérifier que plus de valeurs numériques disponibles
   - Est : "Passe"
   - Nord : "Contre"
   - Ouest : "Passe"
   - Sud : "Surcontré"

## Vérification des Tests Unitaires

Si Flutter/Dart est installé, exécuter :

```bash
flutter test
```

Les tests suivants devraient passer :
- `test/annonce_test.dart` - Test de l'annonce Capot
- `test/etat_jeu_test.dart` - Tests de la position du donneur et du premier joueur
- `test/position_test.dart` - Tests de rotation
- `test/carte_test.dart` - Tests des cartes
- `test/widget_test.dart` - Tests d'intégration

## Notes

- Les changements sont **rétrocompatibles** : si aucun donneur n'est défini, l'application commence par la position du joueur (comportement précédent)
- L'interface suit les règles de la Belote Contrée selon Wikipedia FR
- L'utilisateur a le contrôle total des enchères pour tous les joueurs (utile pour jouer en solo ou saisir les enchères d'une partie réelle)
