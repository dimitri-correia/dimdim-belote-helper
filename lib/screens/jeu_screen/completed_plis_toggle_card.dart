import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';

class CompletedPlisToggleCard extends StatelessWidget {
  final EtatJeu etatJeu;
  final bool afficherTousLesPlis;
  final ValueChanged<bool> onToggle;

  const CompletedPlisToggleCard({
    super.key,
    required this.etatJeu,
    required this.afficherTousLesPlis,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (etatJeu.plisTermines.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Afficher tous les plis (${etatJeu.plisTermines.length}):',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch(
              value: afficherTousLesPlis,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}
