import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../model/map/track_point_model.dart';

/// 海拔剖面图组件
class ElevationProfileWidget extends StatefulWidget {
  /// 轨迹点数据
  final List<TrackPointVO> trackPoints;
  
  /// 路线总距离
  final double totalDistance;
  
  /// 累计爬升
  final double elevationGain;
  
  /// 点击回调（返回距离百分比）
  final Function(double percentage)? onTap;

  const ElevationProfileWidget({
    super.key,
    required this.trackPoints,
    required this.totalDistance,
    required this.elevationGain,
    this.onTap,
  });

  @override
  State<ElevationProfileWidget> createState() => _ElevationProfileWidgetState();
}

class _ElevationProfileWidgetState extends State<ElevationProfileWidget> {
  double? _selectedPosition;

  @override
  Widget build(BuildContext context) {
    if (widget.trackPoints.isEmpty) {
      return _buildEmptyState();
    }

    final elevations = widget.trackPoints
        .map((point) => point.elevation ?? 0.0)
        .toList();
    
    final minElevation = elevations.reduce(math.min);
    final maxElevation = elevations.reduce(math.max);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和统计信息
          _buildHeader(minElevation, maxElevation),
          
          const SizedBox(height: 12),
          
          // 海拔剖面图
          SizedBox(
            height: 120,
            child: GestureDetector(
              onTapDown: (details) => _handleTap(details),
              child: CustomPaint(
                painter: ElevationProfilePainter(
                  elevations: elevations,
                  minElevation: minElevation,
                  maxElevation: maxElevation,
                  selectedPosition: _selectedPosition,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 距离标记
          _buildDistanceMarkers(),
        ],
      ),
    );
  }

  /// 构建标题和统计信息
  Widget _buildHeader(double minElevation, double maxElevation) {
    return Row(
      children: [
        const Icon(
          CupertinoIcons.chart_bar,
          size: 20,
          color: CupertinoColors.activeBlue,
        ),
        const SizedBox(width: 8),
        const Text(
          '海拔剖面',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        _buildStatItem('最高', '${maxElevation.toInt()}m'),
        const SizedBox(width: 16),
        _buildStatItem('最低', '${minElevation.toInt()}m'),
        const SizedBox(width: 16),
        _buildStatItem('爬升', '${widget.elevationGain.toInt()}m'),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.activeBlue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  /// 构建距离标记
  Widget _buildDistanceMarkers() {
    final markerCount = (widget.totalDistance / 10).ceil(); // 每10km一个标记
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(markerCount + 1, (index) {
        final distance = index * 10;
        if (distance > widget.totalDistance) {
          return Text(
            '${widget.totalDistance.toStringAsFixed(1)}km',
            style: const TextStyle(
              fontSize: 10,
              color: CupertinoColors.secondaryLabel,
            ),
          );
        }
        return Text(
          '${distance}km',
          style: const TextStyle(
            fontSize: 10,
            color: CupertinoColors.secondaryLabel,
          ),
        );
      }),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_bar,
              size: 32,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: 8),
            Text(
              '暂无海拔数据',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理点击事件
  void _handleTap(TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final percentage = localPosition.dx / renderBox.size.width;
    
    setState(() {
      _selectedPosition = percentage.clamp(0.0, 1.0);
    });
    
    widget.onTap?.call(_selectedPosition!);
  }
}

/// 海拔剖面图绘制器
class ElevationProfilePainter extends CustomPainter {
  final List<double> elevations;
  final double minElevation;
  final double maxElevation;
  final double? selectedPosition;

  ElevationProfilePainter({
    required this.elevations,
    required this.minElevation,
    required this.maxElevation,
    this.selectedPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (elevations.isEmpty) return;

    final paint = Paint()
      ..color = CupertinoColors.activeBlue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = CupertinoColors.activeBlue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // 计算点位置
    final points = <Offset>[];
    for (int i = 0; i < elevations.length; i++) {
      final x = (i / (elevations.length - 1)) * size.width;
      final normalizedElevation = maxElevation > minElevation
          ? (elevations[i] - minElevation) / (maxElevation - minElevation)
          : 0.5;
      final y = size.height - (normalizedElevation * size.height);
      points.add(Offset(x, y));
    }

    // 绘制填充区域
    fillPath.moveTo(0, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // 绘制线条
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // 绘制选中位置
    if (selectedPosition != null) {
      final selectedX = selectedPosition! * size.width;
      final selectedPaint = Paint()
        ..color = CupertinoColors.systemRed
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(selectedX, 0),
        Offset(selectedX, size.height),
        selectedPaint,
      );

      // 绘制选中点
      final selectedIndex = (selectedPosition! * (elevations.length - 1)).round();
      if (selectedIndex < points.length) {
        final selectedPoint = points[selectedIndex];
        final pointPaint = Paint()
          ..color = CupertinoColors.systemRed
          ..style = PaintingStyle.fill;

        canvas.drawCircle(selectedPoint, 4, pointPaint);
      }
    }

    // 绘制网格线
    _drawGrid(canvas, size);
  }

  /// 绘制网格线
  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = CupertinoColors.separator.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // 水平网格线
    for (int i = 1; i < 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // 垂直网格线
    for (int i = 1; i < 5; i++) {
      final x = (i / 5) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ElevationProfilePainter oldDelegate) {
    return oldDelegate.elevations != elevations ||
        oldDelegate.selectedPosition != selectedPosition;
  }
}