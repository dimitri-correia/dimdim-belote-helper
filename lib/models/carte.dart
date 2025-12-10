enum Couleur {
  pique,
  coeur,
  carreau,
  trefle,
}

enum Valeur {
  sept,
  huit,
  neuf,
  valet,
  dame,
  roi,
  dix,
  as,
}

class Carte {
  final Couleur couleur;
  final Valeur valeur;

  Carte({required this.couleur, required this.valeur});

  String get nomCouleur {
    switch (couleur) {
      case Couleur.pique:
        return '♠';
      case Couleur.coeur:
        return '♥';
      case Couleur.carreau:
        return '♦';
      case Couleur.trefle:
        return '♣';
    }
  }

  String get nomValeur {
    switch (valeur) {
      case Valeur.sept:
        return '7';
      case Valeur.huit:
        return '8';
      case Valeur.neuf:
        return '9';
      case Valeur.valet:
        return 'V';
      case Valeur.dame:
        return 'D';
      case Valeur.roi:
        return 'R';
      case Valeur.dix:
        return '10';
      case Valeur.as:
        return 'A';
    }
  }

  @override
  String toString() => '$nomValeur$nomCouleur';
}
