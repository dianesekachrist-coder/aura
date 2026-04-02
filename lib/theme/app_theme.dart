// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const teal = Color(0xFF00BCD4);
  static const tealDark = Color(0xFF006064);
  static const background = Color(0xFF0A0E14);
  static const surface = Color(0xFF131820);
  static const surfaceCard = Color(0xFF1C2533);
  static const textPrimary = Color(0xFFECF0F8);
  static const textSub = Color(0xFF7A8AA0);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: teal,
          secondary: tealDark,
          surface: surface,
          onSurface: textPrimary,
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: teal,
          inactiveTrackColor: textSub.withOpacity(0.3),
          thumbColor: teal,
          overlayColor: teal.withOpacity(0.15),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.5),
          titleLarge: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
          bodySmall: TextStyle(fontSize: 12, color: textSub),
          labelSmall: TextStyle(fontSize: 11, color: textSub),
        ),
      );
}
