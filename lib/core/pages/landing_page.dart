import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_routes.dart'; // Importar AppRoutes

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(context),
              _buildFeaturesSection(context),
              _buildVoiceCommandsSection(context),
              _buildStatsSection(context),
              _buildBenefitsSection(context),
              _buildTestimonialsSection(context),
              _buildCtaSection(context),
              _buildContactSection(context),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.white,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFFBBF24), // Amber 400
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/Logo.png', // Ruta de tu imagen
                width: 24, // Ajusta el tamaño según necesites
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'SoftBee',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
      actions: [
        if (MediaQuery.of(context).size.width > 600) ...[
          _buildNavItem('Características', () {}),
          _buildNavItem('Beneficios', () {}),
          _buildNavItem('Contacto', () {}),
          const SizedBox(width: 16),
        ],
        TextButton(
          onPressed: () {
            GoRouter.of(context).go(AppRoutes.loginRoute); // Usar GoRouter
          },
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
          child: const Text('Iniciar Sesión'),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 40, // Ajustar la altura para evitar desbordamiento
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Descargar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildNavItem(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF6B7280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSectionHeader(String badge, String title, String description) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF92400E),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Colors.white],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
        vertical: isDesktop ? 80 : 48,
      ),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isDesktop
                  ? Row(
                      children: [
                        Expanded(flex: 6, child: _buildHeroContent(context)),
                        const SizedBox(width: 80),
                        Expanded(flex: 4, child: _buildHeroImage(context)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeroContent(context),
                        const SizedBox(height: 48),
                        _buildHeroImage(context),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Innovación Tecnológica',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Maya: Sistema de\nMonitoreo Inteligente',
          style: TextStyle(
            fontSize: isDesktop ? 48 : 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'La solución definitiva para monitoreo inteligente. Controla y gestiona toda la información de tus sistemas utilizando comandos de voz avanzados.',
          style: TextStyle(
            fontSize: isDesktop ? 20 : 18,
            color: const Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text('Descargar Ahora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
              label: const Text('Ver Demostración'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        _buildTrustIndicators(),
      ],
    );
  }

  Widget _buildTrustIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confiado por más de 500 usuarios',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ...List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.only(right: 4),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFBBF24),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '4.9/5 (127 reseñas)',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Stack(
          children: [
            // Phone mockup
            Container(
              width: 300,
              height: 600,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 8),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Column(
                  children: [
                    // Phone notch
                    Container(height: 24, color: Colors.black),
                    // Phone screen
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background microphone pattern
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Large background microphone
                                    Positioned(
                                      top: 50,
                                      right: -30,
                                      child: Icon(
                                        Icons.mic_rounded,
                                        color: Colors.white.withOpacity(0.1),
                                        size: 150,
                                      ),
                                    ),
                                    // Small background microphones
                                    Positioned(
                                      bottom: 100,
                                      left: -20,
                                      child: Icon(
                                        Icons.mic_rounded,
                                        color: Colors.white.withOpacity(0.05),
                                        size: 80,
                                      ),
                                    ),
                                    Positioned(
                                      top: 200,
                                      left: 20,
                                      child: Icon(
                                        Icons.mic_rounded,
                                        color: Colors.white.withOpacity(0.08),
                                        size: 60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Main content
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mic_rounded,
                                    color: Colors.white,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Maya',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Sistema de Monitoreo\nInteligente',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
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
              ),
            ),
            // Decorative elements
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
        vertical: isDesktop ? 100 : 80,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            _buildSectionHeader(
              'Características',
              'Todo lo que necesitas para monitoreo inteligente',
              'Maya combina tecnología avanzada con una interfaz intuitiva para ofrecerte la mejor experiencia en monitoreo y control.',
            ),
            const SizedBox(height: 64),
            GridView.count(
              crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 32,
              crossAxisSpacing: 32,
              childAspectRatio: isDesktop ? 1.0 : 1.2,
              children: [
                _buildFeatureCard(
                  icon: Icons.mic_rounded,
                  title: 'Control por Voz',
                  description:
                      'Registra datos, consulta información y controla la aplicación utilizando solo comandos de voz.',
                  color: const Color(0xFF3B82F6),
                ),
                _buildFeatureCard(
                  icon: Icons.analytics_rounded,
                  title: 'Estadísticas Detalladas',
                  description:
                      'Visualiza el rendimiento y estado de tus sistemas con gráficos intuitivos y reportes completos.',
                  color: const Color(0xFF10B981),
                ),
                _buildFeatureCard(
                  icon: Icons.cloud_done_rounded,
                  title: 'Almacenamiento Seguro',
                  description:
                      'Toda la información almacenada de forma segura y accesible desde cualquier dispositivo.',
                  color: const Color(0xFF8B5CF6),
                ),
                _buildFeatureCard(
                  icon: Icons.notifications_active_rounded,
                  title: 'Alertas Inteligentes',
                  description:
                      'Recibe notificaciones sobre eventos importantes, mantenimientos y revisiones programadas.',
                  color: const Color(0xFFF59E0B),
                ),
                _buildFeatureCard(
                  icon: Icons.offline_bolt_rounded,
                  title: 'Funciona Sin Internet',
                  description:
                      'Trabaja sin preocuparte por la conexión. Sincroniza los datos cuando vuelvas a tener señal.',
                  color: const Color(0xFFEF4444),
                ),
                _buildFeatureCard(
                  icon: Icons.volume_up_rounded,
                  title: 'Respuesta Auditiva',
                  description:
                      'La aplicación te responde verbalmente, permitiéndote trabajar sin necesidad de mirar la pantalla.',
                  color: const Color(0xFF06B6D4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCommandsSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
        vertical: isDesktop ? 100 : 80,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            _buildSectionHeader(
              'Comandos de Voz',
              'Controla todo con tu voz',
              'Maya entiende tus comandos de voz para que puedas trabajar con las manos libres mientras monitoreas tus sistemas.',
            ),
            const SizedBox(height: 64),
            GridView.count(
              crossAxisCount: isDesktop ? 2 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: isDesktop ? 1.3 : 1.1,
              children: [
                _buildCommandCard(
                  title: 'Registro de Datos',
                  icon: Icons.edit_note_rounded,
                  commands: [
                    '"Registrar temperatura sistema 5: 25 grados"',
                    '"Anotar mantenimiento en equipo norte"',
                    '"Marcar alerta en sensor 12"',
                  ],
                ),
                _buildCommandCard(
                  title: 'Consultas Inteligentes',
                  icon: Icons.search_rounded,
                  commands: [
                    '"¿Cuál fue el promedio de temperatura del mes pasado?"',
                    '"Mostrar historial del sistema número 8"',
                    '"¿Cuándo fue la última revisión del equipo sur?"',
                  ],
                ),
                _buildCommandCard(
                  title: 'Control de la Aplicación',
                  icon: Icons.settings_voice_rounded,
                  commands: [
                    '"Abrir sección de estadísticas"',
                    '"Crear nuevo sistema en zona este"',
                    '"Programar revisión para el próximo martes"',
                  ],
                ),
                _buildCommandCard(
                  title: 'Alertas y Recordatorios',
                  icon: Icons.schedule_rounded,
                  commands: [
                    '"Recordarme revisar los sistemas nuevos en 2 semanas"',
                    '"Programar alerta para mantenimiento en 30 días"',
                    '"Configurar recordatorio de calibración mensual"',
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandCard({
    required String title,
    required IconData icon,
    required List<String> commands,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...commands.map(
            (command) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Comando',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      command,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),
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

  Widget _buildStatsSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
        vertical: isDesktop ? 80 : 60,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('500+', 'Usuarios'),
            _buildStatItem('10K+', 'Sistemas'),
            _buildStatItem('4.9★', 'Calificación'),
            _buildStatItem('24/7', 'Soporte'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
        vertical: isDesktop ? 100 : 80,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            _buildSectionHeader(
              'Beneficios',
              '¿Por qué elegir Maya?',
              'Descubre cómo Maya puede transformar tu sistema de monitoreo y mejorar tu productividad.',
            ),
            const SizedBox(height: 64),
            GridView.count(
              crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 32,
              crossAxisSpacing: 32,
              childAspectRatio: 1.2,
              children: [
                _buildBenefitCard(
                  icon: Icons.timer_rounded,
                  title: 'Ahorra Tiempo',
                  description:
                      'Reduce hasta un 40% el tiempo dedicado a la documentación y registro de datos.',
                  percentage: '40%',
                ),
                _buildBenefitCard(
                  icon: Icons.back_hand_rounded,
                  title: 'Manos Libres',
                  description:
                      'Trabaja con tus sistemas sin interrupciones mientras registras toda la información importante.',
                  percentage: '100%',
                ),
                _buildBenefitCard(
                  icon: Icons.trending_up_rounded,
                  title: 'Decisiones Informadas',
                  description:
                      'Analiza tendencias y patrones para optimizar el rendimiento y estado de tus sistemas.',
                  percentage: '+25%',
                ),
                _buildBenefitCard(
                  icon: Icons.touch_app_rounded,
                  title: 'Fácil de Usar',
                  description:
                      'Interfaz intuitiva diseñada para usuarios de todos los niveles de experiencia tecnológica.',
                  percentage: '5min',
                ),
                _buildBenefitCard(
                  icon: Icons.group_rounded,
                  title: 'Trabajo en Equipo',
                  description:
                      'Comparte información con colaboradores y mantén a todo el equipo sincronizado.',
                  percentage: '∞',
                ),
                _buildBenefitCard(
                  icon: Icons.support_agent_rounded,
                  title: 'Soporte Técnico',
                  description:
                      'Asistencia personalizada y actualizaciones regulares para mejorar tu experiencia.',
                  percentage: '24/7',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required String percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Text(
                percentage,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
        vertical: isDesktop ? 100 : 80,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            _buildSectionHeader(
              'Testimonios',
              'Lo que dicen nuestros usuarios',
              'Conoce las experiencias de usuarios que ya están transformando sus sistemas de monitoreo con Maya.',
            ),
            const SizedBox(height: 64),
            GridView.count(
              crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 0.9,
              children: [
                _buildTestimonialCard(
                  name: 'Carlos Mendoza',
                  role: 'Ingeniero de Sistemas',
                  content:
                      'Maya ha revolucionado nuestro trabajo. Ahora podemos registrar datos mientras monitoreamos los sistemas sin interrupciones.',
                  rating: 5,
                ),
                _buildTestimonialCard(
                  name: 'María González',
                  role: 'Supervisora de Operaciones',
                  content:
                      'La función de comandos de voz es increíble. Nuestro equipo ha mejorado la eficiencia en un 40%.',
                  rating: 5,
                ),
                _buildTestimonialCard(
                  name: 'José Ramírez',
                  role: 'Técnico Especialista',
                  content:
                      'Pensé que sería difícil adaptarme a la tecnología, pero Maya es muy intuitivo. Lo recomiendo totalmente.',
                  rating: 5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard({
    required String name,
    required String role,
    required String content,
    required int rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              rating,
              (index) => const Icon(
                Icons.star_rounded,
                color: Color(0xFFFBBF24),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"$content"',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF374151),
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
        vertical: isDesktop ? 100 : 80,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Text(
              'Únete a la revolución del monitoreo inteligente',
              style: TextStyle(
                fontSize: isDesktop ? 40 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Más de 500 usuarios ya están utilizando Maya para transformar sus sistemas de monitoreo. Únete hoy y descubre el futuro de la tecnología inteligente.',
              style: TextStyle(fontSize: 18, color: Colors.white, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text('Descargar Ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFF59E0B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                  label: const Text('Solicitar Demostración'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Descarga gratuita • Sin compromisos • Soporte incluido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  Widget _buildContactSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
        vertical: isDesktop ? 100 : 80,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildContactInfo()),
                  const SizedBox(width: 80),
                  Expanded(flex: 7, child: _buildContactForm()),
                ],
              )
            : Column(
                children: [
                  _buildContactInfo(),
                  const SizedBox(height: 48),
                  _buildContactForm(),
                ],
              ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
          ),
          child: const Text(
            'Contacto',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF92400E),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¿Tienes preguntas?',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Estamos aquí para ayudarte. Contáctanos y te responderemos a la brevedad.',
          style: TextStyle(fontSize: 18, color: Color(0xFF6B7280), height: 1.6),
        ),
        const SizedBox(height: 40),
        _buildContactItem(
          icon: Icons.phone_rounded,
          title: 'Teléfono',
          content: '+123 456 7890',
        ),
        const SizedBox(height: 24),
        _buildContactItem(
          icon: Icons.email_rounded,
          title: 'Email',
          content: 'info @maya.com',
        ),
        const SizedBox(height: 24),
        _buildContactItem(
          icon: Icons.location_on_rounded,
          title: 'Ubicación',
          content: 'Calle Tecnología 123, Ciudad Digital',
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Envíanos un mensaje',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildFormField(label: 'Nombre', hint: 'Juan'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(label: 'Apellido', hint: 'Pérez'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormField(label: 'Email', hint: 'juan @ejemplo.com'),
          const SizedBox(height: 24),
          _buildFormField(
            label: 'Mensaje',
            hint: 'Escribe tu mensaje aquí...',
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Enviar Mensaje',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1F2937)),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 48,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildFooterBrand()),
                  const SizedBox(width: 80),
                  Expanded(
                    child: _buildFooterLinks('Producto', [
                      'Características',
                      'Precios',
                      'Descargas',
                      'Actualizaciones',
                    ]),
                  ),
                  Expanded(
                    child: _buildFooterLinks('Soporte', [
                      'Documentación',
                      'Tutoriales',
                      'Contacto',
                      'FAQ',
                    ]),
                  ),
                  Expanded(
                    child: _buildFooterLinks('Empresa', [
                      'Acerca de',
                      'Blog',
                      'Carreras',
                      'Prensa',
                    ]),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildFooterBrand(),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFooterLinks('Producto', [
                          'Características',
                          'Precios',
                          'Descargas',
                        ]),
                      ),
                      Expanded(
                        child: _buildFooterLinks('Soporte', [
                          'Documentación',
                          'Contacto',
                          'FAQ',
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 48),
            Container(height: 1, color: const Color(0xFF374151)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '© 2025 SoftBee. Todos los derechos reservados.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                ),
                if (isDesktop)
                  Row(
                    children: [
                      _buildFooterLink('Términos'),
                      const SizedBox(width: 24),
                      _buildFooterLink('Privacidad'),
                      const SizedBox(width: 24),
                      _buildFooterLink('Cookies'),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hexagon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'SoftBee',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Sistema de monitoreo inteligente con control por voz. La solución definitiva para gestión moderna.',
          style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF), height: 1.5),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildSocialIcon(Icons.facebook),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.alternate_email),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.phone),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
    );
  }

  Widget _buildFooterLinks(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFooterLink(link),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
    );
  }
}
