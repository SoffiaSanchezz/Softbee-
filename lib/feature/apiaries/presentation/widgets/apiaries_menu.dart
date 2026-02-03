import 'package:Softbee/core/widgets/honeycomb_loader.dart';
import 'package:Softbee/feature/apiaries/presentation/providers/apiary_providers.dart';
import 'package:Softbee/feature/apiaries/presentation/widgets/apiary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:Softbee/core/router/app_routes.dart';

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

    // Breakpoints responsive
    final isSmallScreen = screenWidth < 400;
    final isLargeScreen = screenWidth >= 600;
    final isExtraLargeScreen = screenWidth >= 900;

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

    // Estado vacío
    if (apiariesState.apiaries.isEmpty) {
      return _buildEmptyState(context, isSmallScreen);
    }

    // Determinar número de columnas para grid en pantallas grandes
    final crossAxisCount = isExtraLargeScreen ? 3 : (isLargeScreen ? 2 : 1);

    // Lista de apiarios con diseño responsive
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(apiariesControllerProvider.notifier).fetchApiaries();
      },
      color: const Color(0xFFFFC107),
      backgroundColor: Colors.white,
      child: CustomScrollView(
        slivers: [
          // Header con contador
          SliverToBoxAdapter(
            child: _buildHeader(
              context,
              apiariesState.apiaries.length,
              isSmallScreen,
            ),
          ),

          // Grid/Lista de apiarios
          if (crossAxisCount > 1)
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 16 : 8,
                vertical: 8,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: isExtraLargeScreen ? 2.2 : 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final apiary = apiariesState.apiaries[index];
                  return ApiaryCard(
                    apiary: apiary,
                    onTap: () => _navigateToApiary(context, apiary),
                  );
                }, childCount: apiariesState.apiaries.length),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final apiary = apiariesState.apiaries[index];
                return ApiaryCard(
                  apiary: apiary,
                  onTap: () => _navigateToApiary(context, apiary),
                );
              }, childCount: apiariesState.apiaries.length),
            ),

          // Espaciado inferior
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  /// Header con contador de apiarios
  Widget _buildHeader(BuildContext context, int count, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 20,
        isSmallScreen ? 12 : 16,
        isSmallScreen ? 16 : 20,
        isSmallScreen ? 8 : 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis Apiarios',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 22 : 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count apiario${count != 1 ? 's' : ''} registrado${count != 1 ? 's' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: const Color(0xFF757575),
                ),
              ),
            ],
          ),
          // Contador visual
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFFC107), const Color(0xFFFFB300)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC107).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hive_rounded,
                  size: isSmallScreen ? 18 : 22,
                  color: const Color(0xFF1A1A1A),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToApiary(BuildContext context, dynamic apiary) {
    context.pushNamed(
      AppRoutes.apiaryDashboardRoute,
      pathParameters: {'apiaryId': apiary.id},
      queryParameters: {
        'apiaryName': apiary.name,
        'apiaryLocation': apiary.location,
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String errorMessage,
    bool isSmallScreen,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 20.0 : 32.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade100, width: 2),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade400,
                  size: isSmallScreen ? 48 : 56,
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 28),
              Text(
                'Algo salió mal',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 20 : 24,
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
                  height: 1.5,
                ),
              ),
              SizedBox(height: isSmallScreen ? 24 : 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref
                      .read(apiariesControllerProvider.notifier)
                      .fetchApiaries(),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    'Reintentar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 14 : 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: const Color(0xFF1A1A1A),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 14 : 16,
                    ),
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 20.0 : 32.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustración mejorada
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 28 : 36),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFC107).withOpacity(0.2),
                      const Color(0xFFFFC107).withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFC107).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.hive_outlined,
                    color: const Color(0xFFF57C00),
                    size: isSmallScreen ? 48 : 60,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 24 : 32),
              Text(
                'Sin apiarios',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 22 : 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'No se encontraron apiarios para tu usuario.\nCrea tu primer apiario para comenzar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 15,
                    color: const Color(0xFF757575),
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 28 : 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Funcionalidad para crear apiario no implementada aún.',
                          style: GoogleFonts.poppins(),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF424242),
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
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: const Color(0xFF1A1A1A),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 14 : 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    shadowColor: const Color(0xFFFFC107).withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref
                    .read(apiariesControllerProvider.notifier)
                    .fetchApiaries(),
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: const Color(0xFF757575),
                ),
                label: Text(
                  'Actualizar lista',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF757575),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
