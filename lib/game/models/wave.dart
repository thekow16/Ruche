/// Wave structure model.
///
/// Pure Dart — no Flutter imports. Waves are defined as data in
/// `lib/game/data/waves_data.dart`.

/// A number of copies of a given threat to spawn in a wave.
class ThreatSpawn {
  final String threatId;
  final int count;
  const ThreatSpawn(this.threatId, [this.count = 1]);
}

class WaveDef {
  /// 1-based wave number.
  final int number;
  final List<ThreatSpawn> spawns;
  final String note;

  const WaveDef({
    required this.number,
    required this.spawns,
    this.note = '',
  });
}
