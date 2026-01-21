import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';

// ============================================
// PÁGINA 404 - TEMA APIARIO/ABEJAS
// ============================================

// Colores del tema
class BeeThemeColors {
  static const Color honey = Color(0xFFF59E0B);
  static const Color honeyLight = Color(0xFFFBBF24);
  static const Color honeyDark = Color(0xFFD97706);
  static const Color amber = Color(0xFFB45309);
  static const Color cream = Color(0xFFFEF3C7);
  static const Color brown = Color(0xFF78350F);
  static const Color backgroundStart = Color(0xFFFFFBEB);
  static const Color backgroundEnd = Color(0xFFFDE68A);
}

class NotFoundPage extends StatefulWidget {
  const NotFoundPage({super.key});

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage>
    with TickerProviderStateMixin {
  late AnimationController _beeFloatController;
  late AnimationController _wingsController;
  late AnimationController _honeycombController;
  late Animation<double> _beeFloatAnimation;
  late Animation<double> _beeRotationAnimation;

  final List<FlyingBee> _flyingBees = [];
  final List<HoneyDrop> _honeyDrops = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Animación de flotación de la abeja principal
    _beeFloatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _beeFloatAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _beeFloatController, curve: Curves.easeInOut),
    );

    _beeRotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _beeFloatController, curve: Curves.easeInOut),
    );

    // Animación de alas
    _wingsController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    )..repeat(reverse: true);

    // Animación del panal
    _honeycombController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    // Generar abejas volando
    for (int i = 0; i < 6; i++) {
      _flyingBees.add(FlyingBee(
        startX: _random.nextDouble(),
        startY: _random.nextDouble(),
        duration: 8 + _random.nextInt(7),
        delay: i * 0.5,
        size: 20 + _random.nextDouble() * 15,
      ));
    }

    // Generar gotas de miel
    for (int i = 0; i < 5; i++) {
      _honeyDrops.add(HoneyDrop(
        x: _random.nextDouble(),
        duration: 4 + _random.nextInt(4),
        delay: i * 0.8,
      ));
    }
  }

  @override
  void dispose() {
    _beeFloatController.dispose();
    _wingsController.dispose();
    _honeycombController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              BeeThemeColors.backgroundStart,
              BeeThemeColors.backgroundEnd,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Fondo de panal
            const HoneycombBackground(),

            // Gotas de miel animadas
            ..._honeyDrops.map((drop) => AnimatedHoneyDrop(drop: drop)),

            // Abejas volando en el fondo
            ..._flyingBees.map((bee) => AnimatedFlyingBee(bee: bee)),

            // Contenido principal
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Número 404 con abeja
                    AnimatedBuilder(
                      animation: _beeFloatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _beeFloatAnimation.value),
                          child: Transform.rotate(
                            angle: _beeRotationAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Texto 404
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                BeeThemeColors.honeyDark,
                                BeeThemeColors.honey,
                                BeeThemeColors.honeyLight,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              '404',
                              style: TextStyle(
                                fontSize: 150,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(4, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Abeja principal
                          Positioned(
                            top: 20,
                            child: AnimatedBuilder(
                              animation: _wingsController,
                              builder: (context, child) {
                                return MainBee(
                                  wingAngle: _wingsController.value,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tarjeta de mensaje
                    Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: BeeThemeColors.honey.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: BeeThemeColors.honey.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Icono de colmena
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  BeeThemeColors.honey,
                                  BeeThemeColors.honeyDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.hive_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            '¡Bzzzz! Esta abeja se perdió',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: BeeThemeColors.brown,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Parece que esta página voló lejos de la colmena. '
                            'No te preocupes, nuestras abejas exploradoras '
                            'te ayudarán a encontrar el camino de regreso.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: BeeThemeColors.brown.withOpacity(0.7),
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Separador decorativo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                child: HexagonWidget(
                                  size: 12,
                                  color: BeeThemeColors.honey.withOpacity(0.5 + i * 0.1),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 28),

                          // Botones
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  GoRouter.of(context).go(AppRoutes.dashboard); // Usando go_router y AppRoutes.dashboard
                                },
                                icon: const Icon(Icons.home_rounded),
                                label: const Text('Volver a la colmena'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: BeeThemeColors.honey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  // Implementar búsqueda
                                },
                                icon: const Icon(Icons.search_rounded),
                                label: const Text('Buscar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: BeeThemeColors.honeyDark,
                                  side: const BorderSide(
                                    color: BeeThemeColors.honey,
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Dato curioso
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BeeThemeColors.honey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: BeeThemeColors.honey.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('🍯', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '¿Sabías que una abeja visita entre 50 y 1000 flores en un solo viaje?',
                              style: TextStyle(
                                fontSize: 14,
                                color: BeeThemeColors.brown.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
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
      ),
    );
  }
}

// ============================================
// WIDGET DE ABEJA PRINCIPAL
// ============================================

class MainBee extends StatelessWidget {
  final double wingAngle;

  const MainBee({super.key, required this.wingAngle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 70,
      child: CustomPaint(
        painter: BeePainter(wingAngle: wingAngle),
      ),
    );
  }
}

class BeePainter extends CustomPainter {
  final double wingAngle;

  BeePainter({required this.wingAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(center: center + const Offset(3, 3), width: 45, height: 35),
      shadowPaint,
    );

    // Alas
    final wingPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final wingOffset = wingAngle * 10;

    // Ala izquierda
    canvas.save();
    canvas.translate(center.dx - 15, center.dy - 10 - wingOffset);
    canvas.rotate(-0.3 - wingAngle * 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 30, height: 18),
      wingPaint,
    );
    canvas.restore();

    // Ala derecha
    canvas.save();
    canvas.translate(center.dx + 15, center.dy - 10 - wingOffset);
    canvas.rotate(0.3 + wingAngle * 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 30, height: 18),
      wingPaint,
    );
    canvas.restore();

    // Cuerpo (gradiente)
    final bodyGradient = RadialGradient(
      colors: [
        BeeThemeColors.honeyLight,
        BeeThemeColors.honey,
        BeeThemeColors.honeyDark,
      ],
    ).createShader(Rect.fromCenter(center: center, width: 45, height: 35));

    final bodyPaint = Paint()..shader = bodyGradient;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 45, height: 35),
      bodyPaint,
    );

    // Rayas negras
    final stripePaint = Paint()
      ..color = BeeThemeColors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    for (int i = -1; i <= 1; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: center + Offset(i * 10.0, 0),
          width: 8,
          height: 30,
        ),
        0,
        pi,
        false,
        stripePaint,
      );
    }

    // Ojos
    final eyePaint = Paint()..color = BeeThemeColors.brown;
    canvas.drawCircle(center + const Offset(-8, -5), 5, eyePaint);
    canvas.drawCircle(center + const Offset(8, -5), 5, eyePaint);

    // Brillo en ojos
    final eyeHighlight = Paint()..color = Colors.white;
    canvas.drawCircle(center + const Offset(-6, -7), 2, eyeHighlight);
    canvas.drawCircle(center + const Offset(10, -7), 2, eyeHighlight);

    // Sonrisa
    final smilePaint = Paint()
      ..color = BeeThemeColors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final smilePath = Path()
      ..moveTo(center.dx - 6, center.dy + 5)
      ..quadraticBezierTo(center.dx, center.dy + 12, center.dx + 6, center.dy + 5);
    canvas.drawPath(smilePath, smilePaint);

    // Mejillas sonrojadas
    final blushPaint = Paint()..color = Colors.pink.withOpacity(0.3);
    canvas.drawCircle(center + const Offset(-15, 2), 5, blushPaint);
    canvas.drawCircle(center + const Offset(15, 2), 5, blushPaint);

    // Antenas
    final antennaPaint = Paint()
      ..color = BeeThemeColors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center + const Offset(-5, -18),
      center + const Offset(-10, -28),
      antennaPaint,
    );
    canvas.drawLine(
      center + const Offset(5, -18),
      center + const Offset(10, -28),
      antennaPaint,
    );

    // Bolitas en antenas
    canvas.drawCircle(center + const Offset(-10, -28), 3, eyePaint);
    canvas.drawCircle(center + const Offset(10, -28), 3, eyePaint);
  }

  @override
  bool shouldRepaint(covariant BeePainter oldDelegate) {
    return oldDelegate.wingAngle != wingAngle;
  }
}

