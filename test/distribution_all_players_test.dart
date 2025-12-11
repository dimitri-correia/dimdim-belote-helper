import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/models/carte.dart';

void main() {
  group('Distribution for All Players Tests', () {
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
    });

    test('definirToutesLesCartes sets cards for all players', () {
      final cartesParJoueur = <Position, List<Carte>>{
        Position.nord: [
          Carte(couleur: Couleur.pique, valeur: Valeur.as),
          Carte(couleur: Couleur.pique, valeur: Valeur.roi),
          Carte(couleur: Couleur.pique, valeur: Valeur.dame),
          Carte(couleur: Couleur.pique, valeur: Valeur.valet),
          Carte(couleur: Couleur.coeur, valeur: Valeur.as),
          Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
          Carte(couleur: Couleur.coeur, valeur: Valeur.dame),
          Carte(couleur: Couleur.coeur, valeur: Valeur.valet),
        ],
        Position.est: [
          Carte(couleur: Couleur.carreau, valeur: Valeur.as),
          Carte(couleur: Couleur.carreau, valeur: Valeur.roi),
          Carte(couleur: Couleur.carreau, valeur: Valeur.dame),
          Carte(couleur: Couleur.carreau, valeur: Valeur.valet),
          Carte(couleur: Couleur.trefle, valeur: Valeur.as),
          Carte(couleur: Couleur.trefle, valeur: Valeur.roi),
          Carte(couleur: Couleur.trefle, valeur: Valeur.dame),
          Carte(couleur: Couleur.trefle, valeur: Valeur.valet),
        ],
        Position.sud: [
          Carte(couleur: Couleur.pique, valeur: Valeur.dix),
          Carte(couleur: Couleur.pique, valeur: Valeur.neuf),
          Carte(couleur: Couleur.pique, valeur: Valeur.huit),
          Carte(couleur: Couleur.pique, valeur: Valeur.sept),
          Carte(couleur: Couleur.coeur, valeur: Valeur.dix),
          Carte(couleur: Couleur.coeur, valeur: Valeur.neuf),
          Carte(couleur: Couleur.coeur, valeur: Valeur.huit),
          Carte(couleur: Couleur.coeur, valeur: Valeur.sept),
        ],
        Position.ouest: [
          Carte(couleur: Couleur.carreau, valeur: Valeur.dix),
          Carte(couleur: Couleur.carreau, valeur: Valeur.neuf),
          Carte(couleur: Couleur.carreau, valeur: Valeur.huit),
          Carte(couleur: Couleur.carreau, valeur: Valeur.sept),
          Carte(couleur: Couleur.trefle, valeur: Valeur.dix),
          Carte(couleur: Couleur.trefle, valeur: Valeur.neuf),
          Carte(couleur: Couleur.trefle, valeur: Valeur.huit),
          Carte(couleur: Couleur.trefle, valeur: Valeur.sept),
        ],
      };

      etatJeu.definirToutesLesCartes(cartesParJoueur);

      // Check that main player's cards are set
      expect(etatJeu.cartesJoueur.length, 8);
      expect(etatJeu.cartesJoueur, cartesParJoueur[Position.sud]);

      // Check that all players' cards are tracked
      for (final position in Position.values) {
        expect(
          etatJeu.cartesParJoueur[position]?.length,
          8,
          reason: 'Player ${position.nom} should have 8 cards',
        );
      }
    });

    test('commencerJeu preserves distributed cards', () {
      final cartesParJoueur = <Position, List<Carte>>{
        Position.nord: [
          Carte(couleur: Couleur.pique, valeur: Valeur.as),
          Carte(couleur: Couleur.pique, valeur: Valeur.roi),
          Carte(couleur: Couleur.pique, valeur: Valeur.dame),
          Carte(couleur: Couleur.pique, valeur: Valeur.valet),
          Carte(couleur: Couleur.coeur, valeur: Valeur.as),
          Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
          Carte(couleur: Couleur.coeur, valeur: Valeur.dame),
          Carte(couleur: Couleur.coeur, valeur: Valeur.valet),
        ],
        Position.est: [
          Carte(couleur: Couleur.carreau, valeur: Valeur.as),
          Carte(couleur: Couleur.carreau, valeur: Valeur.roi),
          Carte(couleur: Couleur.carreau, valeur: Valeur.dame),
          Carte(couleur: Couleur.carreau, valeur: Valeur.valet),
          Carte(couleur: Couleur.trefle, valeur: Valeur.as),
          Carte(couleur: Couleur.trefle, valeur: Valeur.roi),
          Carte(couleur: Couleur.trefle, valeur: Valeur.dame),
          Carte(couleur: Couleur.trefle, valeur: Valeur.valet),
        ],
        Position.sud: [
          Carte(couleur: Couleur.pique, valeur: Valeur.dix),
          Carte(couleur: Couleur.pique, valeur: Valeur.neuf),
          Carte(couleur: Couleur.pique, valeur: Valeur.huit),
          Carte(couleur: Couleur.pique, valeur: Valeur.sept),
          Carte(couleur: Couleur.coeur, valeur: Valeur.dix),
          Carte(couleur: Couleur.coeur, valeur: Valeur.neuf),
          Carte(couleur: Couleur.coeur, valeur: Valeur.huit),
          Carte(couleur: Couleur.coeur, valeur: Valeur.sept),
        ],
        Position.ouest: [
          Carte(couleur: Couleur.carreau, valeur: Valeur.dix),
          Carte(couleur: Couleur.carreau, valeur: Valeur.neuf),
          Carte(couleur: Couleur.carreau, valeur: Valeur.huit),
          Carte(couleur: Couleur.carreau, valeur: Valeur.sept),
          Carte(couleur: Couleur.trefle, valeur: Valeur.dix),
          Carte(couleur: Couleur.trefle, valeur: Valeur.neuf),
          Carte(couleur: Couleur.trefle, valeur: Valeur.huit),
          Carte(couleur: Couleur.trefle, valeur: Valeur.sept),
        ],
      };

      etatJeu.definirToutesLesCartes(cartesParJoueur);
      etatJeu.commencerJeu();

      // Check that cards are still present after commencerJeu
      for (final position in Position.values) {
        expect(
          etatJeu.cartesParJoueur[position]?.length,
          8,
          reason: 'Player ${position.nom} should still have 8 cards after commencerJeu',
        );
      }
    });

    test('peutJouerCartePosition validates cards for any player', () {
      final cartesParJoueur = <Position, List<Carte>>{
        Position.nord: [
          Carte(couleur: Couleur.pique, valeur: Valeur.as),
          Carte(couleur: Couleur.pique, valeur: Valeur.roi),
          Carte(couleur: Couleur.pique, valeur: Valeur.dame),
          Carte(couleur: Couleur.pique, valeur: Valeur.valet),
          Carte(couleur: Couleur.coeur, valeur: Valeur.as),
          Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
          Carte(couleur: Couleur.coeur, valeur: Valeur.dame),
          Carte(couleur: Couleur.coeur, valeur: Valeur.valet),
        ],
        Position.est: [
          Carte(couleur: Couleur.carreau, valeur: Valeur.as),
          Carte(couleur: Couleur.carreau, valeur: Valeur.roi),
          Carte(couleur: Couleur.carreau, valeur: Valeur.dame),
          Carte(couleur: Couleur.carreau, valeur: Valeur.valet),
          Carte(couleur: Couleur.trefle, valeur: Valeur.as),
          Carte(couleur: Couleur.trefle, valeur: Valeur.roi),
          Carte(couleur: Couleur.trefle, valeur: Valeur.dame),
          Carte(couleur: Couleur.trefle, valeur: Valeur.valet),
        ],
        Position.sud: [
          Carte(couleur: Couleur.pique, valeur: Valeur.dix),
          Carte(couleur: Couleur.pique, valeur: Valeur.neuf),
          Carte(couleur: Couleur.pique, valeur: Valeur.huit),
          Carte(couleur: Couleur.pique, valeur: Valeur.sept),
          Carte(couleur: Couleur.coeur, valeur: Valeur.dix),
          Carte(couleur: Couleur.coeur, valeur: Valeur.neuf),
          Carte(couleur: Couleur.coeur, valeur: Valeur.huit),
          Carte(couleur: Couleur.coeur, valeur: Valeur.sept),
        ],
        Position.ouest: [
          Carte(couleur: Couleur.carreau, valeur: Valeur.dix),
          Carte(couleur: Couleur.carreau, valeur: Valeur.neuf),
          Carte(couleur: Couleur.carreau, valeur: Valeur.huit),
          Carte(couleur: Couleur.carreau, valeur: Valeur.sept),
          Carte(couleur: Couleur.trefle, valeur: Valeur.dix),
          Carte(couleur: Couleur.trefle, valeur: Valeur.neuf),
          Carte(couleur: Couleur.trefle, valeur: Valeur.huit),
          Carte(couleur: Couleur.trefle, valeur: Valeur.sept),
        ],
      };

      etatJeu.definirToutesLesCartes(cartesParJoueur);
      etatJeu.commencerJeu();

      // Current player should be Est (right of Nord dealer in horaire rotation)
      expect(etatJeu.joueurActuel, Position.est);

      // Est should be able to play their cards
      final carteEst = Carte(couleur: Couleur.carreau, valeur: Valeur.as);
      expect(etatJeu.peutJouerCartePosition(carteEst, Position.est), true);

      // Est should NOT be able to play cards they don't have
      final carteNonEst = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      expect(etatJeu.peutJouerCartePosition(carteNonEst, Position.est), false);

      // Other positions should not be able to play when it's not their turn
      final carteSud = Carte(couleur: Couleur.pique, valeur: Valeur.dix);
      expect(etatJeu.peutJouerCartePosition(carteSud, Position.sud), false);
    });
  });
}
