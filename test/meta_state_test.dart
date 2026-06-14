import 'package:flutter_test/flutter_test.dart';
import 'package:hive_game/game/meta/meta_state.dart';

void main() {
  group('meta-progression', () {
    test('unlocked-by-default cards are always available', () {
      final meta = MetaState();
      expect(meta.isCardUnlocked('sting'), isTrue);
      expect(meta.isCardUnlocked('frenzy'), isFalse); // locked
    });

    test('banking honey follows the carry fraction', () {
      final meta = MetaState();
      meta.recordRun(runHoney: 100, won: true);
      expect(meta.bankedHoney, 25); // 25% of 100
      expect(meta.nightsWon, 1);
      expect(meta.bestHoney, 100);
    });

    test('cards unlock only when affordable, spending banked honey', () {
      final meta = MetaState(bankedHoney: 40);
      expect(meta.canUnlock('frenzy'), isFalse); // costs 50
      expect(meta.unlock('frenzy'), isFalse);

      meta.bankedHoney = 60;
      expect(meta.canUnlock('frenzy'), isTrue);
      expect(meta.unlock('frenzy'), isTrue);
      expect(meta.bankedHoney, 10);
      expect(meta.isCardUnlocked('frenzy'), isTrue);
      expect(meta.unlock('frenzy'), isFalse); // already unlocked
    });

    test('serialization round-trips', () {
      final meta = MetaState(
        bankedHoney: 123,
        unlockedCardIds: {'frenzy', 'hive_mind'},
        nightsWon: 2,
        bestHoney: 200,
      );
      final restored = MetaState.fromJson(meta.toJson());
      expect(restored.bankedHoney, 123);
      expect(restored.unlockedCardIds, {'frenzy', 'hive_mind'});
      expect(restored.nightsWon, 2);
      expect(restored.bestHoney, 200);
    });
  });
}
