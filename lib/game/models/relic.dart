/// Relic model: a passive run modifier chosen at the start of a night.
///
/// Pure Dart — no Flutter imports. Relics are defined as data in
/// `lib/game/data/relics_data.dart`. Effects are expressed as plain fields so
/// the engine can apply them without per-relic branching.

class Relic {
  final String id;
  final String name;
  final String description;

  /// Added to maximum (and starting) Hive Integrity.
  final int bonusMaxIntegrity;

  /// Added to Pollen at the start of every turn.
  final int bonusPollenPerTurn;

  /// Added to the damage of every Stinger card.
  final int stingerDamageBonus;

  /// Honey banked into the run at the start of the night.
  final int startingHoney;

  const Relic({
    required this.id,
    required this.name,
    required this.description,
    this.bonusMaxIntegrity = 0,
    this.bonusPollenPerTurn = 0,
    this.stingerDamageBonus = 0,
    this.startingHoney = 0,
  });
}
