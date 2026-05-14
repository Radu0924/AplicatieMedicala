import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The 4-tab destination set shared across all primary screens.
enum BottomNavDestination {
  home(label: 'Acasă', icon: Icons.home, route: '/home'),
  notifications(label: 'Notificări', icon: Icons.notifications, route: '/notifications'),
  history(label: 'Istoric', icon: Icons.history, route: '/history'),
  profile(label: 'Profil', icon: Icons.person, route: '/profile');

  const BottomNavDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

/// Bottom navigation bar with active state pill, tap scale feedback, and
/// filled Material Symbols icons for the active state.
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
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
              return Expanded(
                child: _NavItem(
                  destination: dest,
                  active: dest == current,
                  onTap: () => onSelected(dest),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final BottomNavDestination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = widget.active ? cs.secondary : cs.onSurfaceVariant;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        scale: _pressed ? 0.94 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.active
                      ? cs.secondary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Icon(
                  widget.destination.icon,
                  color: color,
                  size: 24,
                  fill: widget.active ? 1 : 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.destination.label,
                style: AppTypography.labelSm.copyWith(
                  color: color,
                  fontWeight:
                      widget.active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
