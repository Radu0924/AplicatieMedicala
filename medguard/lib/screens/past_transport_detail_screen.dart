import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/info_card.dart';

/// Screen 8 - Detaliu sesiune arhivata.
class PastTransportDetailScreen extends StatelessWidget {
  const PastTransportDetailScreen({
    super.key,
    required this.transportId,
  });

  final String transportId;

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository.instance;
    final metrics = repo.metrics;
    final overview = repo.complianceOverview;
    final transport = repo.getPastTransports().firstWhere(
          (item) => item.id == transportId,
          orElse: () => repo.getPastTransports().first,
        );

    final duration = transport.endedAt!.difference(transport.startedAt);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.containerMargin,
          AppSpacing.sectionPadding,
          AppSpacing.containerMargin,
          AppSpacing.xl,
        ),
        children: [
          Text(
            MockRepository.sampleDevice.code,
            style: AppTypography.headlineLg,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sesiune PoC arhivata din logul local',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textDimmed,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                Text(
                  'ARHIVAT',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.statusOk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Durata redarii: ${duration.inHours}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}m',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl + 4),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.2,
            children: [
              _SummaryTile(
                label: 'START',
                value: _formatDateTime(metrics.firstTimestamp),
                icon: Symbols.login,
              ),
              _SummaryTile(
                label: 'FINAL',
                value: _formatDateTime(metrics.lastTimestamp),
                icon: Symbols.logout,
              ),
              _SummaryTile(
                label: 'EVENIMENTE',
                value: '${metrics.totalLines}',
                icon: Symbols.numbers,
              ),
              _SummaryTile(
                label: 'CITIRI PESTE LIMITA',
                value: '${metrics.overLimitTemperatureCount}',
                icon: Symbols.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl + 4),
          _NotesSection(
            violations: overview.violations,
            insufficientData: overview.insufficientData,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime timestamp) {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final hh = timestamp.hour.toString().padLeft(2, '0');
    final mm = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month $hh:$mm';
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textDimmed,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Icon(icon, color: AppColors.primary, size: 24, fill: 1),
          Text(
            value,
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({
    required this.violations,
    required this.insufficientData,
  });

  final int violations;
  final int insufficientData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONCLUZIE',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.textDimmed,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        InfoCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    violations == 0 ? Symbols.check_circle : Symbols.warning,
                    color: violations == 0
                        ? AppColors.statusOk
                        : AppColors.statusCritical,
                    size: 20,
                    fill: 1,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    violations == 0
                        ? 'Fara incalcari detectate'
                        : '$violations reguli incalcate',
                    style: AppTypography.bodyMd.copyWith(
                      color: violations == 0
                          ? AppColors.statusOk
                          : AppColors.statusCritical,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sesiunea foloseste exclusiv logul local. '
                '$insufficientData reguli nu pot fi demonstrate complet doar din acest fisier.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textDimmed,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
