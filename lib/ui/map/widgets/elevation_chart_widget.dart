import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/ui/map/elevation_chart_painter.dart';

/// 海拔图表组件
class ElevationChartWidget extends StatelessWidget {
  /// 轨迹点
  final List<TrackPointVO> trackPoints;

  /// 构造函数
  const ElevationChartWidget({
    super.key,
    required this.trackPoints,
  });

  @override
  Widget build(BuildContext context) {
    if (trackPoints.isEmpty) return const SizedBox.shrink();

    // 提取海拔数据
    final elevations = trackPoints.map((p) => p.elevation).toList();
    final maxElevation = elevations.reduce((a, b) => a > b ? a : b);
    final minElevation = elevations.reduce((a, b) => a < b ? a : b);

    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '海拔图表',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                '最高: ${maxElevation.toStringAsFixed(0)}m 最低: ${minElevation.toStringAsFixed(0)}m',
                style: const TextStyle(
                  fontSize: 10,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: ElevationChartPainter(
                elevations: elevations,
                maxElevation: maxElevation,
                minElevation: minElevation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}