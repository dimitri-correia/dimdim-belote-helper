import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/position.dart';

class CompletedPlisHistory extends StatelessWidget {
  final EtatJeu etatJeu;

  const CompletedPlisHistory({
    super.key,
    required this.etatJeu,
  });

  @override
  Widget build(BuildContext context) {
    if (etatJeu.plisTermines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historique des plis:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...etatJeu.plisTermines.asMap().entries.map((entry) {
          final index = entry.key;
          final pli = entry.value;
          final isLastPli = index == etatJeu.plisTermines.length - 1;

          return Card(
            color: isLastPli ? Colors.amber.shade50 : null,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pli ${index + 1}${isLastPli ? " (dernier)" : ""}:',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${pli.points} pts',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pli.cartes.map((carteJouee) {
                      return Chip(
                        avatar: CircleAvatar(
                          child: Text(carteJouee.joueur.nom[0]),
                        ),
                        label: Text(
                          carteJouee.carte.toString(),
                          style: TextStyle(
                            color: carteJouee.carte.couleur == Couleur.coeur ||
                                    carteJouee.carte.couleur == Couleur.carreau
                                ? Colors.red
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gagné par: ${pli.gagnant.nom}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
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
