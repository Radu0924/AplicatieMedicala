import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// MedGuard typography tokens. Inter, five named text styles.
///
/// Flutter's `height` is a multiplier of fontSize, so we derive it from the
/// design tokens' explicit pixel lineHeight (e.g. 72/64 = 1.125 for display-temp).
class AppTypography {
  AppTypography._();

  static TextStyle get displayTemp => GoogleFonts.inter(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        height: 72 / 64,
        letterSpacing: -0.02 * 64,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLg => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        color: AppColors.onSurface,
      );

  static TextStyle get statusLabel => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 24 / 18,
        letterSpacing: 0.05 * 18,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.02 * 12,
        color: AppColors.textDimmed,
      );

  /// Material TextTheme built from the design system tokens. Maps the five
  /// named styles to the closest Material slots so widgets that read from
  /// `Theme.of(context).textTheme` get sane defaults.
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayTemp,
        displayMedium: displayTemp.copyWith(fontSize: 48, height: 56 / 48),
        headlineLarge: headlineLg,
        headlineMedium: headlineLg.copyWith(fontSize: 20, height: 28 / 20),
        titleLarge: headlineLg.copyWith(fontSize: 18, height: 24 / 18),
        titleMedium: statusLabel,
        titleSmall: statusLabel.copyWith(fontSize: 14, height: 20 / 14),
        bodyLarge: bodyMd,
        bodyMedium: bodyMd,
        bodySmall: bodyMd.copyWith(fontSize: 14, height: 20 / 14),
        labelLarge: bodyMd.copyWith(fontWeight: FontWeight.w600),
        labelMedium: labelSm,
        labelSmall: labelSm,
      );
}
