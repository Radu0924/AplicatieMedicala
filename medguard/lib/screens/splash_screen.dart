import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.medical_services,
            color: AppColors.onPrimary,
            size: 48,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('MedGuard', style: AppTypography.headlineLg),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Monitorizare Medicală Sigură',
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
          SizedBox(
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
            Icons.check_circle,
            color: AppColors.statusOk,
            size: 32,
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          loading ? 'ÎNCĂRCARE LOG POC...' : 'LOG POC ÎNCĂRCAT',
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
          Icons.error,
          color: AppColors.statusCritical,
          size: 32,
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
