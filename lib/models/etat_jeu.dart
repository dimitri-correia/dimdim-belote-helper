import 'package:flutter/foundation.dart';
import 'package:dimdim_belote_helper/models/position.dart';
import 'package:dimdim_belote_helper/models/carte.dart';
import 'package:dimdim_belote_helper/models/annonce.dart';

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
  final Position positionJoueur;
  final SensRotation sensRotation;
  final Position? positionDonneur; // position du donneur (dealer)

  ParametresJeu({
    required this.conditionFin,
    required this.valeurFin,
    required this.positionJoueur,
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
  int _pointsNordSud = 0;
  int _pointsEstOuest = 0;
  List<CarteJouee> _pliActuel = [];
  Position? _premierJoueurPli; // Who played first in current pli
  List<Carte> _cartesJouees = []; // All cards played by the player
  
  // Track all players' cards
  Map<Position, List<Carte>> _cartesParJoueur = {};
  Map<Position, List<Carte>> _cartesJoueesParJoueur = {};
  List<PliTermine> _plisTermines = [];

  ParametresJeu? get parametres => _parametres;
  List<Carte> get cartesJoueur => _cartesJoueur;
  List<Annonce> get annonces => _annonces;
  Position? get joueurActuel => _joueurActuel;
  int get nombrePlis => _nombrePlis;
  int get pointsNordSud => _pointsNordSud;
  int get pointsEstOuest => _pointsEstOuest;
  List<CarteJouee> get pliActuel => _pliActuel;
  Position? get premierJoueurPli => _premierJoueurPli;
  List<Carte> get cartesJouees => _cartesJouees;
  Map<Position, List<Carte>> get cartesParJoueur => _cartesParJoueur;
  Map<Position, List<Carte>> get cartesJoueesParJoueur => _cartesJoueesParJoueur;
  List<PliTermine> get plisTermines => _plisTermines;

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
    _pointsNordSud = 0;
    _pointsEstOuest = 0;
    _pliActuel = [];
    _premierJoueurPli = null;
    _cartesJouees = [];
    _cartesParJoueur = {};
    _cartesJoueesParJoueur = {};
    _plisTermines = [];
    notifyListeners();
  }

  /// Start the game phase
  void commencerJeu() {
    // The first player is the one to the right of the dealer
    if (_parametres?.positionDonneur != null) {
      _joueurActuel = _parametres!.sensRotation == SensRotation.horaire
          ? _parametres!.positionDonneur!.suivant
          : _parametres!.positionDonneur!.precedent;
      _premierJoueurPli = _joueurActuel;
    }
    _nombrePlis = 0;
    _pointsNordSud = 0;
    _pointsEstOuest = 0;
    _pliActuel = [];
    _cartesJouees = [];
    _cartesParJoueur = {};
    _cartesJoueesParJoueur = {};
    _plisTermines = [];
    
    // Initialize cards for all players
    for (final position in Position.values) {
      _cartesJoueesParJoueur[position] = [];
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

    // Track first player of the pli
    if (_pliActuel.isEmpty) {
      _premierJoueurPli = _joueurActuel;
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
    // TODO: Implement proper pli winner determination based on trump suit
    // For now, simplified logic: first player wins
    // In a complete implementation:
    // 1. Get trump suit from winning bid in annonces
    // 2. Compare cards based on trump rules
    // 3. Handle suit following rules
    final gagnant = _premierJoueurPli ?? _joueurActuel ?? Position.nord;
    
    // Calculate points for this pli
    int points = 0;
    for (final carteJouee in _pliActuel) {
      // For now, use non-trump points (will need trump info later)
      points += carteJouee.carte.pointsNonAtout;
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
  /// TODO: Use trump-aware point calculation when trump logic is implemented
  int get pointsPliActuel {
    int points = 0;
    for (final carteJouee in _pliActuel) {
      // For now, use non-trump points (consistent with _terminerPli)
      points += carteJouee.carte.pointsNonAtout;
    }
    return points;
  }

  /// Get the current winner of the pli in progress
  /// TODO: Implement proper pli winner determination based on trump suit
  Position? get gagnantPliActuel {
    if (_pliActuel.isEmpty || _premierJoueurPli == null) return null;
    
    // For now, simplified logic: first player wins (consistent with _terminerPli)
    // In a complete implementation:
    // 1. Get trump suit from winning bid in annonces
    // 2. Compare cards based on trump rules
    // 3. Handle suit following rules
    return _premierJoueurPli;
  }
}
