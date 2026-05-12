import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/core/router/go_router_refresh_notifier.dart';
import 'package:bytebank_app/core/widgets/splash_screen.dart';
import 'package:bytebank_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:bytebank_app/features/auth/presentation/screens/login_screen.dart';
import 'package:bytebank_app/features/auth/presentation/screens/register_screen.dart';
import 'package:bytebank_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/dashboard_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/transaction_form_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/transaction_list_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final notifier = GoRouterRefreshNotifier();
  ref.listen(authNotifierProvider, (prev, next) => notifier.refresh());
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authNotifierProvider);
      return authAsync.when(
        loading: () =>
            state.matchedLocation == '/splash' ? null : '/splash',
        error: (err, stack) => '/login',
        data: (user) {
          final isLoggedIn = user != null;
          final isOnAuthRoute = state.matchedLocation == '/login' ||
              state.matchedLocation == '/register';
          final isOnSplash = state.matchedLocation == '/splash';
          if (!isLoggedIn) {
            return isOnAuthRoute ? null : '/login';
          }
          if (isOnAuthRoute || isOnSplash) return '/dashboard';
          return null;
        },
      );
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const TransactionFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) => TransactionDetailScreen(
              transaction: state.extra as TransactionEntity,
            ),
          ),
        ],
      ),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    ],
  );
}
