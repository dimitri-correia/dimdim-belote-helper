import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/position.dart';

class PlayerCardsWidget extends StatelessWidget {
  final EtatJeu etatJeu;
  final Position position;
  final void Function(Carte) jouerCarte;

  const PlayerCardsWidget({
    super.key,
    required this.etatJeu,
    required this.position,
    required this.jouerCarte,
  });

  /// Compare two cards for sorting
  /// Returns negative if a should come before b, positive if b should come before a
  /// Cards are sorted in descending order of value (highest value first)
  /// 
  /// This uses the same ordering as etat_jeu.dart's comparison methods but adapted for sorting
  int _comparerCartes(Carte a, Carte b, bool estAtout) {
    if (estAtout) {
      // Trump order (low to high): 7, 8, Dame, Roi, 10, As, 9, Valet
      // Same as _comparerValeursAtout in etat_jeu.dart
      const ordre = [
        Valeur.sept,   // 0 points
        Valeur.huit,   // 0 points
        Valeur.dame,   // 3 points
        Valeur.roi,    // 4 points
        Valeur.dix,    // 10 points
        Valeur.as,     // 11 points
        Valeur.neuf,   // 14 points
        Valeur.valet,  // 20 points
      ];
      final indexA = ordre.indexOf(a.valeur);
      final indexB = ordre.indexOf(b.valeur);
      // Higher index = stronger card, so reverse the comparison for descending sort
      return indexB.compareTo(indexA);
    } else {
      // Non-trump order (low to high): 7, 8, 9, Valet, Dame, Roi, 10, As
      // Same as _comparerValeursNonAtout in etat_jeu.dart
      const ordre = [
        Valeur.sept,   // 0 points
        Valeur.huit,   // 0 points
        Valeur.neuf,   // 0 points
        Valeur.valet,  // 2 points
        Valeur.dame,   // 3 points
        Valeur.roi,    // 4 points
        Valeur.dix,    // 10 points
        Valeur.as,     // 11 points
      ];
      final indexA = ordre.indexOf(a.valeur);
      final indexB = ordre.indexOf(b.valeur);
      // Higher index = stronger card, so reverse the comparison for descending sort
      return indexB.compareTo(indexA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parametres = etatJeu.parametres;
    if (parametres == null) return const SizedBox.shrink();

    final estJoueurPrincipal = position == parametres.positionJoueur;

    // Get played and remaining cards for this position
    final cartesJouees = etatJeu.cartesJoueesParJoueur[position] ?? [];

    // Use a Set to track unique cards efficiently
    final cartesUniques = <String, Carte>{};

    // For the main player, show their actual cards
    if (estJoueurPrincipal) {
      // Add current cards from their hand
      for (final carte in etatJeu.cartesJoueur) {
        final key = '${carte.couleur.index}_${carte.valeur.index}';
        cartesUniques[key] = carte;
      }
      // Add played cards
      for (final carte in cartesJouees) {
        final key = '${carte.couleur.index}_${carte.valeur.index}';
        cartesUniques[key] = carte;
      }
    } else {
      // For other players, show:
      // 1. All cards that haven't been played by anyone yet (as possible cards to play)
      //    EXCEPT the main player's cards (they can't have those in hand)
      // 2. The cards this specific player has already played (for reference, shown as disabled)
      
      // Add all their played cards
      for (final carte in cartesJouees) {
        final key = '${carte.couleur.index}_${carte.valeur.index}';
        cartesUniques[key] = carte;
      }
      
      // Add all unplayed cards as possibilities, excluding main player's cards
      // Note: We generate all 32 possible cards (4 colors × 8 values) and filter them.
      // This is acceptable because: 1) The game has only 32 cards total,
      // 2) The list shrinks as cards are played, and 3) The code is clearer this way.
      for (final couleur in Couleur.values) {
        for (final valeur in Valeur.values) {
          final carte = Carte(couleur: couleur, valeur: valeur);
          // Only add if not played by anyone yet AND not in main player's hand
          if (!etatJeu.estCarteJoueeParQuiconque(carte) && 
              !etatJeu.cartesJoueur.any((c) => c.couleur == carte.couleur && c.valeur == carte.valeur)) {
            final key = '${carte.couleur.index}_${carte.valeur.index}';
            cartesUniques[key] = carte;
          }
        }
      }
    }

    // Group cards by color once and sort them
    final cartesByCouleur = <Couleur, List<Carte>>{};
    for (final carte in cartesUniques.values) {
      cartesByCouleur.putIfAbsent(carte.couleur, () => []).add(carte);
    }

    // Get trump color for sorting
    final trumpCouleur = etatJeu.atoutCouleur;

    // Flatten all cards into a single list, grouped by color
    final toutesLesCartes = <Widget>[];
    for (final couleur in Couleur.values) {
      final cartesAffichees = cartesByCouleur[couleur] ?? [];
      if (cartesAffichees.isEmpty) continue;

      // Sort cards within this color by value
      // If this color is trump, use trump order; otherwise use non-trump order
      final estAtout = trumpCouleur != null && couleur == trumpCouleur;
      cartesAffichees.sort((a, b) => _comparerCartes(a, b, estAtout));

      for (final carte in cartesAffichees) {
        final estJouee = etatJeu.estCarteJoueeParJoueur(position, carte);
        final estValide = !estJouee ? etatJeu.peutJouerCartePosition(carte, position) : false;

        toutesLesCartes.add(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed:
                    (!estJouee && estValide) ? () => jouerCarte(carte) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      estJouee ? Colors.grey.shade300 : Colors.white,
                  foregroundColor: estJouee
                      ? Colors.grey.shade600
                      : (couleur == Couleur.coeur || couleur == Couleur.carreau
                          ? Colors.red
                          : Colors.black),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      couleur.symbole,
                      style: TextStyle(
                        fontSize: 14,
                        color: couleur == Couleur.coeur ||
                                couleur == Couleur.carreau
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      carte.nomValeur,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (estJouee)
                Text(
                  'Jouée',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          estJoueurPrincipal ? 'Vos cartes:' : 'Cartes de ${position.nom}:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: toutesLesCartes,
            ),
          ),
        ),
      ],
    );
  }
}
