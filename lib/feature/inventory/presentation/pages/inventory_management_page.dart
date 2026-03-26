import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

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
  final String apiaryId;

  const InventoryManagementPage({super.key, required this.apiaryId});

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
  final TextEditingController descripcionController = TextEditingController();
  
  // Nuevos controladores profesionales
  final TextEditingController loteController = TextEditingController();
  final TextEditingController proveedorController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();
  final TextEditingController stockMinimoController = TextEditingController();
  DateTime? fechaVencimiento;
  DateTime? fechaCompra;
  String categoriaSeleccionada = 'General';

  // Clave para validación del formulario
  final _formKeyAgregar = GlobalKey<FormState>();

  // Variables de estado local para el diálogo de agregar/editar
  String unidadSeleccionada = 'Unidades';

  // Lista de unidades disponibles en español (Colombia)
  final List<String> unidades = [
    'Unidades',
    'Láminas',
    'Pares',
    'Kilogramos',
    'Litros',
    'Metros',
    'Cajas',
    'Gramos',
    'Mililitros',
    'Docenas',
  ];

  final List<String> categorias = [
    'General',
    'Equipos',
    'Medicamentos',
    'Alimentación',
    'Herramientas',
    'Protección',
    'Cosecha',
  ];

  // Función para normalizar unidades del backend al frontend
  String _normalizarUnidad(String? unit) {
    if (unit == null || unit.isEmpty) return 'Unidades';

    final normalizedUnitLower = unit.toLowerCase().trim();

    // 1. Check if the exact unit (case-sensitive) is already in our predefined list
    if (unidades.contains(unit)) {
      return unit;
    }

    // 2. Check if a case-insensitive version exists in our predefined list
    for (String u in unidades) {
      if (u.toLowerCase() == normalizedUnitLower) {
        return u; // Return the canonical form from `unidades`
      }
    }

    // 3. Check the mapping for common backend variations
    final map = {
      'unit': 'Unidades',
      'units': 'Unidades',
      'unidades': 'Unidades',
      'unidad': 'Unidades',
      'pair': 'Pares',
      'pairs': 'Pares',
      'pares': 'Pares',
      'kg': 'Kilogramos',
      'kilogramos': 'Kilogramos',
      'liter': 'Litros',
      'litros': 'Litros',
      'meter': 'Metros',
      'metros': 'Metros',
      'box': 'Cajas',
      'cajas': 'Cajas',
      'gram': 'Gramos',
      'gramos': 'Gramos',
      'ml': 'Mililitros',
      'mililitros': 'Mililitros',
      'dozen': 'Docenas',
      'docenas': 'Docenas',
      'láminas': 'Láminas',
      'laminas': 'Láminas',
    };

    final mappedValue = map[normalizedUnitLower];
    if (mappedValue != null && unidades.contains(mappedValue)) {
      return mappedValue;
    }

    // 4. Fallback to 'Unidades' if no match is found
    return 'Unidades';
  }

  // Método para obtener el ícono según la categoría
  IconData _getIconForCategory(String? category) {
    final cat = category?.trim() ?? 'General';
    switch (cat) {
      case 'Equipos':
        return Icons.precision_manufacturing;
      case 'Herramientas':
        return Icons.handyman;
      case 'Protección':
        return Icons.security;
      case 'Medicamentos':
        return Icons.medication;
      case 'Alimentación':
        return Icons.opacity;
      case 'Cosecha':
        return Icons.shopping_basket;
      case 'General':
      default:
        return Icons.inventory_2;
    }
  }

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
  }

  @override
  void dispose() {
    nombreController.dispose();
    cantidadController.dispose();
    searchController.dispose();
    descripcionController.dispose();
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
        itemToSave = state.editingItem!.copyWith(
          itemName: nombreController.text.trim(),
          quantity: int.parse(cantidadController.text),
          unit: unidadSeleccionada,
          category: categoriaSeleccionada,
          description: descripcionController.text.trim(),
          batchNumber: loteController.text.trim(),
          expiryDate: fechaVencimiento,
          purchaseDate: fechaCompra,
          supplier: proveedorController.text.trim(),
          storageLocation: ubicacionController.text.trim(),
          minimumStock: int.tryParse(stockMinimoController.text) ?? 0,
        );
      } else {
        itemToSave = InventoryItem(
          id: '',
          itemName: nombreController.text.trim(),
          quantity: int.parse(cantidadController.text),
          unit: unidadSeleccionada,
          apiaryId: widget.apiaryId,
          category: categoriaSeleccionada,
          description: descripcionController.text.trim(),
          batchNumber: loteController.text.trim(),
          expiryDate: fechaVencimiento,
          purchaseDate: fechaCompra,
          supplier: proveedorController.text.trim(),
          storageLocation: ubicacionController.text.trim(),
          minimumStock: int.tryParse(stockMinimoController.text) ?? 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      final errorMessage = await controller.guardarInsumo(
        itemToSave,
        apiaryId: widget.apiaryId,
      );

      if (mounted) Navigator.of(context).pop();

      if (errorMessage != null) {
        _showSnackBar(context, errorMessage, Colors.red, Icons.error);
      } else {
        if (mounted) Navigator.of(context).pop();

        _showSnackBar(
          context,
          state.isEditing
              ? 'Insumo actualizado correctamente'
              : 'Insumo agregado correctamente',
          Colors.green,
          Icons.check_circle,
        );

        _limpiarFormulario(controller);
      }
    } catch (e) {
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
            const SizedBox(width: 8),
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

  void _limpiarFormulario(InventoryController controller) {
    nombreController.clear();
    cantidadController.clear();
    descripcionController.clear();
    loteController.clear();
    proveedorController.clear();
    ubicacionController.clear();
    stockMinimoController.clear();
    setState(() {
      unidadSeleccionada = 'Unidades';
      // Si el filtro es diferente de 'Todas', pre-llenamos la categoría con el filtro actual
      categoriaSeleccionada = (categoriaFiltro != 'Todas') ? categoriaFiltro : 'General';
      fechaVencimiento = null;
      fechaCompra = null;
    });
    controller.setEditingItem(null);
  }

  void _editarInsumo(InventoryItem insumo, InventoryController controller) {
    nombreController.text = insumo.itemName;
    cantidadController.text = insumo.quantity.toString();
    unidadSeleccionada = _normalizarUnidad(insumo.unit);
    descripcionController.text = insumo.description ?? '';
    categoriaSeleccionada = insumo.category;
    loteController.text = insumo.batchNumber ?? '';
    proveedorController.text = insumo.supplier ?? '';
    ubicacionController.text = insumo.storageLocation ?? '';
    stockMinimoController.text = insumo.minimumStock.toString();
    fechaVencimiento = insumo.expiryDate;
    fechaCompra = insumo.purchaseDate;

    controller.setEditingItem(insumo);
    _mostrarDialogoAgregar(controller);
  }

  Future<void> _eliminarInsumo(
    String id,
    InventoryController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                '¿Eliminar insumo?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Esta acción no se puede deshacer. El insumo será eliminado permanentemente del inventario.',
            style: TextStyle(fontFamily: 'Poppins'),
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
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const LoadingIndicatorWidget(message: 'Eliminando insumo...'),
        );

        final errorMessage = await controller.eliminarInsumo(
          id,
          apiaryId: widget.apiaryId,
        );

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
                  const SizedBox(width: 8),
                  Text(
                    controller.state.isEditing
                        ? 'Editar Insumo'
                        : 'Agregar Insumo',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKeyAgregar,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del insumo',
                          hintText: 'Ej: Traje de apicultor',
                          prefixIcon: const Icon(Icons.inventory_2, color: Colors.amber),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa un nombre' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: cantidadController,
                              decoration: InputDecoration(
                                labelText: 'Cantidad',
                                prefixIcon: const Icon(Icons.numbers, color: Colors.amber),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: unidadSeleccionada,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Unidad',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: unidades.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (v) => setDialogState(() => unidadSeleccionada = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: categoriaSeleccionada,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          prefixIcon: const Icon(Icons.category, color: Colors.amber),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setDialogState(() => categoriaSeleccionada = v!),
                      ),
                      
                      // Lógica Dinámica: Mostrar campos de calidad solo para categorías específicas
                      if (['Medicamentos', 'Alimentación', 'Cosecha'].contains(categoriaSeleccionada)) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Control de Calidad y Lote',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: loteController,
                          decoration: InputDecoration(
                            labelText: 'Número de Lote',
                            hintText: 'Ej: LOT-2024-001',
                            prefixIcon: const Icon(Icons.qr_code, color: Colors.amber),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: fechaVencimiento ?? DateTime.now().add(const Duration(days: 365)),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (picked != null) setDialogState(() => fechaVencimiento = picked);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Fecha de Vencimiento',
                              prefixIcon: const Icon(Icons.calendar_today, color: Colors.amber),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              fechaVencimiento == null 
                                  ? 'Seleccionar fecha' 
                                  : '${fechaVencimiento!.day}/${fechaVencimiento!.month}/${fechaVencimiento!.year}',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: fechaCompra ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) setDialogState(() => fechaCompra = picked);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Fecha de Compra',
                              prefixIcon: const Icon(Icons.shopping_cart, color: Colors.amber),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              fechaCompra == null 
                                  ? 'Seleccionar fecha' 
                                  : '${fechaCompra!.day}/${fechaCompra!.month}/${fechaCompra!.year}',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      Text(
                        'Logística',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: stockMinimoController,
                        decoration: InputDecoration(
                          labelText: 'Stock Mínimo (Alerta)',
                          prefixIcon: const Icon(Icons.warning_amber, color: Colors.amber),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: proveedorController,
                        decoration: InputDecoration(
                          labelText: 'Proveedor',
                          prefixIcon: const Icon(Icons.business, color: Colors.amber),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ubicacionController,
                        decoration: InputDecoration(
                          labelText: 'Ubicación en Almacén',
                          prefixIcon: const Icon(Icons.place, color: Colors.amber),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descripcionController,
                        decoration: InputDecoration(
                          labelText: 'Notas adicionales',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _limpiarFormulario(controller);
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _guardarInsumo(controller, controller.state),
                  child: Text(
                    controller.state.isEditing ? 'Actualizar' : 'Guardar Insumo',
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

  String categoriaFiltro = 'Todas';

  List<InventoryItem> _getFilteredInsumos(List<InventoryItem> allItems) {
    return allItems.where((insumo) {
      final matchesSearch = insumo.itemName.toLowerCase().contains(searchController.text.toLowerCase());
      final matchesCategory = categoriaFiltro == 'Todas' || insumo.category == categoriaFiltro;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildCategoryFilters() {
    final filtros = ['Todas', ...categorias];
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filtros.length,
        itemBuilder: (context, index) {
          final filtro = filtros[index];
          final isSelected = categoriaFiltro == filtro;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(filtro, style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.amber[900],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
              selectedColor: Colors.amber,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.amber.withOpacity(0.3)),
              ),
              onSelected: (val) => setState(() => categoriaFiltro = filtro),
            ),
          );
        },
      ),
    );
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
      return const Scaffold(
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
                  SizedBox(width: 280, child: _buildSidePanel(state)),
                  const SizedBox(width: 16),
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
                  SizedBox(width: 350, child: _buildSidePanel(state)),
                  const SizedBox(width: 24),
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
                  SizedBox(width: 300, child: _buildStatsPanel(state)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                      fontSize: isDesktop ? 32 : (isTablet ? 28 : 22),
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
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 20 : 16,
                  horizontal: 16,
                ),
              ),
              style: GoogleFonts.poppins(fontSize: isDesktop ? 16 : 14),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildCategoryFilters(),
          const SizedBox(height: 4),
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
              ),
              onPressed: () {
                _limpiarFormulario(controller);
                _mostrarDialogoAgregar(controller);
              },
            ),
          ),
        ],
      ),
    );
  }

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
              'Análisis',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            _buildStatItem(
              'Items en stock',
              '${state.inventorySummary['in_stock_items'] ?? 0}',
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              'Última actualización',
              state.inventorySummary['updated_at'] != null ? 'Hace unos momentos' : 'N/A',
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

  Widget _buildListaInsumos(
    InventoryState state,
    InventoryController controller,
    ScreenType screenType,
  ) {
    final insumosFiltrados = _getFilteredInsumos(state.inventoryItems);
    final isDesktop = screenType == ScreenType.desktop;

    if (insumosFiltrados.isEmpty) {
      return _buildEmptyState(state, controller);
    }

    final groupedInsumos = _groupInsumos(insumosFiltrados);
    final sortedCategories = groupedInsumos.keys.toList()..sort();

    return CustomScrollView(
      slivers: [
        for (final category in sortedCategories) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              child: Row(
                children: [
                  Icon(_getIconForCategory(category), color: Colors.amber[800], size: 24),
                  const SizedBox(width: 12),
                  Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Divider(color: Colors.amber.withOpacity(0.3))),
                  const SizedBox(width: 12),
                  Text(
                    '${groupedInsumos[category]!.length} items',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isDesktop)
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2, // Ajustado para que quepa mejor con el nuevo diseño
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildInsumoCard(
                    groupedInsumos[category]![index],
                    index,
                    screenType,
                    controller,
                  );
                },
                childCount: groupedInsumos[category]!.length,
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildInsumoCard(
                    groupedInsumos[category]![index],
                    index,
                    screenType,
                    controller,
                  );
                },
                childCount: groupedInsumos[category]!.length,
              ),
            ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Map<String, List<InventoryItem>> _groupInsumos(List<InventoryItem> items) {
    final Map<String, List<InventoryItem>> grouped = {};
    for (var item in items) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }
    return grouped;
  }

  Widget _buildInsumoCard(
    InventoryItem insumo,
    int index,
    ScreenType screenType,
    InventoryController controller,
  ) {
    final isDesktop = screenType == ScreenType.desktop;
    final cantidad = insumo.quantity;
    final unidad = insumo.unit;
    final nombre = insumo.itemName;
    final id = insumo.id;

    // Usamos la lógica profesional de stock bajo o vencimiento para el color
    final bool estadoCritico = insumo.isLowStock || insumo.isExpired;

    return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: estadoCritico ? Colors.red.shade100 : Colors.amber.shade100,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: estadoCritico
                    ? [Colors.red.shade50, Colors.white]
                    : [Colors.amber.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: estadoCritico
                              ? Colors.red[100]
                              : Colors.amber[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForCategory(insumo.category),
                          color: estadoCritico ? Colors.red : Colors.amber[700],
                          size: isDesktop ? 26 : 20,
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
                                fontSize: isDesktop ? 18 : 16,
                              ),
                            ),
                            Text(
                              'Stock: $cantidad $unidad • ${insumo.category}',
                              style: GoogleFonts.poppins(
                                color: estadoCritico
                                    ? Colors.red
                                    : Colors.grey[600],
                                fontSize: isDesktop ? 14 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Alertas y Menú de opciones
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (insumo.isExpired)
                            const Icon(Icons.event_busy, color: Colors.red, size: 20)
                          else if (estadoCritico)
                            const Icon(Icons.warning, color: Colors.red, size: 20),
                          
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.grey, size: 22),
                            tooltip: 'Más opciones',
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editarInsumo(insumo, controller);
                              } else if (value == 'delete') {
                                _eliminarInsumo(id, controller);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 20, color: Colors.amber[800]),
                                    const SizedBox(width: 12),
                                    Text('Editar', style: GoogleFonts.poppins(fontSize: 14)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 20, color: Colors.red[700]),
                                    const SizedBox(width: 12),
                                    Text('Eliminar', style: GoogleFonts.poppins(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildActionChip(
                        icon: Icons.history,
                        label: 'Historial',
                        color: Colors.blue[700]!,
                        onTap: () => _mostrarHistorial(insumo, controller),
                      ),
                      const SizedBox(width: 8),
                      _buildActionChip(
                        icon: Icons.sync_alt,
                        label: 'Mover',
                        color: Colors.orange[700]!,
                        onTap: () => _mostrarDialogoMovimiento(insumo, controller),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 100))
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  void _mostrarDialogoMovimiento(InventoryItem insumo, InventoryController controller) {
    int cantidadMovimiento = 1;
    String tipoMovimiento = 'exit'; // Salida por defecto (más común)
    String motivoSeleccionado = 'usage';
    final notasMovController = TextEditingController();

    final motivos = {
      'entry': ['purchase', 'adjustment', 'return'],
      'exit': ['usage', 'adjustment', 'expired', 'loss', 'sale'],
    };

    final motivoLabels = {
      'purchase': 'Compra',
      'usage': 'Uso en Colmena',
      'adjustment': 'Ajuste de Inventario',
      'expired': 'Vencimiento',
      'loss': 'Pérdida/Robo',
      'sale': 'Venta',
      'return': 'Devolución',
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Registrar Movimiento', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(insumo.itemName, style: GoogleFonts.poppins(color: Colors.amber[800], fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'exit', label: Text('Salida'), icon: Icon(Icons.remove_circle_outline)),
                  ButtonSegment(value: 'entry', label: Text('Entrada'), icon: Icon(Icons.add_circle_outline)),
                ],
                selected: {tipoMovimiento},
                onSelectionChanged: (val) => setDialogState(() {
                  tipoMovimiento = val.first;
                  motivoSeleccionado = motivos[tipoMovimiento]!.first;
                }),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: motivoSeleccionado,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Motivo', border: OutlineInputBorder()),
                items: motivos[tipoMovimiento]!.map((m) => DropdownMenuItem(value: m, child: Text(motivoLabels[m]!, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setDialogState(() => motivoSeleccionado = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '1',
                      decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => cantidadMovimiento = int.tryParse(v) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(insumo.unit, style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notasMovController,
                decoration: const InputDecoration(labelText: 'Notas (Opcional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: tipoMovimiento == 'entry' ? Colors.green : Colors.orange),
              onPressed: () async {
                // Validación profesional de stock local
                if (tipoMovimiento == 'exit' && cantidadMovimiento > insumo.quantity) {
                  _showSnackBar(
                    context, 
                    'En stock es de ${insumo.quantity}, la cantidad no esta en stock', 
                    Colors.red, 
                    Icons.warning_amber_rounded
                  );
                  return; // Detiene la ejecución aquí
                }

                if (cantidadMovimiento <= 0) {
                  _showSnackBar(context, 'La cantidad debe ser mayor a 0', Colors.red, Icons.error);
                  return;
                }

                final error = await controller.registrarMovimiento(
                  itemId: insumo.id,
                  type: tipoMovimiento,
                  quantity: cantidadMovimiento,
                  reason: motivoLabels[motivoSeleccionado] ?? motivoSeleccionado,
                  notes: notasMovController.text,
                  apiaryId: widget.apiaryId,
                );
                if (mounted) {
                  Navigator.pop(context);
                  if (error != null) {
                    _showSnackBar(context, error, Colors.red, Icons.error);
                  } else {
                    _showSnackBar(context, 'Movimiento registrado', Colors.green, Icons.check_circle);
                  }
                }
              },
              child: Text(tipoMovimiento == 'entry' ? 'Cargar Stock' : 'Descargar Stock', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarHistorial(InventoryItem insumo, InventoryController controller) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Historial: ${insumo.itemName}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Registro cronológico de cambios', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: controller.obtenerHistorial(insumo.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No hay movimientos registrados', style: GoogleFonts.poppins(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final mov = snapshot.data![index];
                      final String type = mov['movement_type'] ?? '';
                      final isEntry = type == 'entry' || type == 'create';
                      
                      // Determinar icono y color basado en tipo
                      IconData icon;
                      Color iconColor;
                      switch(type) {
                        case 'create': icon = Icons.add_box; iconColor = Colors.green; break;
                        case 'entry': icon = Icons.arrow_upward; iconColor = Colors.blue; break;
                        case 'exit': icon = Icons.arrow_downward; iconColor = Colors.orange; break;
                        case 'update': icon = Icons.edit_note; iconColor = Colors.purple; break;
                        case 'delete': icon = Icons.delete_forever; iconColor = Colors.red; break;
                        default: icon = Icons.sync_alt; iconColor = Colors.grey;
                      }
                      
                      // Parseo seguro de la fecha
                      DateTime date;
                      try {
                        date = DateTime.parse(mov['date']);
                      } catch (e) {
                        date = DateTime.now();
                      }
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: iconColor, size: 20),
                          ),
                          title: Row(
                            children: [
                              Text(
                                '${isEntry ? "+" : "-"}${mov['quantity']} ${insumo.unit}',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal()),
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                mov['reason'] ?? 'Sin motivo especificado',
                                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                              ),
                              if (mov['notes'] != null && mov['notes'].toString().isNotEmpty)
                                Text(
                                  'Nota: ${mov['notes']}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildSmallBadge('Antes: ${mov['stock_before']}', Colors.grey),
                                  const SizedBox(width: 8),
                                  _buildSmallBadge('Después: ${mov['stock_after']}', Colors.amber[800]!),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

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
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
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
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.amber[200]),
          const SizedBox(height: 16),
          Text(
            'No hay insumos registrados',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoAgregar(controller),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Insumo'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAlertas(InventoryState state) {
    if (state.lowStockItems.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                'Todo en orden',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
        ),
      ];
    }
    return state.lowStockItems
        .map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Stock bajo: ${item.itemName}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
