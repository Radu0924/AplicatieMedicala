/// Spacing and radius tokens for the MedGuard design system.
///
/// Values mirror the Stitch HTML implementation (which uses a slightly
/// trimmed scale compared to the original DESIGN.md frontmatter). 1rem = 16px.
class AppSpacing {
  AppSpacing._();

  // Spacing scale (named tokens from the design system)
  static const double containerMargin = 20.0; // 1.25rem
  static const double stackGap = 16.0; // 1rem
  static const double sectionPadding = 24.0; // 1.5rem
  static const double touchTarget = 48.0; // 3rem

  // Generic spacing helpers (not in the DS but useful for compositions)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// Radius tokens — match the Stitch HTML config.
class AppRadius {
  AppRadius._();

  static const double base = 4.0; // 0.25rem (DEFAULT)
  static const double lg = 8.0; // 0.5rem
  static const double xl = 12.0; // 0.75rem
  static const double full = 9999.0;
}
