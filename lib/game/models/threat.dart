/// Threat models: a static [ThreatDef] (data) and a runtime [ThreatInstance].
///
/// Pure Dart — no Flutter imports. Threats are defined as data in
/// `lib/game/data/threats_data.dart`.

class ThreatDef {
  final String id;
  final String name;
  final int maxHp;
  final int damage;

  /// Turns until the threat strikes. Decremented at end of each turn; once it
  /// reaches 0 the threat strikes every turn until killed (or removed).
  final int countdown;

  /// Flat damage reduction applied to each instance of damage taken.
  final int armor;

  /// Untargetable threats can't be damaged (only Block stops their strike).
  /// They are removed after striking once (event-style threats).
  final bool untargetable;

  /// On strike, drains this much Pollen from the player next turn.
  final int drainPollenOnStrike;

  /// On strike, reduces the player's next draw by this many cards (Web).
  final int webOnStrike;

  /// Each turn alive, removes this much Honey from the player's stash.
  final int honeyDrainPerTurn;

  /// Each turn the threat survives, its damage increases by this much (boss).
  final int damageRampPerTurn;

  final String description;

  const ThreatDef({
    required this.id,
    required this.name,
    required this.maxHp,
    required this.damage,
    required this.countdown,
    this.armor = 0,
    this.untargetable = false,
    this.drainPollenOnStrike = 0,
    this.webOnStrike = 0,
    this.honeyDrainPerTurn = 0,
    this.damageRampPerTurn = 0,
    this.description = '',
  });
}

class ThreatInstance {
  /// Unique per-run instance id (distinguishes duplicate spawns).
  final int instanceId;
  final ThreatDef def;

  int hp;
  int damage;
  int countdown;

  /// Active Venom: HP lost each turn.
  int venom;

  ThreatInstance({
    required this.instanceId,
    required this.def,
    required this.hp,
    required this.damage,
    required this.countdown,
    this.venom = 0,
  });

  factory ThreatInstance.fromDef(ThreatDef def, int instanceId) =>
      ThreatInstance(
        instanceId: instanceId,
        def: def,
        hp: def.maxHp,
        damage: def.damage,
        countdown: def.countdown,
      );

  bool get isDead => !def.untargetable && hp <= 0;

  /// Whether the player can target this threat with damage.
  bool get targetable => !def.untargetable;

  /// True if it will strike at the next end-of-turn resolution.
  bool get willStrike => countdown <= 0;

  ThreatInstance clone() => ThreatInstance(
        instanceId: instanceId,
        def: def,
        hp: hp,
        damage: damage,
        countdown: countdown,
        venom: venom,
      );
}
