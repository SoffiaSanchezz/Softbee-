import 'package:go_router/go_router.dart';
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
    builder: (_, __) => const RegisterPage(),
  ),
];