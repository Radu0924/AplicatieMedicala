import 'package:flutter/material.dart';

/// MedGuard color tokens.
///
/// Single source of truth for color values used across the app. Keep values
/// in sync with `stitch_design_system_implementation/medguard_design_system/DESIGN.md`.
class AppColors {
  AppColors._();

  // Surface & background scale
  static const Color surface = Color(0xFFFCF8FA);
  static const Color surfaceDim = Color(0xFFDCD9DB);
  static const Color surfaceBright = Color(0xFFFCF8FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F5);
  static const Color surfaceContainer = Color(0xFFF0EDEF);
  static const Color surfaceContainerHigh = Color(0xFFEAE7E9);
  static const Color surfaceContainerHighest = Color(0xFFE4E2E4);
  static const Color surfaceVariant = Color(0xFFE4E2E4);
  static const Color surfaceMuted = Color(0xFFF8FAFC);

  // Foreground on surface
  static const Color onSurface = Color(0xFF1B1B1D);
  static const Color onSurfaceVariant = Color(0xFF45464D);
  static const Color inverseSurface = Color(0xFF303032);
  static const Color inverseOnSurface = Color(0xFFF3F0F2);

  // Outlines
  static const Color outline = Color(0xFF76777D);
  static const Color outlineVariant = Color(0xFFC6C6CD);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  // Primary
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF131B2E);
  static const Color onPrimaryContainer = Color(0xFF7C839B);
  static const Color inversePrimary = Color(0xFFBEC6E0);

  // Secondary
  static const Color secondary = Color(0xFF0051D5);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF316BF3);
  static const Color onSecondaryContainer = Color(0xFFFEFCFF);

  // Tertiary
  static const Color tertiary = Color(0xFF000000);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF271901);
  static const Color onTertiaryContainer = Color(0xFF98805D);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Status — semantic colors used across the app for OK / WARNING / CRITICAL
  static const Color statusOk = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusCritical = Color(0xFFEF4444);

  // Misc text helpers
  static const Color textDimmed = Color(0xFF64748B);

  // Background
  static const Color background = Color(0xFFFCF8FA);
  static const Color onBackground = Color(0xFF1B1B1D);

  // Surface-tint used by Material 3 for elevation overlays
  static const Color surfaceTint = Color(0xFF565E74);

  /// Returns a transparent variant of [color] at the given alpha 0..1.
  /// Used to mirror the Tailwind `/10`, `/20` color modifiers from the design.
  static Color tint(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
