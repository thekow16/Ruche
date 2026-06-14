/// Persistent meta-progression state — pure Dart, no Flutter imports.
///
/// Honey banked across runs is the meta-currency; spend it to permanently
/// unlock the locked cards.
import '../data/cards_data.dart';

class MetaState {
  /// Fraction of in-run Honey banked toward the persistent total at run end.
  static const double carryFraction = 0.25;

  int bankedHoney;
  final Set<String> unlockedCardIds;
  int nightsWon;
  int bestHoney;

  MetaState({
    this.bankedHoney = 0,
    Set<String>? unlockedCardIds,
    this.nightsWon = 0,
    this.bestHoney = 0,
  }) : unlockedCardIds = unlockedCardIds ?? {};

  /// True if the given card is playable (either always-available or unlocked).
  bool isCardUnlocked(String cardId) =>
      !CardLibrary.lockedCardIds.contains(cardId) ||
      unlockedCardIds.contains(cardId);

  /// Cost to unlock a locked card, or null if it isn't a locked card.
  int? unlockCost(String cardId) {
    for (final e in CardLibrary.lockedCards) {
      if (e.cardId == cardId) return e.cost;
    }
    return null;
  }

  bool canUnlock(String cardId) {
    if (isCardUnlocked(cardId)) return false;
    final cost = unlockCost(cardId);
    return cost != null && bankedHoney >= cost;
  }

  /// Spend banked Honey to unlock a card. Returns true on success.
  bool unlock(String cardId) {
    if (!canUnlock(cardId)) return false;
    bankedHoney -= unlockCost(cardId)!;
    unlockedCardIds.add(cardId);
    return true;
  }

  /// Record the result of a finished run.
  void recordRun({required int runHoney, required bool won}) {
    bankedHoney += (runHoney * carryFraction).floor();
    if (won) nightsWon += 1;
    if (runHoney > bestHoney) bestHoney = runHoney;
  }

  Map<String, dynamic> toJson() => {
        'bankedHoney': bankedHoney,
        'unlockedCardIds': unlockedCardIds.toList(),
        'nightsWon': nightsWon,
        'bestHoney': bestHoney,
      };

  factory MetaState.fromJson(Map<String, dynamic> json) => MetaState(
        bankedHoney: (json['bankedHoney'] as num?)?.toInt() ?? 0,
        unlockedCardIds: ((json['unlockedCardIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toSet(),
        nightsWon: (json['nightsWon'] as num?)?.toInt() ?? 0,
        bestHoney: (json['bestHoney'] as num?)?.toInt() ?? 0,
      );

  MetaState clone() => MetaState(
        bankedHoney: bankedHoney,
        unlockedCardIds: Set.of(unlockedCardIds),
        nightsWon: nightsWon,
        bestHoney: bestHoney,
      );
}
