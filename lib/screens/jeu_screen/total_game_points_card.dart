import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';

class TotalGamePointsCard extends StatelessWidget {
  final EtatJeu etatJeu;
  final Function(EtatJeu) buildPointsBreakdown;

  const TotalGamePointsCard({
    super.key,
    required this.etatJeu,
    required this.buildPointsBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    final parametres = etatJeu.parametres;
    if (parametres == null) return const SizedBox.shrink();

    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            // First line: Team labels and scores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Points: '),
                // Nord-Sud
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('N-S: '),
                      Text(
                        '${etatJeu.pointsTotauxNordSud}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Separator
                const Text('—'),

                // Est-Ouest
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('E-O: '),
                      Text(
                        '${etatJeu.pointsTotauxEstOuest}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Second line: Mains counter and objective
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Mains: '),
                Text(
                  parametres.conditionFin == ConditionFin.plis
                      ? '${etatJeu.nombreMains}/${parametres.valeurFin}'
                      : '${etatJeu.nombreMains}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (parametres.conditionFin == ConditionFin.points) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• Objectif: ${parametres.valeurFin} pts',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),

            // Show detailed breakdown if main is complete
            if (etatJeu.nombrePlis == 8) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              buildPointsBreakdown(etatJeu),
            ],
          ],
        ),
      ),
    );
  }
}
