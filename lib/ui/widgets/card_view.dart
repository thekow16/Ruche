import 'package:flutter/material.dart';

import '../../game/models/card.dart';
import '../../game/models/enums.dart';
import '../theme.dart';

/// A playable card. Shows cost (hex), name, type and rules text.
class CardView extends StatelessWidget {
  final GameCard card;
  final int effectiveCost;
  final bool playable;
  final bool dimmed;
  final VoidCallback? onTap;

  const CardView({
    super.key,
    required this.card,
    required this.effectiveCost,
    this.playable = true,
    this.dimmed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = HiveColors.forType(card.type);
    final discounted = effectiveCost < card.cost;
    return Opacity(
      opacity: dimmed ? 0.45 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 132,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: HiveColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: playable ? typeColor : HiveColors.comb,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CostHex(
                    cost: effectiveCost,
                    color: discounted ? HiveColors.paleHoney : HiveColors.amber,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      card.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HiveColors.paleHoney,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${card.type.label} · ${card.rarity.label}',
                  style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  card.text,
                  style: const TextStyle(
                    color: HiveColors.paleHoney,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostHex extends StatelessWidget {
  final int cost;
  final Color color;
  const _CostHex({required this.cost, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$cost',
        style: const TextStyle(
          color: HiveColors.background,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }
}
