import 'package:flutter/foundation.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/annonce.dart';

enum ConditionFin {
  points,
  plis,
}

enum SensRotation {
  horaire,
  antihoraire,
}

class ParametresJeu {
  final ConditionFin conditionFin;
  final int valeurFin; // nombre de points ou de plis
  final SensRotation sensRotation;
  final Position? positionDonneur; // position du donneur (dealer)

  // Player is always in Position.sud for easier tracking
  Position get positionJoueur => Position.sud;

  ParametresJeu({
    required this.conditionFin,
    required this.valeurFin,
    required this.sensRotation,
    this.positionDonneur,
  });
}

class CarteJouee {
  final Position joueur;
  final Carte carte;

  CarteJouee({required this.joueur, required this.carte});
}

class PliTermine {
  final List<CarteJouee> cartes;
  final Position gagnant;
  final int points;

  PliTermine({
    required this.cartes,
    required this.gagnant,
    required this.points,
  });
}

class EtatJeu extends ChangeNotifier {
  ParametresJeu? _parametres;
  List<Carte> _cartesJoueur = [];
  List<Annonce> _annonces = [];
  Position? _joueurActuel;
  
  // Game phase tracking
  int _nombrePlis = 0;
  int _nombreMains = 0; // Number of completed mains (hands)
  int _pointsNordSud = 0;
  int _pointsEstOuest = 0;
  int _pointsTotauxNordSud = 0; // Total points across all mains
  int _pointsTotauxEstOuest = 0; // Total points across all mains
  bool _mainFinalisee = false; // Track if current main has been finalized
  List<CarteJouee> _pliActuel = [];
  Position? _premierJoueurPli; // Who played first in current pli
  List<Carte> _cartesJouees = []; // All cards played by the player
  
  // Track all players' cards
  Map<Position, List<Carte>> _cartesParJoueur = {};
  Map<Position, List<Carte>> _cartesJoueesParJoueur = {};
  List<PliTermine> _plisTermines = [];
  
  // Track which colors each player cannot play anymore
  Map<Position, Set<Couleur>> _couleursManquantes = {};

  ParametresJeu? get parametres => _parametres;
  List<Carte> get cartesJoueur => _cartesJoueur;
  List<Annonce> get annonces => _annonces;
  Position? get joueurActuel => _joueurActuel;
  int get nombrePlis => _nombrePlis;
  int get nombreMains => _nombreMains;
  int get pointsNordSud => _pointsNordSud;
  int get pointsEstOuest => _pointsEstOuest;
  int get pointsTotauxNordSud => _pointsTotauxNordSud;
  int get pointsTotauxEstOuest => _pointsTotauxEstOuest;
  bool get mainFinalisee => _mainFinalisee;
  List<CarteJouee> get pliActuel => _pliActuel;
  Position? get premierJoueurPli => _premierJoueurPli;
  List<Carte> get cartesJouees => _cartesJouees;
  Map<Position, List<Carte>> get cartesParJoueur => _cartesParJoueur;
  Map<Position, List<Carte>> get cartesJoueesParJoueur => _cartesJoueesParJoueur;
  List<PliTermine> get plisTermines => _plisTermines;
  Map<Position, Set<Couleur>> get couleursManquantes => _couleursManquantes;

  /// Check if all 4 players have passed without any bid.
  /// In this case, cards should be re-drawn (go back to distribution).
  bool get tousOntPasse {
    // Check if we have exactly 4 announcements and all are passes
    if (_annonces.length != 4) return false;
    
    // Verify all announcements are passes
    return _annonces.every((annonce) => annonce.type == TypeAnnonce.passe);
  }

