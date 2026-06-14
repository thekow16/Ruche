import 'package:flutter/material.dart';

import '../game/models/enums.dart';

/// HIVE visual identity: warm honey/amber on deep brown.
class HiveColors {
  static const Color background = Color(0xFF2B1D0E);
  static const Color surface = Color(0xFF3A2814);
  static const Color amber = Color(0xFFE8A100);
  static const Color paleHoney = Color(0xFFF5D67B);
  static const Color danger = Color(0xFFB23A2E);
  static const Color comb = Color(0xFF5A3F1E);

  static Color forType(CardType type) => switch (type) {
        CardType.defender => const Color(0xFF6FA3C7),
        CardType.stinger => danger,
        CardType.worker => amber,
        CardType.architect => const Color(0xFFB07FD0),
      };
}

class HiveTheme {
  static ThemeData build() {
    const base = HiveColors.background;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: base,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: HiveColors.amber,
        secondary: HiveColors.paleHoney,
        surface: HiveColors.surface,
        error: HiveColors.danger,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: HiveColors.paleHoney,
          fontWeight: FontWeight.w800,
          letterSpacing: 4,
        ),
        titleLarge: TextStyle(
          color: HiveColors.paleHoney,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: HiveColors.paleHoney),
        labelLarge: TextStyle(color: HiveColors.background, fontWeight: FontWeight.w700),
      ),
    );
  }
}
