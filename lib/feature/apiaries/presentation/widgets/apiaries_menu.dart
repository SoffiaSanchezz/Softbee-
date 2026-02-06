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
import 'package:Softbee/feature/apiaries/presentation/widgets/apiary_form_dialog.dart';

// ─── Constantes de diseño ────────────────────────────────────────────────────
const _amberPrimary = Color(0xFFFFC107);
const _amberDark = Color(0xFFFFB300);
const _amberAccent = Color(0xFFF57C00);
const _textDark = Color(0xFF1A1A1A);
const _textMuted = Color(0xFF757575);
const _borderLight = Color(0xFFE0E0E0);

// ─── Helper class para valores responsive ────────────────────────────────────
class _SearchBarConfig {
  final double toolbarHeight;
  final double fontSize;
  final double iconSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double clearButtonSize;
  final String hintText;

  const _SearchBarConfig({
    required this.toolbarHeight,
    required this.fontSize,
    required this.iconSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.clearButtonSize,
    required this.hintText,
  });

  /// Factory que determina la configuración según el ancho de pantalla
  factory _SearchBarConfig.fromWidth(double width) {
    if (width < 360) {
      // Dispositivos muy pequeños (iPhone SE, etc.)
      return const _SearchBarConfig(
        toolbarHeight: 60,
        fontSize: 13,
        iconSize: 20,
        horizontalPadding: 12,
        verticalPadding: 8,
        borderRadius: 12,
        clearButtonSize: 16,
        hintText: 'Buscar apiario...',
      );
    } else if (width < 400) {
      // Teléfonos pequeños
      return const _SearchBarConfig(
        toolbarHeight: 64,
        fontSize: 14,
        iconSize: 22,
        horizontalPadding: 14,
        verticalPadding: 8,
        borderRadius: 14,
        clearButtonSize: 17,
        hintText: 'Buscar apiario...',
      );
    } else if (width < 600) {
      // Teléfonos estándar
      return const _SearchBarConfig(
        toolbarHeight: 70,
        fontSize: 15,
        iconSize: 22,
        horizontalPadding: 16,
        verticalPadding: 8,
        borderRadius: 16,
        clearButtonSize: 18,
        hintText: 'Buscar apiario por nombre...',
      );
    } else if (width < 900) {
      // Tablets portrait
      return const _SearchBarConfig(
        toolbarHeight: 74,
        fontSize: 16,
        iconSize: 24,
        horizontalPadding: 24,
        verticalPadding: 10,
        borderRadius: 16,
        clearButtonSize: 18,
        hintText: 'Buscar apiario por nombre...',
      );
    } else {
      // Tablets landscape / pantallas grandes
      return const _SearchBarConfig(
        toolbarHeight: 78,
        fontSize: 16,
        iconSize: 24,
        horizontalPadding: 32,
        verticalPadding: 10,
        borderRadius: 18,
        clearButtonSize: 18,
        hintText: 'Buscar apiario por nombre o ubicación...',
      );
    }
  }
}

// ─── Widget principal ────────────────────────────────────────────────────────
class ApiariesMenu extends ConsumerStatefulWidget {
  const ApiariesMenu({super.key});

  @override
  ConsumerState<ApiariesMenu> createState() => _ApiariesMenuState();
}

