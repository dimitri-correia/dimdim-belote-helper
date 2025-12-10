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
  bool _grayerCartesJoueesJoueur = false;
  bool _afficherCartesAutresJoueurs = false;

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

  Widget _buildCartesJoueur(EtatJeu etatJeu, Position position) {
    final parametres = etatJeu.parametres;
    if (parametres == null) return const SizedBox.shrink();

    final estJoueurPrincipal = position == parametres.positionJoueur;
    final estTourJoueur = etatJeu.joueurActuel == parametres.positionJoueur;
    final cartes = estJoueurPrincipal
        ? etatJeu.cartesJoueur
        : etatJeu.getCartesJoueur(position);

    final cartesJouees = etatJeu.cartesJoueesParJoueur[position] ?? [];

    // Group cards by color
    final cartesByCouleur = <Couleur, List<Carte>>{};
    for (final carte in cartes) {
      cartesByCouleur.putIfAbsent(carte.couleur, () => []).add(carte);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              estJoueurPrincipal ? 'Vos cartes:' : 'Cartes de ${position.nom}:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (estJoueurPrincipal)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _grayerCartesJoueesJoueur = !_grayerCartesJoueesJoueur;
                  });
                },
                icon: Icon(
                  _grayerCartesJoueesJoueur
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                label: Text(
                  _grayerCartesJoueesJoueur
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
        ...Couleur.values.map((couleur) {
          final cartesCouleur = cartesByCouleur[couleur] ?? [];
          if (cartesCouleur.isEmpty && estJoueurPrincipal) {
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
                      color:
                          couleur == Couleur.coeur || couleur == Couleur.carreau
                              ? Colors.red
                              : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cartesCouleur.map((carte) {
                      final estJouee =
                          etatJeu.estCarteJoueeParJoueur(position, carte);
                      final estGrisee = estJoueurPrincipal &&
                          _grayerCartesJoueesJoueur &&
                          estJouee;

                      return ElevatedButton(
                        onPressed:
                            estTourJoueur ? () => _jouerCarte(carte) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              estGrisee ? Colors.grey.shade300 : Colors.white,
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
        }).toList(),
      ],
    );
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

          return SingleChildScrollView(
            child: Padding(
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
                    color: estTourJoueur
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Tour de ${joueurActuel.nom}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: estTourJoueur
                                  ? Colors.green.shade900
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            estTourJoueur
                                ? '(C\'est vous)'
                                : '(Sélectionnez la carte pour ce joueur)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                            ),
                          ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pli en cours:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (etatJeu.premierJoueurPli != null)
                          Text(
                            'Démarré par: ${etatJeu.premierJoueurPli!.nom}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
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
                                  color: carteJouee.carte.couleur ==
                                              Couleur.coeur ||
                                          carteJouee.carte.couleur ==
                                              Couleur.carreau
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

                  // Last completed pli info
                  if (etatJeu.plisTermines.isNotEmpty) ...[
                    Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Dernier pli:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Gagné par: ${etatJeu.plisTermines.last.gagnant.nom}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                Text(
                                  '${etatJeu.plisTermines.last.points} pts',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Toggle to show other players' cards
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Afficher cartes jouées par les autres:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Switch(
                            value: _afficherCartesAutresJoueurs,
                            onChanged: (value) {
                              setState(() {
                                _afficherCartesAutresJoueurs = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Show other players' played cards if toggled
                  if (_afficherCartesAutresJoueurs) ...[
                    const Text(
                      'Cartes jouées par les autres joueurs:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...Position.values
                        .where((p) => p != parametres.positionJoueur)
                        .map((position) {
                      final cartesJouees =
                          etatJeu.cartesJoueesParJoueur[position] ?? [];
                      if (cartesJouees.isEmpty) return const SizedBox.shrink();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${position.nom}:',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: cartesJouees.map((carte) {
                                  return Chip(
                                    label: Text(
                                      carte.toString(),
                                      style: TextStyle(
                                        color: carte.couleur == Couleur.coeur ||
                                                carte.couleur == Couleur.carreau
                                            ? Colors.red
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],

                  // Player's cards (always shown)
                  _buildCartesJoueur(etatJeu, parametres.positionJoueur),
                  const SizedBox(height: 16),

                  // Current player's cards (if not the main player)
                  if (!estTourJoueur) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Sélectionnez la carte pour ${joueurActuel.nom}:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choisissez parmi toutes les cartes non jouées:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Show all unplayed cards as options
                    ...Couleur.values.map((couleur) {
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
                                children: Valeur.values.map((valeur) {
                                  final carte =
                                      Carte(couleur: couleur, valeur: valeur);
                                  final carteDejaJouee =
                                      etatJeu.estCarteJoueeParQuiconque(carte);

                                  return ElevatedButton(
                                    onPressed: carteDejaJouee
                                        ? null
                                        : () => _jouerCarte(carte),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: carteDejaJouee
                                          ? Colors.grey.shade300
                                          : Colors.white,
                                      foregroundColor: carteDejaJouee
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
                    }).toList(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
