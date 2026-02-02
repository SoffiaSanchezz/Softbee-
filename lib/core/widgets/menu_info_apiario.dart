import 'package:Softbee/feature/auth/presentation/widgets/user_profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Softbee/core/router/app_routes.dart';

class ApiaryDashboardMenu extends ConsumerWidget {
  final String apiaryId;
  final String apiaryName;
  final String? apiaryLocation;

  const ApiaryDashboardMenu({
    super.key,
    required this.apiaryId,
    required this.apiaryName,
    this.apiaryLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMobile = screenWidth < 600;

    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Monitoreo',
        'icon': Icons.monitor_heart_rounded,
        'route': AppRoutes.monitoringRoute,
      },
      {
        'title': 'Inventario',
        'icon': Icons.inventory_rounded,
        'route': AppRoutes.inventoryRoute,
      },
      {
        'title': 'Reportes',
        'icon': Icons.description_rounded,
        'route': AppRoutes.reportsRoute,
      },
      {
        'title': 'Historial',
        'icon': Icons.history_edu_rounded,
        'route': AppRoutes.historyRoute,
      },
      {
        'title': 'Colmenas',
        'icon': Icons.hive_rounded,
        'route': AppRoutes.hivesRoute,
      },
      {
        'title': 'Configuración',
        'icon': Icons.settings_rounded,
        'route': AppRoutes.apiarySettingsRoute,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: isSmallScreen ? 12 : 16,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A1A),
          ),
          onPressed: () {
            context.go(AppRoutes.dashboardRoute);
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    apiaryName,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (!isMobile &&
                      apiaryLocation != null &&
                      apiaryLocation!.isNotEmpty)
                    Text(
                      apiaryLocation!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          const UserProfileHeader(),
          SizedBox(width: isSmallScreen ? 4 : 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 2 : (isMobile ? 3 : 4),
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  context.goNamed(
                    item['route'],
                    pathParameters: {'apiaryId': apiaryId},
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'],
                      size: isSmallScreen ? 40 : 50,
                      color: const Color(0xFFFFC107),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['title'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Acción para agregar al apiario $apiaryName'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          isMobile ? 'Agregar' : 'Agregar al apiario',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
