import 'package:Softbee/core/widgets/honeycomb_loader.dart';
import 'package:Softbee/feature/apiaries/presentation/providers/apiary_providers.dart';
import 'package:Softbee/feature/apiaries/presentation/widgets/apiary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:Softbee/core/router/app_routes.dart'; // Import AppRoutes

class ApiariesMenu extends ConsumerStatefulWidget {
  const ApiariesMenu({super.key});

  @override
  ConsumerState<ApiariesMenu> createState() => _ApiariesMenuState();
}

class _ApiariesMenuState extends ConsumerState<ApiariesMenu> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(apiariesControllerProvider.notifier).fetchApiaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiariesState = ref.watch(apiariesControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Estado de carga
    if (apiariesState.isLoading) {
      return const Center(child: HoneycombLoader());
    }

    // Estado de error
    if (apiariesState.errorMessage != null &&
        apiariesState.errorMessage!.isNotEmpty) {
      return _buildErrorState(
        context,
        apiariesState.errorMessage!,
        isSmallScreen,
      );
    }

    // Estado vacio
    if (apiariesState.apiaries.isEmpty) {
      return _buildEmptyState(context, isSmallScreen);
    }

    // Lista de apiarios
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(apiariesControllerProvider.notifier).fetchApiaries();
      },
      color: const Color(0xFFFFC107),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: isSmallScreen ? 4 : 0,
        ),
        itemCount: apiariesState.apiaries.length,
        itemBuilder: (context, index) {
          final apiary = apiariesState.apiaries[index];
          return ApiaryCard(
            apiary: apiary,
            onTap: () {
              // Navegar al ApiaryDashboardMenu pasando los parámetros
              context.pushNamed(
                AppRoutes.apiaryDashboardRoute,
                pathParameters: {'apiaryId': apiary.id},
                queryParameters: {
                  'apiaryName': apiary.name,
                  'apiaryLocation': apiary.location,
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String errorMessage,
    bool isSmallScreen,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 0, 0, 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: isSmallScreen ? 48 : 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Algo salio mal',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 13 : 14,
                color: const Color(0xFF757575),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => ref
                    .read(apiariesControllerProvider.notifier)
                    .fetchApiaries(),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  'Reintentar',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 193, 7, 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hive_outlined,
                color: const Color(0xFFF57C00),
                size: isSmallScreen ? 56 : 72,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin apiarios',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No se encontraron apiarios para tu usuario. Crea tu primer apiario para comenzar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: const Color(0xFF757575),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Funcionalidad para crear apiario no implementada aun.',
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 22),
                label: Text(
                  'Crear nuevo apiario',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 14 : 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
