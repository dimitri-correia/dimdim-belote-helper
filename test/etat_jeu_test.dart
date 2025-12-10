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

    test('Definir parametres', () {
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

    test('Reinitialiser annonces', () {
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
    });
  });
}
