import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/info_card.dart';

/// Screen 4 - Detaliu sesiune PoC.
class DetailTransportScreen extends StatelessWidget {
  const DetailTransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository.instance;

    return Scaffold(

      appBar: const AppTopBar(),
      body: StreamBuilder<TelemetrySnapshot>(
        stream: repo.telemetryStream,
        initialData: repo.current,
        builder: (context, snapshot) {
          final telemetry = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.containerMargin,
              AppSpacing.sectionPadding,
              AppSpacing.containerMargin,
              AppSpacing.xl,
            ),
            children: [
              _SessionHeader(
                telemetry: telemetry,
                metrics: repo.metrics,
              ),
              const SizedBox(height: AppSpacing.xl + 4),
              _TemperatureChart(
                device: MockRepository.sampleDevice,
                points: repo.getTemperatureHistory(),
              ),
              const SizedBox(height: AppSpacing.xl + 4),
              _DetailStatusGrid(
                telemetry: telemetry,
                metrics: repo.metrics,
              ),
              const SizedBox(height: AppSpacing.xl + 4),
              _RecentEventsCard(telemetry: telemetry),
              const SizedBox(height: AppSpacing.xl + 4),
              FilledButton.icon(
                onPressed: () => context.push('/compliance'),
                icon: const Icon(Icons.rule),
                label: const Text('Deschide raportul de conformitate'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => context.push('/report-issue'),
                icon: const Icon(Icons.report_problem),
                label: const Text('Raportează o problemă'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.telemetry,
    required this.metrics,
  });

  final TelemetrySnapshot telemetry;
  final SessionMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MockRepository.sampleDevice.code,
          style: AppTypography.headlineLg,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sesiune PoC bazata pe medical_device_logs_1000.txt',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.textDimmed,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _HeaderPill(
              icon: Icons.schedule,
              label: _formatRange(metrics.firstTimestamp, metrics.lastTimestamp),
            ),
            _HeaderPill(
              icon: Icons.tag,
              label: '${metrics.totalLines} evenimente',
            ),
            _HeaderPill(
              icon: Icons.thermostat,
              label: '${telemetry.temperatureC.toStringAsFixed(1)}°C acum',
            ),
          ],
        ),
      ],
    );
  }

  String _formatRange(DateTime start, DateTime end) {
    final startHm =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endHm =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startHm - $endHm';
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textDimmed, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemperatureChart extends StatelessWidget {
  const _TemperatureChart({
    required this.device,
    required this.points,
  });

  final Device device;
  final List<TemperaturePoint> points;

  @override
  Widget build(BuildContext context) {
    final first = points.isEmpty ? DateTime.now() : points.first.timestamp;
    final last = points.isEmpty ? first : points.last.timestamp;
    final maxX = max(
      60.0,
      max(1, last.difference(first).inSeconds).toDouble(),
    );
    final interval = maxX / 4;
    final spots = points.isEmpty
        ? [const FlSpot(0, 0)]
        : points
            .map(
              (point) => FlSpot(
                point.timestamp.difference(first).inSeconds.toDouble(),
                point.temperatureC,
              ),
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEMPERATURA PE SESIUNE',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.textDimmed,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        InfoCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.borderSubtle,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        final tickTime =
                            first.add(Duration(seconds: value.round()));
                        final hh = tickTime.hour.toString().padLeft(2, '0');
                        final mm = tickTime.minute.toString().padLeft(2, '0');
                        return Text(
                          '$hh:$mm',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textDimmed,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}°C',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textDimmed,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: AppColors.borderSubtle),
                    bottom: BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                minX: 0,
                maxX: maxX,
                minY: 0,
                maxY: max(12.0, device.tempMaxOk + 1),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, device.tempMaxOk),
                      FlSpot(maxX, device.tempMaxOk),
                    ],
                    isCurved: false,
                    color: AppColors.statusCritical,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  LineChartBarData(
                    spots: [
                      FlSpot(0, device.tempMinOk),
                      FlSpot(maxX, device.tempMinOk),
                    ],
                    isCurved: false,
                    color: AppColors.statusCritical,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailStatusGrid extends StatelessWidget {
  const _DetailStatusGrid({
    required this.telemetry,
    required this.metrics,
  });

  final TelemetrySnapshot telemetry;
  final SessionMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.lg,
      crossAxisSpacing: AppSpacing.lg,
      childAspectRatio: 1.2,
      children: [
        _StatusGridTile(
          label: 'BATERIE',
          icon: Icons.battery_charging_full,
          iconColor: AppColors.statusOk,
          value: '${telemetry.batteryPercent}%',
          tone: telemetry.batteryPercent > 20
              ? AppColors.statusOk
              : AppColors.statusWarning,
        ),
        _StatusGridTile(
          label: 'SENZOR SEC.',
          icon: Icons.sensors,
          iconColor: telemetry.sensorSecondaryActive
              ? AppColors.statusOk
              : AppColors.statusWarning,
          value: telemetry.sensorSecondaryActive ? 'Activ' : 'Timeout',
          tone: telemetry.sensorSecondaryActive
              ? AppColors.statusOk
              : AppColors.statusWarning,
        ),
        _StatusGridTile(
          label: 'ALARME LOG',
          icon: Icons.alarm,
          iconColor: AppColors.statusCritical,
          value: '${metrics.alarmTriggeredCount}',
          tone: AppColors.statusCritical,
        ),
        _StatusGridTile(
          label: 'MAX TEMP',
          icon: Icons.thermostat,
          iconColor: metrics.maxTemperature > MockRepository.sampleDevice.tempMaxOk
              ? AppColors.statusCritical
              : AppColors.statusOk,
          value: '${metrics.maxTemperature.toStringAsFixed(1)}°C',
          tone: metrics.maxTemperature > MockRepository.sampleDevice.tempMaxOk
              ? AppColors.statusCritical
              : AppColors.statusOk,
        ),
      ],
    );
  }
}

class _StatusGridTile extends StatelessWidget {
  const _StatusGridTile({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final String value;
  final Color tone;

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
          Icon(icon, color: iconColor, size: 24, fill: 1),
          Text(
            value,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w700,
              color: tone,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentEventsCard extends StatelessWidget {
  const _RecentEventsCard({required this.telemetry});

  final TelemetrySnapshot telemetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EVENIMENTE RECENTE',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.textDimmed,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (telemetry.recentEvents.isEmpty)
          InfoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Niciun eveniment disponibil.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textDimmed,
              ),
            ),
          )
        else
          ...telemetry.recentEvents.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: InfoCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      _iconFor(event.icon),
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.label,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(event.timestamp),
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.textDimmed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'power':
        return Icons.power_settings_new;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'door_open':
        return Icons.meeting_room;
      case 'door_back':
        return Icons.sensor_door;
      case 'thermostat':
        return Icons.thermostat;
      case 'alarm':
        return Icons.alarm;
      case 'sync_problem':
        return Icons.sync_problem;
      case 'sensors':
        return Icons.sensors;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    final ss = time.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}
