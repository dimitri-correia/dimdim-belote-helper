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
  bool _afficherCartesAutresJoueurs = false;
  bool _afficherTousLesPlis = false;

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

  /// Determines if a suit color string represents a red suit (hearts or diamonds)
  bool _estCouleurRouge(String couleur) {
    return couleur.contains('♥') ||
        couleur.contains('Cœur') ||
        couleur.contains('♦') ||
        couleur.contains('Carreau');
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

    // Get played and remaining cards for this position
    final cartesJouees = etatJeu.cartesJoueesParJoueur[position] ?? [];

    // Combine current and played cards
    final cartesCourantes = estJoueurPrincipal
        ? etatJeu.cartesJoueur
        : etatJeu.getCartesJoueur(position);

    // Use a Set to track unique cards efficiently
    final cartesUniques = <String, Carte>{};

    // Add current cards
    for (final carte in cartesCourantes) {
      final key = '${carte.couleur.index}_${carte.valeur.index}';
      cartesUniques[key] = carte;
    }

    // Add played cards (Map keys automatically handle duplicates)
    for (final carte in cartesJouees) {
      final key = '${carte.couleur.index}_${carte.valeur.index}';
      cartesUniques[key] = carte;
    }

    // Group cards by color once and sort them
    final cartesByCouleur = <Couleur, List<Carte>>{};
    for (final carte in cartesUniques.values) {
      cartesByCouleur.putIfAbsent(carte.couleur, () => []).add(carte);
    }

    // Flatten all cards into a single list, grouped by color
    final toutesLesCartes = <Widget>[];
    for (final couleur in Couleur.values) {
      final cartesAffichees = cartesByCouleur[couleur] ?? [];
      if (cartesAffichees.isEmpty) continue;

      for (final carte in cartesAffichees) {
        final estJouee = etatJeu.estCarteJoueeParJoueur(position, carte);

        toutesLesCartes.add(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: (estTourJoueur && !estJouee)
                    ? () => _jouerCarte(carte)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      estJouee ? Colors.grey.shade300 : Colors.white,
                  foregroundColor: estJouee
                      ? Colors.grey.shade600
                      : (couleur == Couleur.coeur || couleur == Couleur.carreau
                          ? Colors.red
                          : Colors.black),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      couleur.symbole,
                      style: TextStyle(
                        fontSize: 16,
                        color: couleur == Couleur.coeur ||
                                couleur == Couleur.carreau
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      carte.nomValeur,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              if (estJouee)
                Text(
                  'Jouée',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          estJoueurPrincipal ? 'Vos cartes:' : 'Cartes de ${position.nom}:',
          style: const TextStyle(
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
              children: toutesLesCartes,
            ),
          ),
        ),
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
                  // Total game points at top
                  Card(
                    color: Colors.purple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Points totaux de la partie',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Nord-Sud',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: (parametres.positionJoueur ==
                                                  Position.nord ||
                                              parametres.positionJoueur ==
                                                  Position.sud)
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${etatJeu.pointsTotauxNordSud}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                '—',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Est-Ouest',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: (parametres.positionJoueur ==
                                                  Position.est ||
                                              parametres.positionJoueur ==
                                                  Position.ouest)
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${etatJeu.pointsTotauxEstOuest}',
                                    style: const TextStyle(
                                      fontSize: 32,
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

                  // Announcements and Atout section
                  if (etatJeu.annonces.isNotEmpty) ...[
                    Card(
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (etatJeu.atout != null)
                                  Text(
                                    etatJeu.atout!,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: _estCouleurRouge(etatJeu.atout!)
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Annonces:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...etatJeu.annonces.map((annonce) {
                              final isWinning = etatJeu.annonceGagnante == annonce;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isWinning
                                      ? Colors.green.shade100
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                  border: isWinning
                                      ? Border.all(
                                          color: Colors.green.shade700,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      child: Text(
                                        annonce.joueur.nom[0],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        annonce.texte,
                                        style: TextStyle(
                                          fontWeight: isWinning
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (isWinning)
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.green.shade700,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Current main points
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            'Points de cette main',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    parametres.conditionFin == ConditionFin.plis
                                        ? 'Plis'
                                        : 'Plis joués',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    parametres.conditionFin == ConditionFin.plis
                                        ? '${etatJeu.nombrePlis}/${parametres.valeurFin}'
                                        : '${etatJeu.nombrePlis}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  if (parametres.conditionFin ==
                                      ConditionFin.points)
                                    Text(
                                      '(${parametres.valeurFin} pts pour gagner)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Nord-Sud',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: (parametres.positionJoueur ==
                                                  Position.nord ||
                                              parametres.positionJoueur ==
                                                  Position.sud)
                                          ? FontWeight.bold
                                          : FontWeight.w500,
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
                                  Text(
                                    'Est-Ouest',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: (parametres.positionJoueur ==
                                                  Position.est ||
                                              parametres.positionJoueur ==
                                                  Position.ouest)
                                          ? FontWeight.bold
                                          : FontWeight.w500,
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
                        Row(
                          children: [
                            Text(
                              '${etatJeu.pointsPliActuel} pts',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (etatJeu.gagnantPliActuel != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• Prend: ${etatJeu.gagnantPliActuel!.nom}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ],
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

                  // All completed plis toggle and display
                  if (etatJeu.plisTermines.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Afficher tous les plis (${etatJeu.plisTermines.length}):',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Switch(
                              value: _afficherTousLesPlis,
                              onChanged: (value) {
                                setState(() {
                                  _afficherTousLesPlis = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Display all completed plis if toggled
                  if (etatJeu.plisTermines.isNotEmpty &&
                      _afficherTousLesPlis) ...[
                    const Text(
                      'Historique des plis:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...etatJeu.plisTermines.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pli = entry.value;
                      final isLastPli =
                          index == etatJeu.plisTermines.length - 1;

                      return Card(
                        color: isLastPli ? Colors.amber.shade50 : null,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pli ${index + 1}${isLastPli ? " (dernier)" : ""}:',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${pli.points} pts',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: pli.cartes.map((carteJouee) {
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
                              const SizedBox(height: 8),
                              Text(
                                'Gagné par: ${pli.gagnant.nom}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
