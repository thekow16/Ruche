/// The [GameCard] model: a single playable card definition.
///
/// Pure Dart — no Flutter imports. Cards are defined as data in
/// `lib/game/data/cards_data.dart`.
import 'effects.dart';
import 'enums.dart';

class GameCard {
  /// Stable identifier (snake_case). Used for save data and unlock tracking.
  final String id;
  final String name;
  final int cost;
  final CardType type;
  final Rarity rarity;

  /// Ordered list of effects applied when the card is played.
  final List<CardEffect> effects;

  /// Exhaust cards are removed from the run when played (one-shot).
  final bool exhaust;

  /// Whether the card counts as a "Honey card" (for Honey Cache scaling).
  final bool isHoneyCard;

  const GameCard({
    required this.id,
    required this.name,
    required this.cost,
    required this.type,
    required this.rarity,
    required this.effects,
    this.exhaust = false,
    this.isHoneyCard = false,
  });

  /// True if playing the card requires choosing a target threat.
  bool get needsTarget => effects.any((e) => e.needsTarget);

  /// Composed human-readable rules text.
  String get text {
    final parts = effects.map((e) => e.describe()).toList();
    if (exhaust) parts.add('Exhaust.');
    return parts.join(' ');
  }

  /// A fresh, identity-distinct copy. Used for temporary cards (Queen's Call)
  /// so they can be tracked and removed without affecting real copies.
  GameCard copy() => GameCard(
        id: id,
        name: name,
        cost: cost,
        type: type,
        rarity: rarity,
        effects: effects,
        exhaust: exhaust,
        isHoneyCard: isHoneyCard,
      );

  @override
  String toString() => 'GameCard($id)';
}
