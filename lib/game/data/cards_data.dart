/// The full prototype card list (32 cards) from the design spec, expressed as
/// data. Adding a card here is all that's needed for it to exist in game.
///
/// Pure Dart — no Flutter imports.
import '../models/card.dart';
import '../models/effects.dart';
import '../models/enums.dart';

class CardLibrary {
  CardLibrary._();

  static const List<GameCard> all = [
    // --- Defenders ----------------------------------------------------------
    GameCard(
      id: 'wax_wall',
      name: 'Wax Wall',
      cost: 1,
      type: CardType.defender,
      rarity: Rarity.common,
      effects: [GainBlock(5)],
    ),
    GameCard(
      id: 'comb_shield',
      name: 'Comb Shield',
      cost: 1,
      type: CardType.defender,
      rarity: Rarity.common,
      effects: [GainBlock(4), DrawCards(1)],
    ),
    GameCard(
      id: 'propolis_seal',
      name: 'Propolis Seal',
      cost: 2,
      type: CardType.defender,
      rarity: Rarity.uncommon,
      effects: [GainBlock(9)],
    ),
    GameCard(
      id: 'hardened_wax',
      name: 'Hardened Wax',
      cost: 2,
      type: CardType.defender,
      rarity: Rarity.uncommon,
      effects: [GainBlock(6), KeepHalfBlockNextTurn()],
    ),
    GameCard(
      id: 'royal_guard',
      name: 'Royal Guard',
      cost: 3,
      type: CardType.defender,
      rarity: Rarity.rare,
      effects: [
        ConditionalBlock(amount: 12, bonusAmount: 18, integrityBelow: 15),
      ],
    ),
    GameCard(
      id: 'swarm_wall',
      name: 'Swarm Wall',
      cost: 2,
      type: CardType.defender,
      rarity: Rarity.uncommon,
      effects: [GainBlockPerThreat(3)],
    ),

    // --- Stingers -----------------------------------------------------------
    GameCard(
      id: 'sting',
      name: 'Sting',
      cost: 1,
      type: CardType.stinger,
      rarity: Rarity.common,
      effects: [DamageSingle(5)],
    ),
    GameCard(
      id: 'quick_jab',
      name: 'Quick Jab',
      cost: 0,
      type: CardType.stinger,
      rarity: Rarity.common,
      effects: [DamageSingle(3)],
    ),
    GameCard(
      id: 'venom_barb',
      name: 'Venom Barb',
      cost: 1,
      type: CardType.stinger,
      rarity: Rarity.common,
      effects: [DamageSingle(4), ApplyVenom(2)],
    ),
    GameCard(
      id: 'wing_slash',
      name: 'Wing Slash',
      cost: 2,
      type: CardType.stinger,
      rarity: Rarity.uncommon,
      effects: [DamageAll(7)],
    ),
    GameCard(
      id: 'piercing_stinger',
      name: 'Piercing Stinger',
      cost: 2,
      type: CardType.stinger,
      rarity: Rarity.uncommon,
      effects: [DamageSingle(10, ignoreArmor: true)],
    ),
    GameCard(
      id: 'death_sting',
      name: 'Death Sting',
      cost: 3,
      type: CardType.stinger,
      rarity: Rarity.rare,
      effects: [DamageSingleCostHp(amount: 16, hpCost: 4)],
    ),
    GameCard(
      id: 'frenzy',
      name: 'Frenzy',
      cost: 1,
      type: CardType.stinger,
      rarity: Rarity.uncommon,
      effects: [FrenzyDamage(3)],
    ),
    GameCard(
      id: 'pheromone_strike',
      name: 'Pheromone Strike',
      cost: 2,
      type: CardType.stinger,
      rarity: Rarity.rare,
      effects: [ChainDamage(6)],
    ),

    // --- Workers ------------------------------------------------------------
    GameCard(
      id: 'forage',
      name: 'Forage',
      cost: 1,
      type: CardType.worker,
      rarity: Rarity.common,
      effects: [GainPollen(2)],
    ),
    GameCard(
      id: 'nectar_run',
      name: 'Nectar Run',
      cost: 1,
      type: CardType.worker,
      rarity: Rarity.common,
      effects: [GainHoney(3)],
      isHoneyCard: true,
    ),
    GameCard(
      id: 'pollinate',
      name: 'Pollinate',
      cost: 0,
      type: CardType.worker,
      rarity: Rarity.common,
      effects: [GainPollen(1), DrawCards(1)],
    ),
    GameCard(
      id: 'honey_cache',
      name: 'Honey Cache',
      cost: 2,
      type: CardType.worker,
      rarity: Rarity.uncommon,
      effects: [GainHoney(6), BlockPerHoneyCardInDiscard()],
      isHoneyCard: true,
    ),
    GameCard(
      id: 'worker_shift',
      name: 'Worker Shift',
      cost: 2,
      type: CardType.worker,
      rarity: Rarity.uncommon,
      effects: [PollenEachTurn(2)],
    ),
    GameCard(
      id: 'golden_harvest',
      name: 'Golden Harvest',
      cost: 3,
      type: CardType.worker,
      rarity: Rarity.rare,
      effects: [GainHoneyPerPollen(2)],
      isHoneyCard: true,
    ),
    GameCard(
      id: 'industrious',
      name: 'Industrious',
      cost: 1,
      type: CardType.worker,
      rarity: Rarity.uncommon,
      effects: [NextCardCheaper(1)],
    ),

    // --- Architects ---------------------------------------------------------
    GameCard(
      id: 'scout',
      name: 'Scout',
      cost: 0,
      type: CardType.architect,
      rarity: Rarity.common,
      effects: [DrawCards(2)],
    ),
    GameCard(
      id: 'waggle_dance',
      name: 'Waggle Dance',
      cost: 1,
      type: CardType.architect,
      rarity: Rarity.common,
      effects: [DrawThenDiscard(draw: 2, discard: 1)],
    ),
    GameCard(
      id: 'hive_mind',
      name: 'Hive Mind',
      cost: 2,
      type: CardType.architect,
      rarity: Rarity.uncommon,
      effects: [DrawCards(3), GainPollen(1)],
    ),
    GameCard(
      id: 'queens_call',
      name: "Queen's Call",
      cost: 3,
      type: CardType.architect,
      rarity: Rarity.rare,
      effects: [AddRandomCards(count: 2, rarity: Rarity.uncommon)],
    ),
    GameCard(
      id: 'regenerate',
      name: 'Regenerate',
      cost: 2,
      type: CardType.architect,
      rarity: Rarity.uncommon,
      effects: [Heal(6)],
    ),
    GameCard(
      id: 'smoke_screen',
      name: 'Smoke Screen',
      cost: 1,
      type: CardType.architect,
      rarity: Rarity.uncommon,
      effects: [IncreaseCountdown(2)],
    ),
    GameCard(
      id: 'resin_trap',
      name: 'Resin Trap',
      cost: 1,
      type: CardType.architect,
      rarity: Rarity.common,
      effects: [ResinTrap(8)],
    ),
    GameCard(
      id: 'synchronize',
      name: 'Synchronize',
      cost: 2,
      type: CardType.architect,
      rarity: Rarity.rare,
      effects: [SynchronizeBlock(3)],
    ),
    GameCard(
      id: 'overwinter',
      name: 'Overwinter',
      cost: 3,
      type: CardType.architect,
      rarity: Rarity.rare,
      effects: [OverwinterConvert()],
      isHoneyCard: true,
    ),
    GameCard(
      id: 'drone_sacrifice',
      name: 'Drone Sacrifice',
      cost: 0,
      type: CardType.architect,
      rarity: Rarity.uncommon,
      effects: [LoseIntegrity(3), GainPollen(3)],
    ),
    GameCard(
      id: 'spring_bloom',
      name: 'Spring Bloom',
      cost: 3,
      type: CardType.architect,
      rarity: Rarity.rare,
      effects: [Heal(4), GainPollen(4), DrawCards(2)],
      exhaust: true,
    ),
  ];

