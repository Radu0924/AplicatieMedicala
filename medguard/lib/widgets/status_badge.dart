import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Three operational states drive most of the mobile UX.
enum DeviceStatus { ok, warning, critical }

extension DeviceStatusUi on DeviceStatus {
  Color get color {
    switch (this) {
      case DeviceStatus.ok:
        return AppColors.statusOk;
      case DeviceStatus.warning:
        return AppColors.statusWarning;
      case DeviceStatus.critical:
        return AppColors.statusCritical;
    }
  }

  IconData get icon {
    switch (this) {
      case DeviceStatus.ok:
        return Symbols.check_circle;
      case DeviceStatus.warning:
        return Symbols.warning;
      case DeviceStatus.critical:
        return Symbols.error;
    }
  }

  String get romanianLabel {
    switch (this) {
      case DeviceStatus.ok:
        return 'STARE OK';
      case DeviceStatus.warning:
        return 'ATENȚIE';
      case DeviceStatus.critical:
        return 'ALERTĂ CRITICĂ';
    }
  }
}

/// Filled / outlined badge variants used across the design.
enum StatusBadgeVariant { filled, soft }

/// A small label with an icon — used for device status, online/offline,
/// door open/closed, sensor states, etc.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.variant = StatusBadgeVariant.soft,
  });

  /// Convenience: build a badge from the canonical [DeviceStatus] palette.
  factory StatusBadge.fromStatus(
    DeviceStatus status, {
    String? overrideLabel,
    StatusBadgeVariant variant = StatusBadgeVariant.soft,
  }) {
    return StatusBadge(
      label: overrideLabel ?? status.romanianLabel,
      color: status.color,
      icon: status.icon,
      variant: variant,
    );
  }

  final String label;
  final Color color;
  final IconData? icon;
  final StatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == StatusBadgeVariant.filled;
    final background = isFilled ? color : AppColors.tint(color, 0.10);
    final foreground = isFilled ? AppColors.onPrimary : color;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg / 2 + 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground, fill: 1),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
