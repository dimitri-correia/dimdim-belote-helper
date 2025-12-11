import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';

class PointsBreakdownWidget extends StatelessWidget {
  final EtatJeu etatJeu;

  const PointsBreakdownWidget({
    super.key,
    required this.etatJeu,
  });

  @override
  Widget build(BuildContext context) {
    final details = etatJeu.calculerPointsDetailles();
    final annonce = details['annonce'] as int;
    final mult = details['multiplicateur'] as int;
    final prenantNordSud = details['prenantNordSud'] as bool;
    final contractReussi = details['contractReussi'] as bool;
    final pointsMainNordSud = details['pointsMainNordSud'] as int;
    final pointsMainEstOuest = details['pointsMainEstOuest'] as int;
    final pointsGagnesNordSud = details['pointsGagnesNordSud'] as int;
    final pointsGagnesEstOuest = details['pointsGagnesEstOuest'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails de cette main:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),

        // Nord-Sud breakdown
        Row(
          children: [
            Text(
              'Nord-Sud: ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: prenantNordSud ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (pointsGagnesNordSud > 0) ...[
              if (prenantNordSud && contractReussi) ...[
                Text(
                  '$annonce',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text(' + ', style: TextStyle(fontSize: 11)),
                Text(
                  '$pointsMainNordSud',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (mult > 1) ...[
                  Text(' × $mult', style: const TextStyle(fontSize: 11)),
                ],
                Text(' = ',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                Text(
                  '$pointsGagnesNordSud',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ] else ...[
                // Defense wins
                Text(
                  '${EtatJeu.pointsDefenseContratChute}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Text(' + ', style: TextStyle(fontSize: 11)),
                Text(
                  '$annonce',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (mult > 1) ...[
                  Text(' × $mult', style: const TextStyle(fontSize: 11)),
                ],
                Text(' = ',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                Text(
                  '$pointsGagnesNordSud',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ] else ...[
              Text(
                '0',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),

        // Est-Ouest breakdown
        Row(
          children: [
            Text(
              'Est-Ouest: ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: !prenantNordSud ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (pointsGagnesEstOuest > 0) ...[
              if (!prenantNordSud && contractReussi) ...[
                Text(
                  '$annonce',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text(' + ', style: TextStyle(fontSize: 11)),
                Text(
                  '$pointsMainEstOuest',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                if (mult > 1) ...[
                  Text(' × $mult', style: const TextStyle(fontSize: 11)),
                ],
                Text(' = ',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                Text(
                  '$pointsGagnesEstOuest',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ] else ...[
                // Defense wins
                Text(
                  '${EtatJeu.pointsDefenseContratChute}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Text(' + ', style: TextStyle(fontSize: 11)),
                Text(
                  '$annonce',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (mult > 1) ...[
                  Text(' × $mult', style: const TextStyle(fontSize: 11)),
                ],
                Text(' = ',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                Text(
                  '$pointsGagnesEstOuest',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ] else ...[
              Text(
                '0',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          contractReussi ? '✓ Contrat réussi' : '✗ Contrat chuté',
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: contractReussi ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ],
    );
  }
}
