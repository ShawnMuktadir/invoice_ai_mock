import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/home/screens/home_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/invoice/screens/ai_processing_screen.dart';
import '../features/invoice/screens/invoice_detail_screen.dart';
import '../shared/widgets/bottom_nav_scaffold.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // If authenticated and on login page, redirect to home
      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/processing/:invoiceId/:fileName',
        builder: (context, state) {
          final invoiceId = state.pathParameters['invoiceId']!;
          final fileName = state.pathParameters['fileName']!;
          return AIProcessingScreen(
            invoiceId: invoiceId,
            fileName: fileName,
          );
        },
      ),
      GoRoute(
        path: '/invoice/:invoiceId',
        builder: (context, state) {
          final invoiceId = state.pathParameters['invoiceId']!;
          return InvoiceDetailScreen(invoiceId: invoiceId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          int currentIndex = 0;
          switch (state.matchedLocation) {
            case '/home':
              currentIndex = 0;
              break;
            case '/history':
              currentIndex = 1;
              break;
            case '/chat':
              currentIndex = 2;
              break;
            case '/settings':
              currentIndex = 3;
              break;
          }

          return BottomNavScaffold(
            currentIndex: currentIndex,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ChatScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});