  /// Check if bidding should end because it's the turn of the last player
  /// who made a non-pass bid and all others have passed since then.
  bool get doitTerminerEncheres {
    if (_annonces.isEmpty || _joueurActuel == null) return false;
    
    // Find the last non-pass announcement
    final indexDernierNonPasse = _annonces.lastIndexWhere(
      (annonce) => annonce.type != TypeAnnonce.passe,
    );
    
    // If no non-pass bid yet, bidding shouldn't end
    if (indexDernierNonPasse == -1) return false;
    
    final dernierNonPasse = _annonces[indexDernierNonPasse];
    
    // Verify that all announcements after the last non-pass are passes
    // and that exactly 3 consecutive passes have occurred (one from each other player)
    final nombrePassesApres = _annonces.length - indexDernierNonPasse - 1;
    if (nombrePassesApres != 3) return false;
    
    // Verify all announcements after last non-pass are actually passes
    for (int i = indexDernierNonPasse + 1; i < _annonces.length; i++) {
      if (_annonces[i].type != TypeAnnonce.passe) return false;
    }
    
    // Check if the current player is the one who made the last non-pass bid
    return _joueurActuel == dernierNonPasse.joueur;
  }

  void definirParametres(ParametresJeu parametres) {
    _parametres = parametres;
    // Le premier à parler est à la droite du donneur
    if (parametres.positionDonneur != null) {
      _joueurActuel = parametres.sensRotation == SensRotation.horaire
          ? parametres.positionDonneur!.suivant
          : parametres.positionDonneur!.precedent;
    } else {
      // Si pas de donneur défini, on commence par le joueur
      _joueurActuel = parametres.positionJoueur;
    }
    notifyListeners();
  }

  void definirCartes(List<Carte> cartes) {
    _cartesJoueur = cartes;
    notifyListeners();
  }

  void ajouterAnnonce(Annonce annonce) {
    _annonces.add(annonce);
    
    // Passer au joueur suivant
    if (_joueurActuel != null && _parametres != null) {
      _joueurActuel = _parametres!.sensRotation == SensRotation.horaire
          ? _joueurActuel!.suivant
          : _joueurActuel!.precedent;
    }
    
    notifyListeners();
  }

  void reinitialiserAnnonces() {
    _annonces.clear();
    if (_parametres != null) {
      // Le premier à parler est à la droite du donneur
      if (_parametres!.positionDonneur != null) {
        _joueurActuel = _parametres!.sensRotation == SensRotation.horaire
            ? _parametres!.positionDonneur!.suivant
            : _parametres!.positionDonneur!.precedent;
      } else {
        _joueurActuel = _parametres!.positionJoueur;
      }
    }
    notifyListeners();
  }

  void reinitialiser() {
    _parametres = null;
    _cartesJoueur = [];
    _annonces = [];
    _joueurActuel = null;
    _nombrePlis = 0;
    _nombreMains = 0;
    _pointsNordSud = 0;
    _pointsEstOuest = 0;
    _pointsTotauxNordSud = 0;
    _pointsTotauxEstOuest = 0;
    _mainFinalisee = false;
    _pliActuel = [];
    _premierJoueurPli = null;
    _cartesJouees = [];
    _cartesParJoueur = {};
    _cartesJoueesParJoueur = {};
    _plisTermines = [];
    _couleursManquantes = {};
    notifyListeners();
  }

  /// Get the trump suit's couleur enum value from the atout string
  Couleur? get atoutCouleur {
    if (atout == null) return null;
    
    if (atout!.contains('♠') || atout!.contains('Pique')) return Couleur.pique;
    if (atout!.contains('♥') || atout!.contains('Cœur')) return Couleur.coeur;
    if (atout!.contains('♦') || atout!.contains('Carreau')) return Couleur.carreau;
    if (atout!.contains('♣') || atout!.contains('Trèfle')) return Couleur.trefle;
    
    return null;
  }

