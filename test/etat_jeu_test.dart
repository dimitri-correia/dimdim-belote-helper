import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote_helper/models/etat_jeu.dart';
import 'package:dimdim_belote_helper/models/position.dart';
import 'package:dimdim_belote_helper/models/carte.dart';
import 'package:dimdim_belote_helper/models/annonce.dart';

void main() {
  group('EtatJeu Tests', () {
    late EtatJeu etatJeu;

    setUp(() {
      etatJeu = EtatJeu();
    });

    test('Initial state', () {
      expect(etatJeu.parametres, isNull);
      expect(etatJeu.cartesJoueur, isEmpty);
      expect(etatJeu.annonces, isEmpty);
      expect(etatJeu.joueurActuel, isNull);
    });

    test('Definir parametres sans donneur', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.sud,
        sensRotation: SensRotation.horaire,
      );

      etatJeu.definirParametres(parametres);

      expect(etatJeu.parametres, isNotNull);
      expect(etatJeu.parametres!.conditionFin, ConditionFin.points);
      expect(etatJeu.parametres!.valeurFin, 1000);
      expect(etatJeu.parametres!.positionJoueur, Position.sud);
      expect(etatJeu.joueurActuel, Position.sud);
    });

    test('Definir parametres avec donneur - rotation horaire', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.sud,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.nord,
      );

      etatJeu.definirParametres(parametres);

      // Le premier à parler est à la droite du donneur en rotation horaire
      // Donneur = Nord, donc premier parleur = Est
      expect(etatJeu.joueurActuel, Position.est);
    });

    test('Definir parametres avec donneur - rotation anti-horaire', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.sud,
        sensRotation: SensRotation.antihoraire,
        positionDonneur: Position.nord,
      );

      etatJeu.definirParametres(parametres);

      // Le premier à parler est à la droite du donneur en rotation anti-horaire
      // Donneur = Nord, donc premier parleur = Ouest
      expect(etatJeu.joueurActuel, Position.ouest);
    });

    test('Definir cartes', () {
      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
      ];

      etatJeu.definirCartes(cartes);

      expect(etatJeu.cartesJoueur.length, 2);
      expect(etatJeu.cartesJoueur[0].couleur, Couleur.pique);
      expect(etatJeu.cartesJoueur[1].couleur, Couleur.coeur);
    });

    test('Ajouter annonce avec rotation horaire', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.nord,
        sensRotation: SensRotation.horaire,
      );

      etatJeu.definirParametres(parametres);

      final annonce = Annonce(
        joueur: Position.nord,
        type: TypeAnnonce.passe,
      );

      etatJeu.ajouterAnnonce(annonce);

      expect(etatJeu.annonces.length, 1);
      expect(etatJeu.annonces[0].joueur, Position.nord);
      expect(etatJeu.joueurActuel, Position.est); // Rotation horaire
    });

    test('Ajouter annonce avec rotation anti-horaire', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.nord,
        sensRotation: SensRotation.antihoraire,
      );

      etatJeu.definirParametres(parametres);

      final annonce = Annonce(
        joueur: Position.nord,
        type: TypeAnnonce.passe,
      );

      etatJeu.ajouterAnnonce(annonce);

      expect(etatJeu.joueurActuel, Position.ouest); // Rotation anti-horaire
    });

    test('Reinitialiser annonces sans donneur', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.sud,
        sensRotation: SensRotation.horaire,
      );

      etatJeu.definirParametres(parametres);

      etatJeu.ajouterAnnonce(
        Annonce(joueur: Position.sud, type: TypeAnnonce.passe),
      );
      etatJeu.ajouterAnnonce(
        Annonce(joueur: Position.ouest, type: TypeAnnonce.passe),
      );

      expect(etatJeu.annonces.length, 2);

      etatJeu.reinitialiserAnnonces();

      expect(etatJeu.annonces, isEmpty);
      expect(etatJeu.joueurActuel, Position.sud); // Reset to initial player
    });

    test('Reinitialiser annonces avec donneur', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.sud,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.est,
      );

      etatJeu.definirParametres(parametres);

      etatJeu.ajouterAnnonce(
        Annonce(joueur: Position.sud, type: TypeAnnonce.passe),
      );

      etatJeu.reinitialiserAnnonces();

      expect(etatJeu.annonces, isEmpty);
      // Reset to first speaker (à droite du donneur)
      expect(etatJeu.joueurActuel, Position.sud); // Donneur = Est, premier = Sud (horaire)
    });

    test('Reinitialiser tout', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.est,
        sensRotation: SensRotation.horaire,
      );

      etatJeu.definirParametres(parametres);
      etatJeu.definirCartes([
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
      ]);
      etatJeu.ajouterAnnonce(
        Annonce(joueur: Position.est, type: TypeAnnonce.passe),
      );

      etatJeu.reinitialiser();

      expect(etatJeu.parametres, isNull);
      expect(etatJeu.cartesJoueur, isEmpty);
      expect(etatJeu.annonces, isEmpty);
      expect(etatJeu.joueurActuel, isNull);
      expect(etatJeu.nombrePlis, 0);
      expect(etatJeu.pointsNordSud, 0);
      expect(etatJeu.pointsEstOuest, 0);
    });

    test('Commencer jeu', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.sud,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.nord,
      );

      etatJeu.definirParametres(parametres);
      etatJeu.definirCartes([
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
      ]);

      etatJeu.commencerJeu();

      expect(etatJeu.nombrePlis, 0);
      expect(etatJeu.pointsNordSud, 0);
      expect(etatJeu.pointsEstOuest, 0);
      expect(etatJeu.pliActuel, isEmpty);
      expect(etatJeu.cartesJouees, isEmpty);
      expect(etatJeu.joueurActuel, Position.est); // First player after dealer
      expect(etatJeu.premierJoueurPli, Position.est);
    });

    test('Jouer carte', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.est,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.nord,
      );

      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
      ];

      etatJeu.definirParametres(parametres);
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();

      final carteAJouer = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      etatJeu.jouerCarte(carteAJouer);

      // Card should be in current pli
      expect(etatJeu.pliActuel.length, 1);
      expect(etatJeu.pliActuel[0].carte.couleur, Couleur.pique);
      expect(etatJeu.pliActuel[0].carte.valeur, Valeur.as);
      expect(etatJeu.pliActuel[0].joueur, Position.est);

      // Card should be removed from player's hand
      expect(etatJeu.cartesJoueur.length, 1);
      expect(etatJeu.cartesJoueur[0].couleur, Couleur.coeur);

      // Card should be tracked as played
      expect(etatJeu.cartesJouees.length, 1);
      expect(etatJeu.cartesJouees[0].couleur, Couleur.pique);

      // Next player should be Sud (rotation horaire)
      expect(etatJeu.joueurActuel, Position.sud);
    });

    test('Completer un pli', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.est,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.nord,
      );

      etatJeu.definirParametres(parametres);
      etatJeu.definirCartes([
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
      ]);
      etatJeu.commencerJeu();

      // Play 4 cards to complete a pli
      etatJeu.jouerCarte(Carte(couleur: Couleur.pique, valeur: Valeur.as)); // Est
      etatJeu.jouerCarte(Carte(couleur: Couleur.coeur, valeur: Valeur.roi)); // Sud
      etatJeu.jouerCarte(Carte(couleur: Couleur.carreau, valeur: Valeur.dame)); // Ouest
      etatJeu.jouerCarte(Carte(couleur: Couleur.trefle, valeur: Valeur.valet)); // Nord

      // Pli should be complete and reset
      expect(etatJeu.nombrePlis, 1);
      expect(etatJeu.pliActuel, isEmpty);
    });

    test('Verifier carte jouee', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.est,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.nord,
      );

      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
      ];

      etatJeu.definirParametres(parametres);
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();

      final carteAJouer = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      final carteNonJouee = Carte(couleur: Couleur.coeur, valeur: Valeur.roi);

      expect(etatJeu.estCarteJouee(carteAJouer), false);
      expect(etatJeu.estCarteJouee(carteNonJouee), false);

      etatJeu.jouerCarte(carteAJouer);

      expect(etatJeu.estCarteJouee(carteAJouer), true);
      expect(etatJeu.estCarteJouee(carteNonJouee), false);
    });

    test('Jouer carte pour autre joueur', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.sud, // Player is Sud
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.nord,
      );

      final cartes = [
        Carte(couleur: Couleur.pique, valeur: Valeur.as),
        Carte(couleur: Couleur.coeur, valeur: Valeur.roi),
      ];

      etatJeu.definirParametres(parametres);
      etatJeu.definirCartes(cartes);
      etatJeu.commencerJeu();

      // Current player should be Est (first after dealer)
      expect(etatJeu.joueurActuel, Position.est);

      // Even though it's Est's turn (not Sud's turn), we can play a card for Est
      final carteAJouer = Carte(couleur: Couleur.carreau, valeur: Valeur.valet);
      etatJeu.jouerCarte(carteAJouer);

      // Card should be added to current pli
      expect(etatJeu.pliActuel.length, 1);
      expect(etatJeu.pliActuel[0].carte.couleur, Couleur.carreau);
      expect(etatJeu.pliActuel[0].carte.valeur, Valeur.valet);
      expect(etatJeu.pliActuel[0].joueur, Position.est);

      // Player's cards should not be affected (card was played for Est, not Sud)
      expect(etatJeu.cartesJoueur.length, 2);
      expect(etatJeu.cartesJouees.length, 0); // No card tracked as played by player

      // Next player should be Sud (rotation horaire)
      expect(etatJeu.joueurActuel, Position.sud);
      
      // Now play a card for Sud (the player)
      final carteJoueur = Carte(couleur: Couleur.pique, valeur: Valeur.as);
      etatJeu.jouerCarte(carteJoueur);
      
      // Card should be removed from player's hand
      expect(etatJeu.cartesJoueur.length, 1);
      expect(etatJeu.cartesJoueur[0].couleur, Couleur.coeur);
      
      // Card should be tracked as played by player
      expect(etatJeu.cartesJouees.length, 1);
      expect(etatJeu.cartesJouees[0].couleur, Couleur.pique);
    });

    test('Doit terminer encheres - pas d\'annonces', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.nord,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.sud,
      );

      etatJeu.definirParametres(parametres);

      // No announcements yet - should not end
      expect(etatJeu.doitTerminerEncheres, false);
    });

    test('Doit terminer encheres - tous passes', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.nord,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.sud,
      );

      etatJeu.definirParametres(parametres);

      // All pass - should not end
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.ouest, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.nord, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.est, type: TypeAnnonce.passe));
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.sud, type: TypeAnnonce.passe));

      expect(etatJeu.doitTerminerEncheres, false);
    });

    test('Doit terminer encheres - une prise puis 3 passes', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.nord,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.sud,
      );

      etatJeu.definirParametres(parametres);
      // Current player should be Ouest (right of dealer)

      // Ouest makes a bid
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.ouest,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));
      // Now Nord's turn
      expect(etatJeu.joueurActuel, Position.nord);
      expect(etatJeu.doitTerminerEncheres, false);

      // Nord passes
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.nord, type: TypeAnnonce.passe));
      // Now Est's turn
      expect(etatJeu.joueurActuel, Position.est);
      expect(etatJeu.doitTerminerEncheres, false);

      // Est passes
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.est, type: TypeAnnonce.passe));
      // Now Sud's turn
      expect(etatJeu.joueurActuel, Position.sud);
      expect(etatJeu.doitTerminerEncheres, false);

      // Sud passes
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.sud, type: TypeAnnonce.passe));
      // Now back to Ouest's turn - should end bidding
      expect(etatJeu.joueurActuel, Position.ouest);
      expect(etatJeu.doitTerminerEncheres, true);
    });

    test('Doit terminer encheres - avec contre et surcontre', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.nord,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.sud,
      );

      etatJeu.definirParametres(parametres);
      // Current player should be Ouest

      // Ouest makes a bid
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.ouest,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));

      // Nord contres
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.nord, type: TypeAnnonce.contre));

      // Est surcontres (last non-pass)
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.est, type: TypeAnnonce.surcontre));

      // Sud passes
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.sud, type: TypeAnnonce.passe));

      // Ouest passes
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.ouest, type: TypeAnnonce.passe));

      // Nord passes
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.nord, type: TypeAnnonce.passe));

      // Now back to Est's turn (who made the last non-pass) - should end
      expect(etatJeu.joueurActuel, Position.est);
      expect(etatJeu.doitTerminerEncheres, true);
    });

    test('Doit terminer encheres - ne termine pas si nouveau prise apres', () {
      final parametres = ParametresJeu(
        conditionFin: ConditionFin.points,
        valeurFin: 1000,
        positionJoueur: Position.nord,
        sensRotation: SensRotation.horaire,
        positionDonneur: Position.sud,
      );

      etatJeu.definirParametres(parametres);

      // Ouest makes a bid
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.ouest,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      ));

      // Nord passes
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.nord, type: TypeAnnonce.passe));

      // Est raises the bid (last non-pass now)
      etatJeu.ajouterAnnonce(Annonce(
        joueur: Position.est,
        type: TypeAnnonce.prise,
        valeur: 90,
        couleur: '♥ Cœur',
      ));

      // Sud passes
      etatJeu.ajouterAnnonce(Annonce(joueur: Position.sud, type: TypeAnnonce.passe));

      // Ouest's turn - should NOT end (not the last bidder)
      expect(etatJeu.joueurActuel, Position.ouest);
      expect(etatJeu.doitTerminerEncheres, false);
    });
  });
}
