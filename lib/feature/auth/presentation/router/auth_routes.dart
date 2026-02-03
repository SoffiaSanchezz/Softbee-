import 'package:go_router/go_router.dart';
import '../pages/forgot_password_page.dart'; // Make sure to create this file
import '../pages/login_page.dart';
import '../pages/reset_password_page.dart';
import '../pages/register_page.dart'; // Importar RegisterPage
import '../../../../core/router/app_routes.dart';

final authRoutes = <GoRoute>[
  GoRoute(path: AppRoutes.loginRoute, builder: (_, __) => const LoginPage()),
  GoRoute(
    path: AppRoutes.registerRoute, // Nueva ruta para el registro
    builder: (_, __) => const RegisterPage(),
  ),
  GoRoute(
    path: '/forgot-password',
    builder: (_, __) => const ForgotPasswordPage(),
  ),
  GoRoute(
    path: AppRoutes.resetPasswordRoute,
    builder: (context, state) {
      final token = state.pathParameters['token'] ?? '';
      return ResetPasswordPage(token: token);
    },
  ),
];
