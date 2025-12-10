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
    // For now, just increment pli count and reset
    // In a complete implementation, we'd determine the winner and add points
    _nombrePlis++;
    
    // The winner of the pli starts the next one
    // For simplicity, we'll just continue with the next player
    // In a real implementation, we'd need to determine who won based on trump suit
    
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
