import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The 4-tab destination set shared across all primary screens.
enum BottomNavDestination {
  home(label: 'Acasă', icon: Symbols.home, route: '/home'),
  notifications(label: 'Notificări', icon: Symbols.notifications, route: '/notifications'),
  history(label: 'Istoric', icon: Symbols.history, route: '/history'),
  profile(label: 'Profil', icon: Symbols.person, route: '/profile');

  const BottomNavDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

/// Bottom navigation bar matching the Stitch design — 4 tabs with filled
/// Material Symbols icons for the active state.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final BottomNavDestination current;
  final ValueChanged<BottomNavDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: BottomNavDestination.values.map((dest) {
              final isActive = dest == current;
              final color =
                  isActive ? AppColors.secondary : AppColors.onSurfaceVariant;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () => onSelected(dest),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          dest.icon,
                          color: color,
                          size: 26,
                          fill: isActive ? 1 : 0,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dest.label,
                          style: AppTypography.labelSm.copyWith(
                            color: color,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
