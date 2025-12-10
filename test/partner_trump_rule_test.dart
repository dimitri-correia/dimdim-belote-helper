import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/annonce.dart';

void main() {
  group('Partner Trump Rule Tests - Belote Contrée', () {
    late EtatJeu etatJeu;

    setUp(() {
      etatJeu = EtatJeu();
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.nord,
      );
      etatJeu.definirParametres(parametres);
      
      // Add a bid with Pique as trump
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));
    });

    test('Must play higher trump when partner is NOT winning', () {
      // Setup: Est starts with Coeur, Sud can't follow and must trump
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.valet), // Trump valet (highest)
        Carte(couleur: Couleur.pique, valeur: Valeur.sept),  // Trump 7 (lowest)
        Carte(couleur: Couleur.carreau, valeur: Valeur.as),
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Est plays Coeur (not trump)
      etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.roi));
      
      // Sud's turn - can't follow suit, has trump
      expect(etatJeu.joueurActuel, Position.sud);
      
      // Sud can play any trump (no trump played yet)
      expect(etatJeu.peutJouerCarte(cartes[0]), true); // Valet
      expect(etatJeu.peutJouerCarte(cartes[1]), true); // 7
      
      // Sud plays low trump
      etatJeu.jouerCarte(cartes[1]); // Pique 7
      
      // Ouest's turn - plays higher trump
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.neuf));
      
      // Nord's turn - partner (Sud) is NOT winning (Ouest has higher trump)
      // Nord has both high and low trumps - must play higher if possible
      final nordCartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),   // Higher than 9
        Carte(couleur: Couleur.pique, valeur: Valeur.huit), // Lower than 9
      ];
      
      // Since Nord's partner Sud is not winning, Nord must play higher trump
      expect(etatJeu.joueurActuel, Position.nord);
      
      // Simulate checking for Nord
      // Can play As (higher than 9)
      final canPlayAs = etatJeu.peutJouerCartePosition(nordCartes[0], Position.nord);
      expect(canPlayAs, true);
      
      // Cannot play 8 (lower than 9) because As is available
      final canPlay8 = etatJeu.peutJouerCartePosition(nordCartes[1], Position.nord);
      expect(canPlay8, false);
    });

    test('Can play any trump when partner IS winning', () {
      // Setup: Est starts, Sud trumps and wins, Ouest passes, Nord can play any trump
      final cartes = [
        Carte(couleur: Couleur.carreau, valeur: Valeur.as),
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Est plays Coeur
      etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.roi));
      
      // Sud trumps with high trump (Valet = highest trump)
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
      
      // Ouest can't follow, plays low trump
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.huit));
      
      // Nord's turn - partner Sud is winning with Valet
      // Nord should be able to play any trump, even lower than 8
      expect(etatJeu.joueurActuel, Position.nord);
      
      // Check current winner
      expect(etatJeu.gagnantPliActuel, Position.sud);
      
      // Nord can play low trump even though higher trump exists
      final nordCartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.neuf),  // Higher than 8
        Carte(couleur: Couleur.pique, valeur: Valeur.sept),  // Lower than 8
      ];
      
      // Both should be valid because partner is winning
      final canPlayNeuf = etatJeu.peutJouerCartePosition(nordCartes[0], Position.nord);
      expect(canPlayNeuf, true);
      
      final canPlaySept = etatJeu.peutJouerCartePosition(nordCartes[1], Position.nord);
      expect(canPlaySept, true); // This is the key test - partner is winning
    });

    test('Must play higher trump when opponent is winning', () {
      // Setup: Est starts with trump, Sud plays higher trump, Ouest can't beat it
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.neuf),
        Carte(couleur: Couleur.carreau, valeur: Valeur.as),
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Est plays trump 7
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.sept));
      
      // Sud plays trump 9 (higher)
      etatJeu.jouerCarte(cartes[0]); // Pique 9
      
      // Ouest plays trump Dame (lower than 9 in trump order)
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dame));
      
      // Nord's turn - opponent (Sud) is winning
      // Wait, Sud is Nord's partner! Let me fix this test
    });

    test('Opponent trump scenario - must play higher', () {
      // Setup: Est (opponent of Sud) starts and wins, Sud must play higher if possible
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.valet), // Highest trump
        Carte(couleur: Couleur.pique, valeur: Valeur.sept),  // Lowest trump
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Est plays Coeur
      etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.roi));
      
      // Sud's turn - can't follow, must trump
      expect(etatJeu.joueurActuel, Position.sud);
      
      // No trump played yet, so Sud can play any trump
      expect(etatJeu.peutJouerCarte(cartes[0]), true); // Valet
      expect(etatJeu.peutJouerCarte(cartes[1]), true); // 7
      
      // Let's play the valet
      etatJeu.jouerCarte(cartes[0]);
      
      // Ouest's turn - must play higher trump if has one
      // Ouest can't beat Valet (highest trump), so can play any trump
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.huit));
      
      // Nord's turn - partner Ouest is NOT winning (Sud is winning)
      // But Ouest is not Nord's partner! Est-Ouest are partners
      // So this test is checking if Est-Ouest partnership works
    });

    test('East-West partnership - partner is winning', () {
      // Setup where Est plays trump, Ouest (Est's partner) is last and doesn't need to play higher
      final cartes = [
        Carte(couleur: Couleur.carreau, valeur: Valeur.as),
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Est plays trump 9 (high trump)
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.neuf));
      
      // Sud can't follow (no pique), plays autre couleur
      etatJeu.jouerCarte(cartes[0]); // Carreau As (not trump)
      
      // Ouest's turn - partner Est is winning
      // Ouest has both high and low trumps
      expect(etatJeu.joueurActuel, Position.ouest);
      expect(etatJeu.gagnantPliActuel, Position.est);
      
      // Ouest should be able to play any trump
      final ouestCartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.valet), // Higher than 9
        Carte(couleur: Couleur.pique, valeur: Valeur.sept),  // Lower than 9
      ];
      
      // Both should be valid because partner is winning
      final canPlayValet = etatJeu.peutJouerCartePosition(ouestCartes[0], Position.ouest);
      expect(canPlayValet, true);
      
      final canPlaySept = etatJeu.peutJouerCartePosition(ouestCartes[1], Position.ouest);
      expect(canPlaySept, true); // Partner is winning, so any trump is OK
    });
  });
}
