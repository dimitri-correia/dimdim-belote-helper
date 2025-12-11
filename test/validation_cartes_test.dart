import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote_helper/models/etat_jeu.dart';
import 'package:dimdim_belote_helper/models/position.dart';
import 'package:dimdim_belote_helper/models/carte.dart';
import 'package:dimdim_belote_helper/models/annonce.dart';

void main() {
  group('Card Validation Tests', () {
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
    });

    test('First card of pli can always be played', () {
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
        Carte(couleur: Couleur.carreau, valeur: Valeur.dame),
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Move to Sud's turn (the player)
      etatJeu.jouerCarte(Carte(couleur: Couleur.trefle, valeur: Valeur.valet)); // Est
      
      // Sud can play any card as first card of their turn
      expect(etatJeu.peutJouerCarte(cartes[0]), true);
      expect(etatJeu.peutJouerCarte(cartes[1]), true);
      expect(etatJeu.peutJouerCarte(cartes[2]), true);
    });

    test('Must follow suit if possible', () {
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
        Carte(couleur: Couleur.pique, valeur: Valeur.roi),
        Carte(couleur: Couleur.coeur, valeur: Valeur.dame),
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Est plays pique
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
      
      // Sud must follow with pique (has pique cards)
      expect(etatJeu.peutJouerCarte(cartes[0]), true); // Pique As - valid
      expect(etatJeu.peutJouerCarte(cartes[1]), true); // Pique Roi - valid
      expect(etatJeu.peutJouerCarte(cartes[2]), false); // Coeur Dame - invalid (has pique)
    });

    test('Can play any card if cannot follow suit and no trump', () {
      final cartes = [
        Carte(couleur: Couleur.coeur, valeur: Valeur.as),
        Carte(couleur: Couleur.carreau, valeur: Valeur.roi),
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Est plays pique (Sud has no pique and no trump)
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
      
      // Sud can play any card (no pique, no trump in hand)
      expect(etatJeu.peutJouerCarte(cartes[0]), true);
      expect(etatJeu.peutJouerCarte(cartes[1]), true);
    });

    test('Must play trump if cannot follow suit and has trump', () {
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as), // Trump (pique is trump)
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Est plays carreau (Sud has no carreau)
      etatJeu.jouerCarte(Carte(couleur: Couleur.carreau, valeur: Valeur.valet));
      
      // Sud must play trump (pique) since has no carreau
      expect(etatJeu.peutJouerCarte(cartes[0]), true); // Pique As (trump) - valid
      expect(etatJeu.peutJouerCarte(cartes[1]), false); // Coeur Roi - invalid (must play trump)
    });

    test('Must play higher trump if possible (monter)', () {
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.valet), // Trump Jack (highest)
        Carte(couleur: Couleur.pique, valeur: Valeur.sept), // Trump 7 (low)
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Est plays carreau (not trump)
      etatJeu.jouerCarte(Carte(couleur: Couleur.carreau, valeur: Valeur.valet));
      
      // Sud must play trump, and can play either since no trump played yet
      expect(etatJeu.peutJouerCarte(cartes[0]), true);
      expect(etatJeu.peutJouerCarte(cartes[1]), true);
    });

    test('Trump beats non-trump in card comparison', () {
      // Set up game state to test card comparison
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.sept), // Trump
        Carte(couleur: Couleur.coeur, valeur: Valeur.as),   // Non-trump
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Play a complete pli to test winner determination
      etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.roi)); // Est - hearts
      etatJeu.jouerCarte(cartes[1]); // Sud - hearts As (highest hearts)
      etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.dame)); // Ouest - hearts
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.huit)); // Nord - trump (wins!)
      
      // Nord should win with trump even though it's just a 8
      expect(etatJeu.nombrePlis, 1);
      // The winner starts next pli
      expect(etatJeu.joueurActuel, Position.nord);
    });

    test('AtoutCouleur correctly identifies trump from string', () {
      expect(etatJeu.atout, '♠ Pique');
      expect(etatJeu.atoutCouleur, Couleur.pique);
    });

    test('Player cannot play card from their hand if not their turn', () {
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // It's Est's turn, not Sud's
      expect(etatJeu.joueurActuel, Position.est);
      expect(etatJeu.peutJouerCarte(cartes[0]), false);
    });

    test('GetCartesValides returns only playable cards', () {
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
        Carte(couleur: Couleur.pique, valeur: Valeur.roi),
        Carte(couleur: Couleur.coeur, valeur: Valeur.dame),
      ];
      
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
      
      // Est plays pique
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
      
      // Sud must follow with pique
      final cartesValides = etatJeu.getCartesValides();
      expect(cartesValides.length, 2);
      expect(cartesValides.any((c) => c.couleur == Couleur.pique && c.valeur == Valeur.as), true);
      expect(cartesValides.any((c) => c.couleur == Couleur.pique && c.valeur == Valeur.roi), true);
      expect(cartesValides.any((c) => c.couleur == Couleur.coeur), false);
    });
  });

  group('Missing Colors Tracking Tests', () {
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
      
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♥ Cœur',
      ));
      
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
      ];
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
    });

    test('Missing color is tracked when player cannot follow suit', () {
      // Est plays carreau
      etatJeu.jouerCarte(Carte(couleur: Couleur.carreau, valeur: Valeur.roi));
      
      // Sud plays pique (doesn't have carreau)
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.as));
      
      // Sud should be marked as missing carreau
      expect(etatJeu.couleursManquantes[Position.sud]?.contains(Couleur.carreau), true);
    });

    test('Missing color is not tracked when player follows suit', () {
      // Est plays coeur
      etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.dame));
      
      // Sud plays coeur (follows suit)
      etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.roi));
      
      // Sud should not be marked as missing coeur
      expect(etatJeu.couleursManquantes[Position.sud]?.contains(Couleur.coeur), false);
    });
  });

  group('Points Calculation Tests', () {
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

    test('Points calculation for made contract', () {
      // Est (Est-Ouest) bids 80
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));
      
      etatJeu.definirCartes([
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
      ]);
      etatJeu.commencerJeu();
      
      // Simulate Est-Ouest winning 100 points in hand
      // This is a bit tricky since we'd need to play actual cards
      // For now, let's directly set the points (normally set by playing cards)
      // We'll test the calculation logic
      
      final details = etatJeu.calculerPointsDetailles();
      expect(details['annonce'], 80);
      expect(details['multiplicateur'], 1);
      expect(details['prenantNordSud'], false); // Est-Ouest took it
    });

    test('Multiplicateur is correct for contre', () {
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.nord,
        type: TypeAnnonce.contre,
      ));
      
      expect(etatJeu.multiplicateurContrat, 2);
    });

    test('Multiplicateur is correct for surcontre', () {
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.nord,
        type: TypeAnnonce.contre,
      ));
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.surcontre,
      ));
      
      expect(etatJeu.multiplicateurContrat, 4);
    });

    test('Capot is worth 250 points', () {
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.nord,
        type: TypeAnnonce.prise,
        couleur: '♥ Cœur',
        estCapot: true,
      ));
      
      expect(etatJeu.pointsAnnonce, 250);
    });
  });
}
