import 'package:flutter/material.dart';

import '../../game/engine/run_state.dart';
import '../theme.dart';
import 'hexagon.dart';

/// Top status bar: hive integrity, pollen, honey, block and wave progress.
class ResourceBar extends StatelessWidget {
  final RunState run;
  const ResourceBar({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: HiveColors.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _IntegrityHex(value: run.integrity, max: run.maxIntegrity),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        'WAVE ${run.waveNumber} / ${run.config.totalWaves}',
                        style: const TextStyle(
                          color: HiveColors.paleHoney,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          _Pill(
                            label: 'POLLEN',
                            value: '${run.pollen}',
                            color: HiveColors.amber,
                          ),
                          _Pill(
                            label: 'HONEY',
                            value: '${run.honey}',
                            color: HiveColors.paleHoney,
                          ),
                          _Pill(
                            label: 'BLOCK',
                            value: '${run.block}',
                            color: const Color(0xFF6FA3C7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntegrityHex extends StatelessWidget {
  final int value;
  final int max;
  const _IntegrityHex({required this.value, required this.max});

  @override
  Widget build(BuildContext context) {
    final ratio = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0).toDouble();
    final color = Color.lerp(HiveColors.danger, HiveColors.amber, ratio)!;
    return HexCell(
      size: 64,
      color: color,
      borderColor: HiveColors.paleHoney,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'HIVE',
            style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Pill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: HiveColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
