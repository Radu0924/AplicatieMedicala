import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradient tokens used for the primary status card and the critical alert
/// background. Translates the HTML `linear-gradient` / `radial-gradient`
/// directly to Flutter's gradient primitives.
class AppGradients {
  AppGradients._();

  /// Subtle blue-tinted gradient for the primary status card surface.
  /// Resolves per-theme so the card stays legible in dark mode.
  static LinearGradient get primaryStatus => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surfaceContainerLowest,
          AppColors.tint(AppColors.secondary, 0.06),
        ],
      );

  /// Darker tinted variant — used when status is OK and we want a calmer feel.
  static LinearGradient statusOkSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surfaceMuted,
      AppColors.tint(AppColors.statusOk, 0.06),
    ],
  );

  /// Radial gradient behind the critical alert — F87171 center → DC2626 edges.
  static const RadialGradient alertCritical = RadialGradient(
    center: Alignment.center,
    radius: 1.1,
    colors: [
      Color(0xFFF87171), // red-400
      Color(0xFFDC2626), // red-600
    ],
    stops: [0.0, 1.0],
  );
}
