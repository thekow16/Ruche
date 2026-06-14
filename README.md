# Ruche
# HIVE — Game Design Content Reference (v1 prototype)

A minimalist roguelike deckbuilder. You are the guardian bee of a hive. Each
“night” (a run), waves of threats besiege the hive. Play cards to defend the
queen and survive until spring.

This document is the **content spec** for the prototype: balance numbers,
card list, threat list, relics, and wave structure. All values are starting
points meant to be tuned by playtesting — they are deliberately conservative
and readable, not finely balanced.

-----

## 1. Core resources & rules

|Resource          |Start|Per-turn behavior                                      |Role                           |
|------------------|-----|-------------------------------------------------------|-------------------------------|
|**Pollen**        |3    |Refills to base each turn (base grows via relics/cards)|Spend to play cards            |
|**Hive Integrity**|30   |Persists across the night                              |Health — run ends at 0         |
|**Honey**         |0    |Accumulates                                            |Score + scaling + meta-currency|

**Turn structure**

1. Wave reveals: 1–3 threats appear, each with HP, damage, countdown.
1. Player gains base Pollen, draws up to a hand of 5 cards.
1. Player plays cards (spend Pollen). Unlimited plays while Pollen allows.
1. Threats with countdown 0 strike: their damage hits Hive Integrity unless blocked.
1. Countdowns tick down. Surviving threats remain.
1. End turn → next wave.

**Deck rules**

- Starting deck: 10 cards (see Starting Deck below).
- Draw 5 per turn. Reshuffle discard into draw pile when empty.
- Block resets each turn (does not carry over unless a card says so).

**Win/lose**

- Win the night by surviving 8 waves (prototype).
- Lose if Hive Integrity reaches 0.

-----

## 2. Card archetypes

- **Defenders** — generate Block to absorb incoming damage.
- **Stingers** — deal damage to threats.
- **Workers** — generate Pollen or Honey (economy/scaling).
- **Architects** — draw, combo enablers, status effects.

Rarity: Common (starter-friendly), Uncommon, Rare. Prototype reward pool
offers a choice of cards after each won wave or every 2 waves (your call).

-----

## 3. Card list (32 cards)

Format: **Name** | Cost | Type | Rarity | Effect

### Defenders

1. **Wax Wall** | 1 | Defender | Common | Gain 5 Block.
1. **Comb Shield** | 1 | Defender | Common | Gain 4 Block. Draw 1 card.
1. **Propolis Seal** | 2 | Defender | Uncommon | Gain 9 Block.
1. **Hardened Wax** | 2 | Defender | Uncommon | Gain 6 Block. Next turn, keep half this Block.
1. **Royal Guard** | 3 | Defender | Rare | Gain 12 Block. If Hive Integrity < 15, gain 18 instead.
1. **Swarm Wall** | 2 | Defender | Uncommon | Gain 3 Block per threat currently present.

### Stingers

1. **Sting** | 1 | Stinger | Common | Deal 5 damage to one threat.
1. **Quick Jab** | 0 | Stinger | Common | Deal 3 damage to one threat.
1. **Venom Barb** | 1 | Stinger | Common | Deal 4 damage. Apply 2 Venom (lose 2 HP/turn).
1. **Wing Slash** | 2 | Stinger | Uncommon | Deal 7 damage to all threats.
1. **Piercing Stinger** | 2 | Stinger | Uncommon | Deal 10 damage to one threat. Ignores armor.
1. **Death Sting** | 3 | Stinger | Rare | Deal 16 damage to one threat. Costs 4 Hive Integrity.
1. **Frenzy** | 1 | Stinger | Uncommon | Deal 3 damage. Repeat for each card played this turn.
1. **Pheromone Strike** | 2 | Stinger | Rare | Deal 6 damage to one threat. If it dies, deal 6 to another.

### Workers

1. **Forage** | 1 | Worker | Common | Gain 2 Pollen.
1. **Nectar Run** | 1 | Worker | Common | Gain 3 Honey.
1. **Pollinate** | 0 | Worker | Common | Gain 1 Pollen. Draw 1 card.
1. **Honey Cache** | 2 | Worker | Uncommon | Gain 6 Honey. Gain 1 Block per Honey card in discard.
1. **Worker Shift** | 2 | Worker | Uncommon | Gain 2 Pollen each turn for the rest of the night.
1. **Golden Harvest** | 3 | Worker | Rare | Gain Honey equal to twice your current Pollen.
1. **Industrious** | 1 | Worker | Uncommon | The next card you play this turn costs 1 less Pollen.

### Architects

