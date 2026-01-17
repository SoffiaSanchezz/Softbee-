// core/router/app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../feature/auth/presentation/router/auth_routes.dart';
import '../../feature/auth/presentation/controllers/auth_controller.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      ...authRoutes,
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      // if (isLoggedIn && isAuthRoute) {
      //   return AppRoutes.home;
      // }

      return null;
    },
  );
});
