import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MedGuardApp());
}

class MedGuardApp extends StatelessWidget {
  const MedGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        final isDark = mode == ThemeMode.dark;
        SystemChrome.setSystemUIOverlayStyle(
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        );
        return MaterialApp.router(
          title: 'MedGuard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          themeAnimationDuration: Duration.zero,
          themeAnimationCurve: Curves.linear,
          routerConfig: appRouter,
          // Force the active route subtree to rebuild on theme change so
          // widgets that read AppColors.xxx directly (not via Theme.of)
          // pick up the new palette immediately — without this, screens
          // only refresh on navigation.
          builder: (context, child) => KeyedSubtree(
            key: ValueKey(mode),
            child: child!,
          ),
        );
      },
    );
  }
}
