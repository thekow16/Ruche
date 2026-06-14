/// The mutable run/combat state — a pure Dart model with no Flutter imports.
///
/// Held and mutated by [CombatEngine]. The UI never mutates it directly; it
/// reads a cloned snapshot exposed through Riverpod.
import '../models/card.dart';
import '../models/enums.dart';
import '../models/relic.dart';
import '../models/threat.dart';

/// Static configuration for a night.
class RunConfig {
  final int totalWaves;
  final int basePollen;
  final int handSize;
  final int baseMaxIntegrity;

  const RunConfig({
    this.totalWaves = 8,
    this.basePollen = 3,
    this.handSize = 5,
    this.baseMaxIntegrity = 30,
  });
}

class RunState {
  final RunConfig config;
  final Relic? relic;

  // Resources
  int maxIntegrity;
  int integrity;
  int pollen;
  int honey;
  int block;

  // Progress
  int waveNumber; // 0 before the first wave begins
  RunPhase phase;

  // Piles
  final List<GameCard> drawPile;
  final List<GameCard> hand;
  final List<GameCard> discardPile;
  final List<GameCard> exhaustPile;

  // Board
  final List<ThreatInstance> threats;

  // Per-turn transient state
  int cardsPlayedThisTurn;
  int nextCardDiscount;
  int synchronizeBlockBonus;
  bool keepHalfBlock;
  bool overwinterActive;
  int pendingDiscardCount;

  // Persistent within the run
  int workerShiftPollen;

  // Carried to next turn
  int pendingPollenDrain;
  int pendingDrawReduction;
  final List<int> resinTrapCharges;

  /// Temporary cards (Queen's Call) tracked by identity, removed at end of turn
  /// if unplayed and never sent to the discard pile.
  final Set<GameCard> temporaryCards;

  int nextInstanceId;

  RunState({
    required this.config,
    this.relic,
    required this.maxIntegrity,
    required this.integrity,
    this.pollen = 0,
    this.honey = 0,
    this.block = 0,
    this.waveNumber = 0,
    this.phase = RunPhase.player,
    List<GameCard>? drawPile,
    List<GameCard>? hand,
    List<GameCard>? discardPile,
    List<GameCard>? exhaustPile,
    List<ThreatInstance>? threats,
    this.cardsPlayedThisTurn = 0,
    this.nextCardDiscount = 0,
    this.synchronizeBlockBonus = 0,
    this.keepHalfBlock = false,
    this.overwinterActive = false,
    this.pendingDiscardCount = 0,
    this.workerShiftPollen = 0,
    this.pendingPollenDrain = 0,
    this.pendingDrawReduction = 0,
    List<int>? resinTrapCharges,
    Set<GameCard>? temporaryCards,
    this.nextInstanceId = 1,
  })  : drawPile = drawPile ?? [],
        hand = hand ?? [],
        discardPile = discardPile ?? [],
        exhaustPile = exhaustPile ?? [],
        threats = threats ?? [],
        resinTrapCharges = resinTrapCharges ?? [],
        temporaryCards = temporaryCards ?? {};

  bool get isOver => phase == RunPhase.won || phase == RunPhase.lost;

  /// Total cards remaining in the deck (draw + hand + discard).
  int get deckSize => drawPile.length + hand.length + discardPile.length;

  /// Threats the player can currently target with damage.
  List<ThreatInstance> get targetableThreats =>
      threats.where((t) => t.targetable && !t.isDead).toList();

  /// A deep-enough copy for Riverpod state emission. Card definitions are
  /// immutable and shared; threat instances are mutable and cloned.
  RunState clone() => RunState(
        config: config,
        relic: relic,
        maxIntegrity: maxIntegrity,
        integrity: integrity,
        pollen: pollen,
        honey: honey,
        block: block,
        waveNumber: waveNumber,
        phase: phase,
        drawPile: List.of(drawPile),
        hand: List.of(hand),
        discardPile: List.of(discardPile),
        exhaustPile: List.of(exhaustPile),
        threats: threats.map((t) => t.clone()).toList(),
        cardsPlayedThisTurn: cardsPlayedThisTurn,
        nextCardDiscount: nextCardDiscount,
        synchronizeBlockBonus: synchronizeBlockBonus,
        keepHalfBlock: keepHalfBlock,
        overwinterActive: overwinterActive,
        pendingDiscardCount: pendingDiscardCount,
        workerShiftPollen: workerShiftPollen,
        pendingPollenDrain: pendingPollenDrain,
        pendingDrawReduction: pendingDrawReduction,
        resinTrapCharges: List.of(resinTrapCharges),
        temporaryCards: Set.of(temporaryCards),
        nextInstanceId: nextInstanceId,
      );
}