  /// Compare two cards to determine which is stronger
  /// Returns -1 if carte1 wins, 1 if carte2 wins, 0 if equal
  int _comparerCartes(Carte carte1, Carte carte2, Couleur? couleurDemandee) {
    final trumpCouleur = atoutCouleur;
    final carte1EstAtout = trumpCouleur != null && carte1.couleur == trumpCouleur;
    final carte2EstAtout = trumpCouleur != null && carte2.couleur == trumpCouleur;
    
    // If one is trump and the other isn't, trump wins
    if (carte1EstAtout && !carte2EstAtout) return -1;
    if (carte2EstAtout && !carte1EstAtout) return 1;
    
    // If both are trump, compare trump values
    if (carte1EstAtout && carte2EstAtout) {
      return _comparerValeursAtout(carte1.valeur, carte2.valeur);
    }
    
    // If neither is trump, only cards of the requested suit can win
    final carte1EstCouleurDemandee = couleurDemandee != null && carte1.couleur == couleurDemandee;
    final carte2EstCouleurDemandee = couleurDemandee != null && carte2.couleur == couleurDemandee;
    
    if (carte1EstCouleurDemandee && !carte2EstCouleurDemandee) return -1;
    if (carte2EstCouleurDemandee && !carte1EstCouleurDemandee) return 1;
    
    // Both are same suit (requested), compare non-trump values
    if (carte1EstCouleurDemandee && carte2EstCouleurDemandee) {
      return _comparerValeursNonAtout(carte1.valeur, carte2.valeur);
    }
    
    // Neither follows suit, first card wins by default
    return -1;
  }

  /// Compare trump card values (higher rank wins)
  int _comparerValeursAtout(Valeur v1, Valeur v2) {
    const ordre = [
      Valeur.sept,
      Valeur.huit,
      Valeur.dame,
      Valeur.roi,
      Valeur.dix,
      Valeur.as,
      Valeur.neuf,
      Valeur.valet,
    ];
    
    final index1 = ordre.indexOf(v1);
    final index2 = ordre.indexOf(v2);
    
    if (index1 > index2) return -1;
    if (index1 < index2) return 1;
    return 0;
  }

  /// Compare non-trump card values (higher rank wins)
  int _comparerValeursNonAtout(Valeur v1, Valeur v2) {
    const ordre = [
      Valeur.sept,
      Valeur.huit,
      Valeur.neuf,
      Valeur.valet,
      Valeur.dame,
      Valeur.roi,
      Valeur.dix,
      Valeur.as,
    ];
    
    final index1 = ordre.indexOf(v1);
    final index2 = ordre.indexOf(v2);
    
    if (index1 > index2) return -1;
    if (index1 < index2) return 1;
    return 0;
  }

  /// Total points available in a Belote Contrée hand
  /// 
  /// In Belote Contrée, there are exactly 162 total points in a complete hand:
  /// - 3 non-trump suits: 3 × 30 = 90 points
  /// - 1 trump suit: 62 points
  /// - Dix de der (last pli bonus): 10 points
  /// Total: 90 + 62 + 10 = 162 points
  /// 
  /// However, when a contract fails, the defense scores 160 points + the announce value.
  /// This represents all the hand points (without separately counting the actual plis won).
  /// The 160 excludes the dix de der which is counted separately in actual play.
  static const int pointsDefenseContratChute = 160;

  /// Check if a card can be legally played based on Belote rules
  /// This is used for the main player during the game phase
  bool peutJouerCarte(Carte carte) {
    if (_joueurActuel == null || _parametres == null) return false;
    
    // Only the current player's cards can be played
    if (_joueurActuel != _parametres!.positionJoueur) return false;
    
    // Check if player has this card
    if (!_cartesJoueur.any((c) => c.couleur == carte.couleur && c.valeur == carte.valeur)) {
      return false;
    }
    
    // Delegate to the shared validation logic
    return _validerCartePourJoueur(carte, _cartesJoueur);
  }

