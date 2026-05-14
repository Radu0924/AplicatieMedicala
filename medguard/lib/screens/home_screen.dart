import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/info_card.dart';
import '../widgets/status_badge.dart';

/// Screen 3 - Home / Starea curenta.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) => const _HomeScreenContent();
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

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
          final metrics = repo.metrics;

          final sections = <Widget>[
            _BatteryWarningBanner(batteryPercent: telemetry.batteryPercent),
            GestureDetector(
              onTap: () => context.push('/detail'),
              child: _PrimaryStatusCard(
                device: MockRepository.sampleDevice,
                telemetry: telemetry,
              ),
            ),
            _TelemetryGrid(telemetry: telemetry),
            _ComplianceOverviewCard(
              overview: repo.complianceOverview,
              metrics: metrics,
            ),
            _SystemHealthCard(
              telemetry: telemetry,
              metrics: metrics,
            ),
            _SourceCard(metrics: metrics),
          ];

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.containerMargin,
              AppSpacing.sectionPadding,
              AppSpacing.containerMargin,
              AppSpacing.xl,
            ),
            itemCount: sections.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.xl + 4),
            itemBuilder: (_, i) => _FadeSlideIn(
              delay: Duration(milliseconds: 60 * i),
              child: sections[i],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        current: BottomNavDestination.home,
        onSelected: (dest) {
          if (dest == BottomNavDestination.home) return;
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

// ---------------------------------------------------------------------------
// Battery warning banner — visible when battery < 20%
// ---------------------------------------------------------------------------

class _BatteryWarningBanner extends StatelessWidget {
  const _BatteryWarningBanner({required this.batteryPercent});

  final int batteryPercent;

  @override
  Widget build(BuildContext context) {
    final show = batteryPercent < 20;
    final isCritical = batteryPercent < 10;
    final color = isCritical ? AppColors.statusCritical : AppColors.statusWarning;

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: show
          ? Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl + 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tint(color, 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.tint(color, 0.45),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    _PulsingIcon(
                      icon: Icons.battery_alert,
                      color: color,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        isCritical
                            ? 'Baterie critică: $batteryPercent% — conectați la alimentare imediat'
                            : 'Baterie scăzută: $batteryPercent% — conectați la alimentare',
                        style: AppTypography.bodyMd.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing icon — opacity 1.0 ↔ 0.35 loop, used for warnings
// ---------------------------------------------------------------------------

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Icon(widget.icon, color: widget.color, size: widget.size, fill: 1),
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing status dot — used in primary status card
// ---------------------------------------------------------------------------

class _PulsingStatusDot extends StatefulWidget {
  const _PulsingStatusDot({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  State<_PulsingStatusDot> createState() => _PulsingStatusDotState();
}

class _PulsingStatusDotState extends State<_PulsingStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingStatusDot old) {
    super.didUpdateWidget(old);
    if (widget.active == old.active) return;
    if (widget.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    );
    if (!widget.active) return dot;
    return ScaleTransition(scale: _scale, child: dot);
  }
}

// ---------------------------------------------------------------------------
// Primary status card
// ---------------------------------------------------------------------------

class _PrimaryStatusCard extends StatelessWidget {
  const _PrimaryStatusCard({required this.device, required this.telemetry});

  final Device device;
  final TelemetrySnapshot telemetry;

  @override
  Widget build(BuildContext context) {
    final status = telemetry.statusFor(device);
    final isAlert =
        status == DeviceStatus.critical || status == DeviceStatus.warning;

    return InfoCard(
      gradient: AppGradients.primaryStatus,
      boxShadow: AppShadows.raised,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl + 4,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                label: telemetry.online ? 'ONLINE' : 'OFFLINE',
                color:
                    telemetry.online ? AppColors.statusOk : AppColors.textDimmed,
                icon: Icons.sensors,
              ),
              StatusBadge(
                label: telemetry.doorOpen ? 'USA DESCHISA' : 'USA INCHISA',
                color: telemetry.doorOpen
                    ? AppColors.statusWarning
                    : AppColors.textDimmed,
                icon: telemetry.doorOpen ? Icons.meeting_room : Icons.sensor_door,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PulsingStatusDot(color: status.color, active: isAlert),
              const SizedBox(width: AppSpacing.xs + 2),
              Icon(status.icon, color: status.color, size: 22, fill: 1),
              const SizedBox(width: AppSpacing.xs),
              Text(
                status.romanianLabel,
                style: AppTypography.statusLabel.copyWith(color: status.color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            ),
            child: Text(
              '${telemetry.temperatureC.toStringAsFixed(1)}°C',
              key: ValueKey(telemetry.temperatureC),
              style: AppTypography.displayTemp.copyWith(fontSize: 72),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'Limita admisa: ${device.tempMinOk.toStringAsFixed(0)}°C - '
              '${device.tempMaxOk.toStringAsFixed(0)}°C',
              style: AppTypography.labelSm,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Telemetry grid
// ---------------------------------------------------------------------------

class _TelemetryGrid extends StatelessWidget {
  const _TelemetryGrid({required this.telemetry});

  final TelemetrySnapshot telemetry;

  @override
  Widget build(BuildContext context) {
    final batteryLow = telemetry.batteryPercent < 20;
    final tiles = <_TelemetryTileData>[
      _TelemetryTileData(
        label: 'VENTILATOR',
        icon: Symbols.mode_fan,
        iconColor: AppColors.primary,
        background: AppColors.tint(AppColors.primaryContainer, 0.10),
        value: '${telemetry.fanRpm} RPM',
        spinRpm: telemetry.fanRpm,
      ),
      _TelemetryTileData(
        label: 'BATERIE',
        icon: batteryLow ? Icons.battery_alert : Icons.battery_charging_full,
        iconColor: batteryLow ? AppColors.statusCritical : AppColors.statusOk,
        background: AppColors.tint(
          batteryLow ? AppColors.statusCritical : AppColors.statusOk,
          0.10,
        ),
        value: '${telemetry.batteryPercent}%',
        pulse: batteryLow,
      ),
      _TelemetryTileData(
        label: 'UMIDITATE',
        icon: Icons.water_drop,
        iconColor: AppColors.secondary,
        background: AppColors.tint(AppColors.secondary, 0.10),
        value: '${telemetry.humidityPercent}%',
      ),
      _TelemetryTileData(
        label: 'TENSIUNE',
        icon: Icons.electrical_services,
        iconColor: AppColors.statusWarning,
        background: AppColors.tint(AppColors.statusWarning, 0.10),
        value: '${telemetry.voltage.toStringAsFixed(1)}V',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.xl + 4,
      crossAxisSpacing: AppSpacing.xl + 4,
      childAspectRatio: 1.05,
      children: tiles.map(_TelemetryTile.new).toList(),
    );
  }
}

class _TelemetryTileData {
  const _TelemetryTileData({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.value,
    this.spinRpm,
    this.pulse = false,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final String value;
  /// Non-null → rotating fan animation at this RPM.
  final int? spinRpm;
  /// True → pulsing opacity animation on the icon.
  final bool pulse;
}

class _TelemetryTile extends StatefulWidget {
  const _TelemetryTile(this.data);

  final _TelemetryTileData data;

  @override
  State<_TelemetryTile> createState() => _TelemetryTileState();
}

class _TelemetryTileState extends State<_TelemetryTile>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();

    // Spin controller
    final rpm = widget.data.spinRpm ?? 0;
    _spinController = AnimationController(
      vsync: this,
      duration: _spinDuration(rpm),
    );
    if (rpm > 0) _spinController.repeat();

    // Pulse controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _pulseOpacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.data.pulse) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_TelemetryTile old) {
    super.didUpdateWidget(old);

    final rpm = widget.data.spinRpm ?? 0;
    final oldRpm = old.data.spinRpm ?? 0;
    if (rpm != oldRpm) {
      _spinController.duration = _spinDuration(rpm);
      if (rpm > 0) {
        if (!_spinController.isAnimating) _spinController.repeat();
      } else {
        _spinController
          ..stop()
          ..reset();
      }
    }

    if (widget.data.pulse != old.data.pulse) {
      if (widget.data.pulse) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController
          ..stop()
          ..reset();
      }
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Maps device RPM to a visually pleasant animation duration.
  /// Divides RPM by 20 so 2000 RPM → ~600ms/turn (fast but readable).
  Duration _spinDuration(int rpm) {
    if (rpm <= 0) return const Duration(seconds: 10);
    final ms = (60000.0 / (rpm / 20.0)).round().clamp(150, 4000);
    return Duration(milliseconds: ms);
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      widget.data.icon,
      color: widget.data.iconColor,
      size: 28,
      fill: 1,
    );

    if (widget.data.spinRpm != null) {
      iconWidget = RotationTransition(
        turns: _spinController,
        child: iconWidget,
      );
    }

    if (widget.data.pulse) {
      iconWidget = FadeTransition(
        opacity: _pulseOpacity,
        child: iconWidget,
      );
    }

    return InfoCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            widget.data.label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textDimmed,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.data.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
          Text(
            widget.data.value,
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compliance overview card
// ---------------------------------------------------------------------------

class _ComplianceOverviewCard extends StatelessWidget {
  const _ComplianceOverviewCard({
    required this.overview,
    required this.metrics,
  });

  final ComplianceOverview overview;
  final SessionMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule, size: 18, color: AppColors.textDimmed),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'CONFORMITATE POC',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textDimmed,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${overview.violations} reguli cu incalcari',
            style: AppTypography.headlineLg.copyWith(fontSize: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Temperatura variaza intre ${metrics.minTemperature.toStringAsFixed(1)}°C '
            'si ${metrics.maxTemperature.toStringAsFixed(1)}°C.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textDimmed,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusBadge(
                label: '${overview.compliant} CONFORME',
                color: AppColors.statusOk,
                icon: Icons.check_circle,
              ),
              StatusBadge(
                label: '${overview.violations} INCALCARI',
                color: AppColors.statusCritical,
                icon: Icons.warning,
              ),
              StatusBadge(
                label: '${overview.insufficientData} INSUF.',
                color: AppColors.statusWarning,
                icon: Icons.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// System health card
// ---------------------------------------------------------------------------

class _SystemHealthCard extends StatelessWidget {
  const _SystemHealthCard({
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
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Text(
            'Stare Sistem',
            style: AppTypography.headlineLg.copyWith(fontSize: 18),
          ),
        ),
        InfoCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _HealthRow(
                icon: Icons.sync,
                label: 'Gap maxim intre evenimente',
                trailing: StatusBadge(
                  label: '${metrics.rawEventGapMaxSeconds}s',
                  color: metrics.rawEventGapMaxSeconds <= 90
                      ? AppColors.statusOk
                      : AppColors.statusCritical,
                  icon: metrics.rawEventGapMaxSeconds <= 90
                      ? Icons.check
                      : Icons.error,
                ),
              ),
              const Divider(),
              _HealthRow(
                icon: Icons.thermostat,
                label: 'Gap maxim intre citiri temperatura',
                trailing: StatusBadge(
                  label: '${metrics.temperatureGapMaxSeconds}s',
                  color: metrics.temperatureGapMaxSeconds <= 30
                      ? AppColors.statusOk
                      : AppColors.statusCritical,
                  icon: metrics.temperatureGapMaxSeconds <= 30
                      ? Icons.check
                      : Icons.warning,
                ),
              ),
              const Divider(),
              _HealthRow(
                icon: Icons.sensors,
                label: 'Timeout-uri senzor secundar',
                trailing: StatusBadge(
                  label: '${metrics.secondarySensorTimeoutCount}',
                  color: metrics.secondarySensorTimeoutCount == 0
                      ? AppColors.statusOk
                      : AppColors.statusWarning,
                  icon: metrics.secondarySensorTimeoutCount == 0
                      ? Icons.check
                      : Icons.sensors,
                ),
              ),
              const Divider(),
              _HealthRow(
                icon: Icons.meeting_room,
                label: 'Maxim deschideri usa / ora',
                trailing: StatusBadge(
                  label: '${metrics.maxDoorOpensPerHour}',
                  color: metrics.maxDoorOpensPerHour > 10
                      ? AppColors.statusCritical
                      : AppColors.statusOk,
                  icon: metrics.maxDoorOpensPerHour > 10
                      ? Icons.warning
                      : Icons.check,
                ),
              ),
              if (telemetry.recentEvents.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'EVENIMENTE RECENTE',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textDimmed,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final event in telemetry.recentEvents) ...[
                  _EventRow(event: event),
                  if (event != telemetry.recentEvents.last)
                    const SizedBox(height: AppSpacing.xs),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textDimmed, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final TelemetryEvent event;

  IconData get _icon {
    switch (event.icon) {
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
        return Icons.bolt;
    }
  }

  String get _time {
    final hh = event.timestamp.hour.toString().padLeft(2, '0');
    final mm = event.timestamp.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(_icon, size: 16, color: AppColors.textDimmed),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            '${event.label} ($_time)',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textDimmed,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Source card
// ---------------------------------------------------------------------------

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.metrics});

  final SessionMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                size: 18,
                color: AppColors.textDimmed,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'SURSA DATE',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textDimmed,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Fisier local: medical_device_logs_1000.txt',
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Reguli aplicate: MED-THERM-2026',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textDimmed,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Interval log: ${_format(metrics.firstTimestamp)} - '
            '${_format(metrics.lastTimestamp)}',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textDimmed,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _format(DateTime timestamp) {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final hh = timestamp.hour.toString().padLeft(2, '0');
    final mm = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month $hh:$mm';
  }
}

// ---------------------------------------------------------------------------
// Entrance animation — fade + slide up, staggered by [delay].
// ---------------------------------------------------------------------------

class _FadeSlideIn extends StatefulWidget {
  const _FadeSlideIn({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
