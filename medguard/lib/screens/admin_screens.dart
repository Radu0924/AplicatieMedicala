import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/info_card.dart';

/// Admin Devices Screen
class AdminDevicesScreen extends StatelessWidget {
  const AdminDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final device = MockRepository.sampleDevice;

    return Scaffold(

      appBar: AppBar(
        title: const Text('Administrare Dispozitive'),
        backgroundColor: AppColors.surface,
        leading: BackButton(onPressed: () => context.go('/admin')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          InfoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device.code, style: AppTypography.headlineLg),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'ID: ${device.id}',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textDimmed,
                          ),
                        ),
                      ],
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
                        'ACTIV',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.statusOk,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _AdminInfoRow('Temperatură Min', '${device.tempMinOk}°C'),
                const SizedBox(height: AppSpacing.md),
                _AdminInfoRow('Temperatură Max', '${device.tempMaxOk}°C'),
                const SizedBox(height: AppSpacing.md),
                _AdminInfoRow('Prag Avertisment', '${device.tempWarningThreshold}°C'),
                const SizedBox(height: AppSpacing.md),
                _AdminInfoRow('Telefon Dispecerat', device.dispatchPhone),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Admin Transporters Screen
class AdminTransportersScreen extends StatelessWidget {
  const AdminTransportersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transporter = MockRepository.sampleTransporter;

    return Scaffold(

      appBar: AppBar(
        title: const Text('Administrare Transportori'),
        backgroundColor: AppColors.surface,
        leading: BackButton(onPressed: () => context.go('/admin')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          InfoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transporter.fullName, style: AppTypography.headlineLg),
                const SizedBox(height: AppSpacing.lg),
                _AdminInfoRow('Email', transporter.email),
                const SizedBox(height: AppSpacing.md),
                _AdminInfoRow('Telefon', transporter.phone),
                const SizedBox(height: AppSpacing.md),
                _AdminInfoRow('ID Utilizator', transporter.id),
                const SizedBox(height: AppSpacing.md),
                _AdminInfoRow('Transporte Completate', '5'),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Editare'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.statusCritical,
                        ),
                        child: const Text('Dezactivare'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Admin Transports Screen
class AdminTransportsScreen extends StatelessWidget {
  const AdminTransportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pastTransports = MockRepository.instance.getPastTransports();

    return Scaffold(

      appBar: AppBar(
        title: const Text('Administrare Transporuri'),
        backgroundColor: AppColors.surface,
        leading: BackButton(onPressed: () => context.go('/admin')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ...pastTransports.map((transport) {
            final duration =
                transport.endedAt!.difference(transport.startedAt);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: InfoCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${transport.from.city} → ${transport.to.city}',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w700,
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
                    const SizedBox(height: AppSpacing.md),
                    _AdminInfoRow(
                      'Durată',
                      '${duration.inHours}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}m',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AdminInfoRow('Transport ID', transport.id),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Admin Alarms Screen
class AdminAlarmsScreen extends StatelessWidget {
  const AdminAlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Administrare Alarme'),
        backgroundColor: AppColors.surface,
        leading: BackButton(onPressed: () => context.go('/admin')),
      ),
      body: Center(
        child: InfoCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle,
                  color: AppColors.statusOk, size: 48, fill: 1),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Niciun Alarm Activ',
                style: AppTypography.headlineLg,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Toate dispozitivele funcționează normal',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textDimmed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Admin Reports Screen
class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Rapoarte Conformitate'),
        backgroundColor: AppColors.surface,
        leading: BackButton(onPressed: () => context.go('/admin')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _ReportCard(
            title: 'Raport Lunar - Februarie 2026',
            status: 'Generat',
            date: '2026-02-28',
            transports: 12,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ReportCard(
            title: 'Raport Anual - 2025',
            status: 'Disponibil',
            date: '2025-12-31',
            transports: 156,
          ),
        ],
      ),
    );
  }
}

/// Admin Settings Screen
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _maintenanceMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Setări Administrație'),
        backgroundColor: AppColors.surface,
        leading: BackButton(onPressed: () => context.go('/admin')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          InfoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mod Mentenanță',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch(
                      value: _maintenanceMode,
                      onChanged: (val) {
                        setState(() => _maintenanceMode = val);
                      },
                      activeThumbColor: AppColors.statusWarning,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          InfoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informații Sistem',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _AdminInfoRow('Versiune API', '1.0.0'),
                const SizedBox(height: AppSpacing.md),
                _AdminInfoRow('Status Bază Date', 'Conectat'),
                const SizedBox(height: AppSpacing.md),
                _AdminInfoRow('Dispozitive Active', '1'),
                const SizedBox(height: AppSpacing.md),
                _AdminInfoRow('Utilizatori Activi', '1'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminInfoRow extends StatelessWidget {
  const _AdminInfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMd),
        Text(
          value,
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.status,
    required this.date,
    required this.transports,
  });

  final String title;
  final String status;
  final String date;
  final int transports;

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
              Expanded(
                child: Text(title, style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                )),
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
                  status,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.statusOk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Data: $date',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textDimmed,
                ),
              ),
              Text(
                '$transports transporuri',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textDimmed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Descărcare'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.print),
                  label: const Text('Tipărire'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
