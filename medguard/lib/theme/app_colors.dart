import 'package:flutter/material.dart';

import 'theme_notifier.dart';

/// MedGuard color tokens.
///
/// Tokens that change between light/dark are exposed as getters that read the
/// global [themeNotifier]. The app rebuilds on theme switch, so getters
/// re-evaluate naturally — widgets that reference `AppColors.xxx` directly
/// stay in sync without any change.
class AppColors {
  AppColors._();

  static bool get _isDark => themeNotifier.value == ThemeMode.dark;
  static Color _pick(Color light, Color dark) => _isDark ? dark : light;

  // Surface & background scale
  static Color get surface =>
      _pick(const Color(0xFFFCF8FA), const Color(0xFF1A1D26));
  static Color get surfaceDim =>
      _pick(const Color(0xFFDCD9DB), const Color(0xFF0D1017));
  static Color get surfaceBright =>
      _pick(const Color(0xFFFCF8FA), const Color(0xFF252840));
  static Color get surfaceContainerLowest =>
      _pick(const Color(0xFFFFFFFF), const Color(0xFF1E2130));
  static Color get surfaceContainerLow =>
      _pick(const Color(0xFFF6F3F5), const Color(0xFF222636));
  static Color get surfaceContainer =>
      _pick(const Color(0xFFF0EDEF), const Color(0xFF252840));
  static Color get surfaceContainerHigh =>
      _pick(const Color(0xFFEAE7E9), const Color(0xFF292D45));
  static Color get surfaceContainerHighest =>
      _pick(const Color(0xFFE4E2E4), const Color(0xFF2D3150));
  static Color get surfaceVariant =>
      _pick(const Color(0xFFE4E2E4), const Color(0xFF252840));
  static Color get surfaceMuted =>
      _pick(const Color(0xFFF8FAFC), const Color(0xFF1E2130));

  // Foreground on surface
  static Color get onSurface =>
      _pick(const Color(0xFF1B1B1D), const Color(0xFFE2E6F2));
  static Color get onSurfaceVariant =>
      _pick(const Color(0xFF45464D), const Color(0xFF8B95B2));
  static Color get inverseSurface =>
      _pick(const Color(0xFF303032), const Color(0xFFE2E6F2));
  static Color get inverseOnSurface =>
      _pick(const Color(0xFFF3F0F2), const Color(0xFF1E2130));

  // Outlines
  static Color get outline =>
      _pick(const Color(0xFF76777D), const Color(0xFF555D7A));
  static Color get outlineVariant =>
      _pick(const Color(0xFFC6C6CD), const Color(0xFF2C3048));
  static Color get borderSubtle =>
      _pick(const Color(0xFFE2E8F0), const Color(0xFF2C3048));

  // Primary (black button on light, white button on dark)
  static Color get primary =>
      _pick(const Color(0xFF000000), const Color(0xFFFFFFFF));
  static Color get onPrimary =>
      _pick(const Color(0xFFFFFFFF), const Color(0xFF111318));
  static Color get primaryContainer =>
      _pick(const Color(0xFF131B2E), const Color(0xFF1C2540));
  static Color get onPrimaryContainer =>
      _pick(const Color(0xFF7C839B), const Color(0xFF8B95B2));
  static Color get inversePrimary =>
      _pick(const Color(0xFFBEC6E0), const Color(0xFF444B60));

  // Secondary — blue accent, kept const since it reads well in both modes.
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
  static Color get errorContainer =>
      _pick(const Color(0xFFFFDAD6), const Color(0xFF5C1F1F));
  static Color get onErrorContainer =>
      _pick(const Color(0xFF93000A), const Color(0xFFFFB3B3));

  // Status — semantic colors, identical across themes (icons + chips).
  static const Color statusOk = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusCritical = Color(0xFFEF4444);

  // Misc text helpers
  static Color get textDimmed =>
      _pick(const Color(0xFF64748B), const Color(0xFF8B95B2));

  // Background
  static Color get background =>
      _pick(const Color(0xFFFCF8FA), const Color(0xFF111318));
  static Color get onBackground =>
      _pick(const Color(0xFF1B1B1D), const Color(0xFFE2E6F2));

  // Surface-tint used by Material 3 for elevation overlays
  static Color get surfaceTint =>
      _pick(const Color(0xFF565E74), const Color(0xFF5B9BF2));

  /// Returns a transparent variant of [color] at the given alpha 0..1.
  static Color tint(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
