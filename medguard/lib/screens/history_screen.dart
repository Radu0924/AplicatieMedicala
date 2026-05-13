import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/mock_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/info_card.dart';

/// Screen 7 — Istoricul transporturilor (Transport history).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pastTransports = MockRepository.instance.getPastTransports();

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
          Text(
            'SESIUNI ANALIZATE',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textDimmed,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (pastTransports.isEmpty)
            InfoCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Nicio sesiune disponibila',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textDimmed,
                ),
              ),
            )
          else
            ...pastTransports.map((transport) {
              final duration = transport.endedAt!.difference(transport.startedAt);
              final daysAgo =
                  DateTime.now().difference(transport.endedAt!).inDays;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: GestureDetector(
                  onTap: () => context.push('/past-detail/${transport.id}'),
                  child: InfoCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route and date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${transport.from.city} → ${transport.to.city}',
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              daysAgo == 0
                                  ? 'Azi'
                                  : daysAgo == 1
                                      ? 'Ieri'
                                      : 'acum ${daysAgo}z',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textDimmed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Facilities
                        Text(
                          '${transport.from.facility} ⟶ ${transport.to.facility}',
                          style: AppTypography.bodyMd.copyWith(
                            fontSize: 13,
                            color: AppColors.textDimmed,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Duration
                        Row(
                          children: [
                            Icon(
                              Symbols.schedule,
                              size: 16,
                              color: AppColors.textDimmed,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '${duration.inHours}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}m',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textDimmed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: BottomNavDestination.history,
        onSelected: (dest) {
          if (dest == BottomNavDestination.history) return;
          context.go(_routeForDestination(dest));
        },
      ),
    );
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
