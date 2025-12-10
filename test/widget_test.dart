import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dimdim_belote_helper/main.dart';

void main() {
  testWidgets('App loads with welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bienvenue dans l\'assistant\nBelote Contrée'), findsOneWidget);
    expect(find.text('Nouvelle partie'), findsOneWidget);
    expect(find.byIcon(Icons.style), findsOneWidget);
  });

  testWidgets('Can navigate to settings screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Nouvelle partie'));
    await tester.pumpAndSettle();

    expect(find.text('Paramètres de la partie'), findsOneWidget);
    expect(find.text('Condition de fin'), findsOneWidget);
    expect(find.text('Votre position'), findsOneWidget);
  });
}
