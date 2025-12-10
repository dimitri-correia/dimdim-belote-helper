import 'package:dimdim_belote_helper/models/position.dart';

enum TypeAnnonce {
  passe,
  prise,
  contre,
  surcontre,
}

class Annonce {
  final Position joueur;
  final TypeAnnonce type;
  final int? valeur; // 80, 90, 100, 110, 120, 130, 140, 150, 160, ou null pour capot
  final String? couleur; // pique, coeur, carreau, trefle
  final bool estCapot; // true si c'est un capot (prendre tous les plis)

  Annonce({
    required this.joueur,
    required this.type,
    this.valeur,
    this.couleur,
    this.estCapot = false,
  });

  String get texte {
    switch (type) {
      case TypeAnnonce.passe:
        return 'Passe';
      case TypeAnnonce.contre:
        return 'Contre';
      case TypeAnnonce.surcontre:
        return 'Surcontré';
      case TypeAnnonce.prise:
        if (estCapot && couleur != null) {
          return 'Capot $couleur';
        } else if (valeur != null && couleur != null) {
          return '$valeur $couleur';
        }
        return 'Prise';
    }
  }

  @override
  String toString() => '${joueur.nom}: $texte';
}
