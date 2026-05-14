import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Full-width primary CTA — adds tap scale feedback, colored shadow, and an
/// optional inline spinner while [loading] is true.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.background,
    this.foreground,
    this.expand = true,
    this.loading = false,
    this.shadow,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? background;
  final Color? foreground;
  final bool expand;
  final bool loading;

  /// Defaults to a blue-tinted glow under a black button (matches HTML mockup).
  /// Pass `[]` to disable the shadow entirely.
  final List<BoxShadow>? shadow;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    final background = widget.background ?? AppColors.primary;
    final foreground = widget.foreground ?? AppColors.onPrimary;
    final bg = disabled ? AppColors.tint(background, 0.55) : background;
    final shadow = disabled
        ? const <BoxShadow>[]
        : (widget.shadow ?? AppShadows.primary());

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 22, color: foreground),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMd.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );

    final button = AnimatedScale(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      scale: _pressed ? 0.97 : 1.0,
      child: Container(
        height: AppSpacing.touchTarget + 8,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: shadow,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: content,
      ),
    );

    final gesture = GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: disabled ? null : widget.onPressed,
      child: button,
    );

    return widget.expand ? SizedBox(width: double.infinity, child: gesture) : gesture;
  }
}
