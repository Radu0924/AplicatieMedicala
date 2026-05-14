import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_notifier.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, this.actions});

  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.touchTarget);

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppSpacing.touchTarget,
          child: Padding(
            padding: EdgeInsets.only(
              left: canPop ? AppSpacing.xs : AppSpacing.containerMargin,
              right: AppSpacing.sm,
            ),
            child: Row(
              children: [
                if (canPop)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: cs.onSurface,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    constraints: const BoxConstraints(),
                    onPressed: () => context.pop(),
                    tooltip: 'Înapoi',
                  )
                else ...[
                  Icon(
                    Icons.medical_services,
                    color: cs.onSurface,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  'MedGuard',
                  style: AppTypography.headlineLg.copyWith(fontSize: 20),
                ),
                const Spacer(),
                if (actions != null) ...actions!,
                // Dark mode toggle
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (_, mode, __) => IconButton(
                    icon: Icon(
                      mode == ThemeMode.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      size: 22,
                    ),
                    color: cs.onSurface,
                    tooltip: mode == ThemeMode.dark ? 'Mod luminos' : 'Mod întunecat',
                    onPressed: () {
                      themeNotifier.value = mode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                    },
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
