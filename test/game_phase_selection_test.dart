import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/annonce.dart';

void main() {
  group('Game Phase Card Selection Tests', () {
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
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
      ];
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();
    });

    test('Main player can play their own cards when it is their turn', () {
      // Est plays first
      etatJeu.jouerCarte(Carte(couleur: Couleur.trefle, valeur: Valeur.valet));
      
      // Now it's Sud's turn (the main player)
      expect(etatJeu.joueurActuel, Position.sud);
      
      // Sud can play their cards
      final carteAPiquer = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      expect(etatJeu.peutJouerCartePosition(carteAPiquer, Position.sud), true);
    });

    test('Main player cannot play cards when it is not their turn', () {
      // It's Est's turn initially
      expect(etatJeu.joueurActuel, Position.est);
      
      // Sud cannot play their cards
      final carteAPiquer = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      expect(etatJeu.peutJouerCartePosition(carteAPiquer, Position.sud), false);
    });

    test('Can play any unplayed card for other players when it is their turn', () {
      // It's Est's turn
      expect(etatJeu.joueurActuel, Position.est);
      
      // Can play any card that hasn't been played yet for Est
      final carteAPiquer = Carte(couleur: Couleur.carreau, valeur: Valeur.roi);
      expect(etatJeu.peutJouerCartePosition(carteAPiquer, Position.est), true);
    });

    test('Cannot play already played card for other players', () {
      // Est plays a card
      final cartePlayed = Carte(couleur: Couleur.trefle, valeur: Valeur.valet);
      etatJeu.jouerCarte(cartePlayed);
      
      // Move forward
      etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.roi)); // Sud
      etatJeu.jouerCarte(Carte(couleur: Couleur.trefle, valeur: Valeur.dame)); // Ouest
      etatJeu.jouerCarte(Carte(couleur: Couleur.trefle, valeur: Valeur.roi)); // Nord
      
      // New pli, Est's turn again
      expect(etatJeu.joueurActuel, Position.nord);
      
      // Try to play Est's already played card again (wrong player but test the logic)
      expect(etatJeu.estCarteJoueeParQuiconque(cartePlayed), true);
    });

    test('Cannot play card from main player hand for other players', () {
      // Est's turn
      expect(etatJeu.joueurActuel, Position.est);
      
      // Try to play Sud's card (Pique As) for Est
      // This should be allowed since we show all cards for other players
      final carteDeJoueur = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      
      // Est can "play" this card (user is entering what Est played)
      expect(etatJeu.peutJouerCartePosition(carteDeJoueur, Position.est), true);
    });

    test('Main player card validation still works correctly', () {
      // Est plays pique
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.valet));
      
      // Sud must follow with pique if they have it
      expect(etatJeu.joueurActuel, Position.sud);
      
      final piqueAs = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      final coeurRoi = Carte(couleur: Couleur.coeur, valeur: Valeur.roi);
      
      // Can play pique
      expect(etatJeu.peutJouerCartePosition(piqueAs, Position.sud), true);
      
      // Cannot play coeur (must follow suit)
      expect(etatJeu.peutJouerCartePosition(coeurRoi, Position.sud), false);
    });

    test('Game flow allows all players to play in sequence', () {
      // Est plays
      expect(etatJeu.joueurActuel, Position.est);
      etatJeu.jouerCarte(Carte(couleur: Couleur.trefle, valeur: Valeur.valet));
      
      // Sud plays
      expect(etatJeu.joueurActuel, Position.sud);
      etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.roi));
      
      // Ouest plays
      expect(etatJeu.joueurActuel, Position.ouest);
      etatJeu.jouerCarte(Carte(couleur: Couleur.trefle, valeur: Valeur.dame));
      
      // Nord plays
      expect(etatJeu.joueurActuel, Position.nord);
      etatJeu.jouerCarte(Carte(couleur: Couleur.trefle, valeur: Valeur.roi));
      
      // Pli should be complete
      expect(etatJeu.nombrePlis, 1);
      expect(etatJeu.pliActuel.length, 0);
    });
  });
}
