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

class EtatJeu extends ChangeNotifier {
  ParametresJeu? _parametres;
  List<Carte> _cartesJoueur = [];
  List<Annonce> _annonces = [];
  Position? _joueurActuel;

  ParametresJeu? get parametres => _parametres;
  List<Carte> get cartesJoueur => _cartesJoueur;
  List<Annonce> get annonces => _annonces;
  Position? get joueurActuel => _joueurActuel;

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
    notifyListeners();
  }
}
