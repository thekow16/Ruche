/// The 4 prototype relics from the design spec, expressed as data.
///
/// Pure Dart — no Flutter imports.
import '../models/relic.dart';

class RelicLibrary {
  RelicLibrary._();

  static const List<Relic> all = [
    Relic(
      id: 'sturdy_comb',
      name: 'Sturdy Comb',
      description: 'Start each night with +5 max Hive Integrity.',
      bonusMaxIntegrity: 5,
    ),
    Relic(
      id: 'rich_nectar',
      name: 'Rich Nectar',
      description: 'Gain +1 Pollen at the start of every turn.',
      bonusPollenPerTurn: 1,
    ),
    Relic(
      id: 'sharp_stingers',
      name: 'Sharp Stingers',
      description: 'All Stinger cards deal +2 damage.',
      stingerDamageBonus: 2,
    ),
    Relic(
      id: 'honey_reserve',
      name: 'Honey Reserve',
      description: 'Start each night with 10 Honey banked.',
      startingHoney: 10,
    ),
  ];

  static final Map<String, Relic> byId = {
    for (final r in all) r.id: r,
  };

  static Relic get(String id) {
    final r = byId[id];
    if (r == null) throw ArgumentError('Unknown relic id: $id');
    return r;
  }
}
