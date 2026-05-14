import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Elevation tokens — translate the polished HTML mockup shadows 1:1 into
/// Flutter [BoxShadow] lists. Compose with `BoxDecoration(boxShadow: ...)`.
class AppShadows {
  AppShadows._();

  /// Subtle card lift — used on every surface card in the design.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F0F172A), // slate-900 @ ~6%
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x080F172A), // slate-900 @ ~3%
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Raised — primary status card, login form card, alert info panel.
  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x140F172A), // ~8%
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // ~4%
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Colored glow around the primary CTA (black button + blue tint).
  static List<BoxShadow> primary({Color tint = AppColors.secondary}) => [
    BoxShadow(
      color: tint.withValues(alpha: 0.28),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    const BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Hot glow used on alert icon containers and critical CTAs.
  static List<BoxShadow> glow(Color color, {double intensity = 0.45}) => [
    BoxShadow(
      color: color.withValues(alpha: intensity),
      blurRadius: 28,
      spreadRadius: 2,
      offset: const Offset(0, 0),
    ),
  ];

  /// White button on a colored background (alert screen).
  static const List<BoxShadow> onColored = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
