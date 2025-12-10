enum Couleur {
  pique,
  coeur,
  carreau,
  trefle,
}

extension CouleurExtension on Couleur {
  String get symbole {
    switch (this) {
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
    return couleur.symbole;
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

  /// Points when this card is trump (atout)
  int get pointsAtout {
    switch (valeur) {
      case Valeur.valet:
        return 20;
      case Valeur.neuf:
        return 14;
      case Valeur.as:
        return 11;
      case Valeur.dix:
        return 10;
      case Valeur.roi:
        return 4;
      case Valeur.dame:
        return 3;
      case Valeur.huit:
      case Valeur.sept:
        return 0;
    }
  }

  /// Points when this card is NOT trump (non-atout)
  int get pointsNonAtout {
    switch (valeur) {
      case Valeur.as:
        return 11;
      case Valeur.dix:
        return 10;
      case Valeur.roi:
        return 4;
      case Valeur.dame:
        return 3;
      case Valeur.valet:
        return 2;
      case Valeur.neuf:
      case Valeur.huit:
      case Valeur.sept:
        return 0;
    }
  }

  @override
  String toString() => '$nomValeur$nomCouleur';
}
