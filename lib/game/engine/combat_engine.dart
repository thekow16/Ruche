/// The combat engine — pure Dart, fully testable, no Flutter imports.
///
/// Owns a [RunState] and applies the rules of the game to it. The UI layer
/// calls the public action methods ([playCard], [endTurn], etc.) and reads a
/// cloned snapshot of [run]. An injectable [Random] keeps tests deterministic.
import 'dart:math';

import '../data/cards_data.dart';
import '../data/threats_data.dart';
import '../data/waves_data.dart';
import '../models/card.dart';
import '../models/effects.dart';
import '../models/enums.dart';
import '../models/relic.dart';
import '../models/threat.dart';
import 'run_state.dart';

/// Result of attempting to play a card.
enum PlayOutcome { ok, notEnoughPollen, needsTarget, wrongPhase, notInHand }

class CombatEngine {
  CombatEngine({
    required this.run,
    Random? rng,
    List<GameCard>? rewardPool,
  })  : _rng = rng ?? Random(),
        _rewardPool = rewardPool ?? CardLibrary.all;

  final Random _rng;

  /// Cards eligible to appear as rewards / be summoned by Queen's Call.
  /// Defaults to every card; pass the player's unlocked pool in production.
  final List<GameCard> _rewardPool;

  RunState run;

  /// Short human-readable combat log (most recent last). Useful for the UI and
  /// for debugging tests.
  final List<String> log = [];

  void _log(String msg) {
    log.add(msg);
    if (log.length > 60) log.removeAt(0);
  }

  // ---------------------------------------------------------------------------
  // Run lifecycle
  // ---------------------------------------------------------------------------

  /// Build a fresh engine for a new night.
  factory CombatEngine.newNight({
    required List<GameCard> deck,
    Relic? relic,
    RunConfig config = const RunConfig(),
    List<GameCard>? rewardPool,
    Random? rng,
  }) {
    final maxIntegrity = config.baseMaxIntegrity + (relic?.bonusMaxIntegrity ?? 0);
    final run = RunState(
      config: config,
      relic: relic,
      maxIntegrity: maxIntegrity,
      integrity: maxIntegrity,
      honey: relic?.startingHoney ?? 0,
      drawPile: List.of(deck),
    );
    final engine = CombatEngine(run: run, rng: rng, rewardPool: rewardPool);
    engine._shuffleDraw();
    engine.beginWave();
    return engine;
  }

  /// Reveal the next wave's threats and start the player's turn.
  void beginWave() {
    run.waveNumber += 1;
    final wave = WaveLibrary.forWave(run.waveNumber);
    for (final spawn in wave.spawns) {
      final def = ThreatLibrary.get(spawn.threatId);
      for (var i = 0; i < spawn.count; i++) {
        run.threats.add(ThreatInstance.fromDef(def, run.nextInstanceId++));
      }
    }
    _log('Wave ${run.waveNumber} reveals ${wave.spawns.length} threat type(s).');
    _startPlayerTurn();
  }

  void _startPlayerTurn() {
    run.phase = RunPhase.player;

    // Block: clear, or keep half if Hardened Wax was played last turn.
    run.block = run.keepHalfBlock ? run.block ~/ 2 : 0;
    run.keepHalfBlock = false;

    // Reset per-turn transient state.
    run.cardsPlayedThisTurn = 0;
    run.nextCardDiscount = 0;
    run.synchronizeBlockBonus = 0;
    run.overwinterActive = false;

    // Pollen for the turn.
    final relicPollen = run.relic?.bonusPollenPerTurn ?? 0;
    run.pollen = (run.config.basePollen +
            relicPollen +
            run.workerShiftPollen -
            run.pendingPollenDrain)
        .clamp(0, 999)
        .toInt();
    run.pendingPollenDrain = 0;

    // Draw a fresh hand (reduced by Web).
    final drawCount =
        (run.config.handSize - run.pendingDrawReduction).clamp(0, 99).toInt();
    run.pendingDrawReduction = 0;
    _draw(drawCount);
  }

  // ---------------------------------------------------------------------------
  // Drawing helpers
  // ---------------------------------------------------------------------------

  void _shuffleDraw() => run.drawPile.shuffle(_rng);

  void _reshuffleDiscardIntoDraw() {
    run.drawPile.addAll(run.discardPile);
    run.discardPile.clear();
    run.drawPile.shuffle(_rng);
  }

  void _draw(int count) {
    for (var i = 0; i < count; i++) {
      if (run.hand.length >= 10) break; // hand cap
      if (run.drawPile.isEmpty) {
        if (run.discardPile.isEmpty) break;
        _reshuffleDiscardIntoDraw();
      }
      run.hand.add(run.drawPile.removeLast());
    }
  }

  // ---------------------------------------------------------------------------
  // Playing cards
  // ---------------------------------------------------------------------------

  int effectiveCost(GameCard card) =>
      (card.cost - run.nextCardDiscount).clamp(0, 99).toInt();

