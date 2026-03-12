import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Softbee/feature/apiaries/presentation/providers/apiary_providers.dart';
import 'package:Softbee/feature/apiaries/domain/entities/apiary.dart';
import '../../domain/entities/question_model.dart';
import '../providers/questions_providers.dart';
import '../widgets/monitoring_widgets.dart';

class QuestionsManagementScreen extends ConsumerStatefulWidget {
  final String apiaryId;
  const QuestionsManagementScreen({super.key, required this.apiaryId});

  @override
  ConsumerState<QuestionsManagementScreen> createState() =>
      _QuestionsManagementScreenState();
}

class _QuestionsManagementScreenState
    extends ConsumerState<QuestionsManagementScreen> {
  String? selectedApiarioId;
  String tipoRespuestaSeleccionado = "texto";
  bool obligatoriaSeleccionada = false;
  String? selectedCategoria;

  // Colores del diseño original
  final Color colorAmarillo = const Color(0xFFFBC209);
  final Color colorNaranja = const Color(0xFFFF9800);
  final Color colorAmbarClaro = const Color(0xFFFFF8E1);
  final Color colorVerde = const Color(0xFF4CAF50);
  final Color colorAmarilloOscuro = const Color(0xFFF57C00);
  final Color colorMorado = const Color(0xFF9C27B0);

  @override
  void initState() {
    super.initState();
    selectedApiarioId = widget.apiaryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(apiariesControllerProvider.notifier).fetchApiaries();
      ref
          .read(questionsControllerProvider.notifier)
          .fetchPreguntas(widget.apiaryId);
      ref.read(questionsControllerProvider.notifier).fetchTemplates();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiariesState = ref.watch(apiariesControllerProvider);
    final questionsState = ref.watch(questionsControllerProvider);

    return Scaffold(
      backgroundColor: colorAmbarClaro,
      appBar: AppBar(
        backgroundColor: colorAmarillo,
        title: Text(
          'Gestión de Preguntas',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: () => ref
                .read(questionsControllerProvider.notifier)
                .fetchPreguntas(widget.apiaryId),
          ),
        ],
      ),
      body: questionsState.isLoading || apiariesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(apiariesState.allApiaries, questionsState),
                Expanded(child: _buildPreguntasList(questionsState.preguntas)),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "bank",
            onPressed: _showQuestionBankDialog,
            backgroundColor: colorAmarilloOscuro,
            child: const Icon(Icons.library_books, color: Colors.white),
          ).animate().scale(delay: 200.ms),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "new",
            onPressed: () => _showPreguntaDialog(),
            backgroundColor: colorVerde,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Nueva Pregunta',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().scale(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildHeader(List<Apiary> apiarios, QuestionsState state) {
    final currentApiaryName = apiarios
        .firstWhere((a) => a.id == selectedApiarioId,
            orElse: () => apiarios.isNotEmpty
                ? apiarios.first
                : Apiary(
                    id: '',
                    name: 'Sin Apiario',
                    userId: '',
                    beehivesCount: 0,
                    treatments: false,
                    createdAt: DateTime.now()))
        .name;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          EnhancedCardWidget(
            title: 'Apiario Actual',
            icon: Icons.location_on,
            color: colorNaranja,
            isCompact: true,
            animationDelay: 0,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colorNaranja.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorNaranja.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place_rounded, size: 14, color: colorNaranja),
                  const SizedBox(width: 6),
                  Text(
                    currentApiaryName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorNaranja,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCardWidget(
                  label: 'Total',
                  value: state.preguntas.length.toString(),
                  icon: Icons.quiz,
                  color: colorVerde,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCardWidget(
                  label: 'Activas',
                  value: state.preguntas
                      .where((p) => p.activa)
                      .length
                      .toString(),
                  icon: Icons.check_circle,
                  color: colorAmarillo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCardWidget(
                  label: 'Banco',
                  value: state.templates.length.toString(),
                  icon: Icons.library_books,
                  color: colorAmarilloOscuro,
                  onTap: _showQuestionBankDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreguntasList(List<Pregunta> preguntas) {
    if (preguntas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: colorNaranja.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay preguntas en este apiario',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    Map<String, List<Pregunta>> grouped = {};
    for (var p in preguntas) {
      final cat = p.categoria ?? 'Sin Categoría';
      if (grouped[cat] == null) grouped[cat] = [];
      grouped[cat]!.add(p);
    }

    final sortedCats = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      itemCount: sortedCats.length,
      itemBuilder: (context, index) {
        final category = sortedCats[index];
        final items = grouped[category]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorNaranja,
                ),
              ),
            ),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) =>
                  _onReorderWithinCategory(category, items, oldIndex, newIndex),
              itemBuilder: (context, idx) {
                final pregunta = items[idx];
                return _buildQuestionCard(pregunta, idx);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuestionCard(Pregunta pregunta, int indexInGroup) {
    return Card(
      key: ValueKey(pregunta.id),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: indexInGroup,
          child: Icon(Icons.drag_handle, color: colorNaranja),
        ),
        title: Text(
          pregunta.texto,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: pregunta.activa ? Colors.black87 : Colors.grey,
            decoration: pregunta.activa ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${pregunta.tipoRespuesta} ${pregunta.obligatoria ? "(Obligatoria)" : ""}',
              style: TextStyle(
                color: pregunta.activa ? Colors.black54 : Colors.grey,
              ),
            ),
            if (pregunta.tipoRespuesta == 'opciones' &&
                pregunta.opciones != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: pregunta.opciones!
                    .map(
                      (opt) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorAmbarClaro,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorAmarillo.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          opt,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: colorAmarilloOscuro,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: pregunta.activa,
              activeColor: colorVerde,
              onChanged: (val) {
                ref
                    .read(questionsControllerProvider.notifier)
                    .updatePregunta(pregunta.copyWith(activa: val));
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (val) {
                if (val == 'delete') _confirmDelete(pregunta);
                if (val == 'edit') _showPreguntaDialog(pregunta: pregunta);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onReorderWithinCategory(
    String category,
    List<Pregunta> categoryItems,
    int oldIndex,
    int newIndex,
  ) {
    if (newIndex > oldIndex) newIndex -= 1;

    final List<Pregunta> reorderedCategory = List<Pregunta>.from(categoryItems);
    final Pregunta movedItem = reorderedCategory.removeAt(oldIndex);
    reorderedCategory.insert(newIndex, movedItem);

    final state = ref.read(questionsControllerProvider);
    final allPreguntas = List<Pregunta>.from(state.preguntas);

    final List<String> currentOrderIds = allPreguntas.map((p) => p.id).toList();
    final List<int> categoryIndices = [];

    for (int i = 0; i < allPreguntas.length; i++) {
      if ((allPreguntas[i].categoria ?? 'Sin Categoría') == category) {
        categoryIndices.add(i);
      }
    }

    for (int i = 0; i < categoryIndices.length; i++) {
      currentOrderIds[categoryIndices[i]] = reorderedCategory[i].id;
    }

    ref
        .read(questionsControllerProvider.notifier)
        .reorderPreguntas(selectedApiarioId!, currentOrderIds);
  }

  void _showQuestionBankDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final state = ref.watch(questionsControllerProvider);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorAmarilloOscuro, colorNaranja],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.library_books, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Banco de Preguntas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final Map<String, List<Pregunta>> grouped = {};
                      for (var t in state.templates) {
                        final cat = t.categoria ?? 'General';
                        if (grouped[cat] == null) grouped[cat] = [];
                        grouped[cat]!.add(t);
                      }
                      final sortedCats = grouped.keys.toList()..sort();

                      return ListView.builder(
                        itemCount: sortedCats.length,
                        itemBuilder: (context, catIdx) {
                          final category = sortedCats[catIdx];
                          final items = grouped[category]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colorNaranja,
                                  ),
                                ),
                              ),
                              ...items.map((template) => ListTile(
                                title: Text(
                                  template.texto,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                                subtitle: Text(
                                  'Tipo: ${template.tipoRespuesta}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.add_circle, color: colorVerde),
                                  onPressed: () {
                                    ref
                                        .read(questionsControllerProvider.notifier)
                                        .createPregunta(
                                          template.copyWith(
                                            apiarioId: selectedApiarioId!,
                                          ),
                                        );
                                    Navigator.pop(context);
                                  },
                                ),
                              )).toList(),
                              const Divider(),
                            ],
                          );
                        },
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPreguntaDialog({Pregunta? pregunta}) {
    showDialog(
      context: context,
      builder: (context) => _PreguntaFormDialog(
        apiaryId: widget.apiaryId,
        pregunta: pregunta,
      ),
    );
  }

  void _confirmDelete(Pregunta pregunta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Pregunta'),
        content: Text('¿Deseas eliminar "${pregunta.texto}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(questionsControllerProvider.notifier)
                  .deletePregunta(pregunta.id, selectedApiarioId!);
              Navigator.pop(context);
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
}

// =============================================
// DIÁLOGO DE FORMULARIO DE PREGUNTA
// =============================================
class _PreguntaFormDialog extends ConsumerStatefulWidget {
  final String apiaryId;
  final Pregunta? pregunta;

  const _PreguntaFormDialog({
    required this.apiaryId,
    this.pregunta,
  });

  @override
  ConsumerState<_PreguntaFormDialog> createState() => _PreguntaFormDialogState();
}

class _PreguntaFormDialogState extends ConsumerState<_PreguntaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _preguntaController;
  late TextEditingController _categoryController;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  final List<TextEditingController> _opcionesControllers = [];
  
  late String _tipoRespuesta;
  late bool _obligatoria;
  String? _selectedCategoryValue;
  bool _isAddingNewCategory = false;

  final Color colorAmarillo = const Color(0xFFFBC209);
  final Color colorNaranja = const Color(0xFFFF9800);
  final Color colorVerde = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    final isEditing = widget.pregunta != null;
    
    _preguntaController = TextEditingController(text: isEditing ? widget.pregunta!.texto : '');
    _categoryController = TextEditingController(text: isEditing ? (widget.pregunta!.categoria ?? 'General') : 'General');
    _minController = TextEditingController(text: isEditing ? widget.pregunta!.min?.toString() : '');
    _maxController = TextEditingController(text: isEditing ? widget.pregunta!.max?.toString() : '');
    
    _tipoRespuesta = isEditing ? widget.pregunta!.tipoRespuesta : "texto";
    _obligatoria = isEditing ? widget.pregunta!.obligatoria : false;
    _selectedCategoryValue = isEditing ? widget.pregunta!.categoria : 'General';

    if (isEditing && widget.pregunta!.opciones != null) {
      for (var opt in widget.pregunta!.opciones!) {
        if (opt.isNotEmpty && opt != '{}') {
          _opcionesControllers.add(TextEditingController(text: opt));
        }
      }
    }
    
    _ensureMinimumOptions();
  }

  @override
  void dispose() {
    _preguntaController.dispose();
    _categoryController.dispose();
    _minController.dispose();
    _maxController.dispose();
    for (var c in _opcionesControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _ensureMinimumOptions() {
    if (_tipoRespuesta == 'opciones' && _opcionesControllers.length < 2) {
      _opcionesControllers.add(TextEditingController());
      _opcionesControllers.add(TextEditingController());
    }
  }

  String _formatQuestionText(String text) {
    if (text.trim().isEmpty) return text;
    String f = text.trim();
    if (!f.startsWith('¿')) f = '¿$f';
    if (!f.endsWith('?')) f = '$f?';
    return f;
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
      prefixIcon: Icon(icon, size: 20, color: colorAmarillo.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorAmarillo, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pregunta != null;
    final questionsState = ref.watch(questionsControllerProvider);
    
    List<String> existingCategories = questionsState.preguntas
        .map((p) => p.categoria ?? 'General')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    if (!existingCategories.contains('General')) existingCategories.add('General');
    existingCategories.sort();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorAmarillo.withOpacity(0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Icon(isEditing ? Icons.edit_rounded : Icons.add_circle_rounded, color: colorAmarillo, size: 28),
            const SizedBox(width: 12),
            Text(
              isEditing ? 'Editar Pregunta' : 'Nueva Pregunta',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      content: Container(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Texto de la Pregunta'),
                TextFormField(
                  controller: _preguntaController,
                  maxLines: 2,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _buildInputDecoration('Ej: ¿Estado de la cría?', Icons.help_outline),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 20),
                
                _buildFieldLabel('Categoría'),
                DropdownButtonFormField<String>(
                  value: _isAddingNewCategory ? 'NEW' : (existingCategories.contains(_selectedCategoryValue) ? _selectedCategoryValue : null),
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                  decoration: _buildInputDecoration('Selecciona o crea una', Icons.folder_outlined),
                  items: [
                    ...existingCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    DropdownMenuItem(
                      value: 'NEW',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: colorNaranja, size: 18),
                          const SizedBox(width: 8),
                          Text('Agregar nueva categoría', style: TextStyle(color: colorNaranja, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      if (val == 'NEW') {
                        _isAddingNewCategory = true;
                        _categoryController.clear();
                      } else {
                        _isAddingNewCategory = false;
                        _selectedCategoryValue = val;
                        _categoryController.text = val ?? '';
                      }
                    });
                  },
                ),
                
                if (_isAddingNewCategory) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryController,
                    style: GoogleFonts.poppins(fontSize: 14),
                    autofocus: true,
                    decoration: _buildInputDecoration('Nombre de la nueva categoría', Icons.create_new_folder_outlined),
                    validator: (v) => _isAddingNewCategory && (v == null || v.isEmpty) ? 'Ingresa un nombre' : null,
                  ),
                ],
                
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Tipo'),
                          DropdownButtonFormField<String>(
                            value: _tipoRespuesta,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                            decoration: _buildInputDecoration('', Icons.input_rounded),
                            items: ['texto', 'numero', 'opciones']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _tipoRespuesta = val!;
                                if (_tipoRespuesta == 'opciones') {
                                  _ensureMinimumOptions();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Estado'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('Obligatoria', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                              value: _obligatoria,
                              activeColor: colorAmarillo,
                              dense: true,
                              onChanged: (val) => setState(() => _obligatoria = val!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (_tipoRespuesta == 'numero') ...[
                  const SizedBox(height: 20),
                  _buildFieldLabel('Rango de Valores'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: _buildInputDecoration('Min', Icons.arrow_downward),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _maxController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: _buildInputDecoration('Max', Icons.arrow_upward),
                        ),
                      ),
                    ],
                  ),
                ],

                if (_tipoRespuesta == 'opciones') ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFieldLabel('Opciones de Respuesta'),
                      TextButton.icon(
                        onPressed: () => setState(() => _opcionesControllers.add(TextEditingController())),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Agregar', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: colorVerde),
                      ),
                    ],
                  ),
                  ..._opcionesControllers.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              style: GoogleFonts.poppins(fontSize: 13),
                              decoration: _buildInputDecoration('Opción ${idx + 1}', Icons.radio_button_checked),
                              validator: (v) => _tipoRespuesta == 'opciones' && (v == null || v.isEmpty) ? 'Requerido' : null,
                            ),
                          ),
                          if (_opcionesControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                              onPressed: () => setState(() {
                                _opcionesControllers[idx].dispose();
                                _opcionesControllers.removeAt(idx);
                              }),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final finalCategory = _isAddingNewCategory ? _categoryController.text : (_selectedCategoryValue ?? 'General');
                    
                    List<String>? finalOptions;
                    if (_tipoRespuesta == 'opciones') {
                      finalOptions = _opcionesControllers
                          .map((c) => c.text.trim())
                          .where((t) => t.isNotEmpty)
                          .toList();
                    }

                    final newPregunta = Pregunta(
                      id: widget.pregunta?.id ?? '',
                      apiarioId: widget.apiaryId,
                      texto: _formatQuestionText(_preguntaController.text),
                      tipoRespuesta: _tipoRespuesta,
                      categoria: finalCategory,
                      obligatoria: _obligatoria,
                      orden: widget.pregunta?.orden ?? 0,
                      min: int.tryParse(_minController.text),
                      max: int.tryParse(_maxController.text),
                      opciones: finalOptions,
                    );
                    
                    if (isEditing) {
                      ref.read(questionsControllerProvider.notifier).updatePregunta(newPregunta);
                    } else {
                      ref.read(questionsControllerProvider.notifier).createPregunta(newPregunta);
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAmarillo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? 'Actualizar' : 'Guardar Pregunta',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
