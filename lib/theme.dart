import 'package:flutter/material.dart';

/// Visual preset: CANDY_SWEET (accents overridden for the Royal Fruits brief).
class AppPalette {
  const AppPalette._();

  static const String name = 'CANDY_SWEET';

  static const Color cream = Color(0xFFFFF2DB);
  static const Color creamTint = Color(0xFFF7E6C8);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color berry = Color(0xFFEF5965);
  static const Color gold = Color(0xFFF8C845);
  static const Color leaf = Color(0xFF56C378);
  static const Color sky = Color(0xFF58AEE0);
  static const Color royal = Color(0xFF5B3D83);

  static const Color loaderTop = Color(0xFF3A2456);
  static const Color loaderBottom = Color(0xFF2A1A42);

  /// Alpha helper so surfaces stay consistent across screens.
  static Color royalA(double o) => royal.withValues(alpha: o);
  static Color creamA(double o) => cream.withValues(alpha: o);
  static Color surfaceA(double o) => surface.withValues(alpha: o);
}

class AppTheme {
  const AppTheme._();

  /// Canonical preset name — must stay one of the 10 workspace presets.
  static const String name = AppPalette.name;

  static const List<FontFeature> tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static ThemeData build() {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppPalette.royal,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppPalette.berry,
          onPrimary: AppPalette.cream,
          secondary: AppPalette.gold,
          onSecondary: AppPalette.royal,
          tertiary: AppPalette.leaf,
          surface: AppPalette.cream,
          onSurface: AppPalette.royal,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.cream,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.0,
          color: AppPalette.cream,
        ),
        headlineMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
          color: AppPalette.royal,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.8,
          color: AppPalette.royal,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppPalette.royal,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: AppPalette.royal,
        ),
      ),
    );
  }
}
