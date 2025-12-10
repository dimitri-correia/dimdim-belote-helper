import 'package:flutter/material.dart';

class OtherPlayersCardsToggle extends StatelessWidget {
  final bool afficherCartesAutresJoueurs;
  final ValueChanged<bool> onToggle;

  const OtherPlayersCardsToggle({
    super.key,
    required this.afficherCartesAutresJoueurs,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Afficher cartes jouées par les autres:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch(
              value: afficherCartesAutresJoueurs,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}