  /// Check if a card can be legally played based on Belote rules for any position
  /// This is used in the helper app to allow inputting cards for all players
  /// 
  /// For the main player (Position.sud): Applies strict Belote rule validation (must follow suit, must play trump, etc.)
  /// For other positions (Nord, Est, Ouest): Relaxed validation - only checks that the card hasn't been played yet by anyone
  bool peutJouerCartePosition(Carte carte, Position position) {
    if (_joueurActuel == null || _parametres == null) return false;
    
    // Only allow playing for the current player in turn
    if (_joueurActuel != position) return false;
    
    // For the main player, check their actual hand and apply strict validation
    if (position == _parametres!.positionJoueur) {
      if (!_cartesJoueur.any((c) => c.couleur == carte.couleur && c.valeur == carte.valeur)) {
        return false;
      }
      return _validerCartePourJoueur(carte, _cartesJoueur);
    }
    
    // For other players (in a helper app), allow any card that hasn't been played yet
    // The user is manually tracking what other players play
    
    // Check if card has already been played by this player
    if (estCarteJoueeParJoueur(position, carte)) {
      return false;
    }
    
    // Check if card has already been played by anyone
    if (estCarteJoueeParQuiconque(carte)) {
      return false;
    }
    
    // Allow the card to be played for other players
    // (the user knows what card was played and is entering it)
    return true;
  }

  /// Check if two positions are partners (same team)
  bool _sontPartenaires(Position pos1, Position pos2) {
    // Nord-Sud are partners, Est-Ouest are partners
    return (pos1 == Position.nord && pos2 == Position.sud) ||
        (pos1 == Position.sud && pos2 == Position.nord) ||
        (pos1 == Position.est && pos2 == Position.ouest) ||
        (pos1 == Position.ouest && pos2 == Position.est);
  }

  /// Shared validation logic for checking if a card play follows Belote rules
  bool _validerCartePourJoueur(Carte carte, List<Carte> cartesJoueur) {
    // First card of pli can always be played
    if (_pliActuel.isEmpty) return true;
    
    final couleurDemandee = _pliActuel.first.carte.couleur;
    final trumpCouleur = atoutCouleur;
    
    // Check if player has any cards of requested suit
    final aCartesCouleurDemandee = cartesJoueur.any((c) => c.couleur == couleurDemandee);
    
    // Must follow suit if possible
    if (aCartesCouleurDemandee) {
      return carte.couleur == couleurDemandee;
    }
    
    // If can't follow suit and trump exists, must play trump if possible
    if (trumpCouleur != null) {
      final aCartesAtout = cartesJoueur.any((c) => c.couleur == trumpCouleur);
      
      if (aCartesAtout) {
        // Must play trump
        if (carte.couleur != trumpCouleur) return false;
        
        // Check if need to play higher trump (monter)
        final atoutsJoues = _pliActuel
            .where((cj) => cj.carte.couleur == trumpCouleur)
            .map((cj) => cj.carte)
            .toList();
        
        if (atoutsJoues.isNotEmpty) {
          // Find the highest trump played
          Carte plusHautAtout = atoutsJoues.first;
          for (final atout in atoutsJoues) {
            if (_comparerCartes(atout, plusHautAtout, null) < 0) {
              plusHautAtout = atout;
            }
          }
          
          // Check if partner is currently winning
          final gagnantActuel = gagnantPliActuel;
          final currentPlayer = _joueurActuel;
          
          // If partner is winning, no need to play higher trump
          if (currentPlayer != null && gagnantActuel != null && 
              _sontPartenaires(currentPlayer, gagnantActuel)) {
            // Partner is winning, any trump is OK
            return true;
          }
          
          // Check if player has a higher trump
          final atoutsDisponibles = cartesJoueur.where((c) => c.couleur == trumpCouleur).toList();
          final aPlusHautAtout = atoutsDisponibles.any(
            (c) => _comparerCartes(c, plusHautAtout, null) < 0
          );
          
          // If player has higher trump, must play it
          if (aPlusHautAtout) {
            return _comparerCartes(carte, plusHautAtout, null) < 0;
          }
        }
        
        return true;
      }
    }
    
    // If can't follow suit and no trump (or no trump cards), can play any card
    return true;
  }

  /// Get list of valid cards that can be played
  List<Carte> getCartesValides() {
    if (_joueurActuel == null || _parametres == null) return [];
    if (_joueurActuel != _parametres!.positionJoueur) return [];
    
    return _cartesJoueur.where((carte) => peutJouerCarte(carte)).toList();
  }

