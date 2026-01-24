// core/router/app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Importar kIsWeb
import '../../feature/auth/presentation/providers/auth_providers.dart';
import '../widgets/dashboard_menu.dart';
import '../pages/not_found_page.dart'; // Importar NotFoundPage
import '../pages/landing_page.dart'; // Importar LandingPage
import 'app_routes.dart';
import '../../feature/auth/presentation/router/auth_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: kIsWeb ? AppRoutes.landing : AppRoutes.login, // Lógica de detección de plataforma
    routes: [
      GoRoute(
        path: AppRoutes.landing, // Ruta para Landing Page
        builder: (context, state) => const LandingPage(),
      ),
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
          state.matchedLocation.startsWith(AppRoutes.resetPassword.split(':')[0]); // Incluir resetPassword
      final isLandingRoute = state.matchedLocation == AppRoutes.landing;


      // If we are still checking the authentication status, don't redirect yet
      if (authState.isAuthenticating) {
        return null; // Or a loading screen route
      }

      // Si no está logueado y no está en una ruta de autenticación o landing, redirigir al login
      if (!isLoggedIn && !isAuthRoute && !isLandingRoute) {
        return AppRoutes.login;
      }
      
      // Si está logueado y en una ruta de autenticación o landing, redirigir al dashboard
      if (isLoggedIn && (isAuthRoute || isLandingRoute)) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    errorBuilder: (context, state) => const NotFoundPage(), // Añadir errorBuilder
  );
});
