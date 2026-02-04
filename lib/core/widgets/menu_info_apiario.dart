import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Softbee/core/router/app_routes.dart';
import 'package:Softbee/feature/auth/presentation/widgets/user_profile_header.dart';
import 'package:Softbee/core/theme/app_colors.dart';

// Data class for menu items
class MenuItemData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String routeName;

  MenuItemData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.routeName,
  });
}

// The main widget, converted to ConsumerStatefulWidget
class ApiaryDashboardMenu extends ConsumerStatefulWidget {
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
  ConsumerState<ApiaryDashboardMenu> createState() =>
      _ApiaryDashboardMenuState();
}

class _ApiaryDashboardMenuState extends ConsumerState<ApiaryDashboardMenu>
    with TickerProviderStateMixin {
  int? _hoveredIndex;
  late final List<MenuItemData> _menuItems;

  @override
  void initState() {
    super.initState();
    _menuItems = [
      MenuItemData(
        title: 'Monitoreo',
        description: 'Estado de colmenas en tiempo real',
        icon: Icons.monitor_heart_rounded,
        color: AppColors.primaryYellow,
        routeName: AppRoutes.monitoringRoute,
      ),
      MenuItemData(
        title: 'Inventario',
        description: 'Gestiona materiales y productos',
        icon: Icons.inventory_rounded,
        color: AppColors.primaryYellow,
        routeName: AppRoutes.inventoryRoute,
      ),
      MenuItemData(
        title: 'Reportes',
        description: 'Genera informes de producción',
        icon: Icons.insert_chart_rounded,
        color: AppColors.primaryYellow,
        routeName: AppRoutes.reportsRoute,
      ),
      MenuItemData(
        title: 'Historial',
        description: 'Revisa inspecciones pasadas',
        icon: Icons.history_edu_rounded,
        color: AppColors.primaryYellow,
        routeName: AppRoutes.historyRoute,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFFF8E1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildInteractiveMenu()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.go(AppRoutes.dashboardRoute),
                color: const Color(0xFF333333),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.apiaryName,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  if (widget.apiaryLocation != null &&
                      widget.apiaryLocation!.isNotEmpty)
                    Text(
                      widget.apiaryLocation!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const UserProfileHeader(),
        ],
      ),
    );
  }

  Widget _buildInteractiveMenu() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth < 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.0;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
          childAspectRatio = 1.1;
        } else {
          crossAxisCount = 3;
          childAspectRatio = 1.2;
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return EnhancedMenuButton(
                title: item.title,
                icon: item.icon,
                color: item.color,
                description: item.description,
                isHovered: _hoveredIndex == index,
                onHover: (hovered) =>
                    setState(() => _hoveredIndex = hovered ? index : null),
                onTap: () {
                  context.goNamed(
                    item.routeName,
                    pathParameters: {'apiaryId': widget.apiaryId},
                  );
                },
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: (100 * index).ms)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 600.ms,
                    delay: (100 * index).ms,
                    curve: Curves.easeOutQuint,
                  );
            },
          ),
        );
      },
    );
  }
}

class EnhancedMenuButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final bool isHovered;
  final Function(bool) onHover;
  final VoidCallback onTap;

  const EnhancedMenuButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  @override
  State<EnhancedMenuButton> createState() => _EnhancedMenuButtonState();
}

class _EnhancedMenuButtonState extends State<EnhancedMenuButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _scaleController.forward();
  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse().then((_) {
      if (mounted) {
        widget.onTap();
      }
    });
  }
  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuart,
            transform: Matrix4.identity()
              ..translate(0.0, widget.isHovered ? -8.0 : 0.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentYellow, AppColors.primaryYellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color:
                      widget.color.withOpacity(widget.isHovered ? 0.4 : 0.2),
                  blurRadius: widget.isHovered ? 20 : 12,
                  offset: Offset(0, widget.isHovered ? 12 : 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    bottom: -30,
                    child: Opacity(
                      opacity: 0.2,
                      child:
                          Icon(widget.icon, size: 140, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(widget.icon,
                                      color: Colors.white, size: 28),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: widget.isHovered ? 1.0 : 0.0,
                          child: const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}