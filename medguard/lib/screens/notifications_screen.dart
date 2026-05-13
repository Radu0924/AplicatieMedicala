import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_repository.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/info_card.dart';
import '../widgets/status_badge.dart';

/// Screen 9 - Notificari derivate din log.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = MockRepository.instance.getNotifications().take(30).toList();
    final unreadCount = notifications.where((notification) => !notification.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.containerMargin,
          AppSpacing.sectionPadding,
          AppSpacing.containerMargin,
          AppSpacing.xl,
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INCIDENTE DIN LOG',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textDimmed,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusCritical,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '$unreadCount noi',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (notifications.isEmpty)
            InfoCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Nu exista notificari generate din log.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textDimmed,
                ),
              ),
            )
          else
            ...notifications.map(
              (notification) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: InfoCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  background: notification.isRead
                      ? AppColors.surface
                      : AppColors.tint(
                          notification.severity.status.color,
                          0.08,
                        ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.tint(
                            notification.severity.status.color,
                            0.15,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _iconFor(notification.severity),
                          color: notification.severity.status.color,
                          size: 24,
                          fill: 1,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: AppTypography.bodyMd.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  notification.severity.romanianLabel,
                                  style: AppTypography.labelSm.copyWith(
                                    color: notification.severity.status.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.message,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.textDimmed,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _formatTime(notification.timestamp),
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textDimmed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: BottomNavDestination.notifications,
        onSelected: (dest) {
          if (dest == BottomNavDestination.notifications) return;
          context.go(_routeForDestination(dest));
        },
      ),
    );
  }

  IconData _iconFor(NotificationSeverity severity) {
    switch (severity) {
      case NotificationSeverity.critical:
        return Symbols.warning;
      case NotificationSeverity.warning:
        return Symbols.notifications_active;
      case NotificationSeverity.info:
        return Symbols.info;
    }
  }

  String _formatTime(DateTime timestamp) {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final hh = timestamp.hour.toString().padLeft(2, '0');
    final mm = timestamp.minute.toString().padLeft(2, '0');
    final ss = timestamp.second.toString().padLeft(2, '0');
    return '$day/$month $hh:$mm:$ss';
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
