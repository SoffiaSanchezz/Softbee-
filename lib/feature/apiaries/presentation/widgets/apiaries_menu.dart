import 'package:Softbee/core/widgets/honeycomb_loader.dart';
import 'package:Softbee/feature/apiaries/domain/entities/apiary.dart';
import 'package:Softbee/feature/apiaries/presentation/controllers/apiaries_controller.dart';
import 'package:Softbee/feature/apiaries/presentation/providers/apiary_providers.dart';
import 'package:Softbee/feature/apiaries/presentation/widgets/apiary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:Softbee/core/router/app_routes.dart';
import 'package:Softbee/feature/apiaries/presentation/widgets/apiary_form_dialog.dart'; // Import the new dialog

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
    // Listen for state changes to show SnackBar messages
    ref.listen<ApiariesState>(apiariesControllerProvider, (previous, next) {
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(apiariesControllerProvider.notifier).clearMessages();
      }
      if ((next.errorCreating != null && next.errorCreating != previous?.errorCreating) ||
          (next.errorUpdating != null && next.errorUpdating != previous?.errorUpdating) ||
          (next.errorDeleting != null && next.errorDeleting != previous?.errorDeleting) ||
          (next.errorMessage != null && next.errorMessage != previous?.errorMessage)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorCreating ?? next.errorUpdating ?? next.errorDeleting ?? next.errorMessage!,
            ),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(apiariesControllerProvider.notifier).clearMessages();
      }
    });

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
                    onEdit: (apiary) => _showApiaryFormDialog(context, apiary: apiary),
                    onDelete: (apiary) => _confirmDeleteApiary(context, apiary),
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
                  onEdit: (apiary) => _showApiaryFormDialog(context, apiary: apiary),
                  onDelete: (apiary) => _confirmDeleteApiary(context, apiary),
                );
              }, childCount: apiariesState.apiaries.length),
            ),

          // Espaciado inferior
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _showApiaryFormDialog(BuildContext context, {Apiary? apiary}) {
    showDialog(
      context: context,
      builder: (context) => ApiaryFormDialog(apiaryToEdit: apiary),
    ).then((_) {
      // Refresh apiaries after dialog is closed
      ref.read(apiariesControllerProvider.notifier).fetchApiaries();
    });
  }

  void _confirmDeleteApiary(BuildContext context, Apiary apiary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Apiario "${apiary.name}"'),
        content: const Text('¿Estás seguro de que quieres eliminar este apiario? Esta acción es irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(apiariesControllerProvider.notifier).deleteApiary(apiary.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
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
                  color: const Color(0xFFFFC107).withAlpha((255 * 0.3).round()),
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

  void _navigateToApiary(BuildContext context, Apiary apiary) {
    print('Navigating to apiary: ${apiary.id}, name: ${apiary.name}, location: ${apiary.location}');
    context.pushNamed(
      AppRoutes.apiaryDashboardRoute,
      pathParameters: {'apiaryId': apiary.id},
      queryParameters: {
        'apiaryName': apiary.name,
        if (apiary.location != null) 'apiaryLocation': apiary.location!,
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
                      color: const Color(0xFFFFC107).withAlpha((255 * 0.3).round()),
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
                  onPressed: () => _showApiaryFormDialog(context),
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
