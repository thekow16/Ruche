/// The 8-wave night structure from the design spec, expressed as data.
///
/// Pure Dart — no Flutter imports.
import '../models/wave.dart';

class WaveLibrary {
  WaveLibrary._();

  static const int wavesPerNight = 8;

  static const List<WaveDef> night = [
    WaveDef(
      number: 1,
      spawns: [ThreatSpawn('scout_wasp')],
      note: 'Tutorial-easy onboarding',
    ),
    WaveDef(
      number: 2,
      spawns: [ThreatSpawn('scout_wasp'), ThreatSpawn('frost_mite')],
      note: 'Introduce Pollen drain',
    ),
    WaveDef(
      number: 3,
      spawns: [ThreatSpawn('soldier_wasp'), ThreatSpawn('beetle')],
      note: 'Introduce armor/tanky',
    ),
    WaveDef(
      number: 4,
      spawns: [ThreatSpawn('drone_fly', 2), ThreatSpawn('hornet')],
      note: 'Multi-target pressure',
    ),
    WaveDef(
      number: 5,
      spawns: [ThreatSpawn('spider'), ThreatSpawn('wax_moth')],
      note: 'Status + economy threat',
    ),
    WaveDef(
      number: 6,
      spawns: [ThreatSpawn('mantis'), ThreatSpawn('frost_wave')],
      note: 'Mini-boss spike',
    ),
    WaveDef(
      number: 7,
      spawns: [ThreatSpawn('soldier_wasp', 2), ThreatSpawn('hornet')],
      note: 'Sustained pressure before boss',
    ),
    WaveDef(
      number: 8,
      spawns: [ThreatSpawn('the_cold')],
      note: 'Climax — escalating damage',
    ),
  ];

  static WaveDef forWave(int number) =>
      night.firstWhere((w) => w.number == number);
}
