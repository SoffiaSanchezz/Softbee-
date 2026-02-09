import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Softbee/feature/inventory/data/models/inventory_item.dart';
import 'package:Softbee/feature/inventory/presentation/providers/inventory_controller.dart';
import 'package:Softbee/feature/inventory/presentation/providers/inventory_state.dart';
import 'package:Softbee/feature/inventory/presentation/widgets/error_display_widget.dart';
import 'package:Softbee/feature/inventory/presentation/widgets/loading_indicator_widget.dart';

// Enum para definir los tipos de pantalla
enum ScreenType { mobile, tablet, desktop }

// Clase para manejar breakpoints responsivos
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1250;
  static const double desktop = 1400;

  static ScreenType getScreenType(double width) {
    if (width < mobile) return ScreenType.mobile;
    if (width < desktop) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}

// Widget responsivo principal
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveBreakpoints.getScreenType(
          constraints.maxWidth,
        );

        switch (screenType) {
          case ScreenType.mobile:
            return mobile;
          case ScreenType.tablet:
            return tablet ?? desktop;
          case ScreenType.desktop:
            return desktop;
        }
      },
    );
  }
}

class InventoryManagementPage extends ConsumerStatefulWidget {
  final String apiaryId; // Changed from int to String

  const InventoryManagementPage({Key? key, required this.apiaryId}) : super(key: key);

  @override
  _InventoryManagementPageState createState() =>
      _InventoryManagementPageState();
}

