import 'package:Softbee/feature/apiaries/domain/entities/apiary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApiaryCard extends StatelessWidget {
  final Apiary apiary;
  final VoidCallback onTap;

  const ApiaryCard({super.key, required this.apiary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Breakpoints para responsive
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 6.0 : 10.0,
        horizontal: isSmallScreen ? 12.0 : 16.0,
      ),
      elevation: isSmallScreen ? 2 : 4,
      shadowColor: const Color(0xFFFFC107).withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        splashColor: const Color(0xFFFFC107).withOpacity(0.2),
        highlightColor: const Color(0xFFFFC107).withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFFFF8E1).withOpacity(0.5)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: isSmallScreen
                ? _buildVerticalLayout(context, isSmallScreen)
                : _buildHorizontalLayout(
                    context,
                    isMediumScreen,
                    isLargeScreen,
                  ),
          ),
        ),
      ),
    );
  }

  /// Layout vertical para pantallas pequeñas
  Widget _buildVerticalLayout(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icono centrado
        _buildIconContainer(size: 56, iconSize: 32),
        const SizedBox(height: 12),

        // Información del apiario
        Text(
          apiary.name,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: const Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                apiary.location ?? 'Ubicación no especificada',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF757575),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Stats row
        _buildStatsRow(isCompact: true),
        const SizedBox(height: 12),

        // Botón de ver detalles
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ver detalles',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF57C00),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Color(0xFFF57C00),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Layout horizontal para pantallas medianas y grandes
  Widget _buildHorizontalLayout(
    BuildContext context,
    bool isMediumScreen,
    bool isLargeScreen,
  ) {
    final iconSize = isLargeScreen ? 60.0 : 52.0;
    final iconInnerSize = isLargeScreen ? 34.0 : 28.0;

    return Row(
      children: [
        // Icono
        _buildIconContainer(size: iconSize, iconSize: iconInnerSize),
        SizedBox(width: isLargeScreen ? 20 : 16),

        // Información del apiario
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                apiary.name,
                style: GoogleFonts.poppins(
                  fontSize: isLargeScreen ? 20 : 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: const Color(0xFF9E9E9E),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      apiary.location ?? 'Ubicación no especificada',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 14 : 13,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
              if (isLargeScreen) ...[
                const SizedBox(height: 10),
                _buildStatsRow(isCompact: false),
              ],
            ],
          ),
        ),

        // Stats para pantallas medianas (inline)
        if (isMediumScreen) ...[
          const SizedBox(width: 12),
          _buildCompactStats(),
        ],

        const SizedBox(width: 8),

        // Flecha indicadora
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFF57C00),
            size: 24,
          ),
        ),
      ],
    );
  }

  /// Container del icono con estilo mejorado
  Widget _buildIconContainer({required double size, required double iconSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFC107).withOpacity(0.25),
            const Color(0xFFFFB300).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: const Color(0xFFFFC107).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.hive_rounded,
        color: const Color(0xFFF57C00),
        size: iconSize,
      ),
    );
  }

  /// Fila de estadísticas
  Widget _buildStatsRow({required bool isCompact}) {
    return Row(
      mainAxisAlignment: isCompact
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.start,
      children: [
        _buildStatItem(
          icon: Icons.grid_view_rounded,
          value: '${apiary.beehivesCount ?? 0}',
          label: 'Colmenas',
          isCompact: isCompact,
        ),
        SizedBox(width: isCompact ? 0 : 20),
        _buildStatItem(
          icon: Icons.calendar_today_rounded,
          value: _formatDate(apiary.createdAt),
          label: 'Creado',
          isCompact: isCompact,
        ),
      ],
    );
  }

  /// Estadísticas compactas para pantallas medianas
  Widget _buildCompactStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.grid_view_rounded,
            size: 16,
            color: Color(0xFFF57C00),
          ),
          const SizedBox(width: 4),
          Text(
            '${apiary.beehivesCount ?? 0}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  /// Item individual de estadística
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isCompact,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isCompact ? 14 : 16, color: const Color(0xFFF57C00)),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isCompact ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF424242),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isCompact ? 11 : 12,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }

  /// Formatea la fecha de creación
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