  PlayOutcome playCard(GameCard card, {ThreatInstance? target}) {
    if (run.phase != RunPhase.player) return PlayOutcome.wrongPhase;
    if (!run.hand.contains(card)) return PlayOutcome.notInHand;

    final cost = effectiveCost(card);
    if (cost > run.pollen) return PlayOutcome.notEnoughPollen;

    // Targeting: required only when there is a valid threat to aim at.
    final targets = run.targetableThreats;
    if (card.needsTarget && target == null && targets.isNotEmpty) {
      return PlayOutcome.needsTarget;
    }

    // Pay (consuming any pending discount).
    run.pollen -= cost;
    run.nextCardDiscount = 0;
    run.cardsPlayedThisTurn += 1;

    final stingerBonus =
        card.type == CardType.stinger ? (run.relic?.stingerDamageBonus ?? 0) : 0;

    for (final effect in card.effects) {
      _applyEffect(effect, card, target, stingerBonus);
    }
    _cleanupDeadThreats();

    // Move the card out of hand.
    run.hand.remove(card);
    if (run.temporaryCards.remove(card)) {
      // Temporary cards vanish instead of going to a pile.
    } else if (card.exhaust) {
      run.exhaustPile.add(card);
    } else {
      run.discardPile.add(card);
    }

    _log('Played ${card.name}.');

    // A self-inflicted death is possible (e.g. Drone Sacrifice at low HP).
    if (run.integrity <= 0) {
      _lose();
    } else if (run.pendingDiscardCount > 0) {
      run.phase = RunPhase.discarding;
    }
    return PlayOutcome.ok;
  }

  /// Discard a card while in the [RunPhase.discarding] phase (e.g. after
  /// Waggle Dance). Returns true when the discard requirement is satisfied.
  bool discardForEffect(GameCard card) {
    if (run.phase != RunPhase.discarding) return false;
    if (!run.hand.contains(card)) return false;
    run.hand.remove(card);
    if (!run.temporaryCards.remove(card)) {
      run.discardPile.add(card);
    }
    run.pendingDiscardCount -= 1;
    if (run.pendingDiscardCount <= 0) {
      run.pendingDiscardCount = 0;
      run.phase = RunPhase.player;
    }
    return run.phase == RunPhase.player;
  }

  void _applyEffect(
    CardEffect effect,
    GameCard source,
    ThreatInstance? target,
    int stingerBonus,
  ) {
    switch (effect) {
      case GainBlock():
        _addBlock(effect.amount);
      case GainBlockPerThreat():
        _addBlock(effect.perThreat * run.threats.length);
      case ConditionalBlock():
        final amount = run.integrity < effect.integrityBelow
            ? effect.bonusAmount
            : effect.amount;
        _addBlock(amount);
      case KeepHalfBlockNextTurn():
        run.keepHalfBlock = true;
      case DamageSingle():
        if (target != null) {
          _dealDamage(target, effect.amount + stingerBonus,
              ignoreArmor: effect.ignoreArmor);
        }
      case DamageAll():
        for (final t in List.of(run.targetableThreats)) {
          _dealDamage(t, effect.amount + stingerBonus);
        }
      case DamageSingleCostHp():
        run.integrity -= effect.hpCost;
        if (target != null) {
          _dealDamage(target, effect.amount + stingerBonus);
        }
      case FrenzyDamage():
        if (target != null) {
          final total = effect.perCard * run.cardsPlayedThisTurn + stingerBonus;
          _dealDamage(target, total);
        }
      case ChainDamage():
        if (target != null) {
          final died = _dealDamage(target, effect.amount + stingerBonus);
          if (died) {
            final next = run.targetableThreats
                .where((t) => t.instanceId != target.instanceId)
                .toList();
            if (next.isNotEmpty) {
              _dealDamage(next.first, effect.amount + stingerBonus);
            }
          }
        }
      case ApplyVenom():
        if (target != null) target.venom += effect.amount;
      case GainPollen():
        run.pollen += effect.amount;
      case GainHoney():
        run.honey += effect.amount;
      case GainHoneyPerPollen():
        run.honey += effect.multiplier * run.pollen;
      case BlockPerHoneyCardInDiscard():
        final count = run.discardPile.where((c) => c.isHoneyCard).length;
        _addBlock(count);
      case PollenEachTurn():
        run.workerShiftPollen += effect.amount;
      case NextCardCheaper():
        run.nextCardDiscount += effect.amount;
      case DrawCards():
        _draw(effect.count);
      case DrawThenDiscard():
        _draw(effect.draw);
        run.pendingDiscardCount +=
            effect.discard.clamp(0, run.hand.length).toInt();
      case AddRandomCards():
        _addRandomCards(effect.count, effect.rarity);
      case Heal():
        run.integrity =
            (run.integrity + effect.amount).clamp(0, run.maxIntegrity).toInt();
      case LoseIntegrity():
        run.integrity -= effect.amount;
      case IncreaseCountdown():
        if (target != null) target.countdown += effect.amount;
      case ResinTrap():
        run.resinTrapCharges.add(effect.amount);
      case SynchronizeBlock():
        run.synchronizeBlockBonus += effect.amount;
      case OverwinterConvert():
        run.overwinterActive = true;
    }
  }

