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
import 'package:dimdim_belote/screens/jeu_screen/other_players_cards_toggle.dart';
import 'package:dimdim_belote/screens/jeu_screen/other_players_cards_display.dart';
import 'package:dimdim_belote/screens/jeu_screen/player_cards_widget.dart';
import 'package:dimdim_belote/screens/jeu_screen/missing_colors_card.dart';
import 'package:dimdim_belote/screens/jeu_screen/waiting_message_card.dart';
import 'package:dimdim_belote/screens/jeu_screen/points_breakdown_widget.dart';

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
                  TotalGamePointsCard(
                    etatJeu: etatJeu,
                    buildPointsBreakdown: _buildPointsBreakdown,
                  ),
                  const SizedBox(height: 16),

                  // Announcements and Atout section
                  if (etatJeu.annonces.isNotEmpty) ...[
                    AnnouncementsCard(
                      etatJeu: etatJeu,
                      estCouleurRouge: _estCouleurRouge,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Current main points
                  CurrentMainPointsCard(etatJeu: etatJeu),
                  const SizedBox(height: 16),

                  // Current player info
                  CurrentPlayerInfoCard(
                    joueurActuel: joueurActuel,
                    estTourJoueur: estTourJoueur,
                    ordreJeu: _obtenirOrdreJeu(),
                  ),
                  const SizedBox(height: 16),

                  // Current pli
                  if (etatJeu.pliActuel.isNotEmpty) ...[
                    CurrentPliCard(etatJeu: etatJeu),
                    const SizedBox(height: 16),
                  ],

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
                    const SizedBox(height: 16),
                  ],

                  // Display all completed plis if toggled
                  if (etatJeu.plisTermines.isNotEmpty &&
                      _afficherTousLesPlis) ...[
                    CompletedPlisHistory(etatJeu: etatJeu),
                    const SizedBox(height: 16),
                  ],

                  // Toggle to show other players' cards
                  OtherPlayersCardsToggle(
                    afficherCartesAutresJoueurs: _afficherCartesAutresJoueurs,
                    onToggle: (value) {
                      setState(() {
                        _afficherCartesAutresJoueurs = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Show other players' played cards if toggled
                  if (_afficherCartesAutresJoueurs) ...[
                    OtherPlayersCardsDisplay(
                      etatJeu: etatJeu,
                      positionJoueur: parametres.positionJoueur,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Player's cards (always shown)
                  _buildCartesJoueur(etatJeu, parametres.positionJoueur),
                  const SizedBox(height: 16),

                  // Display missing colors for all players
                  if (etatJeu.couleursManquantes.values
                      .any((s) => s.isNotEmpty)) ...[
                    MissingColorsCard(
                      etatJeu: etatJeu,
                      positionJoueur: parametres.positionJoueur,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Show waiting message when it's not the player's turn
                  if (!estTourJoueur) ...[
                    const SizedBox(height: 16),
                    WaitingMessageCard(joueurActuel: joueurActuel),
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
