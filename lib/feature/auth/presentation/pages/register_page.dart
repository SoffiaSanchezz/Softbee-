import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/register_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  List<TextEditingController> _apiaryNameControllers = [];
  List<TextEditingController> _apiaryAddressControllers = [];

  static const Color primaryYellow = Color(0xFFFFD100);
  static const Color accentYellow = Color(0xFFFFAB00);
  static const Color lightYellow = Color(0xFFFFF8E1);
  static const Color darkYellow = Color(0xFFF9A825);
  static const Color textDark = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(registerControllerProvider.notifier);
    nombreCtrl.addListener(() => notifier.onNameChanged(nombreCtrl.text));
    correoCtrl.addListener(() => notifier.onEmailChanged(correoCtrl.text));
    telefonoCtrl.addListener(() => notifier.onPhoneChanged(telefonoCtrl.text));
    passCtrl.addListener(() => notifier.onPasswordChanged(passCtrl.text));
    confirmPassCtrl.addListener(() => notifier.onConfirmPasswordChanged(confirmPassCtrl.text));
    _syncControllers(ref.read(registerControllerProvider).apiaries);
  }

  void _syncControllers(List<ApiaryFormState> apiaries) {
    // Dispose old controllers
    for (var i = 0; i < _apiaryNameControllers.length; i++) {
      _apiaryNameControllers[i].dispose();
      _apiaryAddressControllers[i].dispose();
    }
    _apiaryNameControllers = [];
    _apiaryAddressControllers = [];

    // Create new controllers from state
    for (final apiary in apiaries) {
      _apiaryNameControllers.add(TextEditingController(text: apiary.name));
      _apiaryAddressControllers.add(TextEditingController(text: apiary.address));
    }
  }
  
  @override
  void dispose() {
    nombreCtrl.dispose();
    correoCtrl.dispose();
    telefonoCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    for (var i = 0; i < _apiaryNameControllers.length; i++) {
      _apiaryNameControllers[i].dispose();
      _apiaryAddressControllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(registerControllerProvider, (previous, next) {
      if (next.user != null) {
        _showSuccessDialog('¡Registro Exitoso!');
      } else if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showErrorDialog(next.errorMessage!);
      }

      // Sync controllers if the number of apiaries changes
      if (previous != null && previous.apiaries.length != next.apiaries.length) {
        setState(() {
          _syncControllers(next.apiaries);
        });
      }
    });

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final isSmallScreen = width < 600;
          final isLandscape = width > height;
          final isDesktop = width > 1024;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [lightYellow, Colors.white],
              ),
            ),
            child: SafeArea(
              child: isDesktop
                  ? _buildDesktopLayout(context, width, height)
                  : (isLandscape && isSmallScreen
                        ? _buildLandscapeLayout(context, width, height)
                        : _buildPortraitLayout(
                            context,
                            width,
                            height,
                            isSmallScreen,
                          )),
            ),
          );
        },
      ),
    );
  }

  // --- Dialogs ---
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¡Registro Exitoso!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: textDark.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Colors.green, Color(0xFF4CAF50)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Pop the dialog
                    // Potentially navigate to another screen
                    // context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Error en el Registro',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: textDark.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Colors.red, Color(0xFFE53935)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Intentar de nuevo',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Layouts ---
  Widget _buildDesktopLayout(
    BuildContext context,
    double width,
    double height,
  ) {
    final logoSize = width * 0.12;
    final titleSize = width * 0.025;
    final subtitleSize = width * 0.015;
    final verticalSpacing = height * 0.025;

    return Row(
      children: [
        Container(
          width: width * 0.4,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [lightYellow, Colors.white.withOpacity(0.9)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(5, 0),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    height: logoSize,
                    width: logoSize,
                    decoration: BoxDecoration(
                      color: primaryYellow,
                      borderRadius: BorderRadius.circular(logoSize * 0.3),
                      boxShadow: [
                        BoxShadow(
                          color: darkYellow.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.hive,
                      size: logoSize * 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing),
                Text(
                  'SoftBee',
                  style: GoogleFonts.poppins(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.5),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.02,
                    vertical: height * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: lightYellow,
                    borderRadius: BorderRadius.circular(height * 0.02),
                    border: Border.all(color: primaryYellow, width: 2),
                  ),
                  child: Text(
                    'Crea tu cuenta de apicultor',
                    style: GoogleFonts.poppins(
                      fontSize: subtitleSize,
                      color: darkYellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.05,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Registro',
                          style: GoogleFonts.poppins(
                            fontSize: titleSize * 0.9,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: verticalSpacing),
                        _buildRegistrationStepper(width, height, subtitleSize),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    double width,
    double height,
    bool isSmallScreen,
  ) {
    final logoSize = width * (isSmallScreen ? 0.25 : 0.10);
    final titleSize = width * (isSmallScreen ? 0.05 : 0.02);
    final subtitleSize = width * (isSmallScreen ? 0.04 : 0.03);
    final verticalSpacing = height * 0.02;

    return Column(
      children: [
        // Header fijo
        Container(
          height: height * 0.2, // Reducido para dar más espacio al contenido
          padding: EdgeInsets.all(width * 0.05),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    height: logoSize,
                    width: logoSize,
                    decoration: BoxDecoration(
                      color: primaryYellow,
                      borderRadius: BorderRadius.circular(logoSize * 0.3),
                      boxShadow: [
                        BoxShadow(
                          color: darkYellow.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.hive,
                      size: logoSize * 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.5),
                Text(
                  'Registro SoftBee',
                  style: GoogleFonts.poppins(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Contenido scrolleable
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildRegistrationStepper(width, height, subtitleSize),
                  SizedBox(height: verticalSpacing),
                  _buildFooter(width, subtitleSize),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    double width,
    double height,
  ) {
    final logoSize = height * 0.25;
    final titleSize = height * 0.06;
    final subtitleSize = height * 0.035;
    final horizontalPadding = width * 0.05;
    final verticalSpacing = height * 0.03;

    return Row(
      children: [
        // Logo lateral fijo
        Container(
          width: width * 0.3,
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: logoSize,
                width: logoSize,
                decoration: BoxDecoration(
                  color: primaryYellow,
                  borderRadius: BorderRadius.circular(logoSize * 0.25),
                  boxShadow: [
                    BoxShadow(
                      color: darkYellow.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.hive,
                  size: logoSize * 0.4,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: verticalSpacing * 0.5),
              Text(
                'SoftBee',
                style: GoogleFonts.poppins(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Contenido scrolleable
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: Form(
              key: _formKey,
              child: _buildRegistrationStepper(width, height, subtitleSize),
            ),
          ),
        ),
      ],
    );
  }

  // --- Stepper and Form Widgets ---
  Widget _buildRegistrationStepper(
    double width,
    double height,
    double fontSize,
  ) {
    final state = ref.watch(registerControllerProvider);
    final notifier = ref.read(registerControllerProvider.notifier);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: primaryYellow, secondary: accentYellow),
      ),
      child: Stepper(
        type: StepperType.vertical,
        currentStep: state.currentStep,
        physics:
            const NeverScrollableScrollPhysics(), // Evita conflictos de scroll
        onStepContinue: notifier.onStepContinue,
        onStepCancel: () {
          if (state.currentStep == 0) {
            Navigator.of(context).pop();
          } else {
            notifier.onStepCancel();
          }
        },
        onStepTapped: notifier.goToStep,
        controlsBuilder: (context, details) {
          final isLastStep = state.currentStep == 1;

          return Container(
            margin: const EdgeInsets.only(
              top: 20,
              bottom: 20,
            ), // Más margen para mejor accesibilidad
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryYellow.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [primaryYellow, accentYellow],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ), // Más padding para mejor toque
                      ),
                      child: state.isLoading && isLastStep
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isLastStep
                                      ? Icons.check_circle
                                      : Icons.navigate_next,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isLastStep ? 'Registrarse' : 'Continuar',
                                  style: GoogleFonts.poppins(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryYellow, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ), // Más padding para mejor toque
                    ),
                    child: Text(
                      state.currentStep > 0 ? 'Atrás' : 'Cancelar',
                      style: GoogleFonts.poppins(
                        color: darkYellow,
                        fontWeight: FontWeight.normal,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: Text(
              'Información Personal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            content: _buildStep1Content(),
            isActive: state.currentStep >= 0,
            state: state.currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text(
              'Información de Apiarios',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            content: _buildStep2Content(fontSize),
            isActive: state.currentStep >= 1,
            state: state.currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Content() {
    final state = ref.watch(registerControllerProvider);
    final notifier = ref.read(registerControllerProvider.notifier);
    
    return Column(
      children: [
        _buildTextField(
          controller: nombreCtrl,
          label: 'Nombre completo',
          hint: 'Ingresa tu nombre',
          icon: Icons.person_outline,
          errorText: state.showValidation ? state.nameError : null,
          onChanged: notifier.onNameChanged,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: correoCtrl,
          label: 'Correo electrónico',
          hint: 'ejemplo@correo.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: state.showValidation ? state.emailError : null,
          onChanged: notifier.onEmailChanged,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: telefonoCtrl,
          label: 'Teléfono',
          hint: '3XX XXX XXXX',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _phoneFormatter,
          ],
          errorText: state.showValidation ? state.phoneError : null,
          onChanged: notifier.onPhoneChanged,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: passCtrl,
          label: 'Contraseña',
          hint: 'Crea una contraseña segura',
          icon: Icons.lock_outline,
          isPassword: true,
          errorText: state.showValidation ? state.passwordError : null,
          onChanged: notifier.onPasswordChanged,
          showPasswordRequirements: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: confirmPassCtrl,
          label: 'Confirmar contraseña',
          hint: 'Repite tu contraseña',
          icon: Icons.lock_outline,
          isPassword: true,
          errorText: state.showValidation ? state.confirmPasswordError : null,
          onChanged: notifier.onConfirmPasswordChanged,
        ),
      ],
    );
  }

  Widget _buildStep2Content(double fontSize) {
    final state = ref.watch(registerControllerProvider);
    final notifier = ref.read(registerControllerProvider.notifier);
    return Column(
      children: [
        Text(
          'Agrega información sobre tus apiarios',
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            color: textDark.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        ...state.apiaries.asMap().entries.map((entry) {
          final index = entry.key;
          final apiary = entry.value;
          final addressError = (state.apiaryAddressErrors.length > index)
              ? state.apiaryAddressErrors[index]
              : null;

          return _buildApiaryCard(
            nameController: _apiaryNameControllers[index],
            addressController: _apiaryAddressControllers[index],
            apiary: apiary,
            index: index,
            onRemove: () => notifier.removeApiary(index),
            showRemoveButton: state.apiaries.length > 1,
            onNameChanged: (value) => notifier.updateApiaryName(index, value),
            onAddressChanged: (value) => notifier.updateApiaryAddress(index, value),
            onTreatmentChanged: (value) => notifier.updateApiaryTreatment(index, value),
            addressErrorText: addressError,
          );
        }).toList(),
        Padding(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 20,
          ), 
          child: OutlinedButton.icon(
            onPressed: notifier.addApiary,
            icon: const Icon(Icons.add, color: darkYellow),
            label: Text(
              'Agregar otro apiario',
              style: GoogleFonts.poppins(
                color: darkYellow,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primaryYellow, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiaryCard({
    required TextEditingController nameController,
    required TextEditingController addressController,
    required ApiaryFormState apiary,
    required int index,
    required VoidCallback onRemove,
    required bool showRemoveButton,
    required ValueChanged<String> onNameChanged,
    required ValueChanged<String> onAddressChanged,
    required ValueChanged<bool> onTreatmentChanged,
    String? addressErrorText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryYellow.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: lightYellow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Apiario ${index + 1}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: darkYellow,
                  ),
                ),
                if (showRemoveButton)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Eliminar apiario',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField(
                  controller: nameController,
                  label: 'Nombre del apiario',
                  hint: 'Ej: Apiario Las Flores',
                  icon: Icons.label_outline,
                  onChanged: onNameChanged,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: addressController,
                  label: 'Dirección exacta del apiario',
                  hint: 'Ej: Cota, Vereda El Rosal - Finca La Esperanza',
                  icon: Icons.location_on_outlined,
                  onChanged: onAddressChanged,
                  errorText: addressErrorText,
                ),
                const SizedBox(height: 16),
                _buildTreatmentSwitch(
                  value: apiary.appliesTreatments,
                  onChanged: onTreatmentChanged,
                  title:
                      '¿Aplicas tratamientos cuando las abejas están enfermas?',
                  subtitle:
                      'Indica si utilizas medicamentos o tratamientos veterinarios',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentSwitch({
    required bool value,
    required Function(bool) onChanged,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryYellow.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: textDark,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: textDark.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: primaryYellow,
        activeTrackColor: primaryYellow.withOpacity(0.3),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
    bool showPasswordRequirements = false,
  }) {
    // This state is local to the widget and OK to be here.
    final ValueNotifier<bool> isPasswordVisible = ValueNotifier(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: isPasswordVisible,
            builder: (context, isVisible, child) {
              return TextFormField(
                controller: controller,
                obscureText: isPassword && !isVisible,
                keyboardType: keyboardType,
                style: const TextStyle(color: textDark),
                inputFormatters: inputFormatters,
                onChanged: onChanged,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  labelStyle: TextStyle(
                    color: errorText != null ? Colors.red : darkYellow,
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: errorText != null ? Colors.red : primaryYellow,
                  ),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility_off : Icons.visibility,
                            color: errorText != null ? Colors.red : primaryYellow,
                          ),
                          onPressed: () => isPasswordVisible.value = !isVisible,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: errorText != null
                          ? Colors.red.withOpacity(0.5)
                          : primaryYellow.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: errorText != null ? Colors.red : primaryYellow,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              );
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              errorText,
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (showPasswordRequirements && controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: _buildPasswordRequirements(),
          ),
      ],
    );
  }
  
  Widget _buildPasswordRequirements() {
    final state = ref.watch(registerControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _passwordRequirementText(
          'Al menos 8 caracteres',
          state.passwordHasMinLength,
        ),
        _passwordRequirementText(
          'Al menos una letra (a-z, A-Z)',
          state.passwordHasLetter,
        ),
        _passwordRequirementText(
          'Al menos un número (0-9)',
          state.passwordHasNumber,
        ),
        _passwordRequirementText(
          'Al menos un símbolo (!@#\$%^&*(),.?)',
          state.passwordHasSymbol,
        ),
      ],
    );
  }

  Widget _passwordRequirementText(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_off,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: isMet ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  TextInputFormatter get _phoneFormatter {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      if (text.length > 10) {
        text = text.substring(0, 10);
      }
      String newText = '';
      for (int i = 0; i < text.length; i++) {
        if (i == 3 || i == 6) {
          newText += ' ';
        }
        newText += text[i];
      }
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    });
  }

  Widget _buildFooter(double width, double fontSize) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          '© ${DateTime.now().year} SoftBee. Todos los derechos reservados.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: textDark.withOpacity(0.6),
            fontSize: fontSize * 0.7,
          ),
        ),
      ],
    );
  }
}