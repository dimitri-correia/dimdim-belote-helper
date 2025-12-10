import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/annonce.dart';

void main() {
  group('Main Cycle Tests', () {
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
      
      // Add a bid to set trump
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));
      
      // Set up player's cards (Sud)
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
        Carte(couleur: Couleur.pique, valeur: Valeur.roi),
        Carte(couleur: Couleur.coeur, valeur: Valeur.as),
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
        Carte(couleur: Couleur.carreau, valeur: Valeur.as),
        Carte(couleur: Couleur.carreau, valeur: Valeur.roi),
        Carte(couleur: Couleur.trefle, valeur: Valeur.as),
        Carte(couleur: Couleur.trefle, valeur: Valeur.roi),
      ];
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
    });

    test('Main starts with 0 plis', () {
      expect(etatJeu.nombrePlis, 0);
      expect(etatJeu.nombreMains, 0);
      expect(etatJeu.mainFinalisee, false);
    });

    test('After 8 plis, main is not automatically finalized', () {
      // Play 8 plis (4 cards each)
      for (int i = 0; i < 8; i++) {
        // Play 4 cards for each pli
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dame));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dix));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.neuf));
      }
      
      expect(etatJeu.nombrePlis, 8);
      expect(etatJeu.mainFinalisee, false); // Should not be auto-finalized
      expect(etatJeu.nombreMains, 0); // Still on first main
    });

    test('Finalize main increments nombreMains and sets mainFinalisee', () {
      // Play 8 plis
      for (int i = 0; i < 8; i++) {
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dame));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dix));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.neuf));
      }
      
      expect(etatJeu.mainFinalisee, false);
      expect(etatJeu.nombreMains, 0);
      
      // Finalize the main
      etatJeu.finaliserMain();
      
      expect(etatJeu.mainFinalisee, true);
      expect(etatJeu.nombreMains, 1);
      expect(etatJeu.pointsTotauxNordSud + etatJeu.pointsTotauxEstOuest, greaterThan(0));
    });

    test('Finalize main can only be called once per main', () {
      // Play 8 plis
      for (int i = 0; i < 8; i++) {
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dame));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dix));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.neuf));
      }
      
      final initialTotauxNordSud = etatJeu.pointsTotauxNordSud;
      final initialTotauxEstOuest = etatJeu.pointsTotauxEstOuest;
      
      // Finalize the main
      etatJeu.finaliserMain();
      
      final totalNordSudAfterFirst = etatJeu.pointsTotauxNordSud;
      final totalEstOuestAfterFirst = etatJeu.pointsTotauxEstOuest;
      
      expect(totalNordSudAfterFirst, greaterThan(initialTotauxNordSud));
      
      // Try to finalize again - should have no effect
      etatJeu.finaliserMain();
      
      expect(etatJeu.pointsTotauxNordSud, totalNordSudAfterFirst);
      expect(etatJeu.pointsTotauxEstOuest, totalEstOuestAfterFirst);
      expect(etatJeu.nombreMains, 1); // Still 1, not 2
    });

    test('nouvelleMain resets for new cycle', () {
      // Play and finalize a main
      for (int i = 0; i < 8; i++) {
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dame));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dix));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.neuf));
      }
      etatJeu.finaliserMain();
      
      final totalNordSudAfterMain1 = etatJeu.pointsTotauxNordSud;
      final totalEstOuestAfterMain1 = etatJeu.pointsTotauxEstOuest;
      
      // Start new main
      etatJeu.nouvelleMain();
      
      // Check that the cycle state is reset
      expect(etatJeu.nombrePlis, 0);
      expect(etatJeu.pointsNordSud, 0);
      expect(etatJeu.pointsEstOuest, 0);
      expect(etatJeu.mainFinalisee, false);
      expect(etatJeu.pliActuel, isEmpty);
      expect(etatJeu.plisTermines, isEmpty);
      expect(etatJeu.annonces, isEmpty);
      
      // Check that totals are preserved
      expect(etatJeu.pointsTotauxNordSud, totalNordSudAfterMain1);
      expect(etatJeu.pointsTotauxEstOuest, totalEstOuestAfterMain1);
      expect(etatJeu.nombreMains, 1);
    });

    test('Winning condition: points threshold', () {
      // Set up a game with low point threshold
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 200, // Low threshold for testing
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.nord,
      );
      etatJeu.definirParametres(parametres);
      
      // Add a high bid to get enough points
      etatJeu.reinitialiserAnnonces();
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.prise,
        valeur: 160,
        couleur: '♠ Pique',
      ));
      
      etatJeu.commencerJeu();
      
      // Play 8 plis where Est-Ouest wins
      for (int i = 0; i < 8; i++) {
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet)); // Est
        etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.sept)); // Sud
        etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.huit)); // Ouest
        etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.neuf)); // Nord
      }
      
      etatJeu.finaliserMain();
      
      // Check if winning condition is met
      expect(
        etatJeu.pointsTotauxEstOuest >= 200 || etatJeu.pointsTotauxNordSud >= 200,
        true,
      );
    });

    test('Winning condition: number of mains', () {
      // Set up a game with plis condition
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.plis,
        valeurFin: 2, // Only 2 mains
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.nord,
      );
      etatJeu.definirParametres(parametres);
      
      etatJeu.reinitialiserAnnonces();
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));
      
      etatJeu.commencerJeu();
      
      // Play first main
      for (int i = 0; i < 8; i++) {
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dame));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dix));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.neuf));
      }
      etatJeu.finaliserMain();
      expect(etatJeu.nombreMains, 1);
      
      // Start second main
      etatJeu.nouvelleMain();
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));
      etatJeu.commencerJeu();
      
      // Play second main
      for (int i = 0; i < 8; i++) {
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dame));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dix));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.neuf));
      }
      etatJeu.finaliserMain();
      
      expect(etatJeu.nombreMains, 2);
      // Winning condition met
      expect(etatJeu.nombreMains >= parametres.valeurFin, true);
    });

    test('mainFinalisee getter works correctly', () {
      expect(etatJeu.mainFinalisee, false);
      
      // Play 8 plis
      for (int i = 0; i < 8; i++) {
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dame));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.dix));
        etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.neuf));
      }
      
      expect(etatJeu.mainFinalisee, false);
      
      etatJeu.finaliserMain();
      
      expect(etatJeu.mainFinalisee, true);
    });
  });
}