  static final Map<String, GameCard> byId = {
    for (final c in all) c.id: c,
  };

  static GameCard get(String id) {
    final card = byId[id];
    if (card == null) throw ArgumentError('Unknown card id: $id');
    return card;
  }

  /// The 10-card starting deck: 5x Sting, 3x Wax Wall, 1x Forage, 1x Scout.
  static const Map<String, int> startingDeck = {
    'sting': 5,
    'wax_wall': 3,
    'forage': 1,
    'scout': 1,
  };

  /// The 6 meta-locked cards and their cumulative banked-Honey unlock costs.
  static const List<({String cardId, int cost})> lockedCards = [
    (cardId: 'frenzy', cost: 50),
    (cardId: 'worker_shift', cost: 80),
    (cardId: 'hive_mind', cost: 120),
    (cardId: 'pheromone_strike', cost: 160),
    (cardId: 'synchronize', cost: 220),
    (cardId: 'spring_bloom', cost: 300),
  ];

  static final Set<String> lockedCardIds = {
    for (final e in lockedCards) e.cardId,
  };

  /// Cards available to a player given the set of unlocked locked-card ids.
  /// Always includes every card that isn't behind a lock.
  static List<GameCard> availableCards(Set<String> unlockedIds) {
    return all
        .where((c) => !lockedCardIds.contains(c.id) || unlockedIds.contains(c.id))
        .toList();
  }

  static List<GameCard> byRarity(Rarity rarity) =>
      all.where((c) => c.rarity == rarity).toList();
}
