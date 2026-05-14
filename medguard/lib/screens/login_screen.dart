import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/info_card.dart';
import '../widgets/primary_button.dart';

/// Screen 2 — Login / Autentificare.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _passwordVisible = false;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    // Mock auth: accept any non-empty credentials. Real auth wires here later.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _submitting = false);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.xxl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                _Header(),
                const SizedBox(height: AppSpacing.xxl),
                InfoCard(
                  background: AppColors.surfaceContainerLow,
                  boxShadow: AppShadows.raised,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LabeledField(
                        label: 'Nume utilizator',
                        child: TextFormField(
                          controller: _identifier,
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Introduceți numele de utilizator',
                            prefixIcon: Icon(Icons.account_circle, size: 22),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Câmp obligatoriu'
                                  : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _LabeledField(
                        label: 'Parolă',
                        child: TextFormField(
                          controller: _password,
                          obscureText: !_passwordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: 'Introduceți parola',
                            prefixIcon: const Icon(Icons.lock, size: 22),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 22,
                              ),
                              onPressed: () => setState(
                                () => _passwordVisible = !_passwordVisible,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty)
                                  ? 'Câmp obligatoriu'
                                  : (v.length < 8
                                      ? 'Minim 8 caractere'
                                      : null),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Flow resetare parolă — în construcție',
                                ),
                              ),
                            );
                          },
                          child: const Text('Am uitat parola'),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _errorMessage!,
                          style: AppTypography.bodyMd
                              .copyWith(color: AppColors.error, fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: _submitting ? 'Se procesează...' : 'Intră în cont',
                        onPressed: _submitting ? null : _submit,
                        loading: _submitting,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 18,
                      color: AppColors.textDimmed,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Sistem Securizat MedGuard',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textDimmed,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.primary(),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.medical_services,
                size: 30,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'MedGuard',
              style: AppTypography.headlineLg.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Logistics & Tracking System',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
