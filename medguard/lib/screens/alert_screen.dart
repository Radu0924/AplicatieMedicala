import 'package:flutter/material.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Screen 5 — Alertă activă (critical alert modal overlay).
///
/// Takes full control of the UI when a critical condition is detected.
/// Cannot be dismissed without user action.
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
  // Entrance: fade in background, then slide-up content
  late final AnimationController _entranceCtrl;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _contentSlide;

  // Icon pulse: scale 1.0 ↔ 1.18 continuously
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;

  // Ripple rings: 3 concentric rings staggered
  late final AnimationController _rippleCtrl;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
    _entranceFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = MockRepository.sampleDevice;
    final message = widget.alert.romanianMessage;
    final isThermalAlert =
        widget.alert == AlertType.temperatureHigh ||
        widget.alert == AlertType.temperatureLow;

    return Material(
      color: const Color(0xFFDC2626),
      child: FadeTransition(
        opacity: _entranceFade,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.alertCritical),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric ripple rings behind the icon
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: SizedBox(
                      width: 320,
                      height: 320,
                      child: AnimatedBuilder(
                        animation: _rippleCtrl,
                        builder: (context, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: List.generate(3, (i) {
                              final t = (_rippleCtrl.value + i * 0.33) % 1.0;
                              return Opacity(
                                opacity: (1.0 - t).clamp(0.0, 1.0) * 0.55,
                                child: Container(
                                  width: 80 + t * 240,
                                  height: 80 + t * 240,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.tint(
                                        AppColors.onPrimary,
                                        0.6,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Main content
                SlideTransition(
                  position: _contentSlide,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerMargin,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.xxl),
                        // Glowing icon container
                        ScaleTransition(
                          scale: _pulseScale,
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.tint(
                                AppColors.onPrimary,
                                0.18,
                              ),
                              border: Border.all(
                                color: AppColors.tint(
                                  AppColors.onPrimary,
                                  0.6,
                                ),
                                width: 2,
                              ),
                              boxShadow: AppShadows.glow(
                                AppColors.onPrimary,
                                intensity: 0.35,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.warning_rounded,
                              size: 64,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'ALERTĂ CRITICĂ',
                          style: AppTypography.headlineLg.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          message,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 18,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        if (isThermalAlert) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.lg,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tint(
                                AppColors.onPrimary,
                                0.14,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: AppColors.tint(
                                  AppColors.onPrimary,
                                  0.35,
                                ),
                              ),
                              boxShadow: AppShadows.onColored,
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
                                    fontSize: 84,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -2.5,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
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

                        _WhiteDismissButton(onPressed: widget.onDismiss),
                      ],
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

class _WhiteDismissButton extends StatefulWidget {
  const _WhiteDismissButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_WhiteDismissButton> createState() => _WhiteDismissButtonState();
}

class _WhiteDismissButtonState extends State<_WhiteDismissButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        scale: _pressed ? 0.97 : 1.0,
        child: Container(
          width: double.infinity,
          height: AppSpacing.touchTarget + 8,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.onPrimary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.onColored,
          ),
          child: Text(
            'Am înțeles, continuu',
            style: AppTypography.bodyMd.copyWith(
              color: const Color(0xFFDC2626),
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}
