import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Softbee/feature/apiaries/domain/entities/apiary.dart';
import 'package:Softbee/feature/apiaries/presentation/providers/apiary_providers.dart';
import 'package:Softbee/core/services/geocoding_service.dart';

class ApiaryFormDialog extends ConsumerStatefulWidget {
  final Apiary? apiaryToEdit;

  const ApiaryFormDialog({super.key, this.apiaryToEdit});

  @override
  ConsumerState<ApiaryFormDialog> createState() => _ApiaryFormDialogState();
}

class _ApiaryFormDialogState extends ConsumerState<ApiaryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _beehivesCountController;
  bool _treatments = false;
  bool _isLocationValid = false;
  bool _locationValidationAttempted = false;

  final GeocodingService _geocodingService = GeocodingService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.apiaryToEdit?.name ?? '');
    _locationController = TextEditingController(text: widget.apiaryToEdit?.location ?? '');
    _beehivesCountController = TextEditingController(
        text: widget.apiaryToEdit?.beehivesCount.toString() ?? '0');
    _treatments = widget.apiaryToEdit?.treatments ?? false;

    if (widget.apiaryToEdit?.location != null && widget.apiaryToEdit!.location!.isNotEmpty) {
      _isLocationValid = true; // Assume valid if editing an existing apiary with a location
    }

    _locationController.addListener(() {
      setState(() {
        _isLocationValid = false; // Reset validation on change
        _locationValidationAttempted = false;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _beehivesCountController.dispose();
    super.dispose();
  }

  Future<void> _validateLocation() async {
    setState(() {
      _locationValidationAttempted = true;
    });
    if (_locationController.text.trim().isEmpty) {
      setState(() {
        _isLocationValid = false;
      });
      return;
    }
    final isValid = await _geocodingService.validateAddress(_locationController.text);
    setState(() {
      _isLocationValid = isValid;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_isLocationValid && _locationController.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, valida la ubicación o déjala vacía.')),
      );
      return;
    }

    _formKey.currentState!.save();

    final apiariesController = ref.read(apiariesControllerProvider.notifier);

    if (widget.apiaryToEdit == null) {
      // Create new apiary
      await apiariesController.createApiary(
        _nameController.text.trim(),
        _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        int.parse(_beehivesCountController.text),
        _treatments,
      );
    } else {
      // Update existing apiary
      await apiariesController.updateApiary(
        widget.apiaryToEdit!.id,
        _nameController.text.trim(),
        _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        int.parse(_beehivesCountController.text),
        _treatments,
      );
    }

    // Check state and close dialog if successful
    final apiariesState = ref.read(apiariesControllerProvider);
    if (!apiariesState.isCreating && !apiariesState.isUpdating) {
      if (apiariesState.errorCreating == null && apiariesState.errorUpdating == null) {
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiariesState = ref.watch(apiariesControllerProvider);
    final isLoading = apiariesState.isCreating || apiariesState.isUpdating;
    final isEditing = widget.apiaryToEdit != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      title: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.amber.shade100, width: 0),
        ),
        child: Column(
          children: [
            Icon(isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                color: Colors.amber.shade700, size: 36),
            const SizedBox(height: 10),
            Text(
              isEditing ? 'Editar Apiario' : 'Crear Nuevo Apiario',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Apiario',
                  hintText: 'Ej: Apiario El Prado',
                  prefixIcon: const Icon(Icons.hive_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el nombre del apiario';
                  }
                  if (value.length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _nameController.text = value!,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Ubicación (opcional)',
                  hintText: 'Ej: Vereda La Esperanza, Cota',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: _locationController.text.isNotEmpty
                      ? (isLoading
                          ? const CircularProgressIndicator()
                          : IconButton(
                              icon: Icon(
                                _isLocationValid ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                                color: _isLocationValid ? Colors.green : Colors.amber,
                              ),
                              onPressed: _validateLocation,
                            ))
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorText: _locationValidationAttempted && !_isLocationValid && _locationController.text.isNotEmpty
                      ? 'Ubicación no válida o demasiado genérica. Por favor, sé más específico o déjala vacía.'
                      : null,
                ),
                onSaved: (value) => _locationController.text = value!,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _beehivesCountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Número de Colmenas',
                  hintText: 'Ej: 10',
                  prefixIcon: const Icon(Icons.grid_view_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el número de colmenas';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Por favor, introduce un número válido';
                  }
                  return null;
                },
                onSaved: (value) => _beehivesCountController.text = value!,
              ),
              const SizedBox(height: 15),
              SwitchListTile(
                title: Text('Aplicar Tratamientos', style: GoogleFonts.poppins()),
                subtitle: Text('¿Aplicas tratamientos cuando las abejas están enfermas?',
                    style: GoogleFonts.poppins(fontSize: 12)),
                value: _treatments,
                onChanged: (bool value) {
                  setState(() {
                    _treatments = value;
                  });
                },
                activeColor: Colors.amber,
                tileColor: Colors.grey.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 20),
              if (apiariesState.errorCreating != null || apiariesState.errorUpdating != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    apiariesState.errorCreating ?? apiariesState.errorUpdating ?? 'Error desconocido',
                    style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text('Cancelar',
                        style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _submitForm,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(isEditing ? Icons.save_rounded : Icons.add_rounded, color: Colors.white),
                    label: Text(
                      isEditing ? 'Guardar Cambios' : 'Crear Apiario',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}