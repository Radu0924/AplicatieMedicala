import 'package:go_router/go_router.dart';

import 'screens/compliance_screen.dart';
import 'screens/detail_transport_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/past_transport_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/report_issue_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/global_alert_handler.dart';

/// Application route table. Auth-aware redirects will live here once the
/// auth model exists; for now the splash screen owns the timed transition.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) => GlobalAlertHandler(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/detail',
          builder: (_, _) => const DetailTransportScreen(),
        ),
        GoRoute(
          path: '/report-issue',
          builder: (_, _) => const ReportIssueScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (_, _) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/past-detail/:id',
          builder: (_, state) => PastTransportDetailScreen(
            transportId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/notifications',
          builder: (_, _) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, _) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/compliance',
          builder: (_, _) => const ComplianceScreen(),
        ),
      ],
    ),
  ],
);
