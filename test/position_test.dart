import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote/models/position.dart';

void main() {
  group('Position Tests', () {
    test('Position names', () {
      expect(Position.nord.nom, 'Nord');
      expect(Position.est.nom, 'Est');
      expect(Position.sud.nom, 'Sud');
      expect(Position.ouest.nom, 'Ouest');
    });

    test('Position suivant (horaire)', () {
      expect(Position.nord.suivant, Position.est);
      expect(Position.est.suivant, Position.sud);
      expect(Position.sud.suivant, Position.ouest);
      expect(Position.ouest.suivant, Position.nord);
    });

    test('Position precedent (anti-horaire)', () {
      expect(Position.nord.precedent, Position.ouest);
      expect(Position.est.precedent, Position.nord);
      expect(Position.sud.precedent, Position.est);
      expect(Position.ouest.precedent, Position.sud);
    });

    test('Position rotation cycle', () {
      // Test full cycle clockwise
      var pos = Position.nord;
      pos = pos.suivant; // Est
      pos = pos.suivant; // Sud
      pos = pos.suivant; // Ouest
      pos = pos.suivant; // Nord
      expect(pos, Position.nord);

      // Test full cycle counter-clockwise
      pos = Position.nord;
      pos = pos.precedent; // Ouest
      pos = pos.precedent; // Sud
      pos = pos.precedent; // Est
      pos = pos.precedent; // Nord
      expect(pos, Position.nord);
    });
  });
}
