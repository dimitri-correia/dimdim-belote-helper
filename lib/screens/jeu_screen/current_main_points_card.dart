import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/position.dart';

class CurrentMainPointsCard extends StatelessWidget {
  final EtatJeu etatJeu;

  const CurrentMainPointsCard({
    super.key,
    required this.etatJeu,
  });

  @override
  Widget build(BuildContext context) {
    final parametres = etatJeu.parametres;
    if (parametres == null) return const SizedBox.shrink();

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Main:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              'Nord-Sud',
              style: TextStyle(
                fontSize: 12,
                fontWeight: (parametres.positionJoueur == Position.nord ||
                        parametres.positionJoueur == Position.sud)
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
            Text(
              '${etatJeu.pointsNordSud} pts',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              'Est-Ouest',
              style: TextStyle(
                fontSize: 12,
                fontWeight: (parametres.positionJoueur == Position.est ||
                        parametres.positionJoueur == Position.ouest)
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
            Text(
              '${etatJeu.pointsEstOuest} pts',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
