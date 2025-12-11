import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/position.dart';

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title
            const Text(
              'Points totaux de la partie',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Score display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nord-Sud score
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Nord-Sud',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: (parametres.positionJoueur ==
                                      Position.nord ||
                                  parametres.positionJoueur == Position.sud)
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${etatJeu.pointsTotauxNordSud}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Separator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '—',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),

                // Est-Ouest score
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Est-Ouest',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: (parametres.positionJoueur ==
                                      Position.est ||
                                  parametres.positionJoueur == Position.ouest)
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${etatJeu.pointsTotauxEstOuest}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Plis counter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  parametres.conditionFin == ConditionFin.plis
                      ? 'Plis: '
                      : 'Plis joués: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  parametres.conditionFin == ConditionFin.plis
                      ? '${etatJeu.nombrePlis}/${parametres.valeurFin}'
                      : '${etatJeu.nombrePlis}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (parametres.conditionFin == ConditionFin.points)
                  Text(
                    ' (objectif: ${parametres.valeurFin} pts)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),

            // Show detailed breakdown if main is complete
            if (etatJeu.nombrePlis == 8) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              buildPointsBreakdown(etatJeu),
            ],
          ],
        ),
      ),
    );
  }
}
