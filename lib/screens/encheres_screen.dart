import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimdim_belote_helper/models/etat_jeu.dart';
import 'package:dimdim_belote_helper/models/annonce.dart';
import 'package:dimdim_belote_helper/models/position.dart';

class EncheresScreen extends StatefulWidget {
  const EncheresScreen({super.key});

  @override
  State<EncheresScreen> createState() => _EncheresScreenState();
}

class _EncheresScreenState extends State<EncheresScreen> {
  int? _valeurSelectionnee;
  String? _couleurSelectionnee;
  
  final List<int> _valeursDisponibles = [80, 90, 100, 110, 120, 130, 140, 150, 160];
  final List<String> _couleursDisponibles = [
    '♠ Pique',
    '♥ Cœur',
    '♦ Carreau',
    '♣ Trèfle',
    'SA Sans atout',
    'TA Tout atout',
  ];

  bool _peutContrer = false;
  bool _peutSurcontrer = false;

  @override
  void initState() {
    super.initState();
    _mettreAJourOptions();
  }

  void _mettreAJourOptions() {
    final etatJeu = context.read<EtatJeu>();
    final annonces = etatJeu.annonces;
    
    if (annonces.isEmpty) {
      _peutContrer = false;
      _peutSurcontrer = false;
      return;
    }
    
    final derniereAnnonce = annonces.last;
    
    // On peut contrer si la dernière annonce est une prise et qu'elle n'est pas de notre équipe
    if (derniereAnnonce.type == TypeAnnonce.prise) {
      final parametres = etatJeu.parametres;
      if (parametres != null) {
        // Nord-Sud vs Est-Ouest
        final estEquipeNordSud = parametres.positionJoueur == Position.nord ||
            parametres.positionJoueur == Position.sud;
        final annonceEquipeNordSud = derniereAnnonce.joueur == Position.nord ||
            derniereAnnonce.joueur == Position.sud;
        
        _peutContrer = estEquipeNordSud != annonceEquipeNordSud;
        _peutSurcontrer = false;
      }
    } else if (derniereAnnonce.type == TypeAnnonce.contre) {
      _peutContrer = false;
      _peutSurcontrer = true;
    } else {
      _peutContrer = false;
      _peutSurcontrer = false;
    }
  }

  void _ajouterAnnonce(TypeAnnonce type, {int? valeur, String? couleur}) {
    final etatJeu = context.read<EtatJeu>();
    final joueurActuel = etatJeu.joueurActuel;
    
    if (joueurActuel == null) return;
    
    final annonce = Annonce(
      joueur: joueurActuel,
      type: type,
      valeur: valeur,
      couleur: couleur,
    );
    
    etatJeu.ajouterAnnonce(annonce);
    
    setState(() {
      _valeurSelectionnee = null;
      _couleurSelectionnee = null;
      _mettreAJourOptions();
    });
  }

  int _obtenirValeurMinimale() {
    final etatJeu = context.read<EtatJeu>();
    final annonces = etatJeu.annonces;
    
    if (annonces.isEmpty) return 80;
    
    // Trouver la dernière prise
    for (int i = annonces.length - 1; i >= 0; i--) {
      if (annonces[i].type == TypeAnnonce.prise && annonces[i].valeur != null) {
        return annonces[i].valeur! + 10;
      }
    }
    
    return 80;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enchères'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EtatJeu>().reinitialiserAnnonces();
              setState(() {
                _valeurSelectionnee = null;
                _couleurSelectionnee = null;
                _mettreAJourOptions();
              });
            },
            tooltip: 'Recommencer les enchères',
          ),
        ],
      ),
      body: Consumer<EtatJeu>(
        builder: (context, etatJeu, child) {
          final joueurActuel = etatJeu.joueurActuel;
          final parametres = etatJeu.parametres;
          
          if (joueurActuel == null || parametres == null) {
            return const Center(child: Text('Erreur: données manquantes'));
          }
          
          final estMonTour = joueurActuel == parametres.positionJoueur;
          final valeurMin = _obtenirValeurMinimale();
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: estMonTour ? Colors.green.shade50 : Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          estMonTour
                              ? 'C\'est votre tour (${parametres.positionJoueur.nom})'
                              : 'Tour de ${joueurActuel.nom}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (!estMonTour) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Attendez votre tour ou passez pour le joueur actuel',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Historique des annonces
                if (etatJeu.annonces.isNotEmpty) ...[
                  const Text(
                    'Historique des enchères:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: etatJeu.annonces.length,
                        itemBuilder: (context, index) {
                          final annonce = etatJeu.annonces[index];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              child: Text(annonce.joueur.nom[0]),
                              radius: 16,
                            ),
                            title: Text(annonce.texte),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Bouton Passe
                ElevatedButton(
                  onPressed: () => _ajouterAnnonce(TypeAnnonce.passe),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Passe',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Bouton Contre
                if (_peutContrer)
                  ElevatedButton(
                    onPressed: estMonTour
                        ? () => _ajouterAnnonce(TypeAnnonce.contre)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Contre',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                
                if (_peutSurcontrer)
                  ElevatedButton(
                    onPressed: estMonTour
                        ? () => _ajouterAnnonce(TypeAnnonce.surcontre)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Surcontré',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                
                // Section Prise
                const Text(
                  'Faire une annonce:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Valeurs
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Valeur',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView(
                                    children: _valeursDisponibles
                                        .where((v) => v >= valeurMin)
                                        .map((valeur) {
                                      return RadioListTile<int>(
                                        title: Text(valeur.toString()),
                                        value: valeur,
                                        groupValue: _valeurSelectionnee,
                                        dense: true,
                                        onChanged: estMonTour
                                            ? (value) {
                                                setState(() {
                                                  _valeurSelectionnee = value;
                                                });
                                              }
                                            : null,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Couleurs
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Couleur',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView(
                                    children: _couleursDisponibles.map((couleur) {
                                      return RadioListTile<String>(
                                        title: Text(couleur),
                                        value: couleur,
                                        groupValue: _couleurSelectionnee,
                                        dense: true,
                                        onChanged: estMonTour
                                            ? (value) {
                                                setState(() {
                                                  _couleurSelectionnee = value;
                                                });
                                              }
                                            : null,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Bouton Annoncer
                ElevatedButton(
                  onPressed: estMonTour &&
                          _valeurSelectionnee != null &&
                          _couleurSelectionnee != null
                      ? () {
                          _ajouterAnnonce(
                            TypeAnnonce.prise,
                            valeur: _valeurSelectionnee,
                            couleur: _couleurSelectionnee,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Annoncer',
                    style: TextStyle(fontSize: 18),
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
