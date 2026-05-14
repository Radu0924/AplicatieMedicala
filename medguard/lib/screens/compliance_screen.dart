import 'package:flutter/material.dart';

import '../data/mock_repository.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/info_card.dart';
import '../widgets/status_badge.dart';

class ComplianceScreen extends StatelessWidget {
  const ComplianceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository.instance;
    final overview = repo.complianceOverview;
    final checks = repo.getComplianceChecks();
    final metrics = repo.metrics;

    return Scaffold(

      appBar: AppBar(
        title: const Text('Conformitate PoC'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.containerMargin,
          AppSpacing.sectionPadding,
          AppSpacing.containerMargin,
          AppSpacing.xl,
        ),
        children: [
          Text(
            'SUMAR',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textDimmed,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.05,
            children: [
              _SummaryTile(
                label: 'Conforme',
                value: '${overview.compliant}',
                color: AppColors.statusOk,
              ),
              _SummaryTile(
                label: 'Incalcari',
                value: '${overview.violations}',
                color: AppColors.statusCritical,
              ),
              _SummaryTile(
                label: 'Insuficient',
                value: '${overview.insufficientData}',
                color: AppColors.statusWarning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl + 4),
          InfoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Context log',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Interval analizat: ${_formatDateTime(metrics.firstTimestamp)} - '
                  '${_formatDateTime(metrics.lastTimestamp)}',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textDimmed,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Evenimente: ${metrics.totalLines}  |  Temperaturi: '
                  '${metrics.tempReadingCount}',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textDimmed,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl + 4),
          Text(
            'VERIFICARI',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textDimmed,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...checks.map(_ComplianceCheckCard.new),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime timestamp) {
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final hh = timestamp.hour.toString().padLeft(2, '0');
    final mm = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month $hh:$mm';
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTypography.headlineLg.copyWith(
              color: color,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textDimmed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceCheckCard extends StatelessWidget {
  const _ComplianceCheckCard(this.check);

  final ComplianceCheck check;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InfoCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${check.id}  ${check.title}',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusBadge(
                  label: check.state.romanianLabel,
                  color: check.state.status.color,
                  icon: check.state.status.icon,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              check.detail,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textDimmed,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
