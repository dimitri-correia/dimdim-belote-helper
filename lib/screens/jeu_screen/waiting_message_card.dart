import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/position.dart';

class WaitingMessageCard extends StatelessWidget {
  final Position joueurActuel;

  const WaitingMessageCard({
    super.key,
    required this.joueurActuel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: Colors.orange.shade700,
            ),
            const SizedBox(height: 12),
            Text(
              'En attente de ${joueurActuel.nom}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vous ne pouvez jouer que vos propres cartes pendant votre tour',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
