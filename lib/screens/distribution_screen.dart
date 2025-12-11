import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/screens/encheres_screen.dart';
import 'package:dimdim_belote/screens/jeu_screen/total_game_points_card.dart';
import 'package:dimdim_belote/screens/jeu_screen/points_breakdown_widget.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  final List<Carte> _cartesSelectionnees = [];
  final List<List<Carte>> _toutesCartes = [];
  Position? _positionDonneur;

  @override
  void initState() {
    super.initState();
    _genererCartes();
  }

  void _genererCartes() {
    _toutesCartes.clear();

    // Générer toutes les cartes par couleur
    for (final couleur in Couleur.values) {
      final cartesCouleur = <Carte>[];
      for (final valeur in Valeur.values) {
        cartesCouleur.add(Carte(couleur: couleur, valeur: valeur));
      }
      _toutesCartes.add(cartesCouleur);
    }
  }

  void _toggleCarte(Carte carte) {
    setState(() {
      final index = _cartesSelectionnees.indexWhere(
        (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
      );

      if (index >= 0) {
        _cartesSelectionnees.removeAt(index);
      } else {
        if (_cartesSelectionnees.length < 8) {
          _cartesSelectionnees.add(carte);
        }
      }
    });
  }

  bool _estSelectionnee(Carte carte) {
    return _cartesSelectionnees.any(
      (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
    );
  }

  int _calculerPointsCouleur(Couleur couleur, bool estAtout) {
    return _cartesSelectionnees.where((carte) => carte.couleur == couleur).fold(
        0,
        (sum, carte) =>
            sum + (estAtout ? carte.pointsAtout : carte.pointsNonAtout));
  }

  int _calculerPointsTotaux(Couleur? couleurAtout) {
    return _cartesSelectionnees.fold(0, (sum, carte) {
      if (couleurAtout == null) {
        // No trump suit (defensive case, should not happen in Belote Contrée)
        return sum + carte.pointsNonAtout;
      } else if (carte.couleur == couleurAtout) {
        return sum + carte.pointsAtout;
      } else {
        return sum + carte.pointsNonAtout;
      }
    });
  }

  Widget _buildPointsBreakdown(EtatJeu etatJeu) {
    return PointsBreakdownWidget(etatJeu: etatJeu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DIMDIM BELOTE - Distribution'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<EtatJeu>(
        builder: (context, etatJeu, child) {
          // Clear local selection if EtatJeu cards have been cleared (e.g., after all-pass)
          if (etatJeu.cartesJoueur.isEmpty && _cartesSelectionnees.isNotEmpty) {
            // Use post-frame callback to avoid modifying state during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _cartesSelectionnees.clear();
                _positionDonneur = null;
              });
            });
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Show total points if this is not the first main
                if (etatJeu.nombreMains > 0) ...[
                  TotalGamePointsCard(
                    etatJeu: etatJeu,
                    buildPointsBreakdown: _buildPointsBreakdown,
                  ),
                  const SizedBox(height: 8),
                ],
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Sélectionnez vos 8 cartes (${_cartesSelectionnees.length}/8)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _toutesCartes.length,
                itemBuilder: (context, index) {
                  final cartesCouleur = _toutesCartes[index];
                  final couleur = cartesCouleur.first.couleur;
                  final pointsAtout = _calculerPointsCouleur(couleur, true);
                  final pointsNonAtout = _calculerPointsCouleur(couleur, false);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                cartesCouleur.first.nomCouleur,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: couleur == Couleur.coeur ||
                                          couleur == Couleur.carreau
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Atout: $pointsAtout pts | Non-atout: $pointsNonAtout pts',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: cartesCouleur.map((carte) {
                              final estSelectionnee = _estSelectionnee(carte);

                              return FilterChip(
                                label: Text(
                                  carte.nomValeur,
                                  style: TextStyle(
                                    color: estSelectionnee
                                        ? Colors.white
                                        : (couleur == Couleur.coeur ||
                                                couleur == Couleur.carreau
                                            ? Colors.red
                                            : Colors.black),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                selected: estSelectionnee,
                                onSelected: (_) => _toggleCarte(carte),
                                selectedColor: Colors.blue,
                                checkmarkColor: Colors.white,
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
            if (_cartesSelectionnees.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Points en main selon l\'atout:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final couleur in Couleur.values)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                couleur.symbole,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: couleur == Couleur.coeur ||
                                          couleur == Couleur.carreau
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_calculerPointsTotaux(couleur)} points',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Qui a distribué les cartes ?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Position>(
                      initialValue: _positionDonneur,
                      decoration: const InputDecoration(
                        hintText: 'Sélectionnez le donneur',
                        border: OutlineInputBorder(),
                      ),
                      items: Position.values
                          .map((position) => DropdownMenuItem(
                                value: position,
                                child: Text(position.nom),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _positionDonneur = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  _cartesSelectionnees.length == 8 && _positionDonneur != null
                      ? () {
                          final etatJeu = context.read<EtatJeu>();
                          etatJeu.definirCartes(_cartesSelectionnees);

                          // Mettre à jour les paramètres avec la position du donneur
                          final parametres = etatJeu.parametres;
                          if (parametres != null) {
                            etatJeu.definirParametres(ParametresJeu(
                              conditionFin: parametres.conditionFin,
                              valeurFin: parametres.valeurFin,
                              sensRotation: parametres.sensRotation,
                              positionDonneur: _positionDonneur,
                            ));
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EncheresScreen(),
                            ),
                          );
                        }
                      : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                _positionDonneur == null
                    ? 'Sélectionnez le donneur pour continuer'
                    : 'Continuer vers les enchères',
                style: const TextStyle(fontSize: 15),
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
