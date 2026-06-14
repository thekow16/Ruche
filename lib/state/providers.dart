/// Riverpod wiring: bridges the pure game engine to the Flutter UI.
///
/// The engine and run state remain pure Dart; these controllers own an engine
/// instance and emit cloned [RunState] snapshots so the UI rebuilds reactively.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/data/cards_data.dart';
import '../game/deck_builder.dart';
import '../game/engine/combat_engine.dart';
import '../game/engine/run_state.dart';
import '../game/meta/meta_state.dart';
import '../game/meta/save_service.dart';
import '../game/models/card.dart';
import '../game/models/enums.dart';
import '../game/models/relic.dart';
import '../game/models/threat.dart';

final saveServiceProvider = Provider<SaveService>((ref) => SaveService());

/// Persistent meta-progression.
final metaProvider =
    NotifierProvider<MetaController, MetaState>(MetaController.new);

class MetaController extends Notifier<MetaState> {
  @override
  MetaState build() => MetaState();

  Future<void> init() async {
    state = await ref.read(saveServiceProvider).load();
  }

  Future<void> _persist() async {
    await ref.read(saveServiceProvider).save(state);
  }

  Future<bool> unlockCard(String cardId) async {
    final next = state.clone();
    final ok = next.unlock(cardId);
    if (ok) {
      state = next;
      await _persist();
    }
    return ok;
  }

  Future<void> recordRun({required int runHoney, required bool won}) async {
    final next = state.clone();
    next.recordRun(runHoney: runHoney, won: won);
    state = next;
    await _persist();
  }

  Future<void> resetProgress() async {
    await ref.read(saveServiceProvider).reset();
    state = MetaState();
  }
}

/// The active run (null when not in combat).
final runProvider = NotifierProvider<RunController, RunState?>(RunController.new);

/// The card currently awaiting a target selection (UI-side targeting flow).
final pendingTargetProvider = StateProvider<GameCard?>((ref) => null);

class RunController extends Notifier<RunState?> {
  CombatEngine? _engine;
  bool _recorded = false;
  List<GameCard> _rewardOptions = [];

  CombatEngine? get engine => _engine;
  List<String> get log => _engine?.log ?? const [];
  List<GameCard> get rewardOptions => _rewardOptions;

  @override
  RunState? build() => null;

  void startNight({Relic? relic}) {
    final meta = ref.read(metaProvider);
    final pool = CardLibrary.availableCards(meta.unlockedCardIds);
    _engine = CombatEngine.newNight(
      deck: buildStartingDeck(),
      relic: relic,
      rewardPool: pool,
    );
    _recorded = false;
    _rewardOptions = [];
    state = _engine!.run.clone();
  }

  /// Plays [card]. [targetId] identifies the chosen threat; because the UI only
  /// sees cloned snapshots, we resolve it back to the engine's real instance.
  void playCard(GameCard card, {int? targetId}) {
    final e = _engine;
    if (e == null) return;
    ThreatInstance? target;
    if (targetId != null) {
      for (final t in e.run.threats) {
        if (t.instanceId == targetId) {
          target = t;
          break;
        }
      }
    }
    e.playCard(card, target: target);
    ref.read(pendingTargetProvider.notifier).state = null;
    _sync();
  }

  void discardForEffect(GameCard card) {
    _engine?.discardForEffect(card);
    _sync();
  }

  void endTurn() {
    _engine?.endTurn();
    _sync();
  }

  void chooseReward(GameCard? card) {
    _engine?.chooseReward(card);
    _rewardOptions = [];
    _sync();
  }

  void abandon() {
    _engine = null;
    _recorded = false;
    _rewardOptions = [];
    state = null;
  }

  void _sync() {
    final e = _engine;
    if (e == null) return;
    if (e.run.phase == RunPhase.reward && _rewardOptions.isEmpty) {
      _rewardOptions = e.rewardChoices();
    }
    if (e.run.isOver && !_recorded) {
      _recorded = true;
      // Fire-and-forget; persistence isn't on the UI critical path.
      ref.read(metaProvider.notifier).recordRun(
            runHoney: e.run.honey,
            won: e.run.phase == RunPhase.won,
          );
    }
    state = e.run.clone();
  }
}
