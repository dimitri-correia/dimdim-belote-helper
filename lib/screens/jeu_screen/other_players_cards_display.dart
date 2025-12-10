import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/models/carte.dart';

class OtherPlayersCardsDisplay extends StatelessWidget {
  final EtatJeu etatJeu;
  final Position positionJoueur;

  const OtherPlayersCardsDisplay({
    super.key,
    required this.etatJeu,
    required this.positionJoueur,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cartes jouées par les autres joueurs:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...Position.values.where((p) => p != positionJoueur).map((position) {
          final cartesJouees = etatJeu.cartesJoueesParJoueur[position] ?? [];
          if (cartesJouees.isEmpty) return const SizedBox.shrink();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${position.nom}:',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cartesJouees.map((carte) {
                      return Chip(
                        label: Text(
                          carte.toString(),
                          style: TextStyle(
                            color: carte.couleur == Couleur.coeur ||
                                    carte.couleur == Couleur.carreau
                                ? Colors.red
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
