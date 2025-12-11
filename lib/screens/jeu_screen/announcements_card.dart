import 'package:flutter/material.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/position.dart';

class AnnouncementsCard extends StatelessWidget {
  final EtatJeu etatJeu;
  final bool Function(String) estCouleurRouge;

  const AnnouncementsCard({
    super.key,
    required this.etatJeu,
    required this.estCouleurRouge,
  });

  @override
  Widget build(BuildContext context) {
    if (etatJeu.annonces.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Atout',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (etatJeu.atout != null)
                  Text(
                    etatJeu.atout!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: estCouleurRouge(etatJeu.atout!)
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: etatJeu.annonces.map((annonce) {
                  final isWinning = etatJeu.annonceGagnante == annonce;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isWinning
                          ? Colors.green.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: isWinning
                          ? Border.all(
                              color: Colors.green.shade700,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          child: Text(
                            annonce.joueur.nom[0],
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          annonce.texte,
                          style: TextStyle(
                            fontWeight: isWinning
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        if (isWinning) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
