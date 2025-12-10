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
  });
}
