import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_game/game/data/cards_data.dart';
import 'package:hive_game/game/data/relics_data.dart';
import 'package:hive_game/game/data/threats_data.dart';
import 'package:hive_game/game/deck_builder.dart';
import 'package:hive_game/game/engine/combat_engine.dart';
import 'package:hive_game/game/engine/run_state.dart';
import 'package:hive_game/game/models/card.dart';
import 'package:hive_game/game/models/enums.dart';
import 'package:hive_game/game/models/relic.dart';
import 'package:hive_game/game/models/threat.dart';

/// Builds an engine on wave 1 with a controllable hand. The drawn hand is
/// cleared so each test can stage exactly the cards it needs.
CombatEngine freshEngine({
  RunConfig config = const RunConfig(),
  Relic? relic,
}) {
  final engine = CombatEngine.newNight(
    deck: buildStartingDeck(),
    relic: relic,
    config: config,
    rng: Random(7),
  );
  engine.run.hand.clear();
  return engine;
}

ThreatInstance spawn(CombatEngine e, String id, {int? countdown}) {
  final t = ThreatInstance.fromDef(ThreatLibrary.get(id), e.run.nextInstanceId++);
  if (countdown != null) t.countdown = countdown;
  e.run.threats.add(t);
  return t;
}

void give(CombatEngine e, String cardId) =>
    e.run.hand.add(CardLibrary.get(cardId));

