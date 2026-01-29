import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Softbee/feature/auth/presentation/providers/auth_providers.dart';

class UserProfileHeader extends ConsumerWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    // Muestra un indicador de carga mientras se autentica o si el usuario aún no se ha cargado
    if (authState.isAuthenticating || (authState.isAuthenticated && authState.user == null)) {
      return const Padding(
        padding: EdgeInsets.only(right: 16.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Si el usuario está autenticado, muestra el perfil
    if (authState.isAuthenticated && authState.user != null) {
      final user = authState.user!;
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFFBBF24), // Amarillo del tema
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              user.username,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 8),
            // Añadimos un botón de logout para darle funcionalidad
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.grey),
              tooltip: 'Cerrar Sesión',
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ],
        ),
      );
    }

    // Si no está autenticado, no muestra nada
    return const SizedBox.shrink();
  }
}