  void _addBlock(int amount) {
    if (amount <= 0 && run.synchronizeBlockBonus <= 0) return;
    run.block += amount + run.synchronizeBlockBonus;
  }

  /// Deals [amount] to [threat], honoring armor unless [ignoreArmor]. Returns
  /// true if the threat died.
  bool _dealDamage(ThreatInstance threat, int amount, {bool ignoreArmor = false}) {
    if (!threat.targetable || threat.isDead) return false;
    final effective = ignoreArmor
        ? amount
        : (amount - threat.def.armor).clamp(0, 9999).toInt();
    threat.hp -= effective;
    return threat.isDead;
  }

  void _addRandomCards(int count, Rarity rarity) {
    final pool = _rewardPool.where((c) => c.rarity == rarity).toList();
    if (pool.isEmpty) return;
    for (var i = 0; i < count; i++) {
      if (run.hand.length >= 10) break;
      final card = pool[_rng.nextInt(pool.length)].copy();
      run.hand.add(card);
      run.temporaryCards.add(card);
    }
  }

  void _cleanupDeadThreats() {
    run.threats.removeWhere((t) => t.isDead);
  }

  // ---------------------------------------------------------------------------
  // End of turn resolution
  // ---------------------------------------------------------------------------

  void endTurn() {
    if (run.phase != RunPhase.player) return;

    _resolveResinTraps();
    _resolveVenom();
    _resolveStrikes();
    _resolveUpkeep();

    // Overwinter: convert remaining Block into Honey.
    if (run.overwinterActive && run.block > 0) {
      run.honey += run.block;
      _log('Overwinter converts ${run.block} Block into Honey.');
      run.block = 0;
    }

    // Discard the leftover hand; temporary cards simply vanish.
    final leftovers = List.of(run.hand);
    run.hand.clear();
    for (final c in leftovers) {
      if (!run.temporaryCards.remove(c)) run.discardPile.add(c);
    }
    run.temporaryCards.clear();

    // Tick remaining countdowns toward striking.
    for (final t in run.threats) {
      if (t.countdown > 0) t.countdown -= 1;
    }

    if (run.integrity <= 0) {
      _lose();
      return;
    }
    if (run.waveNumber >= run.config.totalWaves) {
      run.phase = RunPhase.won;
      _log('The hive survives until spring. Night won!');
      return;
    }
    run.phase = RunPhase.reward;
  }

  void _resolveResinTraps() {
    if (run.resinTrapCharges.isEmpty) return;
    for (final dmg in run.resinTrapCharges) {
      final striking =
          run.targetableThreats.where((t) => t.willStrike).toList();
      if (striking.isEmpty) continue;
      _dealDamage(striking.first, dmg);
    }
    run.resinTrapCharges.clear();
    _cleanupDeadThreats();
  }

  void _resolveVenom() {
    for (final t in run.threats) {
      if (t.venom > 0 && t.targetable) t.hp -= t.venom;
    }
    _cleanupDeadThreats();
  }

  void _resolveStrikes() {
    final removeAfter = <int>[];
    for (final t in List.of(run.threats)) {
      if (!t.willStrike) continue;
      _applyStrike(t);
      if (t.def.untargetable) removeAfter.add(t.instanceId);
    }
    if (removeAfter.isNotEmpty) {
      run.threats.removeWhere((t) => removeAfter.contains(t.instanceId));
    }
  }

  void _applyStrike(ThreatInstance t) {
    final dmg = t.damage;
    if (run.block >= dmg) {
      run.block -= dmg;
    } else {
      final overflow = dmg - run.block;
      run.block = 0;
      run.integrity -= overflow;
      _log('${t.def.name} strikes for $overflow.');
    }
    if (t.def.drainPollenOnStrike > 0) {
      run.pendingPollenDrain += t.def.drainPollenOnStrike;
    }
    if (t.def.webOnStrike > 0) {
      run.pendingDrawReduction += t.def.webOnStrike;
    }
  }

  void _resolveUpkeep() {
    for (final t in run.threats) {
      if (t.isDead) continue;
      if (t.def.honeyDrainPerTurn > 0) {
        run.honey =
            (run.honey - t.def.honeyDrainPerTurn).clamp(0, 1 << 30).toInt();
      }
      if (t.def.damageRampPerTurn > 0) {
        t.damage += t.def.damageRampPerTurn;
      }
    }
  }

  void _lose() {
    run.phase = RunPhase.lost;
    _log('The hive has fallen.');
  }

  // ---------------------------------------------------------------------------
  // Rewards between waves
  // ---------------------------------------------------------------------------

  /// Generate up to [count] distinct reward card choices from the reward pool.
  List<GameCard> rewardChoices({int count = 3}) {
    final pool = List.of(_rewardPool)..shuffle(_rng);
    return pool.take(count).toList();
  }

  /// Add a chosen reward card to the deck (enters the discard pile), then
  /// proceed to the next wave. Pass null to skip the reward.
  void chooseReward(GameCard? card) {
    if (run.phase != RunPhase.reward) return;
    if (card != null) {
      run.discardPile.add(card);
      _log('Added ${card.name} to the deck.');
    }
    beginWave();
  }
}
