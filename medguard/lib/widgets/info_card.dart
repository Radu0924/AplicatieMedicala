import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Surface card with a subtle border and rounded-xl radius. Mirrors the
/// `bg-surface rounded-xl border border-border-subtle` pattern used
/// throughout the Stitch designs.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.background = AppColors.surface,
    this.borderColor = AppColors.borderSubtle,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color background;
  final Color borderColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.xl);
    final container = Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(color: borderColor),
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: container,
      ),
    );
  }
}