1. **Scout** | 0 | Architect | Common | Draw 2 cards.
1. **Waggle Dance** | 1 | Architect | Common | Draw 2 cards. Discard 1.
1. **Hive Mind** | 2 | Architect | Uncommon | Draw 3 cards. Gain 1 Pollen.
1. **Queen’s Call** | 3 | Architect | Rare | Add 2 random Uncommon cards to your hand this turn.
1. **Regenerate** | 2 | Architect | Uncommon | Heal 6 Hive Integrity.
1. **Smoke Screen** | 1 | Architect | Uncommon | One threat skips its next strike (countdown +2).
1. **Resin Trap** | 1 | Architect | Common | A threat that strikes next turn takes 8 damage first.
1. **Synchronize** | 2 | Architect | Rare | Cards that gain Block this turn gain +3 Block.
1. **Overwinter** | 3 | Architect | Rare | Convert all current Block into Honey at end of turn.
1. **Drone Sacrifice** | 0 | Architect | Uncommon | Lose 3 Hive Integrity. Gain 3 Pollen.
1. **Spring Bloom** | 3 | Architect | Rare | Heal 4. Gain 4 Pollen. Draw 2. (One-shot exhaust card.)

### Starting deck (10 cards)

5× Sting, 3× Wax Wall, 1× Forage, 1× Scout.

### Meta-locked cards (unlock with Honey)

Suggest locking these 6 behind cumulative Honey thresholds:
Frenzy, Worker Shift, Hive Mind, Pheromone Strike, Synchronize, Spring Bloom.

-----

## 4. Threat list (11 types)

Format: **Name** | HP | Damage | Countdown | Behavior

1. **Scout Wasp** | 6 | 4 | 1 | Basic. Strikes fast.
1. **Soldier Wasp** | 12 | 7 | 2 | Standard heavy hitter.
1. **Frost Mite** | 8 | 3 | 2 | On strike, also drains 1 Pollen next turn.
1. **Beetle** | 20 | 5 | 3 | Armor 2 (reduces each instance of damage by 2).
1. **Hornet** | 10 | 9 | 2 | High burst. Low HP — priority kill.
1. **Spider** | 14 | 4 | 2 | On strike, applies Web (you draw 1 fewer next turn).
1. **Wax Moth** | 9 | 2 | 1 | Each turn alive, eats 2 Honey from your stash.
1. **Drone Fly (swarm)** | 4 | 2 | 1 | Spawns 2 copies at once. Cheap but numerous.
1. **Frost Wave** | 0 | 6 | 3 | Untargetable event-threat; only Block stops it.
1. **Mantis** | 24 | 11 | 4 | Mini-boss. Slow but devastating. Appears wave 6+.
1. **The Cold (boss)** | 40 | 8 | 3 | Final wave. Gains +2 damage each turn it survives.

-----

## 5. Wave structure (8-wave night, prototype)

|Wave|Threats                     |Notes                         |
|----|----------------------------|------------------------------|
|1   |1× Scout Wasp               |Tutorial-easy onboarding      |
|2   |1× Scout Wasp, 1× Frost Mite|Introduce Pollen drain        |
|3   |1× Soldier Wasp, 1× Beetle  |Introduce armor/tanky         |
|4   |2× Drone Fly, 1× Hornet     |Multi-target pressure         |
|5   |1× Spider, 1× Wax Moth      |Status + economy threat       |
|6   |1× Mantis, 1× Frost Wave    |Mini-boss spike               |
|7   |2× Soldier Wasp, 1× Hornet  |Sustained pressure before boss|
|8   |The Cold (boss)             |Climax — escalating damage    |

**Difficulty scaling for later nights (post-prototype):** add +1 to threat HP
and damage per night cleared, introduce an extra threat per wave, and let
the boss start with +1 damage per prior night.

-----

## 6. Relics (4 for prototype)

Passive modifiers, chosen at the start of a run.

1. **Sturdy Comb** — Start each night with +5 max Hive Integrity.
1. **Rich Nectar** — Gain +1 Pollen at the start of every turn.
1. **Sharp Stingers** — All Stinger cards deal +2 damage.
1. **Honey Reserve** — Start each night with 10 Honey banked.

Unlock additional relics with meta-progression later. Relics should feel
build-defining, not just stat bumps — these four each nudge toward a different
archetype (defense, economy, aggression, scoring).

-----

## 7. Meta-progression (between nights)

- **Honey is the meta-currency.** Honey earned during runs banks to a
  persistent total (separate from in-run Honey, or carried over — your call;
  carrying over a fraction, e.g. 25%, is a clean default).
- **Unlock track:** spend banked Honey to permanently unlock the 6 locked
  cards and additional relics.
- **Suggested unlock costs (banked Honey):** 50, 80, 120, 160, 220, 300.
- Save all progress locally.

-----

## 8. Balance philosophy (notes for tuning)

- The prototype should be **winnable but not trivial** with the starting deck
  after a few attempts. Target a ~30–40% win rate for a new player by night’s
  end once they understand the loop.
- Pollen economy is the central tension: 3 base Pollen forces hard choices
  between offense, defense, and economy each turn.
- Block not carrying over (by default) keeps each wave a fresh puzzle.
- All numbers here are **first-pass guesses**. Expect to retune costs, HP,
  and damage heavily once the loop is playable — this is the part only
  hands-on playtesting can resolve.