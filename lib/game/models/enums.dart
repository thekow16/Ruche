/// Core enumerations for HIVE game content.
///
/// Pure Dart — no Flutter imports. Safe to use from tests and UI alike.

/// Archetype a card belongs to. Drives grouping and the [Rarity]-independent
/// "Sharp Stingers" relic which boosts only [CardType.stinger] cards.
enum CardType { defender, stinger, worker, architect }

/// Rarity tiers used for reward pools and meta-unlock thresholds.
enum Rarity { common, uncommon, rare }

/// High level phase of a run, used by the UI to decide what to render.
enum RunPhase {
  /// Player is taking their turn (playing cards).
  player,

  /// Player must pick a discard (e.g. after Waggle Dance).
  discarding,

  /// Player is choosing a reward card after clearing a wave.
  reward,

  /// The night was survived.
  won,

  /// The hive fell.
  lost,
}

extension CardTypeLabel on CardType {
  String get label => switch (this) {
        CardType.defender => 'Defender',
        CardType.stinger => 'Stinger',
        CardType.worker => 'Worker',
        CardType.architect => 'Architect',
      };
}

extension RarityLabel on Rarity {
  String get label => switch (this) {
        Rarity.common => 'Common',
        Rarity.uncommon => 'Uncommon',
        Rarity.rare => 'Rare',
      };
}
