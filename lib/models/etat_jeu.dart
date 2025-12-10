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
    
    // Check that all announcements after the last non-pass are passes
    // and that at least 3 consecutive passes have occurred (all other players)
    final nombrePassesApres = _annonces.length - indexDernierNonPasse - 1;
    if (nombrePassesApres < 3) return false;
    
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
    notifyListeners();
  }

  /// Play a card
  void jouerCarte(Carte carte) {
    if (_joueurActuel == null) return;

    // Add to current pli
    _pliActuel.add(CarteJouee(joueur: _joueurActuel!, carte: carte));

    // If this is the player's card, remove it and track it
    if (_joueurActuel == _parametres?.positionJoueur) {
      _cartesJoueur.removeWhere(
        (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
      );
      _cartesJouees.add(carte);
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
    // For now, just increment pli count and reset
    // In a complete implementation, we'd:
    // 1. Determine the trump suit from the winning bid
    // 2. Calculate which card wins (trump > suit > other)
    // 3. Award points to the winning team
    // 4. Set the winner as the first player for the next pli
    _nombrePlis++;
    
    _pliActuel = [];
    // _joueurActuel is already set to the next player
  }

  /// Check if a card has been played by the player
  bool estCarteJouee(Carte carte) {
    return _cartesJouees.any(
      (c) => c.couleur == carte.couleur && c.valeur == carte.valeur,
    );
  }
}
