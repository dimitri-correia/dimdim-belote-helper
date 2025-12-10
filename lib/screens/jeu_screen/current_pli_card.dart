import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/position.dart';

class CurrentPliCard extends StatelessWidget {
  final EtatJeu etatJeu;

  const CurrentPliCard({
    super.key,
    required this.etatJeu,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate current pli number (completed plis + 1 for current pli)
    final currentPliNumber = etatJeu.nombrePlis + 1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Pli en cours: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$currentPliNumber/8',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${etatJeu.pointsPliActuel} pts',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (etatJeu.gagnantPliActuel != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• Prend: ${etatJeu.gagnantPliActuel!.nom}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: etatJeu.pliActuel.map((carteJouee) {
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
          ),
        ),
      ],
    );
  }
}
