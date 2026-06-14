import 'package:flutter/material.dart';

import '../../game/models/threat.dart';
import '../theme.dart';
import 'hexagon.dart';

/// A single threat rendered as a hex with HP, damage and countdown.
class ThreatView extends StatelessWidget {
  final ThreatInstance threat;
  final bool selectable;
  final VoidCallback? onTap;

  const ThreatView({
    super.key,
    required this.threat,
    this.selectable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final def = threat.def;
    final striking = threat.willStrike;
    final borderColor = selectable
        ? HiveColors.paleHoney
        : (striking ? HiveColors.danger : HiveColors.comb);

    return GestureDetector(
      onTap: selectable ? onTap : null,
      child: SizedBox(
        width: 92,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                HexCell(
                  size: 78,
                  color: striking ? HiveColors.danger : HiveColors.comb,
                  borderColor: borderColor,
                  borderWidth: selectable ? 3 : 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bug_report,
                        color: HiveColors.paleHoney,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      if (def.untargetable)
                        const Text('—',
                            style: TextStyle(color: Colors.white, fontSize: 14))
                      else
                        Text(
                          '${threat.hp}/${def.maxHp}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Countdown badge.
                Positioned(
                  top: 0,
                  right: 8,
                  child: _Badge(
                    text: striking ? '!' : '${threat.countdown}',
                    color: striking ? HiveColors.danger : HiveColors.amber,
                  ),
                ),
                // Damage badge.
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: _Badge(text: '${threat.damage}', color: HiveColors.danger),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              def.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: HiveColors.paleHoney,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (threat.venom > 0)
              Text(
                '☠ ${threat.venom}',
                style: const TextStyle(color: Color(0xFF8FCB6B), fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: HiveColors.background, width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
