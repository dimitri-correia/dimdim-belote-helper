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

  @override
  Widget build(BuildContext context) {
    final parametres = etatJeu.parametres;
    if (parametres == null) return const SizedBox.shrink();

    final estJoueurPrincipal = position == parametres.positionJoueur;

    // Get played and remaining cards for this position
    final cartesJouees = etatJeu.cartesJoueesParJoueur[position] ?? [];

    // Combine current and played cards
    final cartesCourantes = estJoueurPrincipal
        ? etatJeu.cartesJoueur
        : etatJeu.getCartesJoueur(position);

    // Use a Set to track unique cards efficiently
    final cartesUniques = <String, Carte>{};

    // Add current cards
    for (final carte in cartesCourantes) {
      final key = '${carte.couleur.index}_${carte.valeur.index}';
      cartesUniques[key] = carte;
    }

    // Add played cards (Map keys automatically handle duplicates)
    for (final carte in cartesJouees) {
      final key = '${carte.couleur.index}_${carte.valeur.index}';
      cartesUniques[key] = carte;
    }

    // Group cards by color once and sort them
    final cartesByCouleur = <Couleur, List<Carte>>{};
    for (final carte in cartesUniques.values) {
      cartesByCouleur.putIfAbsent(carte.couleur, () => []).add(carte);
    }

    // Flatten all cards into a single list, grouped by color
    final toutesLesCartes = <Widget>[];
    for (final couleur in Couleur.values) {
      final cartesAffichees = cartesByCouleur[couleur] ?? [];
      if (cartesAffichees.isEmpty) continue;

      for (final carte in cartesAffichees) {
        final estJouee = etatJeu.estCarteJoueeParJoueur(position, carte);
        final estValide = !estJouee ? etatJeu.peutJouerCarte(carte) : false;

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
