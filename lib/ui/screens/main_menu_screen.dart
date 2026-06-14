import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/data/cards_data.dart';
import '../../game/data/relics_data.dart';
import '../../game/models/relic.dart';
import '../../state/providers.dart';
import '../theme.dart';
import '../widgets/hexagon.dart';
import 'combat_screen.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  Relic? _selectedRelic;

  void _startNight() {
    ref.read(runProvider.notifier).startNight(relic: _selectedRelic);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CombatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = ref.watch(metaProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: HexCell(
                  size: 96,
                  color: HiveColors.amber,
                  borderColor: HiveColors.paleHoney,
                  child: const Icon(Icons.hive, size: 48, color: HiveColors.background),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text('HIVE', style: Theme.of(context).textTheme.displaySmall),
              ),
              const Center(
                child: Text(
                  'Guard the hive until spring.',
                  style: TextStyle(color: HiveColors.paleHoney, fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),
              _StatsRow(
                banked: meta.bankedHoney,
                nights: meta.nightsWon,
                best: meta.bestHoney,
              ),
              const SizedBox(height: 24),
              _SectionTitle('Choose a relic'),
              const SizedBox(height: 8),
              ...RelicLibrary.all.map(
                (r) => _RelicTile(
                  relic: r,
                  selected: _selectedRelic?.id == r.id,
                  onTap: () => setState(() {
                    _selectedRelic = _selectedRelic?.id == r.id ? null : r;
                  }),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: HexButton(
                  label: 'START NIGHT',
                  icon: Icons.nightlight_round,
                  onTap: _startNight,
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle('Unlock cards (spend banked Honey)'),
              const SizedBox(height: 8),
              ...CardLibrary.lockedCards.map((entry) {
                final card = CardLibrary.get(entry.cardId);
                final unlocked = meta.unlockedCardIds.contains(entry.cardId);
                final canAfford = meta.bankedHoney >= entry.cost;
                return _UnlockTile(
                  name: card.name,
                  text: card.text,
                  cost: entry.cost,
                  unlocked: unlocked,
                  canAfford: canAfford,
                  onUnlock: () =>
                      ref.read(metaProvider.notifier).unlockCard(entry.cardId),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int banked;
  final int nights;
  final int best;
  const _StatsRow({required this.banked, required this.nights, required this.best});

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, String value) => Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: HiveColors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(color: HiveColors.paleHoney, fontSize: 11)),
          ],
        );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: HiveColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          stat('BANKED HONEY', '$banked'),
          stat('NIGHTS WON', '$nights'),
          stat('BEST HONEY', '$best'),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: HiveColors.amber,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        fontSize: 13,
      ),
    );
  }
}

class _RelicTile extends StatelessWidget {
  final Relic relic;
  final bool selected;
  final VoidCallback onTap;
  const _RelicTile({required this.relic, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? HiveColors.amber.withOpacity(0.18) : HiveColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? HiveColors.amber : HiveColors.comb,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? HiveColors.amber : HiveColors.comb,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(relic.name,
                      style: const TextStyle(
                          color: HiveColors.paleHoney, fontWeight: FontWeight.w800)),
                  Text(relic.description,
                      style: const TextStyle(color: HiveColors.paleHoney, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockTile extends StatelessWidget {
  final String name;
  final String text;
  final int cost;
  final bool unlocked;
  final bool canAfford;
  final VoidCallback onUnlock;

  const _UnlockTile({
    required this.name,
    required this.text,
    required this.cost,
    required this.unlocked,
    required this.canAfford,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HiveColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: unlocked ? HiveColors.amber : HiveColors.comb),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: HiveColors.paleHoney, fontWeight: FontWeight.w800)),
                Text(text,
                    style: const TextStyle(color: HiveColors.paleHoney, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (unlocked)
            const Icon(Icons.lock_open, color: HiveColors.amber)
          else
            HexButton(
              label: '$cost',
              icon: Icons.lock,
              color: canAfford ? HiveColors.amber : HiveColors.comb,
              onTap: canAfford ? onUnlock : null,
            ),
        ],
      ),
    );
  }
}
