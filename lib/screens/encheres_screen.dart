import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/annonce.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/models/carte.dart';
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
        // Reset bidding state and clear cards before going back
        etatJeu.reinitialiserAnnonces();
        etatJeu.definirCartes([]); // Clear previously selected cards
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

  /// Calculate total points in hand for a given trump color
  int _calculerPointsPourAtout(EtatJeu etatJeu, Couleur couleurAtout) {
    return etatJeu.cartesJoueur.fold(0, (sum, carte) {
      if (carte.couleur == couleurAtout) {
        return sum + carte.pointsAtout;
      } else {
        return sum + carte.pointsNonAtout;
      }
    });
  }

  /// Calculate points for all trump scenarios (cached for performance)
  Map<Couleur, int> _calculerTousLesPointsAtout(EtatJeu etatJeu) {
    final resultat = <Couleur, int>{};
    for (final couleur in Couleur.values) {
      resultat[couleur] = _calculerPointsPourAtout(etatJeu, couleur);
    }
    return resultat;
  }

  /// Check if a suit is red (hearts or diamonds)
  bool _isRedSuit(Couleur couleur) {
    return couleur == Couleur.coeur || couleur == Couleur.carreau;
  }

  /// Calculate points for a specific color in hand
  int _calculerPointsCouleur(EtatJeu etatJeu, Couleur couleur, bool estAtout) {
    return etatJeu.cartesJoueur.where((carte) => carte.couleur == couleur).fold(
        0,
        (sum, carte) =>
            sum + (estAtout ? carte.pointsAtout : carte.pointsNonAtout));
  }

  /// Build list of widgets showing points breakdown for all trump scenarios
  List<Widget> _buildPointsBreakdown(EtatJeu etatJeu) {
    // Calculate all points once for performance
    final pointsParCouleur = _calculerTousLesPointsAtout(etatJeu);
    return Couleur.values.map((couleur) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(
              couleur.symbole,
              style: TextStyle(
                fontSize: 16,
                color: _isRedSuit(couleur) ? Colors.red : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${pointsParCouleur[couleur]} points',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Build widget showing cards by color
  Widget _buildCartesParCouleur(EtatJeu etatJeu) {
    // Group cards by color
    final Map<Couleur, List<Carte>> cartesByCouleur = {};
    for (final carte in etatJeu.cartesJoueur) {
      cartesByCouleur[carte.couleur] ??= [];
      cartesByCouleur[carte.couleur]!.add(carte);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: Couleur.values.map((couleur) {
        final cartes = cartesByCouleur[couleur] ?? [];
        if (cartes.isEmpty) return const SizedBox.shrink();

        final pointsAtout = _calculerPointsCouleur(etatJeu, couleur, true);
        final pointsNonAtout = _calculerPointsCouleur(etatJeu, couleur, false);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                couleur.symbole,
                style: TextStyle(
                  fontSize: 18,
                  color: _isRedSuit(couleur) ? Colors.red : Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: cartes.map((carte) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Text(
                        carte.nomValeur,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isRedSuit(couleur) ? Colors.red : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'A: $pointsAtout | N: $pointsNonAtout',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
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

                // Display player's cards and points
                if (etatJeu.cartesJoueur.isNotEmpty) ...[
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vos cartes:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCartesParCouleur(etatJeu),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Points en main selon l'atout:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._buildPointsBreakdown(etatJeu),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

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
