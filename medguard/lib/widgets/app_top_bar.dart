import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Sticky app bar with the MedGuard wordmark + medical_services icon.
/// Automatically shows a back button when there is a route to pop.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, this.actions});

  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.touchTarget);

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppSpacing.touchTarget,
          child: Padding(
            padding: EdgeInsets.only(
              left: canPop ? AppSpacing.xs : AppSpacing.containerMargin,
              right: AppSpacing.containerMargin,
            ),
            child: Row(
              children: [
                if (canPop)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    constraints: const BoxConstraints(),
                    onPressed: () => context.pop(),
                    tooltip: 'Înapoi',
                  )
                else ...[
                  const Icon(
                    Symbols.medical_services,
                    color: AppColors.primary,
                    size: 24,
                    fill: 1,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  'MedGuard',
                  style: AppTypography.headlineLg.copyWith(fontSize: 20),
                ),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
