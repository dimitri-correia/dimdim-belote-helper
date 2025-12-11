import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote/models/carte.dart';

void main() {
  group('Card Ordering Tests', () {
    /// Compare two cards for sorting (same as in PlayerCardsWidget)
    int comparerCartes(Carte a, Carte b, bool estAtout) {
      if (estAtout) {
        // Trump order: Valet (20) > 9 (14) > As (11) > 10 (10) > Roi (4) > Dame (3) > 8 (0) > 7 (0)
        const ordre = [
          Valeur.valet,  // 20 points
          Valeur.neuf,   // 14 points
          Valeur.as,     // 11 points
          Valeur.dix,    // 10 points
          Valeur.roi,    // 4 points
          Valeur.dame,   // 3 points
          Valeur.huit,   // 0 points
          Valeur.sept,   // 0 points
        ];
        return ordre.indexOf(a.valeur).compareTo(ordre.indexOf(b.valeur));
      } else {
        // Non-trump order: As (11) > 10 (10) > Roi (4) > Dame (3) > Valet (2) > 9 (0) > 8 (0) > 7 (0)
        const ordre = [
          Valeur.as,     // 11 points
          Valeur.dix,    // 10 points
          Valeur.roi,    // 4 points
          Valeur.dame,   // 3 points
          Valeur.valet,  // 2 points
          Valeur.neuf,   // 0 points
          Valeur.huit,   // 0 points
          Valeur.sept,   // 0 points
        ];
        return ordre.indexOf(a.valeur).compareTo(ordre.indexOf(b.valeur));
      }
    }

    test('Trump cards should be ordered by trump value', () {
      // Create all spades cards
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.sept),
        Carte(couleur: Couleur.pique, valeur: Valeur.huit),
        Carte(couleur: Couleur.pique, valeur: Valeur.neuf),
        Carte(couleur: Couleur.pique, valeur: Valeur.valet),
        Carte(couleur: Couleur.pique, valeur: Valeur.dame),
        Carte(couleur: Couleur.pique, valeur: Valeur.roi),
        Carte(couleur: Couleur.pique, valeur: Valeur.dix),
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
      ];

      // Sort as trump
      cartes.sort((a, b) => comparerCartes(a, b, true));

      // Expected order: Valet, 9, As, 10, Roi, Dame, 8, 7
      expect(cartes[0].valeur, Valeur.valet);
      expect(cartes[1].valeur, Valeur.neuf);
      expect(cartes[2].valeur, Valeur.as);
      expect(cartes[3].valeur, Valeur.dix);
      expect(cartes[4].valeur, Valeur.roi);
      expect(cartes[5].valeur, Valeur.dame);
      expect(cartes[6].valeur, Valeur.huit);
      expect(cartes[7].valeur, Valeur.sept);
    });

    test('Non-trump cards should be ordered by non-trump value', () {
      // Create all hearts cards
      final cartes = [
        Carte(couleur: Couleur.coeur, valeur: Valeur.sept),
        Carte(couleur: Couleur.coeur, valeur: Valeur.huit),
        Carte(couleur: Couleur.coeur, valeur: Valeur.neuf),
        Carte(couleur: Couleur.coeur, valeur: Valeur.valet),
        Carte(couleur: Couleur.coeur, valeur: Valeur.dame),
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
        Carte(couleur: Couleur.coeur, valeur: Valeur.dix),
        Carte(couleur: Couleur.coeur, valeur: Valeur.as),
      ];

      // Sort as non-trump
      cartes.sort((a, b) => comparerCartes(a, b, false));

      // Expected order: As, 10, Roi, Dame, Valet, 9, 8, 7
      expect(cartes[0].valeur, Valeur.as);
      expect(cartes[1].valeur, Valeur.dix);
      expect(cartes[2].valeur, Valeur.roi);
      expect(cartes[3].valeur, Valeur.dame);
      expect(cartes[4].valeur, Valeur.valet);
      expect(cartes[5].valeur, Valeur.neuf);
      expect(cartes[6].valeur, Valeur.huit);
      expect(cartes[7].valeur, Valeur.sept);
    });

    test('Trump ordering should differ from non-trump ordering', () {
      // Create some cards
      final valet = Carte(couleur: Couleur.pique, valeur: Valeur.valet);
      final neuf = Carte(couleur: Couleur.pique, valeur: Valeur.neuf);
      final as = Carte(couleur: Couleur.pique, valeur: Valeur.as);

      // In trump: Valet > 9 > As
      expect(comparerCartes(valet, neuf, true) < 0, true);
      expect(comparerCartes(neuf, as, true) < 0, true);
      expect(comparerCartes(valet, as, true) < 0, true);

      // In non-trump: As > Valet > 9
      expect(comparerCartes(as, valet, false) < 0, true);
      expect(comparerCartes(valet, neuf, false) < 0, true);
      expect(comparerCartes(as, neuf, false) < 0, true);
    });

    test('Trump order matches trump points', () {
      // Verify that the sort order corresponds to point values
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.sept),
        Carte(couleur: Couleur.pique, valeur: Valeur.huit),
        Carte(couleur: Couleur.pique, valeur: Valeur.neuf),
        Carte(couleur: Couleur.pique, valeur: Valeur.valet),
        Carte(couleur: Couleur.pique, valeur: Valeur.dame),
        Carte(couleur: Couleur.pique, valeur: Valeur.roi),
        Carte(couleur: Couleur.pique, valeur: Valeur.dix),
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
      ];

      cartes.sort((a, b) => comparerCartes(a, b, true));

      // Check that cards are in descending order of trump points
      for (int i = 0; i < cartes.length - 1; i++) {
        expect(
          cartes[i].pointsAtout >= cartes[i + 1].pointsAtout,
          true,
          reason:
              '${cartes[i].nomValeur} (${cartes[i].pointsAtout} pts) should be >= ${cartes[i + 1].nomValeur} (${cartes[i + 1].pointsAtout} pts)',
        );
      }
    });

    test('Non-trump order matches non-trump points', () {
      // Verify that the sort order corresponds to point values
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.sept),
        Carte(couleur: Couleur.pique, valeur: Valeur.huit),
        Carte(couleur: Couleur.pique, valeur: Valeur.neuf),
        Carte(couleur: Couleur.pique, valeur: Valeur.valet),
        Carte(couleur: Couleur.pique, valeur: Valeur.dame),
        Carte(couleur: Couleur.pique, valeur: Valeur.roi),
        Carte(couleur: Couleur.pique, valeur: Valeur.dix),
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
      ];

      cartes.sort((a, b) => comparerCartes(a, b, false));

      // Check that cards are in descending order of non-trump points
      for (int i = 0; i < cartes.length - 1; i++) {
        expect(
          cartes[i].pointsNonAtout >= cartes[i + 1].pointsNonAtout,
          true,
          reason:
              '${cartes[i].nomValeur} (${cartes[i].pointsNonAtout} pts) should be >= ${cartes[i + 1].nomValeur} (${cartes[i + 1].pointsNonAtout} pts)',
        );
      }
    });
  });
}
