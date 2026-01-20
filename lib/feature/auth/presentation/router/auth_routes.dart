import 'package:go_router/go_router.dart';
import '../pages/forgot_password_page.dart'; // Make sure to create this file
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../../../../core/router/app_routes.dart';

final authRoutes = <GoRoute>[
  GoRoute(
    path: AppRoutes.login,
    builder: (_, __) => const LoginPage(),
  ),
  GoRoute(
    path: AppRoutes.register,
    builder: (_, __) => RegisterPage(),
  ),
  GoRoute(
    path: '/forgot-password',
    builder: (_, __) => const ForgotPasswordPage(),
  ),
];