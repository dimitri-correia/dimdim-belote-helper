import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/position.dart';

class CurrentPlayerInfoCard extends StatelessWidget {
  final Position joueurActuel;
  final bool estTourJoueur;
  final String ordreJeu;

  const CurrentPlayerInfoCard({
    super.key,
    required this.joueurActuel,
    required this.estTourJoueur,
    required this.ordreJeu,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: estTourJoueur ? Colors.green.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Tour de ${joueurActuel.nom} ${estTourJoueur ? "(vous)" : ""}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: estTourJoueur ? Colors.green.shade900 : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              ordreJeu,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
