import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/models/carte.dart';

class MissingColorsCard extends StatelessWidget {
  final EtatJeu etatJeu;
  final Position positionJoueur;

  const MissingColorsCard({
    super.key,
    required this.etatJeu,
    required this.positionJoueur,
  });

  @override
  Widget build(BuildContext context) {
    if (!etatJeu.couleursManquantes.values.any((s) => s.isNotEmpty)) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Couleurs manquantes:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...Position.values.map((pos) {
              final couleursManquantes = etatJeu.couleursManquantes[pos] ?? {};
              if (couleursManquantes.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(
                      '${pos.nom}: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: pos == positionJoueur
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    ...couleursManquantes.map((couleur) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          couleur.symbole,
                          style: TextStyle(
                            fontSize: 16,
                            color: couleur == Couleur.coeur ||
                                    couleur == Couleur.carreau
                                ? Colors.red
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
