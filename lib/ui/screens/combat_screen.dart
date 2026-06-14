import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/engine/run_state.dart';
import '../../game/models/card.dart';
import '../../game/models/enums.dart';
import '../../game/models/threat.dart';
import '../../state/providers.dart';
import '../theme.dart';
import '../widgets/card_view.dart';
import '../widgets/hexagon.dart';
import '../widgets/resource_bar.dart';
import '../widgets/threat_view.dart';
import 'summary_screen.dart';

class CombatScreen extends ConsumerWidget {
  const CombatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Navigate to the summary once the run ends.
    ref.listen<RunState?>(runProvider, (prev, next) {
      if (next != null && next.isOver && (prev == null || !prev.isOver)) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SummaryScreen()),
        );
      }
    });

    final run = ref.watch(runProvider);
    if (run == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final controller = ref.read(runProvider.notifier);
    final pendingTarget = ref.watch(pendingTargetProvider);
    final targeting = pendingTarget != null;
    final discarding = run.phase == RunPhase.discarding;

    void tapCard(GameCard card) {
      if (discarding) {
        controller.discardForEffect(card);
        return;
      }
      if (run.phase != RunPhase.player) return;
      final cost = controller.engine!.effectiveCost(card);
      if (cost > run.pollen) return;
      if (card.needsTarget && run.targetableThreats.isNotEmpty) {
        ref.read(pendingTargetProvider.notifier).state = card;
      } else {
        controller.playCard(card);
      }
    }

    void tapThreat(ThreatInstance threat) {
      if (pendingTarget != null) {
        controller.playCard(pendingTarget, targetId: threat.instanceId);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                ResourceBar(run: run),
                if (targeting || discarding)
                  _Banner(
                    text: discarding
                        ? 'Tap ${run.pendingDiscardCount} card(s) to discard'
                        : 'Select a target — tap a threat',
                    onCancel: targeting
                        ? () =>
                            ref.read(pendingTargetProvider.notifier).state = null
                        : null,
                  ),
                Expanded(
                  child: _Board(
                    run: run,
                    selectable: targeting,
                    onTapThreat: tapThreat,
                  ),
                ),
                _HandArea(
                  run: run,
                  controller: controller,
                  pendingTarget: pendingTarget,
                  onTapCard: tapCard,
                ),
              ],
            ),
            if (run.phase == RunPhase.reward)
              _RewardOverlay(
                options: controller.rewardOptions,
                onPick: controller.chooseReward,
              ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;
  final VoidCallback? onCancel;
  const _Banner({required this.text, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: HiveColors.amber.withValues(alpha: 0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: HiveColors.background,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (onCancel != null)
            GestureDetector(
              onTap: onCancel,
              child: const Icon(Icons.close, color: HiveColors.background),
            ),
        ],
      ),
    );
  }
}

class _Board extends StatelessWidget {
  final RunState run;
  final bool selectable;
  final void Function(ThreatInstance) onTapThreat;

  const _Board({
    required this.run,
    required this.selectable,
    required this.onTapThreat,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          if (run.threats.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('The hive is quiet...',
                  style: TextStyle(color: HiveColors.paleHoney)),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 10,
              children: [
                for (final t in run.threats)
                  ThreatView(
                    threat: t,
                    selectable: selectable && t.targetable,
                    onTap: () => onTapThreat(t),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _HandArea extends StatelessWidget {
  final RunState run;
  final RunController controller;
  final GameCard? pendingTarget;
  final void Function(GameCard) onTapCard;

  const _HandArea({
    required this.run,
    required this.controller,
    required this.pendingTarget,
    required this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HiveColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          SizedBox(
            height: 168,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (final card in run.hand)
                  Builder(builder: (_) {
                    final cost = controller.engine!.effectiveCost(card);
                    final affordable = cost <= run.pollen;
                    final isPending = identical(card, pendingTarget);
                    return CardView(
                      card: card,
                      effectiveCost: cost,
                      playable: affordable && run.phase == RunPhase.player,
                      dimmed: !affordable && run.phase == RunPhase.player,
                      onTap: () => onTapCard(card),
                    ).targetHighlight(isPending);
                  }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 12),
              Text(
                'Draw ${run.drawPile.length} · Discard ${run.discardPile.length}',
                style: const TextStyle(color: HiveColors.paleHoney, fontSize: 12),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: HexButton(
                  label: 'END TURN',
                  icon: Icons.fast_forward,
                  color: run.phase == RunPhase.player
                      ? HiveColors.amber
                      : HiveColors.comb,
                  onTap: run.phase == RunPhase.player ? controller.endTurn : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tiny helper to highlight the card currently awaiting a target.
extension on Widget {
  Widget targetHighlight(bool highlight) {
    if (!highlight) return this;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HiveColors.paleHoney, width: 3),
      ),
      child: this,
    );
  }
}

class _RewardOverlay extends StatelessWidget {
  final List<GameCard> options;
  final void Function(GameCard?) onPick;
  const _RewardOverlay({required this.options, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'WAVE CLEARED',
                style: TextStyle(
                  color: HiveColors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Choose a card to add to your deck',
                  style: TextStyle(color: HiveColors.paleHoney)),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 12,
                children: [
                  for (final card in options)
                    CardView(
                      card: card,
                      effectiveCost: card.cost,
                      onTap: () => onPick(card),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              HexButton(
                label: 'SKIP',
                color: HiveColors.comb,
                onTap: () => onPick(null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
