import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/info_card.dart';

/// Screen 10 - Context PoC si sumar local.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository.instance;
    final metrics = repo.metrics;

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
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.dataset,
                    size: 40,
                    color: AppColors.onPrimaryContainer,
                    fill: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Scenariu PoC Local',
                  style: AppTypography.headlineLg,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Aplicatia ruleaza exclusiv pe logul local si pe regulile MED-THERM-2026.',
                  textAlign: TextAlign.center,
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
            'SURSE',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textDimmed,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(
                  label: 'Fisier log',
                  value: 'medical_device_logs_1000.txt',
                ),
                SizedBox(height: AppSpacing.md),
                _InfoRow(
                  label: 'Standard',
                  value: 'MED-THERM-2026',
                ),
                SizedBox(height: AppSpacing.md),
                _InfoRow(
                  label: 'AI / backend',
                  value: 'Neutilizat in acest PoC',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl + 4),
          Text(
            'METRICI',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textDimmed,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.2,
            children: [
              _MetricTile(
                label: 'Evenimente',
                value: '${metrics.totalLines}',
                icon: Symbols.numbers,
              ),
              _MetricTile(
                label: 'Citiri temp',
                value: '${metrics.tempReadingCount}',
                icon: Symbols.thermostat,
              ),
              _MetricTile(
                label: 'Temp max',
                value: '${metrics.maxTemperature.toStringAsFixed(1)}C',
                icon: Symbols.device_thermostat,
              ),
              _MetricTile(
                label: 'Baterie min',
                value: '${metrics.minBattery.toStringAsFixed(1)}%',
                icon: Symbols.battery_low,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl + 4),
          FilledButton.icon(
            onPressed: () => context.push('/compliance'),
            icon: const Icon(Symbols.rule),
            label: const Text('Vezi verificarea de conformitate'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Symbols.logout),
            label: const Text('Inapoi la ecranul initial'),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: BottomNavDestination.profile,
        onSelected: (dest) {
          if (dest == BottomNavDestination.profile) return;
          context.go(_routeForDestination(dest));
        },
      ),
    );
  }

  String _routeForDestination(BottomNavDestination dest) {
    switch (dest) {
      case BottomNavDestination.home:
        return '/home';
      case BottomNavDestination.notifications:
        return '/notifications';
      case BottomNavDestination.history:
        return '/history';
      case BottomNavDestination.profile:
        return '/profile';
    }
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          Icon(icon, color: AppColors.primary, size: 24, fill: 1),
          Text(
            value,
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textDimmed,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
