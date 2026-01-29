import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Softbee/feature/auth/presentation/widgets/user_profile_header.dart'; // Importar el nuevo widget
import '../router/app_routes.dart';

class MenuScreen extends ConsumerWidget { // Cambiar a ConsumerWidget
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Añadir WidgetRef ref
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          // Widget para mostrar el perfil del usuario
          UserProfileHeader(),
          const SizedBox(width: 8),
          // Botón de ejemplo para ir a la página de perfil (si existiera)
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onPressed: () {
              // Navegar a la página de gestión de usuario o perfil
              // GoRouter.of(context).go(AppRoutes.userProfile); // Asumiendo una ruta de perfil
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Softbee!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ejemplo de navegación al cerrar sesión, esto ya se maneja en UserProfileHeader
                // ref.read(authControllerProvider.notifier).logout();
              },
              child: const Text('Ir a Landing Page'),
            ),
          ],
        ),
      ),
    );
  }
}
