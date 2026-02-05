import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/reset_password_controller.dart';
import '../providers/auth_providers.dart';
import '../providers/reset_password_state.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String token;

  const ResetPasswordPage({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Colores personalizados
  static const Color _lightYellow = Color(0xFFFFF9C4);
  static const Color _primaryYellow = Color(0xFFFFC107);
  static const Color _accentYellow = Color(0xFFFFA000);
  static const Color _darkYellow = Color(0xFFFF8F00);

  @override
  void initState() {
    super.initState();

    // Limpiar el estado del controlador al entrar en la página
    ref.read(resetPasswordControllerProvider.notifier).resetState();

    // Validar token al inicializar (simulado)
    // if (widget.token.isEmpty) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     // ref.read(resetPasswordControllerProvider.notifier).setErrorMessage('Token inválido');
    //     // GoRouter.of(context).go('/forgot-password'); // Asegúrate de que esta ruta exista
    //   });
    // }

    // Inicializar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Suscribir los controladores de texto a los métodos del StateNotifier
    _passwordController.addListener(() {
      ref
          .read(resetPasswordControllerProvider.notifier)
          .onPasswordChanged(_passwordController.text);
      _formKey.currentState?.validate(); // Revalidar al cambiar contraseña
    });
    _confirmPasswordController.addListener(() {
      ref
          .read(resetPasswordControllerProvider.notifier)
          .onConfirmPasswordChanged(_confirmPasswordController.text);
      _formKey.currentState?.validate(); // Revalidar al cambiar contraseña
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar el estado para reaccionar a cambios importantes
    ref.listen<ResetPasswordState>(resetPasswordControllerProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        _showErrorSnackBar(next.errorMessage!);
      }
      if (next.passwordChanged && !previous!.passwordChanged) {
        _showSuccessSnackBar('Contraseña cambiada con éxito.');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            GoRouter.of(
              context,
            ).go('/login'); // Asegúrate de que esta ruta exista
          }
        });
      }
    });

    final state = ref.watch(resetPasswordControllerProvider);
    final controller = ref.read(resetPasswordControllerProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lightYellow, Colors.white],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 20),
                    _buildMainCard(state, controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkYellow),
          onPressed: () {
            ref.read(resetPasswordControllerProvider.notifier).resetState();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildMainCard(
    ResetPasswordState state,
    ResetPasswordController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildPasswordField(state, controller),
            const SizedBox(height: 20),
            _buildConfirmPasswordField(state, controller),
            const SizedBox(height: 32),
            _buildSubmitButton(state, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primaryYellow, _accentYellow],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primaryYellow.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          'Nueva Contraseña',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crea una contraseña segura para tu cuenta',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    ResetPasswordState state,
    ResetPasswordController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nueva contraseña',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !state.showPassword,
          style: GoogleFonts.poppins(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Mínimo 8 caracteres',
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.lock_outline, color: _primaryYellow),
            suffixIcon: IconButton(
              icon: Icon(
                state.showPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[400],
              ),
              onPressed: controller.toggleShowPassword,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _primaryYellow, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) => controller.validatePassword(value),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(
    ResetPasswordState state,
    ResetPasswordController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirmar contraseña',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !state.showConfirmPassword,
          style: GoogleFonts.poppins(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Repite tu nueva contraseña',
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.lock_outline, color: _primaryYellow),
            suffixIcon: IconButton(
              icon: Icon(
                state.showConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey[400],
              ),
              onPressed: controller.toggleShowConfirmPassword,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _primaryYellow, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) => controller.validateConfirmPassword(value),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    ResetPasswordState state,
    ResetPasswordController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryYellow, _accentYellow],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryYellow.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: (state.isLoading || state.passwordChanged)
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    controller.submitNewPassword(widget.token);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: state.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      state.passwordChanged
                          ? Icons.check_circle
                          : Icons.lock_open,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      state.passwordChanged
                          ? 'Contraseña Cambiada'
                          : 'Cambiar Contraseña',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
