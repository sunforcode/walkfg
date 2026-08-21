import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background / decorative
// ─────────────────────────────────────────────────────────────────────────────

class TopoBackground extends StatelessWidget {
  const TopoBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: const RouteSketchPainter(
        strokeColor: Color(0x22FFFFFF),
        backgroundOnly: true,
      ),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.15,
            colors: [Color(0xFF2A4A38), Color(0xFF07130F)],
          ),
        ),
      ),
    );
  }
}

class RouteSketchBox extends StatelessWidget {
  const RouteSketchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF102019).withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(38),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const CustomPaint(
        painter: RouteSketchPainter(
            strokeColor: Color(0xFFB6FF5C), backgroundOnly: false),
        child: SizedBox.expand(),
      ),
    );
  }
}

class RouteSketchPainter extends CustomPainter {
  final Color strokeColor;
  final bool backgroundOnly;

  const RouteSketchPainter({
    required this.strokeColor,
    required this.backgroundOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawContours(canvas, size);
    if (!backgroundOnly) _drawRoute(canvas, size);
  }

  void _drawContours(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          backgroundOnly ? strokeColor : Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 15; i++) {
      final y = size.height * (0.06 + i * 0.075);
      final path = Path()..moveTo(-20, y);
      path.cubicTo(
        size.width * 0.22,
        y - 28 + math.sin(i) * 12,
        size.width * 0.56,
        y + 26 - math.cos(i) * 10,
        size.width + 20,
        y - 8,
      );
      canvas.drawPath(path, paint);
    }
  }

  void _drawRoute(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;
    final routePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    final path = Path()
      ..moveTo(size.width * 0.14, size.height * 0.72)
      ..cubicTo(size.width * 0.27, size.height * 0.22, size.width * 0.47,
          size.height * 0.92, size.width * 0.62, size.height * 0.43)
      ..cubicTo(size.width * 0.72, size.height * 0.12, size.width * 0.83,
          size.height * 0.28, size.width * 0.88, size.height * 0.18);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, routePaint);

    final dotPaint = Paint()..color = const Color(0xFF07130F);
    final rimPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final start = Offset(size.width * 0.14, size.height * 0.72);
    final end = Offset(size.width * 0.88, size.height * 0.18);
    canvas.drawCircle(start, 8, dotPaint);
    canvas.drawCircle(start, 8, rimPaint);
    canvas.drawCircle(end, 8, dotPaint);
    canvas.drawCircle(end, 8, rimPaint);
  }

  @override
  bool shouldRepaint(covariant RouteSketchPainter old) =>
      old.strokeColor != strokeColor || old.backgroundOnly != backgroundOnly;
}
