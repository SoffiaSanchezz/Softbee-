import 'package:Softbee/core/widgets/menu_info_apiario.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../feature/auth/presentation/providers/auth_providers.dart';
import '../../feature/auth/presentation/controllers/auth_controller.dart';
import '../pages/not_found_page.dart';
import '../pages/landing_page.dart';
import '../../feature/auth/presentation/pages/user_management_page.dart';

// import '../../feature/apiaries/presentation/widgets/apiary_dashboard_menu.dart';
import '../../feature/apiaries/presentation/pages/monitoring_page.dart';
import '../../feature/apiaries/presentation/pages/inventory_page.dart';
import '../../feature/apiaries/presentation/pages/reports_page.dart';
import '../../feature/apiaries/presentation/pages/history_page.dart';
import '../../feature/apiaries/presentation/pages/hives_page.dart';
import '../../feature/apiaries/presentation/pages/apiary_settings_page.dart';
import '../widgets/dashboard_menu.dart';

import 'app_routes.dart';
import '../../feature/auth/presentation/router/auth_routes.dart';

// Notifier to trigger router refresh on auth state change
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: kIsWeb
        ? AppRoutes.landingRoute
        : AppRoutes.loginRoute, // Lógica de detección de plataforma
    routes: [
      GoRoute(
        path: AppRoutes.landingRoute, // Ruta para Landing Page
        builder: (context, state) => const LandingPage(),
      ),
      ...authRoutes,
      GoRoute(
        path: AppRoutes
            .dashboardRoute, // La ruta principal del dashboard ahora muestra la lista de apiarios
        builder: (context, state) => const MenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.userProfileRoute, // Ruta de perfil de usuario
        builder: (context, state) => const UserManagementPage(),
      ),
      // Rutas específicas del apiario
      GoRoute(
        name: AppRoutes.apiaryDashboardRoute,
        path: AppRoutes.apiaryDashboardRoute,
        builder: (context, state) {
          final apiaryId = state.pathParameters['apiaryId']!;
          final apiaryName = state.uri.queryParameters['apiaryName'];
          final apiaryLocation = state.uri.queryParameters['apiaryLocation'];

          return ApiaryDashboardMenu(
            apiaryId: apiaryId,
            apiaryName: apiaryName ?? 'Apiario Desconocido',
            apiaryLocation: apiaryLocation,
          );
        },
        routes: [
          GoRoute(
            path: 'monitoring',
            name: AppRoutes.monitoringRoute, // Usar nombre para la ruta
            builder: (context, state) {
              final apiaryId = state.pathParameters['apiaryId']!;
              return MonitoringPage(apiaryId: apiaryId);
            },
          ),
          GoRoute(
            path: 'inventory',
            name: AppRoutes.inventoryRoute,
            builder: (context, state) {
              final apiaryId = state.pathParameters['apiaryId']!;
              return InventoryPage(apiaryId: apiaryId);
            },
          ),
          GoRoute(
            path: 'reports',
            name: AppRoutes.reportsRoute,
            builder: (context, state) {
              final apiaryId = state.pathParameters['apiaryId']!;
              return ReportsPage(apiaryId: apiaryId);
            },
          ),
          GoRoute(
            path: 'history',
            name: AppRoutes.historyRoute,
            builder: (context, state) {
              final apiaryId = state.pathParameters['apiaryId']!;
              return HistoryPage(apiaryId: apiaryId);
            },
          ),
          GoRoute(
            path: 'hives',
            name: AppRoutes.hivesRoute,
            builder: (context, state) {
              final apiaryId = state.pathParameters['apiaryId']!;
              return HivesPage(apiaryId: apiaryId);
            },
          ),
          GoRoute(
            path: 'settings',
            name: AppRoutes.apiarySettingsRoute,
            builder: (context, state) {
              final apiaryId = state.pathParameters['apiaryId']!;
              return ApiarySettingsPage(apiaryId: apiaryId);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.loginRoute ||
          state.matchedLocation.startsWith(
            AppRoutes.resetPasswordRoute.split(':')[0],
          );
      final isLandingRoute = state.matchedLocation == AppRoutes.landingRoute;

      // If we are still checking the authentication status, don't redirect yet
      if (authState.isAuthenticating) {
        return null; // Or a loading screen route
      }

      // Si no está logueado y no está en una ruta de autenticación o landing, redirigir al login
      if (!isLoggedIn && !isAuthRoute && !isLandingRoute) {
        return AppRoutes.loginRoute;
      }

      // Si está logueado y en una ruta de autenticación o landing, redirigir al dashboard
      if (isLoggedIn && (isAuthRoute || isLandingRoute)) {
        return AppRoutes.dashboardRoute;
      }

      return null;
    },
    errorBuilder: (context, state) =>
        const NotFoundPage(), // Añadir errorBuilder
  );
});
