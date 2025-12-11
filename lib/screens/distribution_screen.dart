import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/screens/encheres_screen.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  final Map<Position, List<Carte>> _cartesParJoueur = {};
  final List<List<Carte>> _toutesCartes = [];
  Position? _positionDonneur;
  Position _joueurSelectionne = Position.sud; // Start with the main player

  @override
  void initState() {
    super.initState();
    _genererCartes();
    // Initialize empty card lists for all players
    for (final position in Position.values) {
      _cartesParJoueur[position] = [];
    }
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
      final cartesJoueur = _cartesParJoueur[_joueurSelectionne]!;
      final index = cartesJoueur.indexWhere(
        (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
      );

      if (index >= 0) {
        cartesJoueur.removeAt(index);
      } else {
        // Check if card is already assigned to another player
        bool carteDejaAssignee = false;
        for (final position in Position.values) {
          if (position != _joueurSelectionne) {
            if (_cartesParJoueur[position]!.any(
              (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
            )) {
              carteDejaAssignee = true;
              break;
            }
          }
        }

        if (!carteDejaAssignee && cartesJoueur.length < 8) {
          cartesJoueur.add(carte);
        }
      }
    });
  }

  bool _estSelectionnee(Carte carte) {
    return _cartesParJoueur[_joueurSelectionne]!.any(
      (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
    );
  }

  bool _estCarteDejaAssignee(Carte carte) {
    for (final position in Position.values) {
      if (_cartesParJoueur[position]!.any(
        (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
      )) {
        return true;
      }
    }
    return false;
  }

  int _calculerPointsCouleur(Couleur couleur, bool estAtout) {
    return _cartesParJoueur[_joueurSelectionne]!
        .where((carte) => carte.couleur == couleur)
        .fold(
            0,
            (sum, carte) =>
                sum + (estAtout ? carte.pointsAtout : carte.pointsNonAtout));
  }

  int _calculerPointsTotaux(Couleur? couleurAtout) {
    return _cartesParJoueur[_joueurSelectionne]!.fold(0, (sum, carte) {
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

  int _getTotalCartesSelectionnees() {
    return _cartesParJoueur.values.fold(0, (sum, cartes) => sum + cartes.length);
  }

  bool _tousLesJoueursOnt8Cartes() {
    for (final position in Position.values) {
      if (_cartesParJoueur[position]!.length != 8) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cartesJoueurSelectionne = _cartesParJoueur[_joueurSelectionne]!;
    final totalCartes = _getTotalCartesSelectionnees();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('DIMDIM BELOTE - Distribution'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Player selector
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sélection des cartes pour:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Position.values.map((position) {
                        final cartes = _cartesParJoueur[position]!;
                        final estSelectionne = _joueurSelectionne == position;
                        
                        return ChoiceChip(
                          label: Text(
                            '${position.nom} (${cartes.length}/8)',
                            style: TextStyle(
                              color: estSelectionne ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: estSelectionne,
                          onSelected: (_) {
                            setState(() {
                              _joueurSelectionne = position;
                            });
                          },
                          selectedColor: Colors.purple,
                          backgroundColor: cartes.length == 8
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Sélectionnez les 8 cartes de ${_joueurSelectionne.nom} (${cartesJoueurSelectionne.length}/8) - Total: $totalCartes/32',
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
                              final estDejaAssignee = _estCarteDejaAssignee(carte);

                              return FilterChip(
                                label: Text(
                                  carte.nomValeur,
                                  style: TextStyle(
                                    color: estSelectionnee
                                        ? Colors.white
                                        : (estDejaAssignee
                                            ? Colors.grey
                                            : (couleur == Couleur.coeur ||
                                                    couleur == Couleur.carreau
                                                ? Colors.red
                                                : Colors.black)),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                selected: estSelectionnee,
                                onSelected: estDejaAssignee && !estSelectionnee
                                    ? null
                                    : (_) => _toggleCarte(carte),
                                selectedColor: Colors.blue,
                                checkmarkColor: Colors.white,
                                disabledColor: Colors.grey.shade300,
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
            if (cartesJoueurSelectionne.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Points en main de ${_joueurSelectionne.nom} selon l\'atout:',
                        style: const TextStyle(
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
                  _tousLesJoueursOnt8Cartes() && _positionDonneur != null
                      ? () {
                          final etatJeu = context.read<EtatJeu>();
                          etatJeu.definirToutesLesCartes(_cartesParJoueur);

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
                    : (!_tousLesJoueursOnt8Cartes()
                        ? 'Sélectionnez 8 cartes pour chaque joueur ($totalCartes/32)'
                        : 'Continuer vers les enchères'),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
