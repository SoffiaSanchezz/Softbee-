import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/router/app_routes.dart';
import '../providers/auth_providers.dart';
import '../providers/login_state.dart';
import '../providers/login_controller.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.isAuthenticated) {
        GoRouter.of(context).go(AppRoutes.dashboard);
      }
    });

    return const _LoginPageContent();
  }
}

class _LoginPageContent extends ConsumerStatefulWidget {
  const _LoginPageContent({super.key});

  @override
  ConsumerState<_LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends ConsumerState<_LoginPageContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifierController;
  late final TextEditingController _passwordController;
  late final FocusNode _identifierFocusNode;
  late final FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    final loginState = ref.read(loginControllerProvider);
    _identifierController = TextEditingController(text: loginState.identifier);
    _passwordController = TextEditingController(text: loginState.password);
    _identifierFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _identifierController.addListener(_onIdentifierChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onIdentifierChanged() {
    ref
        .read(loginControllerProvider.notifier)
        .onIdentifierChanged(_identifierController.text);
  }

  void _onPasswordChanged() {
    ref
        .read(loginControllerProvider.notifier)
        .onPasswordChanged(_passwordController.text);
  }

  @override
  void dispose() {
    _identifierController.removeListener(_onIdentifierChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _identifierController.dispose();
    _passwordController.dispose();
    _identifierFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final loginController = ref.read(loginControllerProvider.notifier);

    // Sincronizar controladores con estado
    if (_identifierController.text != loginState.identifier &&
        !_identifierFocusNode.hasFocus) {
      _identifierController.text = loginState.identifier;
    }
    if (_passwordController.text != loginState.password &&
        !_passwordFocusNode.hasFocus) {
      _passwordController.text = loginState.password;
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isSmallScreen = width < 600;
    final isLandscape = width > height;
    final isDesktop = width > 1024;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.lightYellow, Colors.white],
          ),
        ),
        child: SafeArea(
          child: loginState.isLoading
              ? Center(
                  child: Lottie.asset(
                    'assets/animations/LoadHIVE.json',
                    width: 200.0,
                    height: 200.0,
                  ),
                )
              : isDesktop
              ? _buildDesktopLayout(
                  context,
                  width,
                  height,
                  loginState,
                  loginController,
                )
              : (isLandscape && isSmallScreen
                    ? _buildLandscapeLayout(
                        context,
                        width,
                        height,
                        loginState,
                        loginController,
                      )
                    : _buildPortraitLayout(
                        context,
                        width,
                        height,
                        isSmallScreen,
                        loginState,
                        loginController,
                      )),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    double width,
    double height,
    LoginState loginState,
    LoginController loginController,
  ) {
    final logoSize = width * 0.12;
    final titleSize = width * 0.025;
    final subtitleSize = width * 0.015;
    final buttonHeight = height * 0.07;
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
              colors: [AppColors.lightYellow, Colors.white.withOpacity(0.9)],
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
                Container(
                  height: logoSize,
                  width: logoSize,
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(logoSize * 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkYellow.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/Logo.png',
                    width: logoSize * 0.6,
                    height: logoSize * 0.6,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: verticalSpacing),
                Text(
                  'SoftBee',
                  style: GoogleFonts.poppins(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
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
                    color: AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(height * 0.02),
                    border: Border.all(
                      color: AppColors.primaryYellow,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Bienvenido a tu plataforma',
                    style: GoogleFonts.poppins(
                      fontSize: subtitleSize,
                      color: AppColors.darkYellow,
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
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildLoginForm(
                    context,
                    titleSize * 0.9,
                    subtitleSize,
                    buttonHeight,
                    verticalSpacing,
                    loginState,
                    loginController,
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
    LoginState loginState,
    LoginController loginController,
  ) {
    final logoSize = width * (isSmallScreen ? 0.25 : 0.1);
    final titleSize = width * (isSmallScreen ? 0.10 : 0.04);
    final subtitleSize = width * (isSmallScreen ? 0.04 : 0.02);
    final buttonHeight = height * 0.07;
    final verticalSpacing = height * 0.02;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: height * 0.35,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: logoSize,
                      width: logoSize,
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(logoSize * 0.3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkYellow.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: logoSize * 0.6,
                        height: logoSize * 0.6,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    Text(
                      'SoftBee',
                      style: GoogleFonts.poppins(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildLoginForm(
              context,
              titleSize * 0.8,
              subtitleSize,
              buttonHeight,
              verticalSpacing,
              loginState,
              loginController,
            ),
            Padding(
              padding: EdgeInsets.only(top: verticalSpacing),
              child: _buildFooter(width, subtitleSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    double width,
    double height,
    LoginState loginState,
    LoginController loginController,
  ) {
    final logoSize = height * 0.25;
    final titleSize = height * 0.06;
    final subtitleSize = height * 0.035;
    final horizontalPadding = width * 0.05;
    final verticalSpacing = height * 0.03;
    final buttonHeight = height * 0.12;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: logoSize,
                    width: logoSize,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(logoSize * 0.25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkYellow.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: logoSize * 0.6,
                      height: logoSize * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'SoftBee',
                    style: GoogleFonts.poppins(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: width * 0.05),
            Expanded(
              child: _buildLoginForm(
                context,
                titleSize * 0.8,
                subtitleSize,
                buttonHeight,
                verticalSpacing,
                loginState,
                loginController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    double titleSize,
    double subtitleSize,
    double buttonHeight,
    double verticalSpacing,
    LoginState loginState,
    LoginController loginController,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Iniciar Sesión',
            style: GoogleFonts.poppins(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: verticalSpacing),
          if (loginState.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: verticalSpacing),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loginState.errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          _buildTextField(
            controller: _identifierController,
            label: 'Email',
            hint: 'ejemplo@correo.com',
            icon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (loginState.showValidationErrors &&
                  (value == null || value.isEmpty)) {
                return 'Por favor, ingrese su usuario o email';
              }
              return null;
            },
            onChanged: loginController.onIdentifierChanged,
            focusNode: _identifierFocusNode,
          ),
          SizedBox(height: verticalSpacing),
          _buildTextField(
            controller: _passwordController,
            label: 'Contraseña',
            hint: 'Ingresa tu contraseña',
            icon: Icons.lock_outline,
            isPassword: true,
            isPasswordVisible: loginState.isPasswordVisible,
            togglePasswordVisibility: loginController.togglePasswordVisibility,
            validator: (value) {
              if (loginState.showValidationErrors &&
                  (value == null || value.isEmpty)) {
                return 'Por favor, ingrese su contraseña';
              }
              if (loginState.showValidationErrors && value!.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              return null;
            },
            onChanged: loginController.onPasswordChanged,
            focusNode: _passwordFocusNode,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                GoRouter.of(context).push('/forgot-password');
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.darkYellow,
              ),
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: subtitleSize * 0.9,
                ),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing),
          SizedBox(
            height: buttonHeight,
            child: _buildLoginButton(
              fontSize: subtitleSize,
              isLoading: loginState.isLoading,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await loginController.login();
                } else {
                  loginController.state = loginController.state.copyWith(
                    showValidationErrors: true,
                  );
                }
              },
            ),
          ),
          SizedBox(height: verticalSpacing),
          _buildDivider(), // Añadir el divisor
          SizedBox(height: verticalSpacing),
          SizedBox(
            height: buttonHeight,
            child: _buildRegisterButton( // Añadir el botón de registro
              context: context,
              fontSize: subtitleSize,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? togglePasswordVisibility,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    FocusNode? focusNode,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textDark),
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppColors.darkYellow),
          prefixIcon: Icon(icon, color: AppColors.primaryYellow),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primaryYellow,
                  ),
                  onPressed: togglePasswordVisibility,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primaryYellow.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryYellow,
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
      ),
    );
  }

  Widget _buildLoginButton({
    required double fontSize,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryYellow.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: const LinearGradient(
          colors: [AppColors.primaryYellow, AppColors.accentYellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? Lottie.asset(
                'assets/animations/LoadHIVE.json',
                width: 40.0,
                height: 40.0,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Iniciar Sesión',
                    style: GoogleFonts.poppins(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.primaryYellow.withOpacity(0.5),
            thickness: 1.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightYellow,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryYellow, width: 1.5),
            ),
            child: Text(
              'O',
              style: GoogleFonts.poppins(
                color: AppColors.darkYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.primaryYellow.withOpacity(0.5),
            thickness: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton({
    required BuildContext context,
    required double fontSize,
  }) {
    return OutlinedButton(
      onPressed: () {
        GoRouter.of(context).push(AppRoutes.register);
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryYellow, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_add_outlined,
            color: AppColors.darkYellow,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Crear una cuenta',
            style: GoogleFonts.poppins(
              color: AppColors.darkYellow,
              fontWeight: FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double width, double fontSize) {
    return Column(
      children: [
        Text(
          '© ${DateTime.now().year} SoftBee. Todos los derechos reservados.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppColors.textDark.withOpacity(0.6),
            fontSize: fontSize * 0.7,
          ),
        ),
      ],
    );
  }
}


