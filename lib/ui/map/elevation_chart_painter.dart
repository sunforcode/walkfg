import 'package:flutter/material.dart';

/// 海拔图表绘制器
class ElevationChartPainter extends CustomPainter {
  /// 海拔数据
  final List<double> elevations;

  /// 最高海拔
  final double maxElevation;

  /// 最低海拔
  final double minElevation;

  /// 构造函数
  const ElevationChartPainter({
    required this.elevations,
    required this.maxElevation,
    required this.minElevation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (elevations.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.withOpacity(0.5),
          Colors.blue.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // 计算高度范围，确保有一定的边距
    final elevationRange =
        (maxElevation - minElevation).clamp(100.0, double.infinity);
    final normalizedMinElevation = minElevation - elevationRange * 0.1;

    // 绘制路径
    for (int i = 0; i < elevations.length; i++) {
      final x = size.width * i / (elevations.length - 1);
      final normalizedElevation =
          (elevations[i] - normalizedMinElevation) / elevationRange;
      final y = size.height * (1 - normalizedElevation.clamp(0.0, 1.0));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // 完成填充路径
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // 绘制填充
    canvas.drawPath(fillPath, fillPaint);

    // 绘制线条
    canvas.drawPath(path, paint);

    // 绘制水平参考线
    final referencePaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 绘制3条参考线
    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), referencePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ElevationChartPainter oldDelegate) {
    return elevations != oldDelegate.elevations ||
        maxElevation != oldDelegate.maxElevation ||
        minElevation != oldDelegate.minElevation;
  }
}
