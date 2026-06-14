/// Deck construction helpers — pure Dart, no Flutter imports.
import 'data/cards_data.dart';
import 'models/card.dart';

/// Builds the 10-card starting deck described in the spec.
List<GameCard> buildStartingDeck() {
  final deck = <GameCard>[];
  CardLibrary.startingDeck.forEach((id, count) {
    final card = CardLibrary.get(id);
    for (var i = 0; i < count; i++) {
      deck.add(card);
    }
  });
  return deck;
}