class _ApiariesMenuState extends ConsumerState<ApiariesMenu> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _searchFocusNode.addListener(_onFocusChanged);

    _searchController.addListener(() {
      ref
          .read(apiariesControllerProvider.notifier)
          .applyFilter(_searchController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(apiariesControllerProvider.notifier).fetchApiaries();
    });
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() => _isFocused = _searchFocusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes to show SnackBar messages
    ref.listen<ApiariesState>(apiariesControllerProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(apiariesControllerProvider.notifier).clearMessages();
      }
      if ((next.errorCreating != null &&
              next.errorCreating != previous?.errorCreating) ||
          (next.errorUpdating != null &&
              next.errorUpdating != previous?.errorUpdating) ||
          (next.errorDeleting != null &&
              next.errorDeleting != previous?.errorDeleting) ||
          (next.errorMessage != null &&
              next.errorMessage != previous?.errorMessage)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorCreating ??
                  next.errorUpdating ??
                  next.errorDeleting ??
                  next.errorMessage!,
            ),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(apiariesControllerProvider.notifier).clearMessages();
      }
    });

    final apiariesState = ref.watch(apiariesControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final config = _SearchBarConfig.fromWidth(screenWidth);

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
    if (apiariesState.filteredApiaries.isEmpty) {
      if (apiariesState.searchQuery.isNotEmpty) {
        return _buildNoSearchResultsState(
          context,
          isSmallScreen,
          apiariesState.searchQuery,
        );
      } else {
        return _buildEmptyState(context, isSmallScreen);
      }
    }

    // Determinar número de columnas para grid en pantallas grandes
    final crossAxisCount = isExtraLargeScreen ? 3 : (isLargeScreen ? 2 : 1);

    // Lista de apiarios con diseño responsive
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(apiariesControllerProvider.notifier).fetchApiaries();
      },
      color: _amberPrimary,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        slivers: [
          // ─── SliverAppBar mejorado ─────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            toolbarHeight: config.toolbarHeight,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            shadowColor: Colors.black.withOpacity(0.1),
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: _buildSearchBar(config, isLargeScreen, isExtraLargeScreen),
          ),

          // Header con contador
          SliverToBoxAdapter(
            child: _buildHeader(
              context,
              apiariesState.filteredApiaries.length,
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
                  final apiary = apiariesState.filteredApiaries[index];
                  return ApiaryCard(
                    apiary: apiary,
                    onTap: () => _navigateToApiary(context, apiary),
                    onEdit: (apiary) =>
                        _showApiaryFormDialog(context, apiary: apiary),
                    onDelete: (apiary) => _confirmDeleteApiary(context, apiary),
                  );
                }, childCount: apiariesState.filteredApiaries.length),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final apiary = apiariesState.filteredApiaries[index];
                return ApiaryCard(
                  apiary: apiary,
                  onTap: () => _navigateToApiary(context, apiary),
                  onEdit: (apiary) =>
                      _showApiaryFormDialog(context, apiary: apiary),
                  onDelete: (apiary) => _confirmDeleteApiary(context, apiary),
                );
              }, childCount: apiariesState.filteredApiaries.length),
            ),

          // Espaciado inferior
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // ─── Barra de búsqueda responsive con animaciones ──────────────────────────
  Widget _buildSearchBar(
    _SearchBarConfig config,
    bool isLargeScreen,
    bool isExtraLargeScreen,
  ) {
    // Limitar ancho en pantallas grandes para que no se estire infinitamente
    final double maxWidth = isExtraLargeScreen
        ? 680
        : isLargeScreen
        ? 540
        : double.infinity;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: config.horizontalPadding,
        vertical: config.verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListenableBuilder(
            listenable: _searchController,
            builder: (context, _) {
              final hasText = _searchController.text.isNotEmpty;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _isFocused
                      ? Colors.white
                      : hasText
                      ? const Color(0xFFFFFDF5)
                      : const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(config.borderRadius),
                  border: Border.all(
                    color: _isFocused
                        ? _amberPrimary
                        : hasText
                        ? _amberPrimary.withOpacity(0.4)
                        : _borderLight,
                    width: _isFocused ? 2.0 : 1.5,
                  ),
                  boxShadow: [
                    if (_isFocused)
                      BoxShadow(
                        color: _amberPrimary.withOpacity(0.12),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: TextFormField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: config.hintText,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: config.fontSize,
                      color: const Color(0xFFB0B0B0),
                      fontWeight: FontWeight.w400,
                    ),

                    // ── Icono de búsqueda con cambio de color animado ──
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                        left: config.horizontalPadding * 0.8,
                        right: 8,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: Icon(
                          Icons.search_rounded,
                          key: ValueKey<bool>(_isFocused || hasText),
                          color: _isFocused || hasText
                              ? _amberAccent
                              : const Color(0xFF9E9E9E),
                          size: config.iconSize,
                        ),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: config.iconSize + config.horizontalPadding,
                      minHeight: 0,
                    ),

                    // ── Botón de limpiar con animación de escala ──
                    suffixIcon: hasText
                        ? Padding(
                            padding: EdgeInsets.only(
                              right: config.horizontalPadding * 0.5,
                            ),
                            child: _AnimatedClearButton(
                              size: config.clearButtonSize,
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(apiariesControllerProvider.notifier)
                                    .applyFilter('');
                              },
                            ),
                          )
                        : null,
                    suffixIconConstraints: BoxConstraints(
                      minWidth: config.iconSize + config.horizontalPadding,
                      minHeight: 0,
                    ),

                    // ── Sin bordes propios (el contenedor padre los maneja) ──
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: config.verticalPadding + 4,
                      horizontal: 0,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: config.fontSize,
                    fontWeight: FontWeight.w500,
                    color: _textDark,
                  ),
                  cursorColor: _amberAccent,
                  cursorWidth: 2,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Diálogos ──────────────────────────────────────────────────────────────

  void _showApiaryFormDialog(BuildContext context, {Apiary? apiary}) {
    showDialog(
      context: context,
      builder: (context) => ApiaryFormDialog(apiaryToEdit: apiary),
    ).then((_) {
      ref.read(apiariesControllerProvider.notifier).fetchApiaries();
    });
  }

  void _confirmDeleteApiary(BuildContext context, Apiary apiary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Apiario "${apiary.name}"'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este apiario? Esta acción es irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(apiariesControllerProvider.notifier)
                  .deleteApiary(apiary.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header con contador ───────────────────────────────────────────────────

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Apiarios',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 22 : 26,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$count apiario${count != 1 ? 's' : ''} registrado${count != 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 10,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_amberPrimary, _amberDark],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _amberPrimary.withAlpha((255 * 0.3).round()),
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
                  color: _textDark,
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Navegación ────────────────────────────────────────────────────────────

  void _navigateToApiary(BuildContext context, Apiary apiary) {
    context.pushNamed(
      AppRoutes.apiaryDashboardRoute,
      pathParameters: {'apiaryId': apiary.id},
      queryParameters: {
        'apiaryName': apiary.name,
        if (apiary.location != null) 'apiaryLocation': apiary.location!,
      },
    );
  }

  // ─── Estados vacíos / error ────────────────────────────────────────────────

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
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: _textMuted,
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
                    backgroundColor: _amberPrimary,
                    foregroundColor: _textDark,
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 28 : 36),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _amberPrimary.withOpacity(0.2),
                      _amberPrimary.withOpacity(0.05),
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
                      color: _amberPrimary.withAlpha((255 * 0.3).round()),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.hive_outlined,
                    color: _amberAccent,
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
                  color: _textDark,
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
                    color: _textMuted,
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
                    backgroundColor: _amberPrimary,
                    foregroundColor: _textDark,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 14 : 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    shadowColor: _amberPrimary.withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref
                    .read(apiariesControllerProvider.notifier)
                    .fetchApiaries(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: _textMuted,
                ),
                label: Text(
                  'Actualizar lista',
                  style: GoogleFonts.poppins(fontSize: 13, color: _textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResultsState(
    BuildContext context,
    bool isSmallScreen,
    String searchQuery,
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
                padding: EdgeInsets.all(isSmallScreen ? 28 : 36),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.grey.shade300.withOpacity(0.2),
                      Colors.grey.shade300.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    color: Colors.grey.shade500,
                    size: isSmallScreen ? 48 : 60,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 24 : 32),
              Text(
                'No hay resultados',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 22 : 26,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'No se encontraron apiarios que coincidan con "$searchQuery".\nIntenta con otro nombre o revisa la ortografía.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 15,
                    color: _textMuted,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 28 : 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(apiariesControllerProvider.notifier)
                        .applyFilter('');
                  },
                  icon: const Icon(Icons.clear_all_rounded, size: 22),
                  label: Text(
                    'Limpiar búsqueda',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 14 : 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    shadowColor: Colors.grey.shade700.withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref
                    .read(apiariesControllerProvider.notifier)
                    .fetchApiaries(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: _textMuted,
                ),
                label: Text(
                  'Actualizar lista completa',
                  style: GoogleFonts.poppins(fontSize: 13, color: _textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Botón de limpiar con animación de escala al aparecer ─────────────────────
class _AnimatedClearButton extends StatefulWidget {
  final double size;
  final VoidCallback onPressed;

  const _AnimatedClearButton({required this.size, required this.onPressed});

  @override
  State<_AnimatedClearButton> createState() => _AnimatedClearButtonState();
}

class _AnimatedClearButtonState extends State<_AnimatedClearButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: const Color(0xFF616161),
            size: widget.size,
          ),
        ),
        onPressed: widget.onPressed,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
