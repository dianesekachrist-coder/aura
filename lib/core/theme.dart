// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuraTheme {
  // Brand colors
  static const Color primary = Color(0xFFB388FF); // Soft violet
  static const Color primaryDark = Color(0xFF7C4DFF); // Deep violet
  static const Color accent = Color(0xFF64FFDA); // Mint accent
  static const Color surface = Color(0xFF121218); // Near-black
  static const Color surfaceCard = Color(0xFF1E1E2A); // Card bg
  static const Color surfaceElevated = Color(0xFF252535);
  static const Color onSurface = Color(0xFFF5F5FF);
  static const Color onSurfaceMuted = Color(0xFF8888AA);
  static const Color divider = Color(0xFF2A2A3E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.dark().textTheme.copyWith(
              displayLarge: const TextStyle(
                color: onSurface,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              titleLarge: const TextStyle(
                color: onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: const TextStyle(
                color: onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              bodyMedium: const TextStyle(
                color: onSurfaceMuted,
                fontSize: 14,
              ),
              labelSmall: const TextStyle(
                color: onSurfaceMuted,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceCard,
        indicatorColor: primary.withOpacity(0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return GoogleFonts.dmSans(
            fontSize: 11,
            color: onSurfaceMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: onSurfaceMuted, size: 22);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withOpacity(0.2),
        thumbColor: Colors.white,
        overlayColor: primary.withOpacity(0.15),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      iconTheme: const IconThemeData(color: onSurface),
      dividerColor: divider,
    );
  }
}
