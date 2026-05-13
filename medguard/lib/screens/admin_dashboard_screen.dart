import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_repository.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/info_card.dart';

/// Admin Dashboard — Overview of all devices, transports, and alarms.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository.instance;
    final pastTransports = repo.getPastTransports();
    final isWebLayout = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'MedGuard Admin',
          style: AppTypography.headlineLg.copyWith(fontSize: 20),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: FilledButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Symbols.logout),
                label: const Text('Deconectare'),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWebLayout ? AppSpacing.xl : AppSpacing.lg),
        child: isWebLayout
            ? _WebLayout(repo: repo, pastTransports: pastTransports)
            : _MobileLayout(repo: repo, pastTransports: pastTransports),
      ),
    );
  }
}

class _WebLayout extends StatelessWidget {
  const _WebLayout({
    required this.repo,
    required this.pastTransports,
  });

  final MockRepository repo;
  final List<Transport> pastTransports;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Dispozitive Active',
                value: '1',
                icon: Symbols.thermostat,
                color: AppColors.statusOk,
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: _StatCard(
                label: 'Transporte Activ',
                value: '1',
                icon: Symbols.local_shipping,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: _StatCard(
                label: 'Alerte Nerezolvate',
                value: '0',
                icon: Symbols.warning,
                color: AppColors.statusCritical,
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: _StatCard(
                label: 'Transporturi Completate',
                value: '${pastTransports.length}',
                icon: Symbols.check_circle,
                color: AppColors.statusOk,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl + 4),

        // Admin sections
        Text(
          'ADMINISTRARE',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.textDimmed,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Admin menu grid
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.lg,
          children: [
            _AdminMenuTile(
              icon: Symbols.devices,
              label: 'Dispozitive',
              onTap: () => context.go('/admin-devices'),
            ),
            _AdminMenuTile(
              icon: Symbols.people,
              label: 'Transportori',
              onTap: () => context.go('/admin-transporters'),
            ),
            _AdminMenuTile(
              icon: Symbols.directions_bus,
              label: 'Transporuri',
              onTap: () => context.go('/admin-transports'),
            ),
            _AdminMenuTile(
              icon: Symbols.error,
              label: 'Alarme',
              onTap: () => context.go('/admin-alarms'),
            ),
            _AdminMenuTile(
              icon: Symbols.description,
              label: 'Rapoarte',
              onTap: () => context.go('/admin-reports'),
            ),
            _AdminMenuTile(
              icon: Symbols.settings,
              label: 'Setări',
              onTap: () => context.go('/admin-settings'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl + 4),

        // Recent transports
        Text(
          'TRANSPORTE RECENTE',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.textDimmed,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _TransportsList(transports: pastTransports.take(5).toList()),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.repo,
    required this.pastTransports,
  });

  final MockRepository repo;
  final List<Transport> pastTransports;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatCard(
          label: 'Dispozitive Active',
          value: '1',
          icon: Symbols.thermostat,
          color: AppColors.statusOk,
        ),
        const SizedBox(height: AppSpacing.lg),
        _StatCard(
          label: 'Transporte Activ',
          value: '1',
          icon: Symbols.local_shipping,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.lg),
        _StatCard(
          label: 'Alerte Nerezolvate',
          value: '0',
          icon: Symbols.warning,
          color: AppColors.statusCritical,
        ),
        const SizedBox(height: AppSpacing.xl + 4),
        _TransportsList(transports: pastTransports),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textDimmed,
                ),
              ),
              Icon(icon, color: color, size: 20, fill: 1),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.displayTemp.copyWith(fontSize: 32),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  const _AdminMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: InfoCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 32, fill: 1),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransportsList extends StatelessWidget {
  const _TransportsList({required this.transports});

  final List<Transport> transports;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: transports
          .map(
            (transport) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: InfoCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${transport.from.city} → ${transport.to.city}',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            transport.from.facility,
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.textDimmed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tint(AppColors.statusOk, 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Text(
                        'Completat',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.statusOk,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
