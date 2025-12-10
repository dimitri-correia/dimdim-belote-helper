import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimdim_belote_helper/models/etat_jeu.dart';
import 'package:dimdim_belote_helper/models/carte.dart';
import 'package:dimdim_belote_helper/screens/encheres_screen.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  final List<Carte> _cartesSelectionnees = [];
  final List<List<Carte>> _toutesCartes = [];

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
    return _cartesSelectionnees
        .where((carte) => carte.couleur == couleur)
        .fold(0, (sum, carte) => sum + (estAtout ? carte.pointsAtout : carte.pointsNonAtout));
  }

  int _calculerPointsTotaux(Couleur? couleurAtout) {
    return _cartesSelectionnees.fold(0, (sum, carte) {
      if (couleurAtout == null) {
        // Sans atout
        return sum + carte.pointsNonAtout;
      } else if (carte.couleur == couleurAtout) {
        return sum + carte.pointsAtout;
      } else {
        return sum + carte.pointsNonAtout;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribution des cartes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Sélectionnez vos 8 cartes (${_cartesSelectionnees.length}/8)',
                  style: const TextStyle(
                    fontSize: 16,
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
                                  fontSize: 24,
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
                                  fontSize: 14,
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
                          fontSize: 16,
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
                                Carte(couleur: couleur, valeur: Valeur.as).nomCouleur,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: couleur == Couleur.coeur ||
                                          couleur == Couleur.carreau
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'atout: ${_calculerPointsTotaux(couleur)} points',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          'Sans atout: points basés sur valeur non-atout',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cartesSelectionnees.length == 8
                  ? () {
                      context.read<EtatJeu>().definirCartes(_cartesSelectionnees);
                      
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
              child: const Text(
                'Continuer vers les enchères',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
