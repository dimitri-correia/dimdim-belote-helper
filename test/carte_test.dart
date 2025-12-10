import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote_helper/models/carte.dart';

void main() {
  group('Carte Tests', () {
    test('Carte creation', () {
      final carte = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      expect(carte.couleur, Couleur.pique);
      expect(carte.valeur, Valeur.as);
    });

    test('Carte symbols', () {
      final cartePique = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      final carteCoeur = Carte(couleur: Couleur.coeur, valeur: Valeur.roi);
      final carteCarreau = Carte(couleur: Couleur.carreau, valeur: Valeur.dame);
      final carteTrefle = Carte(couleur: Couleur.trefle, valeur: Valeur.valet);

      expect(cartePique.nomCouleur, '♠');
      expect(carteCoeur.nomCouleur, '♥');
      expect(carteCarreau.nomCouleur, '♦');
      expect(carteTrefle.nomCouleur, '♣');
    });

    test('Carte values', () {
      final carteAs = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      final carteRoi = Carte(couleur: Couleur.pique, valeur: Valeur.roi);
      final carteDame = Carte(couleur: Couleur.pique, valeur: Valeur.dame);
      final carteValet = Carte(couleur: Couleur.pique, valeur: Valeur.valet);
      final carte10 = Carte(couleur: Couleur.pique, valeur: Valeur.dix);
      final carte9 = Carte(couleur: Couleur.pique, valeur: Valeur.neuf);
      final carte8 = Carte(couleur: Couleur.pique, valeur: Valeur.huit);
      final carte7 = Carte(couleur: Couleur.pique, valeur: Valeur.sept);

      expect(carteAs.nomValeur, 'A');
      expect(carteRoi.nomValeur, 'R');
      expect(carteDame.nomValeur, 'D');
      expect(carteValet.nomValeur, 'V');
      expect(carte10.nomValeur, '10');
      expect(carte9.nomValeur, '9');
      expect(carte8.nomValeur, '8');
      expect(carte7.nomValeur, '7');
    });

    test('Carte toString', () {
      final carte = Carte(couleur: Couleur.coeur, valeur: Valeur.as);
      expect(carte.toString(), 'A♥');
    });

    test('Points atout', () {
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.valet).pointsAtout, 20);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.neuf).pointsAtout, 14);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.as).pointsAtout, 11);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.dix).pointsAtout, 10);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.roi).pointsAtout, 4);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.dame).pointsAtout, 3);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.huit).pointsAtout, 0);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.sept).pointsAtout, 0);
    });

    test('Points non-atout', () {
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.as).pointsNonAtout, 11);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.dix).pointsNonAtout, 10);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.roi).pointsNonAtout, 4);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.dame).pointsNonAtout, 3);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.valet).pointsNonAtout, 2);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.neuf).pointsNonAtout, 0);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.huit).pointsNonAtout, 0);
      expect(Carte(couleur: Couleur.pique, valeur: Valeur.sept).pointsNonAtout, 0);
    });

    test('Total points for a full color as atout', () {
      // A full color as atout should sum to 62 points
      int total = 0;
      for (final valeur in Valeur.values) {
        total += Carte(couleur: Couleur.pique, valeur: valeur).pointsAtout;
      }
      expect(total, 62);
    });

    test('Total points for a full color as non-atout', () {
      // A full color as non-atout should sum to 30 points
      int total = 0;
      for (final valeur in Valeur.values) {
        total += Carte(couleur: Couleur.pique, valeur: valeur).pointsNonAtout;
      }
      expect(total, 30);
    });

    test('All colors have same point values', () {
      // Verify that all colors follow the same point rules
      for (final couleur in Couleur.values) {
        int totalAtout = 0;
        int totalNonAtout = 0;
        for (final valeur in Valeur.values) {
          final carte = Carte(couleur: couleur, valeur: valeur);
          totalAtout += carte.pointsAtout;
          totalNonAtout += carte.pointsNonAtout;
        }
        expect(totalAtout, 62, reason: 'Total atout points should be 62 for ${couleur.name}');
        expect(totalNonAtout, 30, reason: 'Total non-atout points should be 30 for ${couleur.name}');
      }
    });
  });
}
