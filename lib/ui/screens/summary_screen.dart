import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/meta/meta_state.dart';
import '../../game/models/enums.dart';
import '../../state/providers.dart';
import '../theme.dart';
import '../widgets/hexagon.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(runProvider);
    final won = run?.phase == RunPhase.won;
    final honey = run?.honey ?? 0;
    final banked = (honey * MetaState.carryFraction).floor();
    final wave = run?.waveNumber ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HexCell(
                  size: 120,
                  color: won ? HiveColors.amber : HiveColors.danger,
                  borderColor: HiveColors.paleHoney,
                  child: Icon(
                    won ? Icons.wb_sunny : Icons.ac_unit,
                    size: 56,
                    color: HiveColors.background,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  won ? 'SPRING ARRIVES' : 'THE HIVE FALLS',
                  style: TextStyle(
                    color: won ? HiveColors.paleHoney : HiveColors.danger,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  won
                      ? 'You survived all 8 waves.'
                      : 'You fell on wave $wave.',
                  style: const TextStyle(color: HiveColors.paleHoney),
                ),
                const SizedBox(height: 24),
                _SummaryRow(label: 'Honey earned this run', value: '$honey'),
                _SummaryRow(
                  label: 'Banked to total (${(MetaState.carryFraction * 100).round()}%)',
                  value: '+$banked',
                ),
                const SizedBox(height: 28),
                HexButton(
                  label: 'BACK TO HIVE',
                  icon: Icons.home,
                  onTap: () {
                    ref.read(runProvider.notifier).abandon();
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: HiveColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: const TextStyle(color: HiveColors.paleHoney, fontSize: 13)),
          ),
          Text(value,
              style: const TextStyle(
                  color: HiveColors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