void main() {
  group('setup', () {
    test('new night starts with spec resources and wave 1', () {
      final e = freshEngine();
      expect(e.run.maxIntegrity, 30);
      expect(e.run.integrity, 30);
      expect(e.run.pollen, 3);
      expect(e.run.waveNumber, 1);
      expect(e.run.phase, RunPhase.player);
    });

    test('relics modify the starting state', () {
      final sturdy = freshEngine(relic: RelicLibrary.get('sturdy_comb'));
      expect(sturdy.run.maxIntegrity, 35);
      expect(sturdy.run.integrity, 35);

      final reserve = freshEngine(relic: RelicLibrary.get('honey_reserve'));
      expect(reserve.run.honey, 10);

      final rich = freshEngine(relic: RelicLibrary.get('rich_nectar'));
      expect(rich.run.pollen, 4); // base 3 + 1
    });
  });

  group('playing cards', () {
    test('Wax Wall grants block and spends pollen', () {
      final e = freshEngine();
      give(e, 'wax_wall');
      final outcome = e.playCard(CardLibrary.get('wax_wall'));
      expect(outcome, PlayOutcome.ok);
      expect(e.run.block, 5);
      expect(e.run.pollen, 2);
    });

    test('cannot play without enough pollen', () {
      final e = freshEngine();
      e.run.pollen = 0;
      give(e, 'wax_wall');
      expect(e.playCard(CardLibrary.get('wax_wall')), PlayOutcome.notEnoughPollen);
      expect(e.run.block, 0);
    });

    test('damage respects armor unless ignored', () {
      final e = freshEngine();
      final beetle = spawn(e, 'beetle'); // hp 20, armor 2
      give(e, 'sting');
      e.playCard(CardLibrary.get('sting'), target: beetle); // 5 - 2 armor
      expect(beetle.hp, 17);

      give(e, 'piercing_stinger');
      e.run.pollen = 5;
      e.playCard(CardLibrary.get('piercing_stinger'), target: beetle); // 10, ignores armor
      expect(beetle.hp, 7);
    });

    test('Sharp Stingers relic boosts stinger damage', () {
      final e = freshEngine(relic: RelicLibrary.get('sharp_stingers'));
      final mantis = spawn(e, 'mantis'); // hp 24, no armor
      give(e, 'sting');
      e.playCard(CardLibrary.get('sting'), target: mantis); // 5 + 2
      expect(mantis.hp, 17);
    });

    test('lethal damage removes a threat', () {
      final e = freshEngine();
      final wasp = spawn(e, 'scout_wasp'); // hp 6
      give(e, 'sting');
      give(e, 'quick_jab');
      e.run.pollen = 5;
      e.playCard(CardLibrary.get('sting'), target: wasp); // 6 -> 1
      e.playCard(CardLibrary.get('quick_jab'), target: wasp); // 1 -> dead
      expect(e.run.threats, isEmpty);
    });

    test('Frenzy scales with cards played this turn', () {
      final e = freshEngine();
      final mantis = spawn(e, 'mantis'); // hp 24
      e.run.pollen = 5;
      give(e, 'quick_jab');
      give(e, 'frenzy');
      e.playCard(CardLibrary.get('quick_jab'), target: mantis); // 3 -> 21
      e.playCard(CardLibrary.get('frenzy'), target: mantis); // 3 * 2 cards = 6 -> 15
      expect(mantis.hp, 15);
    });

    test('conditional block reacts to low integrity', () {
      final high = freshEngine();
      high.run.pollen = 3;
      give(high, 'royal_guard');
      high.playCard(CardLibrary.get('royal_guard'));
      expect(high.run.block, 12);

      final low = freshEngine();
      low.run.integrity = 10;
      low.run.pollen = 3;
      give(low, 'royal_guard');
      low.playCard(CardLibrary.get('royal_guard'));
      expect(low.run.block, 18);
    });

    test('Golden Harvest converts current pollen into honey', () {
      final e = freshEngine();
      e.run.pollen = 5;
      give(e, 'golden_harvest'); // cost 3, then 2x remaining pollen (2) = 4
      e.playCard(CardLibrary.get('golden_harvest'));
      expect(e.run.pollen, 2);
      expect(e.run.honey, 4);
    });

    test('Scout reshuffles the discard pile when the draw pile is empty', () {
      final e = freshEngine();
      e.run.drawPile.clear();
      e.run.discardPile
        ..clear()
        ..addAll([CardLibrary.get('forage'), CardLibrary.get('forage')]);
      give(e, 'scout');
      e.playCard(CardLibrary.get('scout')); // draw 2 -> reshuffle
      expect(e.run.hand.length, 2);
      expect(e.run.discardPile, [CardLibrary.get('scout')]);
    });

    test('exhaust cards leave the deck when played', () {
      final e = freshEngine();
      e.run.pollen = 3;
      give(e, 'spring_bloom');
      e.playCard(CardLibrary.get('spring_bloom'));
      expect(e.run.exhaustPile, contains(CardLibrary.get('spring_bloom')));
      expect(e.run.discardPile, isNot(contains(CardLibrary.get('spring_bloom'))));
    });
  });

  group('end of turn resolution', () {
    test('a ready threat strikes the hive when unblocked', () {
      final e = freshEngine();
      spawn(e, 'scout_wasp', countdown: 0); // damage 4
      final before = e.run.integrity;
      e.endTurn();
      expect(e.run.integrity, before - 4);
      expect(e.run.phase, RunPhase.reward);
    });

    test('block absorbs incoming damage', () {
      final e = freshEngine();
      spawn(e, 'scout_wasp', countdown: 0); // damage 4
      e.run.block = 10;
      final before = e.run.integrity;
      e.endTurn();
      expect(e.run.integrity, before);
      expect(e.run.block, 6);
    });

    test('venom ticks at end of turn', () {
      final e = freshEngine();
      final mantis = spawn(e, 'mantis', countdown: 4);
      give(e, 'venom_barb');
      e.playCard(CardLibrary.get('venom_barb'), target: mantis); // 4 dmg + 2 venom
      expect(mantis.hp, 20);
      e.endTurn(); // venom 2
      expect(mantis.hp, 18);
    });

    test('countdowns tick down between turns', () {
      final e = freshEngine();
      final wasp = spawn(e, 'soldier_wasp', countdown: 2);
      e.endTurn();
      expect(wasp.countdown, 1);
    });

    test('Frost Mite drains pollen next turn', () {
      final e = freshEngine(config: const RunConfig(totalWaves: 8));
      spawn(e, 'frost_mite', countdown: 0); // drains 1 pollen
      e.run.block = 99; // ignore its damage
      e.endTurn();
      e.chooseReward(null); // advance to next wave / player turn
      expect(e.run.pollen, 3 - 1); // base 3 minus 1 drained
    });

    test('losing all integrity ends the run', () {
      final e = freshEngine();
      spawn(e, 'hornet', countdown: 0); // damage 9
      e.run.integrity = 5;
      e.endTurn();
      expect(e.run.phase, RunPhase.lost);
      expect(e.run.isOver, isTrue);
    });

    test('surviving the final wave wins the night', () {
      final e = freshEngine(config: const RunConfig(totalWaves: 1));
      // Wave 1 is active; clear the board and end the turn.
      e.run.threats.clear();
      e.endTurn();
      expect(e.run.phase, RunPhase.won);
    });
  });

  group('overwinter and persistent economy', () {
    test('Overwinter converts leftover block into honey', () {
      final e = freshEngine();
      e.run.block = 8;
      e.run.pollen = 3;
      give(e, 'overwinter');
      e.playCard(CardLibrary.get('overwinter'));
      e.endTurn();
      expect(e.run.honey, 8);
      expect(e.run.block, 0);
    });

    test('Worker Shift grants pollen every following turn', () {
      final e = freshEngine(config: const RunConfig(totalWaves: 8));
      e.run.pollen = 2;
      give(e, 'worker_shift');
      e.playCard(CardLibrary.get('worker_shift'));
      e.run.threats.clear();
      e.endTurn();
      e.chooseReward(null);
      expect(e.run.pollen, 3 + 2); // base + worker shift
    });

    test('Hardened Wax carries half its block into the next turn', () {
      final e = freshEngine(config: const RunConfig(totalWaves: 8));
      e.run.pollen = 2;
      give(e, 'hardened_wax'); // 6 block, keep half
      e.playCard(CardLibrary.get('hardened_wax'));
      e.run.threats.clear();
      e.endTurn();
      e.chooseReward(null);
      expect(e.run.block, 3);
    });
  });
}
