import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/annonce.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/screens/jeu_screen.dart';

class EncheresScreen extends StatefulWidget {
  const EncheresScreen({super.key});

  @override
  State<EncheresScreen> createState() => _EncheresScreenState();
}

class _EncheresScreenState extends State<EncheresScreen> {
  int? _valeurSelectionnee;
  String? _couleurSelectionnee;
  bool _estCapot = false;

  final List<int> _valeursDisponibles = [
    80,
    90,
    100,
    110,
    120,
    130,
    140,
    150,
    160
  ];
  final List<String> _couleursDisponibles = [
    '♠ Pique',
    '♥ Cœur',
    '♦ Carreau',
    '♣ Trèfle',
  ];

  bool _peutContrer = false;
  bool _peutSurcontrer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mettreAJourOptions();
  }

  void _mettreAJourOptions() {
    final etatJeu = Provider.of<EtatJeu>(context, listen: false);
    final annonces = etatJeu.annonces;

    if (annonces.isEmpty) {
      _peutContrer = false;
      _peutSurcontrer = false;
      return;
    }

    final derniereAnnonce = annonces.last;
    final joueurActuel = etatJeu.joueurActuel;

    // On peut contrer si la dernière annonce est une prise et qu'elle n'est pas de notre équipe
    if (derniereAnnonce.type == TypeAnnonce.prise && joueurActuel != null) {
      final parametres = etatJeu.parametres;
      if (parametres != null) {
        // Nord-Sud vs Est-Ouest
        final joueurActuelEquipeNordSud =
            joueurActuel == Position.nord || joueurActuel == Position.sud;
        final annonceEquipeNordSud = derniereAnnonce.joueur == Position.nord ||
            derniereAnnonce.joueur == Position.sud;

        _peutContrer = joueurActuelEquipeNordSud != annonceEquipeNordSud;
        _peutSurcontrer = false;
      }
    } else if (derniereAnnonce.type == TypeAnnonce.contre &&
        joueurActuel != null) {
      // On peut surcontrer si la dernière annonce est un contre et qu'il vient de l'équipe adverse
      final parametres = etatJeu.parametres;
      if (parametres != null) {
        final joueurActuelEquipeNordSud =
            joueurActuel == Position.nord || joueurActuel == Position.sud;
        final contreEquipeNordSud = derniereAnnonce.joueur == Position.nord ||
            derniereAnnonce.joueur == Position.sud;

        _peutContrer = false;
        _peutSurcontrer = joueurActuelEquipeNordSud != contreEquipeNordSud;
      }
    } else {
      _peutContrer = false;
      _peutSurcontrer = false;
    }
  }

  void _ajouterAnnonce(TypeAnnonce type,
      {int? valeur, String? couleur, bool estCapot = false}) {
    final etatJeu = context.read<EtatJeu>();
    final joueurActuel = etatJeu.joueurActuel;

    if (joueurActuel == null) return;

    final annonce = Annonce(
      joueur: joueurActuel,
      type: type,
      valeur: valeur,
      couleur: couleur,
      estCapot: estCapot,
    );

    etatJeu.ajouterAnnonce(annonce);

    setState(() {
      _valeurSelectionnee = null;
      _couleurSelectionnee = null;
      _estCapot = false;
      _mettreAJourOptions();
    });

    // Check if all players passed - need to re-draw cards
    // Use post-frame callback to avoid navigation during build
    if (etatJeu.tousOntPasse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // No one bid - navigate back to distribution to re-draw cards
        Navigator.pop(context);
      });
      return;
    }

    // Check if bidding should end (last speaker's turn again with all others passed)
    // Use post-frame callback to avoid navigation during build
    if (etatJeu.doitTerminerEncheres) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Navigate to game screen automatically, replacing current screen
        // to prevent going back to completed bidding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const JeuScreen(),
          ),
        );
      });
    }
  }

  /// Obtient la valeur minimale pour une nouvelle enchère.
  /// Retourne null si les enchères sont bloquées (après un Capot).
  /// Retourne 80 s'il n'y a pas encore d'annonces.
  /// Sinon, retourne la dernière valeur + 10.
  int? _obtenirValeurMinimale() {
    final etatJeu = context.read<EtatJeu>();
    final annonces = etatJeu.annonces;

    if (annonces.isEmpty) return 80;

    // Si la dernière annonce est un capot, on ne peut plus enchérir
    for (int i = annonces.length - 1; i >= 0; i--) {
      if (annonces[i].type == TypeAnnonce.prise) {
        if (annonces[i].estCapot) {
          return null; // null indique qu'on ne peut plus enchérir (après un capot)
        }
        if (annonces[i].valeur != null) {
          return annonces[i].valeur! + 10;
        }
      }
    }

    return 80;
  }

  /// Retourne true si on peut annoncer un Capot (pas de Capot déjà annoncé).
  bool _peutAnnoncerCapot() {
    final valeurMin = _obtenirValeurMinimale();
    // On peut annoncer capot si on peut encore enchérir (pas de capot avant)
    return valeurMin != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DIMDIM BELOTE -Enchères'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EtatJeu>().reinitialiserAnnonces();
              setState(() {
                _valeurSelectionnee = null;
                _couleurSelectionnee = null;
                _estCapot = false;
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

          final valeurMin = _obtenirValeurMinimale();
          final peutAnnoncerCapot = _peutAnnoncerCapot();
          final doitTerminer = etatJeu.doitTerminerEncheres;
          final tousOntPasse = etatJeu.tousOntPasse;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          'Tour de ${joueurActuel.nom}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          joueurActuel == parametres.positionJoueur
                              ? '(C\'est vous)'
                              : '(Sélectionnez l\'enchère pour ce joueur)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                        ),
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
                      fontSize: 14,
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
                              radius: 16,
                              child: Text(annonce.joueur.nom[0]),
                            ),
                            title: Text(annonce.texte),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Show message if all players passed - need to re-draw cards
                if (tousOntPasse) ...[
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tous les joueurs ont passé',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Personne n\'a fait d\'annonce.\nLes cartes vont être redistribuées.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Show message if bidding should end, otherwise show bidding options
                if (doitTerminer) ...[
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Les enchères sont terminées',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tous les autres joueurs ont passé.\nLe jeu va commencer.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Bouton Passe
                if (!doitTerminer && !tousOntPasse)
                  ElevatedButton(
                    onPressed: () => _ajouterAnnonce(TypeAnnonce.passe),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'Passe',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),

                if (!doitTerminer && !tousOntPasse) const SizedBox(height: 12),

                // Bouton Contre
                if (!doitTerminer && !tousOntPasse && _peutContrer)
                  ElevatedButton(
                    onPressed: () => _ajouterAnnonce(TypeAnnonce.contre),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Contre',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),

                if (!doitTerminer && !tousOntPasse && _peutSurcontrer)
                  ElevatedButton(
                    onPressed: () => _ajouterAnnonce(TypeAnnonce.surcontre),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Surcontré',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),

                if (!doitTerminer && !tousOntPasse) const SizedBox(height: 12),
                if (!doitTerminer && !tousOntPasse) const Divider(),
                if (!doitTerminer && !tousOntPasse) const SizedBox(height: 12),

                // Section Prise
                if (!doitTerminer && !tousOntPasse)
                  const Text(
                    'Faire une annonce:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (!doitTerminer && !tousOntPasse) const SizedBox(height: 12),

                // Checkbox Capot
                if (!doitTerminer && !tousOntPasse && peutAnnoncerCapot)
                  CheckboxListTile(
                    title: const Text(
                      'Capot (prendre tous les plis)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('La plus haute enchère possible'),
                    value: _estCapot,
                    onChanged: (value) {
                      setState(() {
                        _estCapot = value ?? false;
                        if (_estCapot) {
                          _valeurSelectionnee = null;
                        }
                      });
                    },
                  ),

                if (!doitTerminer && !tousOntPasse)
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Valeurs
                        if (!_estCapot)
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Valeur',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: ListView(
                                        children: _valeursDisponibles
                                            .where((v) =>
                                                valeurMin != null &&
                                                v >= valeurMin)
                                            .map((valeur) {
                                          return ListTile(
                                            dense: true,
                                            title: Text(valeur.toString()),
                                            leading: Radio<int>(
                                              value: valeur,
                                              // ignore: deprecated_member_use
                                              groupValue: _valeurSelectionnee,
                                              // ignore: deprecated_member_use
                                              onChanged: (value) {
                                                setState(() {
                                                  _valeurSelectionnee = value;
                                                });
                                              },
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _valeurSelectionnee = valeur;
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (!_estCapot) const SizedBox(width: 8),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView(
                                      children:
                                          _couleursDisponibles.map((couleur) {
                                        return ListTile(
                                          dense: true,
                                          title: Text(couleur),
                                          leading: Radio<String>(
                                            value: couleur,
                                            // ignore: deprecated_member_use
                                            groupValue: _couleurSelectionnee,
                                            // ignore: deprecated_member_use
                                            onChanged: (value) {
                                              setState(() {
                                                _couleurSelectionnee = value;
                                              });
                                            },
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _couleurSelectionnee = couleur;
                                            });
                                          },
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

                if (!doitTerminer && !tousOntPasse) const SizedBox(height: 12),

                // Bouton Annoncer
                if (!doitTerminer && !tousOntPasse)
                  ElevatedButton(
                    onPressed: (_estCapot && _couleurSelectionnee != null) ||
                            (!_estCapot &&
                                _valeurSelectionnee != null &&
                                _couleurSelectionnee != null)
                        ? () {
                            _ajouterAnnonce(
                              TypeAnnonce.prise,
                              valeur: _estCapot ? null : _valeurSelectionnee,
                              couleur: _couleurSelectionnee,
                              estCapot: _estCapot,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      _estCapot ? 'Annoncer Capot' : 'Annoncer',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),

                // Button to proceed to game phase
                if (etatJeu.annonces.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JeuScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Commencer le jeu',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.green,
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
