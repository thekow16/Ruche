/// The 11 prototype threats from the design spec, expressed as data.
///
/// Pure Dart — no Flutter imports.
import '../models/threat.dart';

class ThreatLibrary {
  ThreatLibrary._();

  static const List<ThreatDef> all = [
    ThreatDef(
      id: 'scout_wasp',
      name: 'Scout Wasp',
      maxHp: 6,
      damage: 4,
      countdown: 1,
      description: 'Basic. Strikes fast.',
    ),
    ThreatDef(
      id: 'soldier_wasp',
      name: 'Soldier Wasp',
      maxHp: 12,
      damage: 7,
      countdown: 2,
      description: 'Standard heavy hitter.',
    ),
    ThreatDef(
      id: 'frost_mite',
      name: 'Frost Mite',
      maxHp: 8,
      damage: 3,
      countdown: 2,
      drainPollenOnStrike: 1,
      description: 'On strike, also drains 1 Pollen next turn.',
    ),
    ThreatDef(
      id: 'beetle',
      name: 'Beetle',
      maxHp: 20,
      damage: 5,
      countdown: 3,
      armor: 2,
      description: 'Armor 2 (reduces each instance of damage by 2).',
    ),
    ThreatDef(
      id: 'hornet',
      name: 'Hornet',
      maxHp: 10,
      damage: 9,
      countdown: 2,
      description: 'High burst. Low HP — priority kill.',
    ),
    ThreatDef(
      id: 'spider',
      name: 'Spider',
      maxHp: 14,
      damage: 4,
      countdown: 2,
      webOnStrike: 1,
      description: 'On strike, applies Web (you draw 1 fewer next turn).',
    ),
    ThreatDef(
      id: 'wax_moth',
      name: 'Wax Moth',
      maxHp: 9,
      damage: 2,
      countdown: 1,
      honeyDrainPerTurn: 2,
      description: 'Each turn alive, eats 2 Honey from your stash.',
    ),
    ThreatDef(
      id: 'drone_fly',
      name: 'Drone Fly',
      maxHp: 4,
      damage: 2,
      countdown: 1,
      description: 'Swarm. Cheap but numerous.',
    ),
    ThreatDef(
      id: 'frost_wave',
      name: 'Frost Wave',
      maxHp: 0,
      damage: 6,
      countdown: 3,
      untargetable: true,
      description: 'Untargetable event — only Block stops it.',
    ),
    ThreatDef(
      id: 'mantis',
      name: 'Mantis',
      maxHp: 24,
      damage: 11,
      countdown: 4,
      description: 'Mini-boss. Slow but devastating.',
    ),
    ThreatDef(
      id: 'the_cold',
      name: 'The Cold',
      maxHp: 40,
      damage: 8,
      countdown: 3,
      damageRampPerTurn: 2,
      description: 'Final boss. Gains +2 damage each turn it survives.',
    ),
  ];

  static final Map<String, ThreatDef> byId = {
    for (final t in all) t.id: t,
  };

  static ThreatDef get(String id) {
    final t = byId[id];
    if (t == null) throw ArgumentError('Unknown threat id: $id');
    return t;
  }
}
