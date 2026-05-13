import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Screen 1 - Splash / Incarcare.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await Future.wait([
        MockRepository.instance.ensureLoaded(),
        Future<void>.delayed(const Duration(milliseconds: 2000)),
      ]);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = null;
      });
      _timer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        context.go('/home');
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Nu am putut incarca logul PoC.\n$error';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Brandmark centered in full screen
            Center(child: _BrandMark()),
            // Loading / error pinned to bottom
            Positioned(
              left: AppSpacing.containerMargin,
              right: AppSpacing.containerMargin,
              bottom: AppSpacing.xxl,
              child: _errorMessage != null
                  ? _ErrorState(
                      message: _errorMessage!,
                      onRetry: () {
                        setState(() {
                          _loading = true;
                          _errorMessage = null;
                        });
                        _bootstrap();
                      },
                    )
                  : _LoadingIndicator(loading: _loading),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Symbols.medical_services,
            color: AppColors.onPrimary,
            size: 48,
            fill: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('MedGuard', style: AppTypography.headlineLg),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Secure Medical Logistics',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading)
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
              backgroundColor: AppColors.outlineVariant,
            ),
          )
        else
          const Icon(
            Symbols.check_circle,
            color: AppColors.statusOk,
            size: 32,
            fill: 1,
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          loading ? 'INCARCARE LOG POC...' : 'LOG POC INCARCAT',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.outline,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Symbols.error,
          color: AppColors.statusCritical,
          size: 32,
          fill: 1,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.statusCritical,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: onRetry,
          child: const Text('Reincarca'),
        ),
      ],
    );
  }
}