class _InventoryManagementPageState
    extends ConsumerState<InventoryManagementPage>
    with SingleTickerProviderStateMixin {
  // Controladores para los formularios
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Clave para validación del formulario
  final _formKeyAgregar = GlobalKey<FormState>();

  // Variables de estado local para el diálogo de agregar/editar
  // These will be managed by the InventoryController, but the form state needs local management
  // for the dialog.
  String unidadSeleccionada = 'unidades';

  // Lista de unidades disponibles
  final List<String> unidades = [
    'unidades',
    'láminas',
    'pares',
    'unit',
    'pair',
    'kg',
    'liter',
    'meter',
    'box',
    'gram',
    'ml',
    'dozen',
  ].toSet().toList();

  // Controlador de animación
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
    // No need to call _loadInventoryItems here, as the controller does it
  }

  @override
  void dispose() {
    nombreController.dispose();
    cantidadController.dispose();
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Método para agregar o editar insumos
  Future<void> _guardarInsumo(
    InventoryController controller,
    InventoryState state,
  ) async {
    if (!_formKeyAgregar.currentState!.validate()) {
      return;
    }

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingIndicatorWidget(
          message: state.isEditing
              ? 'Actualizando insumo...'
              : 'Agregando insumo...',
        ),
      );

      InventoryItem itemToSave;
      if (state.isEditing && state.editingItem != null) {
        // Editar insumo existente
        itemToSave = state.editingItem!.copyWith(
          itemName: nombreController.text.trim(),
          quantity: int.parse(cantidadController.text),
          unit: unidadSeleccionada,
        );
      } else {
        // Agregar nuevo insumo
        itemToSave = InventoryItem(
          id: '', // Pass empty string for new items, backend will assign UUID
          itemName: nombreController.text.trim(),
          quantity: int.parse(cantidadController.text),
          unit: unidadSeleccionada,
          apiaryId: widget.apiaryId, // Use the apiaryId from the widget
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      final errorMessage = await controller.guardarInsumo(
        itemToSave,
        apiaryId: widget.apiaryId,
      );

      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();

      if (errorMessage != null) {
        // Show error message
        _showSnackBar(context, errorMessage, Colors.red, Icons.error);
      } else {
        // Cerrar diálogo de formulario
        if (mounted) Navigator.of(context).pop();

        // Mostrar mensaje de éxito
        _showSnackBar(
          context,
          state.isEditing
              ? 'Insumo actualizado correctamente'
              : 'Insumo agregado correctamente',
          Colors.green,
          Icons.check_circle,
        );

        // Limpiar formulario y reset editing state
        _limpiarFormulario(controller);
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (mounted) Navigator.of(context).pop();
      _showSnackBar(context, 'Error: ${e.toString()}', Colors.red, Icons.error);
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message, style: GoogleFonts.poppins())),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Método para limpiar el formulario y resetear el estado de edición del controlador
  void _limpiarFormulario(InventoryController controller) {
    nombreController.clear();
    cantidadController.clear();
    setState(() {
      unidadSeleccionada = 'unit';
    });
    controller.setEditingItem(null); // Reset editing state in controller
  }

  // Método para editar insumos
  void _editarInsumo(InventoryItem insumo, InventoryController controller) {
    nombreController.text = insumo.itemName;
    cantidadController.text = insumo.quantity.toString();
    unidadSeleccionada = insumo.unit;
    controller.setEditingItem(insumo); // Set editing item in controller

    _mostrarDialogoAgregar(controller);
  }

  // Método para eliminar insumos
  Future<void> _eliminarInsumo(String id, InventoryController controller) async { // Changed id to String
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text(
                '¿Eliminar insumo?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Esta acción no se puede deshacer. El insumo será eliminado permanentemente del inventario.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Eliminar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Mostrar indicador de carga
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              LoadingIndicatorWidget(message: 'Eliminando insumo...'),
        );

        final errorMessage = await controller.eliminarInsumo(
          id,
          apiaryId: widget.apiaryId,
        );

        // Cerrar diálogo de carga
        if (mounted) Navigator.of(context).pop();

        if (errorMessage != null) {
          _showSnackBar(context, errorMessage, Colors.red, Icons.error);
        } else {
          _showSnackBar(
            context,
            'Insumo eliminado correctamente',
            Colors.red,
            Icons.delete,
          );
        }
      } catch (e) {
        // Cerrar diálogo de carga
        if (mounted) Navigator.of(context).pop();
        _showSnackBar(
          context,
          'Error al eliminar: ${e.toString()}',
          Colors.red,
          Icons.error,
        );
      }
    }
  }

  // Método para mostrar diálogo de agregar/editar
  void _mostrarDialogoAgregar(InventoryController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    controller.state.isEditing ? Icons.edit : Icons.add_circle,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 8),
                  Text(
                    controller.state.isEditing
                        ? 'Editar Insumo'
                        : 'Agregar Insumo',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Form(
                key: _formKeyAgregar,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completa los detalles del insumo para tu apiario.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del insumo',
                        labelStyle: GoogleFonts.poppins(),
                        hintText: 'Ej: Traje de apicultor',
                        prefixIcon: Icon(
                          Icons.inventory_2,
                          color: Colors.amber,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                        errorStyle: GoogleFonts.poppins(color: Colors.red),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa un nombre';
                        }
                        if (value.trim().length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: cantidadController,
                            decoration: InputDecoration(
                              labelText: 'Cantidad',
                              labelStyle: GoogleFonts.poppins(),
                              hintText: 'Ej: 5',
                              prefixIcon: Icon(
                                Icons.numbers,
                                color: Colors.amber,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.amber),
                              ),
                              errorStyle: GoogleFonts.poppins(
                                color: Colors.red,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa cantidad';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Número válido';
                              }
                              if (int.parse(value) < 0) {
                                return 'Mayor a 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: unidadSeleccionada,
                            decoration: InputDecoration(
                              labelText: 'Unidad',
                              labelStyle: GoogleFonts.poppins(),
                              prefixIcon: Icon(
                                Icons.straighten,
                                color: Colors.amber,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.amber),
                              ),
                            ),
                            items: unidades.map((String unidad) {
                              return DropdownMenuItem<String>(
                                value: unidad,
                                child: Text(
                                  unidad,
                                  style: GoogleFonts.poppins(),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setDialogState(() {
                                unidadSeleccionada = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _limpiarFormulario(controller);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _guardarInsumo(controller, controller.state),
                  child: Text(
                    controller.state.isEditing ? 'Actualizar' : 'Agregar',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método para filtrar insumos
  List<InventoryItem> _getFilteredInsumos(List<InventoryItem> allItems) {
    if (searchController.text.isEmpty) {
      return allItems;
    }
    return allItems
        .where(
          (insumo) => insumo.itemName.toLowerCase().contains(
            searchController.text.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(
      inventoryControllerProvider(widget.apiaryId),
    );
    final inventoryController = ref.read(
      inventoryControllerProvider(widget.apiaryId).notifier,
    );

    if (inventoryState.isLoading) {
      return Scaffold(
        body: LoadingIndicatorWidget(message: 'Cargando inventario...'),
      );
    }

    if (inventoryState.errorMessage != null) {
      return Scaffold(
        body: ErrorDisplayWidget(
          message: inventoryState.errorMessage!,
          onRetry: () =>
              inventoryController.loadInventoryItems(apiaryId: widget.apiaryId),
        ),
      );
    }

    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(inventoryState, inventoryController),
        tablet: _buildTabletLayout(inventoryState, inventoryController),
        desktop: _buildDesktopLayout(inventoryState, inventoryController),
      ),
    );
  }

  // Layout para móviles (diseño actual)
  Widget _buildMobileLayout(
    InventoryState state,
    InventoryController controller,
  ) {
    return Container(
      color: const Color(0xFFFFF8E1),
      child: Column(
        children: [
          _buildHeader(state, ScreenType.mobile),
          _buildSearchAndAddSection(state, controller, ScreenType.mobile),
          Expanded(
            child: _buildListaInsumos(state, controller, ScreenType.mobile),
          ),
        ],
      ),
    );
  }

  // Layout para tablets
  Widget _buildTabletLayout(
    InventoryState state,
    InventoryController controller,
  ) {
    return Container(
      color: const Color(0xFFFFF8E1),
      child: Column(
        children: [
          _buildHeader(state, ScreenType.tablet),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Panel lateral con información
                  SizedBox(width: 280, child: _buildSidePanel(state)),
                  const SizedBox(width: 16),
                  // Contenido principal
                  Expanded(
                    child: Column(
                      children: [
                        _buildSearchAndAddSection(
                          state,
                          controller,
                          ScreenType.tablet,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildListaInsumos(
                            state,
                            controller,
                            ScreenType.tablet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Layout para desktop
  Widget _buildDesktopLayout(
    InventoryState state,
    InventoryController controller,
  ) {
    return Container(
      color: const Color(0xFFFFF8E1),
      child: Column(
        children: [
          _buildHeader(state, ScreenType.desktop),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Panel lateral expandido
                  SizedBox(width: 350, child: _buildSidePanel(state)),
                  const SizedBox(width: 24),
                  // Contenido principal
                  Expanded(
                    child: Column(
                      children: [
                        _buildSearchAndAddSection(
                          state,
                          controller,
                          ScreenType.desktop,
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: _buildListaInsumos(
                            state,
                            controller,
                            ScreenType.desktop,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Panel de estadísticas (solo desktop)
                  SizedBox(width: 300, child: _buildStatsPanel(state)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header responsivo
  Widget _buildHeader(InventoryState state, ScreenType screenType) {
    final isDesktop = screenType == ScreenType.desktop;
    final isTablet = screenType == ScreenType.tablet;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber, Colors.amber[600]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isDesktop ? 28 : 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de Inventario',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop
                          ? 32
                          : isTablet
                          ? 28
                          : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Administra tus insumos de apiario',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 16 : 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 16 : 12,
                vertical: isDesktop ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: Colors.amber[700],
                    size: isDesktop ? 20 : 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.inventoryItems.length}',
                    style: GoogleFonts.poppins(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sección de búsqueda y agregar
  Widget _buildSearchAndAddSection(
    InventoryState state,
    InventoryController controller,
    ScreenType screenType,
  ) {
    final isDesktop = screenType == ScreenType.desktop;
    final isTablet = screenType == ScreenType.tablet;
    final padding = (isDesktop || isTablet) ? 0.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar insumo...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          // No setState needed, just clear and rebuild will happen
                          searchController.clear();
                          // Force a rebuild to update the filtered list
                          ref
                              .read(
                                inventoryControllerProvider(
                                  widget.apiaryId,
                                ).notifier,
                              )
                              .loadInventoryItems(apiaryId: widget.apiaryId);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 20 : 16,
                  horizontal: 16,
                ),
              ),
              style: GoogleFonts.poppins(fontSize: isDesktop ? 16 : 14),
              onChanged: (value) {
                // Force a rebuild to update the filtered list
                // This will re-evaluate _getFilteredInsumos in _buildListaInsumos
                ref
                    .read(inventoryControllerProvider(widget.apiaryId).notifier)
                    .loadInventoryItems(apiaryId: widget.apiaryId);
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.add, size: isDesktop ? 24 : 20),
              label: Text(
                'Agregar Nuevo Insumo',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 20 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () {
                _limpiarFormulario(
                  controller,
                ); // Clear form and reset editing state
                _mostrarDialogoAgregar(controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Panel lateral para tablet y desktop
  Widget _buildSidePanel(InventoryState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Inventario',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              'Total de Insumos',
              '${state.inventorySummary['total_items'] ?? 0}',
              Icons.inventory_2,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(
              'Stock Bajo',
              '${state.inventorySummary['low_stock_items'] ?? 0}',
              Icons.warning,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(
              'Sin Stock',
              '${_getSinStockCount(state)}', // Use a helper for out of stock count
              Icons.error,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(
              'Stock Total',
              '${state.inventorySummary['total_quantity'] ?? 0}',
              Icons.assessment,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // Panel de estadísticas para desktop
  Widget _buildStatsPanel(InventoryState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análisis de Inventario',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            _buildStatItem(
              'Items disponibles',
              '${state.inventorySummary['in_stock_items'] ?? 0}',
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              'Promedio de stock',
              '${_getPromedioStock(state).toStringAsFixed(1)} unidades',
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              'Última actualización',
              '${state.inventorySummary['updated_at'] != null ? 'Hace unos momentos' : 'N/A'}',
            ),
            const SizedBox(height: 24),
            Text(
              'Alertas',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ..._buildAlertas(state),
          ],
        ),
      ),
    );
  }

  // Lista de insumos responsiva
  Widget _buildListaInsumos(
    InventoryState state,
    InventoryController controller,
    ScreenType screenType,
  ) {
    final insumosFiltrados = _getFilteredInsumos(state.inventoryItems);
    final isDesktop = screenType == ScreenType.desktop;
    final isTablet = screenType == ScreenType.tablet;

    if (insumosFiltrados.isEmpty) {
      return _buildEmptyState(state, controller);
    }

    // Para desktop, usar grid de 2 columnas
    if (isDesktop) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.0,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: insumosFiltrados.length,
        itemBuilder: (context, index) {
          return _buildInsumoCard(
            insumosFiltrados[index],
            index,
            screenType,
            controller,
          );
        },
      );
    }

    // Para tablet y móvil, usar lista
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: (isDesktop || isTablet) ? 0 : 16,
      ),
      itemCount: insumosFiltrados.length,
      itemBuilder: (context, index) {
        return _buildInsumoCard(
          insumosFiltrados[index],
          index,
          screenType,
          controller,
        );
      },
    );
  }

  // Card de insumo responsivo
  Widget _buildInsumoCard(
    InventoryItem insumo,
    int index,
    ScreenType screenType,
    InventoryController controller,
  ) {
    final isDesktop = screenType == ScreenType.desktop;
    final isTablet = screenType == ScreenType.tablet;
    final isMobile = screenType == ScreenType.mobile;

    final cantidad = insumo.quantity;
    final unidad = insumo.unit;
    final nombre = insumo.itemName;
    final id = insumo.id;

    final bool cantidadBaja = cantidad <= 1;

    // Ajustes específicos para cada tamaño de pantalla
    final cardMargin = isMobile
        ? const EdgeInsets.only(bottom: 12)
        : isTablet
        ? const EdgeInsets.only(bottom: 10)
        : EdgeInsets.zero;

    final cardPadding = isDesktop
        ? const EdgeInsets.all(24)
        : isTablet
        ? const EdgeInsets.all(12)
        : const EdgeInsets.all(16);

    final iconSize = isDesktop
        ? 26
        : isTablet
        ? 18
        : 20;
    final titleFontSize = isDesktop
        ? 18
        : isTablet
        ? 14
        : 16;
    final subtitleFontSize = isDesktop
        ? 14
        : isTablet
        ? 11
        : 12;

    return Card(
          margin: cardMargin,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: cantidadBaja
                  ? Colors.red[100] ?? Colors.red.shade100
                  : Colors.amber[100] ?? Colors.amber.shade100,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: cantidadBaja
                    ? [
                        Colors.red[50] ?? Colors.red.shade50,
                        Colors.red[25] ?? Colors.red.shade100,
                      ]
                    : [Colors.amber[50] ?? Colors.amber.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          isDesktop
                              ? 12
                              : isTablet
                              ? 6
                              : 8,
                        ),
                        decoration: BoxDecoration(
                          color: cantidadBaja
                              ? Colors.red[100] ?? Colors.red.shade100
                              : Colors.amber[100] ?? Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.inventory_2,
                          color: cantidadBaja
                              ? Colors.red[700] ?? Colors.red
                              : Colors.amber[700] ?? Colors.amber,
                          size: iconSize.toDouble(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: titleFontSize.toDouble(),
                                color: cantidadBaja
                                    ? Colors.red[800] ?? Colors.red
                                    : Colors.grey[800] ?? Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Stock: ',
                                  style: GoogleFonts.poppins(
                                    fontSize: subtitleFontSize.toDouble(),
                                    color: Colors.grey[600] ?? Colors.grey,
                                  ),
                                ),
                                Text(
                                  '$cantidad $unidad',
                                  style: GoogleFonts.poppins(
                                    fontSize: subtitleFontSize.toDouble(),
                                    fontWeight: FontWeight.w600,
                                    color: cantidadBaja
                                        ? Colors.red[700] ?? Colors.red
                                        : Colors.amber[700] ?? Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (cantidadBaja)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'STOCK BAJO',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: isDesktop
                        ? 16
                        : isTablet
                        ? 10
                        : 12,
                  ),
                  // Botones responsivos
                  isDesktop
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: Text(
                                'Editar',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    Colors.amber[700] ?? Colors.amber,
                                side: BorderSide(
                                  color: Colors.amber[300] ?? Colors.amber,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () =>
                                  _editarInsumo(insumo, controller),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.delete, size: 16),
                              label: Text(
                                'Eliminar',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red[700] ?? Colors.red,
                                side: BorderSide(
                                  color: Colors.red[300] ?? Colors.red,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () => _eliminarInsumo(id, controller),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: Icon(
                                  Icons.edit,
                                  size: isTablet ? 14 : 16,
                                ),
                                label: Text(
                                  'Editar',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: isTablet ? 12 : 14,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      Colors.amber[700] ?? Colors.amber,
                                  side: BorderSide(
                                    color: Colors.amber[300] ?? Colors.amber,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () =>
                                    _editarInsumo(insumo, controller),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: Icon(
                                  Icons.delete,
                                  size: isTablet ? 14 : 16,
                                ),
                                label: Text(
                                  'Eliminar',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: isTablet ? 12 : 14,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      Colors.red[700] ?? Colors.red,
                                  side: BorderSide(
                                    color: Colors.red[300] ?? Colors.red,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () =>
                                    _eliminarInsumo(id, controller),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: index * 100),
        )
        .slideX(
          begin: 0.2,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutQuad,
        );
  }

  // Widgets auxiliares
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    InventoryState state,
    InventoryController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchController.text.isNotEmpty
                ? Icons.search_off
                : Icons.inventory_2_outlined,
            size: 64,
            color: Colors.amber[300] ?? Colors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            searchController.text.isNotEmpty
                ? 'No se encontraron insumos'
                : 'No hay insumos registrados',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600] ?? Colors.grey,
            ),
          ),
          Text(
            searchController.text.isNotEmpty
                ? 'Intenta con otro término de búsqueda'
                : 'Agrega tu primer insumo al inventario',
            style: GoogleFonts.poppins(color: Colors.grey[500] ?? Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: searchController.text.isNotEmpty
                ? () => controller.loadInventoryItems(apiaryId: widget.apiaryId)
                : () {
                    _limpiarFormulario(controller);
                    _mostrarDialogoAgregar(controller);
                  },
            icon: Icon(
              searchController.text.isNotEmpty ? Icons.refresh : Icons.add,
            ),
            label: Text(
              searchController.text.isNotEmpty ? 'Recargar' : 'Agregar Insumo',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  List<Widget> _buildAlertas(InventoryState state) {
    List<Widget> alertas = [];

    final sinStockCount = _getSinStockCount(state);
    if (sinStockCount > 0) {
      alertas.add(
        _buildAlerta(
          '$sinStockCount productos sin stock',
          Icons.error,
          Colors.red,
        ),
      );
    }

    if (state.lowStockItems.isNotEmpty) {
      final lowStockCount = state.lowStockItems.length;
      alertas.add(
        _buildAlerta(
          '$lowStockCount productos con stock bajo',
          Icons.warning,
          Colors.orange,
        ),
      );
    }

    if (alertas.isEmpty) {
      alertas.add(
        _buildAlerta(
          'Inventario en buen estado',
          Icons.check_circle,
          Colors.green,
        ),
      );
    }

    return alertas;
  }

  Widget _buildAlerta(String mensaje, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares para estadísticas
  int _getSinStockCount(InventoryState state) {
    return (state.inventorySummary['out_of_stock_items'] as num?)?.toInt() ?? 0;
  }

  double _getPromedioStock(InventoryState state) {
    final totalQuantity =
        (state.inventorySummary['total_quantity'] as num?) ?? 0;
    final totalItems = (state.inventorySummary['total_items'] as num?) ?? 0;
    return totalItems > 0 ? totalQuantity / totalItems : 0.0;
  }
}