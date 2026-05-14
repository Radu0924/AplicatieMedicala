import 'package:flutter/material.dart';

import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Surface card with a subtle border, rounded-xl radius and an optional
/// shadow. Mirrors the `bg-surface rounded-xl border + box-shadow` pattern
/// used throughout the Stitch designs.
class InfoCard extends StatefulWidget {
  const InfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.background,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.gradient,
    this.boxShadow = AppShadows.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final List<BoxShadow> boxShadow;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadius.xl);
    final cs = Theme.of(context).colorScheme;

    final bg = widget.background ?? cs.surfaceContainerLowest;
    final border = widget.borderColor ?? cs.outlineVariant;

    final container = AnimatedScale(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      scale: _pressed ? 0.985 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: widget.gradient == null ? bg : null,
          gradient: widget.gradient,
          borderRadius: radius,
          border: Border.all(color: border),
          boxShadow: widget.boxShadow,
        ),
        padding: widget.padding,
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return container;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: container,
    );
  }
}
