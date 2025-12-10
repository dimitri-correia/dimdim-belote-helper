import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/screens/jeu_screen/total_game_points_card.dart';
import 'package:dimdim_belote/screens/jeu_screen/announcements_card.dart';
import 'package:dimdim_belote/screens/jeu_screen/current_main_points_card.dart';
import 'package:dimdim_belote/screens/jeu_screen/current_player_info_card.dart';
import 'package:dimdim_belote/screens/jeu_screen/current_pli_card.dart';
import 'package:dimdim_belote/screens/jeu_screen/completed_plis_toggle_card.dart';
import 'package:dimdim_belote/screens/jeu_screen/completed_plis_history.dart';
import 'package:dimdim_belote/screens/jeu_screen/player_cards_widget.dart';
import 'package:dimdim_belote/screens/jeu_screen/missing_colors_card.dart';
import 'package:dimdim_belote/screens/jeu_screen/points_breakdown_widget.dart';
import 'package:dimdim_belote/screens/distribution_screen.dart';

class JeuScreen extends StatefulWidget {
  const JeuScreen({super.key});

  @override
  State<JeuScreen> createState() => _JeuScreenState();
}

class _JeuScreenState extends State<JeuScreen> {
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

  Widget _buildPointsBreakdown(EtatJeu etatJeu) {
    return PointsBreakdownWidget(etatJeu: etatJeu);
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

    return ordre.map((p) => p.nom).join(' → ');
  }

  Widget _buildCartesJoueur(EtatJeu etatJeu, Position position) {
    return PlayerCardsWidget(
      etatJeu: etatJeu,
      position: position,
      jouerCarte: _jouerCarte,
    );
  }

  void _finaliserMain(BuildContext context, EtatJeu etatJeu) {
    // Finalize the main (add points to totals)
    etatJeu.finaliserMain();

    // Check if winning condition is met
    final parametres = etatJeu.parametres;
    if (parametres == null) return;

    bool jeuTermine = false;
    String? equipeGagnante;

    if (parametres.conditionFin == ConditionFin.points) {
      // Check if either team reached the point threshold
      if (etatJeu.pointsTotauxNordSud >= parametres.valeurFin) {
        jeuTermine = true;
        equipeGagnante = 'Nord-Sud';
      } else if (etatJeu.pointsTotauxEstOuest >= parametres.valeurFin) {
        jeuTermine = true;
        equipeGagnante = 'Est-Ouest';
      }
    } else {
      // Check if we've reached the number of mains
      if (etatJeu.nombreMains >= parametres.valeurFin) {
        jeuTermine = true;
        // Winner is the team with the most points
        if (etatJeu.pointsTotauxNordSud > etatJeu.pointsTotauxEstOuest) {
          equipeGagnante = 'Nord-Sud';
        } else if (etatJeu.pointsTotauxEstOuest > etatJeu.pointsTotauxNordSud) {
          equipeGagnante = 'Est-Ouest';
        } else {
          equipeGagnante = 'Égalité';
        }
      }
    }

    if (jeuTermine) {
      // Show victory dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('🎉 Partie terminée !'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  equipeGagnante == 'Égalité'
                      ? 'La partie se termine sur une égalité !'
                      : 'L\'équipe $equipeGagnante a gagné !',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nord-Sud: ${etatJeu.pointsTotauxNordSud} points',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Est-Ouest: ${etatJeu.pointsTotauxEstOuest} points',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Reset game and go back to home
                  etatJeu.reinitialiser();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Nouvelle partie'),
              ),
            ],
          );
        },
      );
    } else {
      // Continue to next main - go to distribution screen
      etatJeu.nouvelleMain();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DistributionScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DIMDIM BELOTE'),
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
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Total game points at top
                  TotalGamePointsCard(
                    etatJeu: etatJeu,
                    buildPointsBreakdown: _buildPointsBreakdown,
                  ),

                  // Announcements and Atout section
                  AnnouncementsCard(
                    etatJeu: etatJeu,
                    estCouleurRouge: _estCouleurRouge,
                  ),

                  // Current main points
                  CurrentMainPointsCard(etatJeu: etatJeu),

                  if (etatJeu.pliActuel.isNotEmpty) ...[
                    // Current pli
                    CurrentPliCard(etatJeu: etatJeu),
                  ] else
                    // Current player info
                    CurrentPlayerInfoCard(
                      joueurActuel: joueurActuel,
                      estTourJoueur: estTourJoueur,
                      ordreJeu: _obtenirOrdreJeu(),
                    ),

                  // All completed plis toggle and display
                  if (etatJeu.plisTermines.isNotEmpty) ...[
                    CompletedPlisToggleCard(
                      etatJeu: etatJeu,
                      afficherTousLesPlis: _afficherTousLesPlis,
                      onToggle: (value) {
                        setState(() {
                          _afficherTousLesPlis = value;
                        });
                      },
                    ),
                  ],

                  // Display all completed plis if toggled
                  if (etatJeu.plisTermines.isNotEmpty &&
                      _afficherTousLesPlis) ...[
                    CompletedPlisHistory(etatJeu: etatJeu),
                  ],

                  // Finalize main button when all 8 plis are complete
                  if (etatJeu.nombrePlis == 8 && !etatJeu.mainFinalisee) ...[
                    const SizedBox(height: 16),
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
                              'Main terminée !',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                _finaliserMain(context, etatJeu);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                                backgroundColor: Colors.green,
                              ),
                              child: const Text(
                                'Finaliser cette main et continuer',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // All players' cards (everyone can play since it's a helper app)
                  ...Position.values
                      .map((position) => _buildCartesJoueur(etatJeu, position)),

                  // Display missing colors for all players
                  if (etatJeu.couleursManquantes.values
                      .any((s) => s.isNotEmpty)) ...[
                    MissingColorsCard(
                      etatJeu: etatJeu,
                      positionJoueur: parametres.positionJoueur,
                    ),
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
