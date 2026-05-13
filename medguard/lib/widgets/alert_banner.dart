import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AlertBanner extends StatelessWidget {
  const AlertBanner({super.key, required this.alert});
  final AlertType alert;

  @override
  Widget build(BuildContext context) {
    if (alert == AlertType.none) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.statusCritical,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerMargin,
        vertical: AppSpacing.sm,
      ),
      child: SafeArea(
        bottom: false,
        child: Text(
          alert.romanianMessage,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
