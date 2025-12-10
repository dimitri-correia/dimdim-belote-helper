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
  });
}
