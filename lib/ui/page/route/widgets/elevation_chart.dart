import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/map/track_point_model.dart';

/// 高程图组件
class ElevationChart extends StatelessWidget {
  /// 轨迹点列表
  final List<TrackPointVO> trackPoints;

  /// 最高点海拔
  final int highestPoint;

  /// 最低点海拔
  final int lowestPoint;

  /// 图表高度
  final double height;

  /// 图表宽度
  final double? width;

  /// 图表颜色
  final Color color;

  /// 图表填充颜色
  final Color fillColor;

  /// 构造函数
  const ElevationChart({
    super.key,
    required this.trackPoints,
    required this.highestPoint,
    required this.lowestPoint,
    this.height = 100,
    this.width,
    this.color = Colors.blue,
    this.fillColor = Colors.lightBlue,
  });

  @override
  Widget build(BuildContext context) {
    if (trackPoints.isEmpty) {
      return const Center(
        child: Text('暂无高程数据'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '高程图',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),
            Row(
              children: [
                Text(
                  '最高: ${highestPoint}m',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '最低: ${lowestPoint}m',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          width: width ?? double.infinity,
          child: CustomPaint(
            painter: _ElevationChartPainter(
              trackPoints: trackPoints,
              highestPoint: highestPoint,
              lowestPoint: lowestPoint,
              lineColor: color,
              fillColor: fillColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '起点',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),
            Text(
              '总距离: ${trackPoints.isNotEmpty ? (trackPoints.length / 1000).toStringAsFixed(1) : 0}km',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),
            Text(
              '终点',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 高程图绘制器
class _ElevationChartPainter extends CustomPainter {
  /// 轨迹点列表
  final List<TrackPointVO> trackPoints;

  /// 最高点海拔
  final int highestPoint;

  /// 最低点海拔
  final int lowestPoint;

  /// 线条颜色
  final Color lineColor;

  /// 填充颜色
  final Color fillColor;

  /// 构造函数
  _ElevationChartPainter({
    required this.trackPoints,
    required this.highestPoint,
    required this.lowestPoint,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trackPoints.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = fillColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // 计算高度范围，确保有一定的边距
    final elevationRange = (highestPoint - lowestPoint).toDouble();
    final minElevation = lowestPoint - (elevationRange * 0.1);
    final maxElevation = highestPoint + (elevationRange * 0.1);

    // 采样轨迹点，避免绘制过多点导致性能问题
    final sampleRate = (trackPoints.length / 100).ceil();
    final sampledPoints = <TrackPointVO>[];

    for (int i = 0; i < trackPoints.length; i += sampleRate) {
      sampledPoints.add(trackPoints[i]);
    }

    // 确保包含最后一个点
    if (sampledPoints.isEmpty || sampledPoints.last != trackPoints.last) {
      sampledPoints.add(trackPoints.last);
    }

    // 绘制路径
    for (int i = 0; i < sampledPoints.length; i++) {
      final point = sampledPoints[i];
      final x = size.width * i / (sampledPoints.length - 1);
      final y = size.height -
          (point.elevation - minElevation) /
              (maxElevation - minElevation) *
              size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // 完成填充路径
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // 绘制填充
    canvas.drawPath(fillPath, fillPaint);

    // 绘制线条
    canvas.drawPath(path, paint);

    // 绘制关键点
    final keyPointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // 绘制最高点和最低点
    int highestIndex = 0;
    int lowestIndex = 0;

    for (int i = 0; i < trackPoints.length; i++) {
      if ((trackPoints[i].elevation ?? 0) >= (trackPoints[highestIndex].elevation ?? 0)) {
        highestIndex = i;
      }
      if (trackPoints[i].elevation <= trackPoints[lowestIndex].elevation) {
        lowestIndex = i;
      }
    }

    // 绘制最高点标记
    final highestX = size.width * highestIndex / (trackPoints.length - 1);
    final highestY = size.height -
        (trackPoints[highestIndex].elevation - minElevation) /
            (maxElevation - minElevation) *
            size.height;
    canvas.drawCircle(Offset(highestX, highestY), 4, keyPointPaint);

    // 绘制最低点标记
    final lowestX = size.width * lowestIndex / (trackPoints.length - 1);
    final lowestY = size.height -
        (trackPoints[lowestIndex].elevation - minElevation) /
            (maxElevation - minElevation) *
            size.height;
    canvas.drawCircle(
        Offset(lowestX, lowestY), 4, keyPointPaint..color = Colors.blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
