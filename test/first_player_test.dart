import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote/models/etat_jeu.dart';
import 'package:dimdim_belote/models/position.dart';
import 'package:dimdim_belote/models/carte.dart';
import 'package:dimdim_belote/models/annonce.dart';

void main() {
  group('First Player Tests - Belote Contrée Rules', () {
    late EtatJeu etatJeu;

    setUp(() {
      etatJeu = EtatJeu();
    });

    test('First player in game phase should be after dealer (not bidder) - clockwise', () {
      // Setup: Nord is dealer, rotation is clockwise
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.nord,
      );

      etatJeu.definirParametres(parametres);
      
      // First speaker in bidding is Est (right of dealer in clockwise)
      expect(etatJeu.joueurActuel, Position.est);

      // Bidding sequence: Est passes, Sud bids, others pass
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.est, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.sud,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.ouest, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.nord, type: TypeAnnonce.passe));

      // Sud won the bidding
      expect(etatJeu.equipePrenante, Position.sud);

      // Start the game
      etatJeu.definirCartes([
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
      ]);
      etatJeu.commencerJeu();

      // First player should be Est (right of dealer), not Sud (the bidder)
      expect(etatJeu.joueurActuel, Position.est);
      expect(etatJeu.premierJoueurPli, Position.est);
    });

    test('First player in game phase should be after dealer (not bidder) - counter-clockwise', () {
      // Setup: Sud is dealer, rotation is counter-clockwise
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        sensRotation: SensRotation.antihoraire,
        positionDonneur: Position.sud,
      );

      etatJeu.definirParametres(parametres);
      
      // First speaker in bidding is Est (right of dealer in counter-clockwise)
      expect(etatJeu.joueurActuel, Position.est);

      // Bidding sequence: Est passes, Nord bids, others pass
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.est, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.nord,
        type: TypeAnnonce.prise,
        valeur: 90,
        couleur: '♥ Cœur',
      ));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.ouest, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.sud, type: TypeAnnonce.passe));

      // Nord won the bidding
      expect(etatJeu.equipePrenante, Position.nord);

      // Start the game
      etatJeu.definirCartes([
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
      ]);
      etatJeu.commencerJeu();

      // First player should be Est (right of dealer), not Nord (the bidder)
      expect(etatJeu.joueurActuel, Position.est);
      expect(etatJeu.premierJoueurPli, Position.est);
    });

    test('First player is after dealer, even when different player wins bid', () {
      // Setup: Est is dealer, rotation is clockwise
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.est,
      );

      etatJeu.definirParametres(parametres);
      
      // First speaker is Sud (right of dealer)
      expect(etatJeu.joueurActuel, Position.sud);

      // Bidding: Sud passes, Ouest bids
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.sud, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.ouest,
        type: TypeAnnonce.prise,
        valeur: 100,
        couleur: '♦ Carreau',
      ));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.nord, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.est, type: TypeAnnonce.passe));

      // Ouest won the bidding
      expect(etatJeu.equipePrenante, Position.ouest);

      // Start the game
      etatJeu.definirCartes([
        Carte(couleur: Couleur.carreau, valeur: Valeur.dame),
      ]);
      etatJeu.commencerJeu();

      // First player should be Sud (right of dealer), not Ouest (the bidder)
      expect(etatJeu.joueurActuel, Position.sud);
      expect(etatJeu.premierJoueurPli, Position.sud);
    });

    test('First player is after dealer with contre and surcontre', () {
      // Setup: Ouest is dealer, rotation is clockwise
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.ouest,
      );

      etatJeu.definirParametres(parametres);

      // Bidding with contre and surcontre
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.nord,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♣ Trèfle',
      ));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.est, type: TypeAnnonce.contre));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.sud, type: TypeAnnonce.surcontre));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.ouest, type: TypeAnnonce.passe));

      // Nord won the bidding (made the prise)
      expect(etatJeu.equipePrenante, Position.nord);

      // Start the game
      etatJeu.definirCartes([
        Carte(couleur: Couleur.trefle, valeur: Valeur.valet),
      ]);
      etatJeu.commencerJeu();

      // First player should be Nord (right of dealer), not the original bidder or surcontrer
      expect(etatJeu.joueurActuel, Position.nord);
      expect(etatJeu.premierJoueurPli, Position.nord);
    });

    test('First player is after dealer with capot bid', () {
      // Setup: Sud is dealer, rotation is clockwise
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.sud,
      );

      etatJeu.definirParametres(parametres);

      // Ouest makes a capot bid
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.ouest,
        type: TypeAnnonce.prise,
        couleur: '♠ Pique',
        estCapot: true,
      ));
      // Others pass (can't bid higher than capot)
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.nord, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.est, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.sud, type: TypeAnnonce.passe));

      // Ouest won with capot
      expect(etatJeu.equipePrenante, Position.ouest);

      // Start the game
      etatJeu.definirCartes([
        Carte(couleur: Couleur.pique, valeur: Valeur.sept),
      ]);
      etatJeu.commencerJeu();

      // First player should be Ouest (right of dealer), even though Ouest is also the capot bidder
      expect(etatJeu.joueurActuel, Position.ouest);
      expect(etatJeu.premierJoueurPli, Position.ouest);
    });
  });
}
