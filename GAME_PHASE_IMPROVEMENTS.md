# Game Phase Improvements

## Overview

This document describes the improvements made to the game phase (Jeu screen) to meet the following requirements:

1. Show all cards, not only the player's cards
2. Display player's cards with graying for already played cards
3. Toggle button to show/hide all cards played by other players
4. Indication of who started and who won each pli
5. Display points for each pli
6. Card selection interface for the current player

## Changes to EtatJeu Model

### New Classes

#### `PliTermine`
A new class to track completed plis (tricks):
```dart
class PliTermine {
  final List<CarteJouee> cartes;    // Cards played in this pli
  final Position gagnant;            // Winner of the pli
  final int points;                  // Points awarded for this pli
}
```

### New State Variables

- `Map<Position, List<Carte>> _cartesParJoueur`: Tracks cards for all players
- `Map<Position, List<Carte>> _cartesJoueesParJoueur`: Tracks which cards each player has played
- `List<PliTermine> _plisTermines`: History of completed plis with winners and points

### New Public Getters

- `Map<Position, List<Carte>> get cartesParJoueur`: Access all players' cards
- `Map<Position, List<Carte>> get cartesJoueesParJoueur`: Access played cards per player
- `List<PliTermine> get plisTermines`: Access completed plis history

### New Methods

- `bool estCarteJoueeParJoueur(Position joueur, Carte carte)`: Check if a specific player has played a card
- `List<Carte> getCartesJoueur(Position joueur)`: Get all cards for a specific player

### Updated Methods

#### `commencerJeu()`
Now initializes:
- Cards tracking for all players
- Played cards tracking for all players
- Empty list for completed plis

#### `jouerCarte(Carte carte)`
Now:
- Tracks the first player of each pli (`_premierJoueurPli`)
- Records played cards for each player in `_cartesJoueesParJoueur`
- Updates `_cartesParJoueur` when a card is removed

#### `_terminerPli()`
Now:
- Calculates points for the completed pli
- Awards points to the winning team (Nord-Sud or Est-Ouest)
- Stores completed pli information in `_plisTermines`
- Adds the "dix de der" (10 bonus points) for the 8th pli
- Sets the winner as the first player for the next pli

#### `reinitialiser()`
Now clears all new state variables

## Changes to JeuScreen

### New State Variables

- `bool _grayerCartesJoueesJoueur`: Toggle for graying out player's already played cards
- `bool _afficherCartesAutresJoueurs`: Toggle for showing other players' played cards

### New Methods

#### `_buildCartesJoueur(EtatJeu etatJeu, Position position)`
A reusable method to display cards for any player with:
- Grouping by color
- Graying out played cards (for the main player)
- Toggle button to show/hide played cards (for the main player)

### Updated UI Components

1. **Current Pli Display**
   - Shows who started the pli (`Démarré par: [Position]`)
   - Displays all cards in the current pli with player indicators

2. **Last Completed Pli Info**
   - Shows winner of the last completed pli
   - Displays points awarded for that pli
   - Highlighted in amber for visibility

3. **Other Players' Cards Toggle**
   - Switch to show/hide cards played by other players
   - When enabled, shows a list of all played cards per player
   - Grouped by player position

4. **Player's Cards Section**
   - Always visible at the top
   - Shows cards grouped by color
   - Toggle button to gray out already played cards
   - Played cards are visually distinguished (gray when toggled)

5. **Current Player Selection Interface**
   - When it's not the main player's turn
   - Shows all 32 cards organized by color
   - Disables cards that have already been played by anyone
   - Provides clear indication of whose turn it is

## User Experience Flow

### For the Main Player's Turn

1. Player sees their remaining cards at the top
2. Can toggle to gray out already played cards for clarity
3. Clicks on a card to play it
4. Card is added to the current pli
5. Turn advances to the next player

### For Other Players' Turns

1. Player sees whose turn it is (highlighted in gray/green)
2. Below their own cards, they see all 32 cards
3. Already played cards are disabled (grayed out)
4. Player selects a card on behalf of that player
5. Card is added to the current pli
6. Turn advances to the next player

### Completed Pli

1. When 4 cards are played, the pli is completed
2. Winner is determined (currently: first player wins; TODO: proper trump logic)
3. Points are calculated and awarded to winning team
4. Last completed pli info is displayed showing winner and points
5. Winner starts the next pli

### Viewing Other Players' Cards

1. Toggle the "Afficher cartes jouées par les autres" switch
2. See a list of all cards played by each other player
3. Organized by player position (excluding main player)
4. Each card shown with proper color coding

## Points Calculation

Currently implements basic point calculation:
- Sum of card values (using non-trump points)
- 10 bonus points for the 8th pli (dix de der)

**TODO**: Implement proper trump suit handling based on the winning bid from enchères phase

## Future Enhancements

1. **Trump Suit Support**
   - Use the winning bid from enchères to determine trump suit
   - Calculate proper card values (trump vs non-trump)
   - Implement correct pli winner determination

2. **Better Winner Determination**
   - Compare cards based on trump suit
   - Handle suit following rules
   - Implement proper belote contrée rules

3. **Belote/Rebelote Announcements**
   - Detect King-Queen of trump
   - Allow players to announce
   - Award bonus points

4. **Game End Detection**
   - Check for game end conditions (points or plis)
   - Display final scores
   - Option to start new game

5. **Undo/Redo**
   - Allow undoing last card played
   - History of actions

6. **Smart Card Suggestions**
   - Highlight legal plays
   - Suggest optimal cards

## Testing Recommendations

Manual testing should cover:
1. Playing all 8 plis
2. Toggling card visibility options
3. Playing cards for all 4 positions
4. Verifying point calculations
5. Checking winner determination
6. Viewing completed plis history
7. Testing with different rotation directions (horaire/antihoraire)
8. Testing with different player positions (Nord, Sud, Est, Ouest)

## Known Limitations

1. **Winner Determination**: Currently simplified (first player wins). Needs proper implementation based on trump suit and card strength.
2. **No Trump Support**: Point calculations and winner determination don't consider trump suit yet.
3. **No Bid Integration**: The game phase doesn't yet use information from the enchères phase.
4. **Basic UI**: The current player selection interface could be improved with better visual feedback.
5. **No Suit Following Validation**: The card selection doesn't enforce Belote rules (e.g., following suit when required). This is intentional for this iteration to allow full flexibility in testing. Future versions should add proper game rule validation.
6. **Performance**: The `estCarteJoueeParQuiconque` method could be optimized with a Set for O(1) lookups instead of iterating through positions. This is acceptable for 32 cards but could be improved.

## Compatibility

All changes are backward compatible:
- Existing EtatJeu API is preserved
- New features are additive only
- No breaking changes to existing screens
- Tests continue to pass without modification
