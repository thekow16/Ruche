/// Data-driven card effects.
///
/// Each card is a list of [CardEffect]s. The combat engine interprets them, so
/// adding a card is purely a matter of composing existing effect primitives in
/// the data files (no engine changes needed for the common cases).
///
/// Pure Dart — no Flutter imports.
import 'enums.dart';

/// Base type for every card effect. [needsTarget] is true when the effect must
/// be aimed at a single threat (the UI prompts the player to pick one).
sealed class CardEffect {
  const CardEffect();

  bool get needsTarget => false;

  /// One-line human readable description, composed into the card text.
  String describe();
}

// --- Defence -----------------------------------------------------------------

/// Gain a flat amount of Block.
class GainBlock extends CardEffect {
  final int amount;
  const GainBlock(this.amount);
  @override
  String describe() => 'Gain $amount Block.';
}

/// Gain Block scaled by the number of threats currently present.
class GainBlockPerThreat extends CardEffect {
  final int perThreat;
  const GainBlockPerThreat(this.perThreat);
  @override
  String describe() => 'Gain $perThreat Block per threat present.';
}

/// Gain [amount] Block, or [bonusAmount] instead if Hive Integrity is below
/// [integrityBelow].
class ConditionalBlock extends CardEffect {
  final int amount;
  final int bonusAmount;
  final int integrityBelow;
  const ConditionalBlock({
    required this.amount,
    required this.bonusAmount,
    required this.integrityBelow,
  });
  @override
  String describe() =>
      'Gain $amount Block. If Hive Integrity < $integrityBelow, gain $bonusAmount instead.';
}

/// Carry half of this turn's Block into the next turn.
class KeepHalfBlockNextTurn extends CardEffect {
  const KeepHalfBlockNextTurn();
  @override
  String describe() => 'Next turn, keep half this Block.';
}

// --- Offence -----------------------------------------------------------------

/// Deal damage to a single chosen threat.
class DamageSingle extends CardEffect {
  final int amount;
  final bool ignoreArmor;
  const DamageSingle(this.amount, {this.ignoreArmor = false});
  @override
  bool get needsTarget => true;
  @override
  String describe() => ignoreArmor
      ? 'Deal $amount damage to one threat. Ignores armor.'
      : 'Deal $amount damage to one threat.';
}

/// Deal damage to every threat.
class DamageAll extends CardEffect {
  final int amount;
  const DamageAll(this.amount);
  @override
  String describe() => 'Deal $amount damage to all threats.';
}

/// Deal damage to a single threat at the cost of Hive Integrity.
class DamageSingleCostHp extends CardEffect {
  final int amount;
  final int hpCost;
  const DamageSingleCostHp({required this.amount, required this.hpCost});
  @override
  bool get needsTarget => true;
  @override
  String describe() =>
      'Deal $amount damage to one threat. Costs $hpCost Hive Integrity.';
}

/// Deal [perCard] damage to one threat, multiplied by the number of cards
/// played this turn (including this one).
class FrenzyDamage extends CardEffect {
  final int perCard;
  const FrenzyDamage(this.perCard);
  @override
  bool get needsTarget => true;
  @override
  String describe() =>
      'Deal $perCard damage to one threat. Repeat for each card played this turn.';
}

/// Deal damage to a chosen threat; if it dies, deal the same to another.
class ChainDamage extends CardEffect {
  final int amount;
  const ChainDamage(this.amount);
  @override
  bool get needsTarget => true;
  @override
  String describe() =>
      'Deal $amount damage to one threat. If it dies, deal $amount to another.';
}

/// Apply Venom stacks to a chosen threat (it loses HP each turn).
class ApplyVenom extends CardEffect {
  final int amount;
  const ApplyVenom(this.amount);
  @override
  bool get needsTarget => true;
  @override
  String describe() => 'Apply $amount Venom (lose $amount HP/turn).';
}

// --- Economy -----------------------------------------------------------------

/// Gain Pollen now.
class GainPollen extends CardEffect {
  final int amount;
  const GainPollen(this.amount);
  @override
  String describe() => 'Gain $amount Pollen.';
}

/// Gain Honey now.
class GainHoney extends CardEffect {
  final int amount;
  const GainHoney(this.amount);
  @override
  String describe() => 'Gain $amount Honey.';
}

/// Gain Honey equal to [multiplier] times current Pollen.
class GainHoneyPerPollen extends CardEffect {
  final int multiplier;
  const GainHoneyPerPollen(this.multiplier);
  @override
  String describe() => multiplier == 2
      ? 'Gain Honey equal to twice your current Pollen.'
      : 'Gain Honey equal to $multiplier x current Pollen.';
}

/// Gain 1 Block per Honey-generating card in the discard pile.
class BlockPerHoneyCardInDiscard extends CardEffect {
  const BlockPerHoneyCardInDiscard();
  @override
  String describe() => 'Gain 1 Block per Honey card in discard.';
}

/// Permanently gain extra Pollen at the start of every remaining turn.
class PollenEachTurn extends CardEffect {
  final int amount;
  const PollenEachTurn(this.amount);
  @override
  String describe() =>
      'Gain $amount Pollen each turn for the rest of the night.';
}

/// The next card played this turn costs [amount] less Pollen.
class NextCardCheaper extends CardEffect {
  final int amount;
  const NextCardCheaper(this.amount);
  @override
  String describe() =>
      'The next card you play this turn costs $amount less Pollen.';
}

// --- Tempo / utility ---------------------------------------------------------

/// Draw cards.
class DrawCards extends CardEffect {
  final int count;
  const DrawCards(this.count);
  @override
  String describe() => 'Draw $count card${count == 1 ? '' : 's'}.';
}

/// Draw then choose cards to discard.
class DrawThenDiscard extends CardEffect {
  final int draw;
  final int discard;
  const DrawThenDiscard({required this.draw, required this.discard});
  @override
  String describe() => 'Draw $draw cards. Discard $discard.';
}

/// Add random cards of a given rarity to the hand for this turn only.
class AddRandomCards extends CardEffect {
  final int count;
  final Rarity rarity;
  const AddRandomCards({required this.count, required this.rarity});
  @override
  String describe() =>
      'Add $count random ${rarity.label} cards to your hand this turn.';
}

/// Heal Hive Integrity.
class Heal extends CardEffect {
  final int amount;
  const Heal(this.amount);
  @override
  String describe() => 'Heal $amount Hive Integrity.';
}

/// Lose Hive Integrity (a cost paired with a benefit).
class LoseIntegrity extends CardEffect {
  final int amount;
  const LoseIntegrity(this.amount);
  @override
  String describe() => 'Lose $amount Hive Integrity.';
}

/// Increase a chosen threat's countdown (delaying its strike).
class IncreaseCountdown extends CardEffect {
  final int amount;
  const IncreaseCountdown(this.amount);
  @override
  bool get needsTarget => true;
  @override
  String describe() => 'One threat skips its next strike (countdown +$amount).';
}

/// A threat about to strike takes damage first.
class ResinTrap extends CardEffect {
  final int amount;
  const ResinTrap(this.amount);
  @override
  String describe() =>
      'A threat that strikes next turn takes $amount damage first.';
}

/// Cards that gain Block this turn gain extra Block.
class SynchronizeBlock extends CardEffect {
  final int amount;
  const SynchronizeBlock(this.amount);
  @override
  String describe() => 'Cards that gain Block this turn gain +$amount Block.';
}

/// At end of turn, convert all current Block into Honey.
class OverwinterConvert extends CardEffect {
  const OverwinterConvert();
  @override
  String describe() => 'Convert all current Block into Honey at end of turn.';
}