// ============================================
// FONDO DE PANAL
// ============================================

class HoneycombBackground extends StatelessWidget {
  const HoneycombBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hexSize = 40.0;
        final cols = (constraints.maxWidth / (hexSize * 1.5)).ceil() + 1;
        final rows = (constraints.maxHeight / (hexSize * 1.73)).ceil() + 1;

        return Stack(
          children: List.generate(rows * cols, (index) {
            final row = index ~/ cols;
            final col = index % cols;
            final offset = row.isOdd ? hexSize * 0.75 : 0.0;

            return Positioned(
              left: col * hexSize * 1.5 + offset,
              top: row * hexSize * 0.866,
              child: HexagonWidget(
                size: hexSize,
                color: BeeThemeColors.honey.withOpacity(0.08),
                filled: Random().nextDouble() > 0.85,
              ),
            );
          }),
        );
      },
    );
  }
}

// ============================================
// HEXÁGONO
// ============================================

class HexagonWidget extends StatelessWidget {
  final double size;
  final Color color;
  final bool filled;

  const HexagonWidget({
    super.key,
    required this.size,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.866,
      child: CustomPaint(
        painter: HexagonPainter(
          color: color,
          filled: filled,
        ),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color color;
  final bool filled;

  HexagonPainter({required this.color, this.filled = false});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.25, 0);
    path.lineTo(w * 0.75, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.25, h);
    path.lineTo(0, h * 0.5);
    path.close();

    final paint = Paint()
      ..color = filled ? BeeThemeColors.honey.withOpacity(0.3) : color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================
// MODELOS Y WIDGETS ANIMADOS
// ============================================

class FlyingBee {
  final double startX;
  final double startY;
  final int duration;
  final double delay;
  final double size;

  FlyingBee({
    required this.startX,
    required this.startY,
    required this.duration,
    required this.delay,
    required this.size,
  });
}

class HoneyDrop {
  final double x;
  final int duration;
  final double delay;

  HoneyDrop({
    required this.x,
    required this.duration,
    required this.delay,
  });
}

class AnimatedFlyingBee extends StatefulWidget {
  final FlyingBee bee;

  const AnimatedFlyingBee({super.key, required this.bee});

  @override
  State<AnimatedFlyingBee> createState() => _AnimatedFlyingBeeState();
}

class _AnimatedFlyingBeeState extends State<AnimatedFlyingBee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: widget.bee.duration),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: (widget.bee.delay * 1000).toInt()), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        final x = (widget.bee.startX + _controller.value) % 1.0 * screenWidth;
        final y = widget.bee.startY * screenHeight +
            sin(_controller.value * 4 * pi) * 30;

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: 0.6,
            child: Transform.scale(
              scale: widget.bee.size / 30,
              child: const Text('🐝', style: TextStyle(fontSize: 24)),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedHoneyDrop extends StatefulWidget {
  final HoneyDrop drop;

  const AnimatedHoneyDrop({super.key, required this.drop});

  @override
  State<AnimatedHoneyDrop> createState() => _AnimatedHoneyDropState();
}

class _AnimatedHoneyDropState extends State<AnimatedHoneyDrop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: widget.drop.duration),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: (widget.drop.delay * 1000).toInt()), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Positioned(
          left: widget.drop.x * screenWidth,
          top: _controller.value * screenHeight - 50,
          child: Container(
            width: 12,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  BeeThemeColors.honeyLight,
                  BeeThemeColors.honey,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: BeeThemeColors.honey.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

