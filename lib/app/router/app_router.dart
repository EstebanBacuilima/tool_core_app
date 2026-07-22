import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
}

/// Router with an auth guard driven by the [AuthCubit]:
/// - session unknown  -> splash (while restoring the session)
/// - unauthenticated  -> login
/// - authenticated    -> never stays on splash/login
GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    // Re-evaluates redirects whenever the auth state changes
    // (login, logout, expired session).
    refreshListenable: _CubitRefreshListenable(authCubit),
    redirect: (context, state) {
      final status = authCubit.state.status;
      final location = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }
      if (status == AuthStatus.unauthenticated) {
        return location == AppRoutes.login ? null : AppRoutes.login;
      }
      // Authenticated: leave transient screens.
      if (location == AppRoutes.splash || location == AppRoutes.login) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}

/// Bridges the AuthCubit stream into a [Listenable] for go_router.
class _CubitRefreshListenable extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  _CubitRefreshListenable(AuthCubit cubit) {
    _subscription = cubit.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
