import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_repository.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Screen 5 — Alertă activă (critical alert modal overlay).
///
/// This modal takes full control of the UI when a critical condition is
/// detected. It cannot be dismissed without user action.
class AlertScreen extends StatefulWidget {
  const AlertScreen({
    super.key,
    required this.alert,
    required this.telemetry,
    required this.onDismiss,
  });

  final AlertType alert;
  final TelemetrySnapshot telemetry;
  final VoidCallback onDismiss;

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen>
    with TickerProviderStateMixin {
  // Entrance: fade + scale in on mount
  late final AnimationController _entranceCtrl;
  late final Animation<double> _entranceFade;
  late final Animation<double> _entranceScale;

  // Icon pulse: scale 1.0 ↔ 1.18 continuously
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );
    _entranceScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = MockRepository.sampleDevice;
    final message = widget.alert.romanianMessage;
    final isThermalAlert =
        widget.alert == AlertType.temperatureHigh ||
        widget.alert == AlertType.temperatureLow;

    return FadeTransition(
      opacity: _entranceFade,
      child: ScaleTransition(
        scale: _entranceScale,
        child: Material(
          color: AppColors.statusCritical,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing warning icon
                ScaleTransition(
                  scale: _pulseScale,
                  child: Icon(
                    Symbols.warning,
                    size: 56,
                    color: AppColors.tint(AppColors.onPrimary, 0.85),
                    fill: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Title
                Text(
                  'ALERTĂ CRITICĂ',
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Message
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerMargin,
                  ),
                  child: Text(
                    message,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 18,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Temperature display (if thermal alert)
                if (isThermalAlert) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tint(AppColors.onPrimary, 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.tint(AppColors.onPrimary, 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TEMPERATURA CURENTĂ',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${widget.telemetry.temperatureC.toStringAsFixed(1)}°C',
                          style: AppTypography.displayTemp.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 80,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.alert == AlertType.temperatureHigh
                              ? 'Peste limita de ${device.tempMaxOk.toStringAsFixed(1)}°C'
                              : 'Sub limita de ${device.tempMinOk.toStringAsFixed(1)}°C',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // Dismiss button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerMargin,
                  ),
                  child: OutlinedButton(
                    onPressed: widget.onDismiss,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onPrimary,
                      side: BorderSide(
                        color: AppColors.tint(AppColors.onPrimary, 0.5),
                      ),
                      minimumSize: const Size.fromHeight(
                        AppSpacing.touchTarget + 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Text(
                      'Am înțeles, continuu',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