  /// Start the game phase
  void commencerJeu() {
    // The first player is the one who won the bidding (the preneur)
    final preneur = equipePrenante;
    if (preneur != null) {
      _joueurActuel = preneur;
      _premierJoueurPli = _joueurActuel;
    } else if (_parametres?.positionDonneur != null) {
      // Fallback: if no bid was made, start with player to right of dealer
      _joueurActuel = _parametres!.sensRotation == SensRotation.horaire
          ? _parametres!.positionDonneur!.suivant
          : _parametres!.positionDonneur!.precedent;
      _premierJoueurPli = _joueurActuel;
    }
    _nombrePlis = 0;
    _pointsNordSud = 0;
    _pointsEstOuest = 0;
    _mainFinalisee = false;
    _pliActuel = [];
    _cartesJouees = [];
    _cartesParJoueur = {};
    _cartesJoueesParJoueur = {};
    _plisTermines = [];
    
    // Initialize cards for all players
    for (final position in Position.values) {
      _cartesJoueesParJoueur[position] = [];
      _couleursManquantes[position] = {};
      if (position == _parametres?.positionJoueur) {
        _cartesParJoueur[position] = List.from(_cartesJoueur);
      } else {
        // Initialize with all 8 cards for other players (unknown cards)
        _cartesParJoueur[position] = [];
      }
    }
    notifyListeners();
  }

