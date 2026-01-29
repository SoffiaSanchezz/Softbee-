import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final borderPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    // Dibujar hexágono perfecto
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2.1; // Un poco más pequeño para el borde

    final path = Path();

    // Crear los 6 puntos del hexágono
    for (int i = 0; i < 6; i++) {
      final angle = 2 * math.pi * i / 6 - math.pi / 6; // Rotar 30°
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HexagonParticle extends StatelessWidget {
  const HexagonParticle({
    super.key,
    required this.animation,
    required this.delay,
    required this.left,
    required this.top,
    this.color = const Color(0xFFF3F3F3),
    this.size = 40.0, // Aumentado de 24.0 a 40.0
  });

  final Animation<double> animation;
  final double delay;
  final double left;
  final double top;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          double animationValue = animation.value;

          // Aplicar delay
          if (animationValue < delay) {
            return const SizedBox();
          }

          animationValue = (animationValue - delay) / (1.0 - delay);

          // Calcular animación
          double scale = 0.0;
          double opacity = 0.0;

          if (animationValue <= 0.25) {
            // 0-25%: aparecer
            final double progress = animationValue / 0.25;
            scale = Curves.easeOut.transform(progress);
            opacity = Curves.easeOut.transform(progress);
          } else if (animationValue <= 0.65) {
            // 25-65%: visible
            scale = 1.0;
            opacity = 1.0;
          } else if (animationValue <= 1.0) {
            // 65-100%: desaparecer
            final double progress = (animationValue - 0.65) / 0.35;
            scale = 1.0 - Curves.easeIn.transform(progress);
            opacity = 1.0 - Curves.easeIn.transform(progress);
          }

          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale.clamp(0.0, 1.0),
              child: SizedBox(
                width: size,
                height: size,
                child: CustomPaint(painter: HexagonPainter(color)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HoneycombLoader extends StatefulWidget {
  final Color color;
  final double size;

  const HoneycombLoader({
    super.key,
    this.color = const Color(0xFFF3F3F3),
    this.size = 180.0, // Aumentado de 120.0 a 180.0
  });

  @override
  State<HoneycombLoader> createState() => _HoneycombLoaderState();
}

class _HoneycombLoaderState extends State<HoneycombLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tamaño de cada hexágono - AHORA MÁS GRANDES
    final double hexSize = widget.size * 0.22; // 22% del tamaño total
    // Radio para el patrón
    final double radius = widget.size * 0.36;

    // Coordenadas del centro
    final double centerX = widget.size / 2;
    final double centerY = widget.size / 2;

    // Posiciones del patrón de panal (7 hexágonos)
    final List<Offset> positions = [
      // Centro
      Offset(centerX - hexSize / 2, centerY - hexSize / 2),

      // Arriba
      Offset(centerX - hexSize / 2, centerY - hexSize / 2 - radius),

      // Arriba derecha
      Offset(
        centerX - hexSize / 2 + radius * 0.866,
        centerY - hexSize / 2 - radius * 0.5,
      ),

      // Abajo derecha
      Offset(
        centerX - hexSize / 2 + radius * 0.866,
        centerY - hexSize / 2 + radius * 0.5,
      ),

      // Abajo
      Offset(centerX - hexSize / 2, centerY - hexSize / 2 + radius),

      // Abajo izquierda
      Offset(
        centerX - hexSize / 2 - radius * 0.866,
        centerY - hexSize / 2 + radius * 0.5,
      ),

      // Arriba izquierda
      Offset(
        centerX - hexSize / 2 - radius * 0.866,
        centerY - hexSize / 2 - radius * 0.5,
      ),
    ];

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: List.generate(positions.length, (index) {
          return HexagonParticle(
            animation: _controller,
            delay: index * 0.12,
            left: positions[index].dx,
            top: positions[index].dy,
            color: widget.color,
            size: hexSize,
          );
        }),
      ),
    );
  }
}
