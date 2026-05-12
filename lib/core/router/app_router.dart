import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/core/router/go_router_refresh_notifier.dart';
import 'package:bytebank_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:bytebank_app/features/auth/presentation/screens/login_screen.dart';
import 'package:bytebank_app/features/auth/presentation/screens/register_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/dashboard_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/transaction_form_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:bytebank_app/features/profile/presentation/screens/profile_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final notifier = GoRouterRefreshNotifier(
    ref.watch(authStateStreamProvider.stream),
  );
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authNotifierProvider);
      return authAsync.when(
        loading: () => null,
        error: (_, __) => '/login',
        data: (user) {
          final isLoggedIn = user != null;
          final isOnAuthRoute = state.matchedLocation == '/login' ||
              state.matchedLocation == '/register';
          if (!isLoggedIn && !isOnAuthRoute) return '/login';
          if (isLoggedIn && isOnAuthRoute) return '/dashboard';
          return null;
        },
      );
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(
        path: '/transactions',
        builder: (_, __) => const TransactionListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, __) => const TransactionFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) => TransactionDetailScreen(
              transaction: state.extra as TransactionEntity,
            ),
          ),
        ],
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
}