  /// Play a card
  void jouerCarte(Carte carte) {
    if (_joueurActuel == null) return;

    // Validate card can be played (for the player only)
    if (_joueurActuel == _parametres?.positionJoueur) {
      if (!peutJouerCarte(carte)) {
        // Invalid card play - should not happen with proper UI
        return;
      }
    }

    // Track first player of the pli
    if (_pliActuel.isEmpty) {
      _premierJoueurPli = _joueurActuel;
    }

    // Detect if player didn't follow suit (missing color)
    if (_pliActuel.isNotEmpty) {
      final couleurDemandee = _pliActuel.first.carte.couleur;
      if (carte.couleur != couleurDemandee) {
        // Player didn't follow suit, mark this color as missing
        _couleursManquantes[_joueurActuel!] ??= {};
        _couleursManquantes[_joueurActuel!]!.add(couleurDemandee);
      }
    }

    // Add to current pli
    _pliActuel.add(CarteJouee(joueur: _joueurActuel!, carte: carte));

    // Track played card for this player
    _cartesJoueesParJoueur[_joueurActuel!] ??= [];
    _cartesJoueesParJoueur[_joueurActuel!]!.add(carte);

    // If this is the player's card, remove it and track it
    if (_joueurActuel == _parametres?.positionJoueur) {
      _cartesJoueur.removeWhere(
        (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
      );
      _cartesJouees.add(carte);
      _cartesParJoueur[_joueurActuel!]?.removeWhere(
        (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
      );
    }

    // Move to next player
    if (_parametres != null) {
      _joueurActuel = _parametres!.sensRotation == SensRotation.horaire
          ? _joueurActuel!.suivant
          : _joueurActuel!.precedent;
    }

    // If pli is complete (4 cards), determine winner
    if (_pliActuel.length == 4) {
      _terminerPli();
    }

    notifyListeners();
  }

  void _terminerPli() {
    if (_pliActuel.isEmpty || _premierJoueurPli == null) return;
    
    // Determine winner by comparing cards
    final couleurDemandee = _pliActuel.first.carte.couleur;
    CarteJouee carteGagnante = _pliActuel.first;
    
    for (int i = 1; i < _pliActuel.length; i++) {
      final carteJouee = _pliActuel[i];
      if (_comparerCartes(carteJouee.carte, carteGagnante.carte, couleurDemandee) < 0) {
        carteGagnante = carteJouee;
      }
    }
    
    final gagnant = carteGagnante.joueur;
    
    // Calculate points for this pli
    final trumpCouleur = atoutCouleur;
    int points = 0;
    for (final carteJouee in _pliActuel) {
      // Use trump points if card is trump, otherwise non-trump points
      if (trumpCouleur != null && carteJouee.carte.couleur == trumpCouleur) {
        points += carteJouee.carte.pointsAtout;
      } else {
        points += carteJouee.carte.pointsNonAtout;
      }
    }
    
    // Add 10 points for the last pli (dix de der)
    if (_nombrePlis == 7) { // 8th pli (0-indexed)
      points += 10;
    }
    
    // Store the completed pli
    _plisTermines.add(PliTermine(
      cartes: List.from(_pliActuel),
      gagnant: gagnant,
      points: points,
    ));
    
    // Award points to winning team
    if (gagnant == Position.nord || gagnant == Position.sud) {
      _pointsNordSud += points;
    } else {
      _pointsEstOuest += points;
    }
    
    _nombrePlis++;
    _pliActuel = [];
    _joueurActuel = gagnant; // Winner plays first in next pli
  }

  /// Check if a card has been played by the player
  bool estCarteJouee(Carte carte) {
    return _cartesJouees.any(
      (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
    );
  }

  /// Check if a card has been played by a specific player
  bool estCarteJoueeParJoueur(Position joueur, Carte carte) {
    return _cartesJoueesParJoueur[joueur]?.any(
      (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
    ) ?? false;
  }

  /// Check if a card has been played by any player
  bool estCarteJoueeParQuiconque(Carte carte) {
    for (final pos in Position.values) {
      if (estCarteJoueeParJoueur(pos, carte)) {
        return true;
      }
    }
    // Also check current pli
    return _pliActuel.any(
      (cj) => cj.carte.couleur == carte.couleur && cj.carte.valeur == carte.valeur,
    );
  }

  /// Get all cards for a specific player
  List<Carte> getCartesJoueur(Position joueur) {
    return _cartesParJoueur[joueur] ?? [];
  }

  /// Calculate current pli points
  int get pointsPliActuel {
    final trumpCouleur = atoutCouleur;
    int points = 0;
    for (final carteJouee in _pliActuel) {
      // Use trump points if card is trump, otherwise non-trump points
      if (trumpCouleur != null && carteJouee.carte.couleur == trumpCouleur) {
        points += carteJouee.carte.pointsAtout;
      } else {
        points += carteJouee.carte.pointsNonAtout;
      }
    }
    return points;
  }

  /// Get the current winner of the pli in progress
  Position? get gagnantPliActuel {
    if (_pliActuel.isEmpty || _premierJoueurPli == null) return null;
    
    final couleurDemandee = _pliActuel.first.carte.couleur;
    CarteJouee carteGagnante = _pliActuel.first;
    
    for (int i = 1; i < _pliActuel.length; i++) {
      final carteJouee = _pliActuel[i];
      if (_comparerCartes(carteJouee.carte, carteGagnante.carte, couleurDemandee) < 0) {
        carteGagnante = carteJouee;
      }
    }
    
    return carteGagnante.joueur;
  }

  /// Get the multiplier for the current contract (contre, surcontre)
  int get multiplicateurContrat {
    final derniere = annonceGagnante;
    if (derniere == null) return 1;
    
    if (derniere.type == TypeAnnonce.surcontre) return 4;
    if (derniere.type == TypeAnnonce.contre) return 2;
    return 1;
  }

  /// Get the announce points (value of the bid)
  int get pointsAnnonce {
    // Find the last prise announcement
    for (int i = _annonces.length - 1; i >= 0; i--) {
      final annonce = _annonces[i];
      if (annonce.type == TypeAnnonce.prise) {
        if (annonce.estCapot) {
          return 250; // Capot is worth 250 points
        }
        return annonce.valeur ?? 0;
      }
    }
    return 0;
  }

  /// Get the team that made the winning bid
  Position? get equipePrenante {
    // Find the last prise announcement
    for (int i = _annonces.length - 1; i >= 0; i--) {
      final annonce = _annonces[i];
      if (annonce.type == TypeAnnonce.prise) {
        return annonce.joueur;
      }
    }
    return null;
  }

  /// Check if Nord-Sud made the contract
  bool get nordSudEstPrenante {
    final prenante = equipePrenante;
    if (prenante == null) return false;
    return prenante == Position.nord || prenante == Position.sud;
  }

  /// Calculate detailed points breakdown for finalization
  Map<String, dynamic> calculerPointsDetailles() {
    final annonce = pointsAnnonce;
    final mult = multiplicateurContrat;
    final prenantNordSud = nordSudEstPrenante;
    
    // Check if contract was made
    final pointsPrenante = prenantNordSud ? _pointsNordSud : _pointsEstOuest;
    final contractReussi = pointsPrenante >= annonce;
    
    int pointsGagnesNordSud = 0;
    int pointsGagnesEstOuest = 0;
    
    if (contractReussi) {
      // Contract made - prenante gets contract + hand points
      if (prenantNordSud) {
        pointsGagnesNordSud = (annonce + _pointsNordSud) * mult;
        pointsGagnesEstOuest = 0; // Defense gets nothing when contract is made
      } else {
        pointsGagnesEstOuest = (annonce + _pointsEstOuest) * mult;
        pointsGagnesNordSud = 0;
      }
    } else {
      // Contract failed - defense gets all hand points + contract value
      if (prenantNordSud) {
        pointsGagnesEstOuest = (pointsDefenseContratChute + annonce) * mult;
        pointsGagnesNordSud = 0;
      } else {
        pointsGagnesNordSud = (pointsDefenseContratChute + annonce) * mult;
        pointsGagnesEstOuest = 0;
      }
    }
    
    return {
      'contractReussi': contractReussi,
      'annonce': annonce,
      'multiplicateur': mult,
      'prenantNordSud': prenantNordSud,
      'pointsMainNordSud': _pointsNordSud,
      'pointsMainEstOuest': _pointsEstOuest,
      'pointsGagnesNordSud': pointsGagnesNordSud,
      'pointsGagnesEstOuest': pointsGagnesEstOuest,
    };
  }

  /// Finalize the current main and add points to totals
  void finaliserMain() {
    // Only finalize once per main
    if (_mainFinalisee) return;
    
    final details = calculerPointsDetailles();
    _pointsTotauxNordSud += details['pointsGagnesNordSud'] as int;
    _pointsTotauxEstOuest += details['pointsGagnesEstOuest'] as int;
    _mainFinalisee = true;
    _nombreMains++;
    notifyListeners();
  }

  /// Start a new main (keeping totals)
  void nouvelleMain() {
    _nombrePlis = 0;
    _pointsNordSud = 0;
    _pointsEstOuest = 0;
    _mainFinalisee = false;
    _pliActuel = [];
    _premierJoueurPli = null;
    _cartesJouees = [];
    _cartesParJoueur = {};
    _cartesJoueesParJoueur = {};
    _plisTermines = [];
    _annonces = [];
    _couleursManquantes = {};
    
    // Reset to first player
    if (_parametres?.positionDonneur != null) {
      _joueurActuel = _parametres!.sensRotation == SensRotation.horaire
          ? _parametres!.positionDonneur!.suivant
          : _parametres!.positionDonneur!.precedent;
      _premierJoueurPli = _joueurActuel;
    }
    
    notifyListeners();
  }

  /// Get the winning announcement (the last prise/contre/surcontre)
  Annonce? get annonceGagnante {
    if (_annonces.isEmpty) return null;
    
    // Find the last non-pass announcement
    for (int i = _annonces.length - 1; i >= 0; i--) {
      if (_annonces[i].type != TypeAnnonce.passe) {
        return _annonces[i];
      }
    }
    
    return null;
  }

  /// Get the atout (trump) color from the winning bid
  /// Returns the couleur from the last prise announcement, which is the actual bid
  /// that establishes the trump. Contre and surcontre don't change the trump,
  /// they only affect the multiplier.
  String? get atout {
    // Check if there's any prise with a couleur
    if (!_annonces.any((a) => a.type == TypeAnnonce.prise && a.couleur != null)) {
      return null;
    }
    
    return _annonces
        .lastWhere(
          (a) => a.type == TypeAnnonce.prise && a.couleur != null,
        )
        .couleur;
  }
}
