// core/router/app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:softbee/feature/auth/presentation/controllers/auth_controller.dart';
import '../../feature/auth/presentation/providers/auth_providers.dart';
import '../widgets/dashboard_menu.dart';
import 'app_routes.dart';
import '../../feature/auth/presentation/router/auth_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      ...authRoutes,
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const MenuScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // If we are still checking the authentication status, don't redirect yet
      if (authState.isAuthenticating) {
        return null; // Or a loading screen route
      }

      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.dashboard;
      }

      return null;
    },
  );
});
