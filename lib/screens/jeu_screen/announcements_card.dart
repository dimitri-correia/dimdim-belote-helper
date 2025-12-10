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
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Atout section with distinct background
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400, width: 1.5),
              ),
              child: Center(
                child: Text(
                  etatJeu.atout!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: estCouleurRouge(etatJeu.atout!)
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Scrollable announcements section
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: etatJeu.annonces.map((annonce) {
                    final isWinning = etatJeu.annonceGagnante == annonce;
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isWinning
                            ? Colors.green.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: isWinning
                            ? Border.all(
                                color: Colors.green.shade700,
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            child: Text(
                              annonce.joueur.nom[0],
                              style: const TextStyle(fontSize: 9),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            annonce.texte,
                            style: TextStyle(
                              fontWeight: isWinning
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                          if (isWinning) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.green.shade700,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
