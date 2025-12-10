import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote_helper/models/annonce.dart';
import 'package:dimdim_belote_helper/models/position.dart';

void main() {
  group('Annonce Tests', () {
    test('Annonce passe', () {
      final annonce = Annonce(
        joueur: Position.nord,
        type: TypeAnnonce.passe,
      );

      expect(annonce.joueur, Position.nord);
      expect(annonce.type, TypeAnnonce.passe);
      expect(annonce.texte, 'Passe');
      expect(annonce.toString(), 'Nord: Passe');
    });

    test('Annonce prise', () {
      final annonce = Annonce(
        joueur: Position.sud,
        type: TypeAnnonce.prise,
        valeur: 80,
        couleur: '♠ Pique',
      );

      expect(annonce.joueur, Position.sud);
      expect(annonce.type, TypeAnnonce.prise);
      expect(annonce.valeur, 80);
      expect(annonce.couleur, '♠ Pique');
      expect(annonce.texte, '80 ♠ Pique');
    });

    test('Annonce capot', () {
      final annonce = Annonce(
        joueur: Position.nord,
        type: TypeAnnonce.prise,
        couleur: '♥ Cœur',
        estCapot: true,
      );

      expect(annonce.joueur, Position.nord);
      expect(annonce.type, TypeAnnonce.prise);
      expect(annonce.estCapot, true);
      expect(annonce.couleur, '♥ Cœur');
      expect(annonce.texte, 'Capot ♥ Cœur');
    });

    test('Annonce contre', () {
      final annonce = Annonce(
        joueur: Position.est,
        type: TypeAnnonce.contre,
      );

      expect(annonce.type, TypeAnnonce.contre);
      expect(annonce.texte, 'Contre');
    });

    test('Annonce surcontre', () {
      final annonce = Annonce(
        joueur: Position.ouest,
        type: TypeAnnonce.surcontre,
      );

      expect(annonce.type, TypeAnnonce.surcontre);
      expect(annonce.texte, 'Surcontré');
    });
  });
}
