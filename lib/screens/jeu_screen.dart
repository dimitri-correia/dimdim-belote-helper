import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimdim_belote_helper/models/etat_jeu.dart';
import 'package:dimdim_belote_helper/models/carte.dart';
import 'package:dimdim_belote_helper/models/position.dart';

class JeuScreen extends StatefulWidget {
  const JeuScreen({super.key});

  @override
  State<JeuScreen> createState() => _JeuScreenState();
}

class _JeuScreenState extends State<JeuScreen> {
  bool _grayerCartesJouees = false;

  @override
  void initState() {
    super.initState();
    // Initialize the game phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EtatJeu>().commencerJeu();
    });
  }

  void _jouerCarte(Carte carte) {
    context.read<EtatJeu>().jouerCarte(carte);
  }

  String _obtenirOrdreJeu() {
    final etatJeu = context.read<EtatJeu>();
    final parametres = etatJeu.parametres;
    final premierJoueur = etatJeu.premierJoueurPli ?? etatJeu.joueurActuel;
    
    if (parametres == null || premierJoueur == null) return '';

    final ordre = <Position>[];
    var joueur = premierJoueur;
    for (int i = 0; i < 4; i++) {
      ordre.add(joueur);
      joueur = parametres.sensRotation == SensRotation.horaire
          ? joueur.suivant
          : joueur.precedent;
    }

    return 'Ordre: ${ordre.map((p) => p.nom).join(' → ')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<EtatJeu>(
        builder: (context, etatJeu, child) {
          final joueurActuel = etatJeu.joueurActuel;
          final parametres = etatJeu.parametres;
          
          if (joueurActuel == null || parametres == null) {
            return const Center(child: Text('Erreur: données manquantes'));
          }

          final estTourJoueur = joueurActuel == parametres.positionJoueur;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Game info at top
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Plis joués',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${etatJeu.nombrePlis}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Nord-Sud',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${etatJeu.pointsNordSud} pts',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Est-Ouest',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${etatJeu.pointsEstOuest} pts',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Current player info
                Card(
                  color: estTourJoueur ? Colors.green.shade50 : Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          estTourJoueur 
                              ? 'C\'est votre tour'
                              : 'Tour de ${joueurActuel.nom}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: estTourJoueur ? Colors.green.shade900 : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _obtenirOrdreJeu(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Current pli
                if (etatJeu.pliActuel.isNotEmpty) ...[
                  const Text(
                    'Pli en cours:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                  const SizedBox(height: 16),
                ],

                // Toggle button for graying played cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Vos cartes:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _grayerCartesJouees = !_grayerCartesJouees;
                        });
                      },
                      icon: Icon(
                        _grayerCartesJouees
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      label: Text(
                        _grayerCartesJouees
                            ? 'Montrer jouées'
                            : 'Griser jouées',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Player's cards
                Expanded(
                  child: ListView.builder(
                    itemCount: Couleur.values.length,
                    itemBuilder: (context, index) {
                      final couleur = Couleur.values[index];
                      final cartesCouleur = etatJeu.cartesJoueur
                          .where((c) => c.couleur == couleur)
                          .toList();

                      if (cartesCouleur.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                couleur.symbole,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: couleur == Couleur.coeur ||
                                          couleur == Couleur.carreau
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: cartesCouleur.map((carte) {
                                  final estJouee = etatJeu.estCarteJouee(carte);
                                  final estGrisee = _grayerCartesJouees && estJouee;

                                  return ElevatedButton(
                                    onPressed: estTourJoueur
                                        ? () => _jouerCarte(carte)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: estGrisee
                                          ? Colors.grey.shade300
                                          : Colors.white,
                                      foregroundColor: estGrisee
                                          ? Colors.grey.shade600
                                          : (couleur == Couleur.coeur ||
                                                  couleur == Couleur.carreau
                                              ? Colors.red
                                              : Colors.black),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      carte.nomValeur,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
