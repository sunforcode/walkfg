import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/map/track_point_model.dart';

/// 海拔图表配置
class ElevationChartConfig {
  /// 图表高度
  final double height;

  /// 线条颜色
  final Color lineColor;

  /// 填充颜色
  final List<Color> fillColors;

  /// 选中点颜色
  final Color selectedPointColor;

  /// 网格线颜色
  final Color gridColor;

  /// 文字颜色
  final Color textColor;

  /// 是否显示网格
  final bool showGrid;

  /// 是否显示标签
  final bool showLabels;

  /// 是否启用交互
  final bool enableInteraction;

  /// 线条宽度
  final double strokeWidth;

  const ElevationChartConfig({
    this.height = 120.0,
    this.lineColor = const Color(0xFF2196F3),
    this.fillColors = const [
      Color(0x802196F3),
      Color(0x202196F3),
    ],
    this.selectedPointColor = const Color(0xFFFF9800),
    this.gridColor = const Color(0x40000000),
    this.textColor = const Color(0xFF666666),
    this.showGrid = true,
    this.showLabels = true,
    this.enableInteraction = true,
    this.strokeWidth = 2.0,
  });
}

/// 海拔图表事件
class ElevationChartEvents {
  /// 点选择事件
  final void Function(int index, TrackPointVO point)? onPointSelected;

  /// 滑动事件
  final void Function(double progress)? onProgressChanged;

  const ElevationChartEvents({
    this.onPointSelected,
    this.onProgressChanged,
  });
}

/// 增强的海拔图表组件
class ElevationChartWidget extends StatefulWidget {
  /// 轨迹点数据
  final List<TrackPointVO> trackPoints;

  /// 图表配置
  final ElevationChartConfig config;

  /// 事件回调
  final ElevationChartEvents events;

  /// 当前选中的点索引
  final int? selectedIndex;

  const ElevationChartWidget({
    super.key,
    required this.trackPoints,
    this.config = const ElevationChartConfig(),
    this.events = const ElevationChartEvents(),
    this.selectedIndex,
  });

  @override
  State<ElevationChartWidget> createState() => _ElevationChartWidgetState();
}

class _ElevationChartWidgetState extends State<ElevationChartWidget> {
  int? _selectedIndex;
  double? _totalDistance;
  double? _maxElevation;
  double? _minElevation;
  double? _elevationGain;
  double? _elevationLoss;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _calculateStatistics();
  }

  @override
  void didUpdateWidget(ElevationChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trackPoints != oldWidget.trackPoints) {
      _calculateStatistics();
    }
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  /// 计算统计数据
  void _calculateStatistics() {
    if (widget.trackPoints.isEmpty) return;

    final elevations = widget.trackPoints.map((p) => p.elevation).toList();
    _maxElevation = elevations.reduce(max);
    _minElevation = elevations.reduce(min);

    // 计算总距离
    _totalDistance = 0.0;
    for (int i = 1; i < widget.trackPoints.length; i++) {
      _totalDistance = _totalDistance! +
          _calculateDistance(
            widget.trackPoints[i - 1],
            widget.trackPoints[i],
          );
    }

    // 计算累计爬升和下降
    _elevationGain = 0.0;
    _elevationLoss = 0.0;
    for (int i = 1; i < widget.trackPoints.length; i++) {
      final diff =
          widget.trackPoints[i].elevation - widget.trackPoints[i - 1].elevation;
      if (diff > 0) {
        _elevationGain = _elevationGain! + diff;
      } else {
        _elevationLoss = _elevationLoss! + diff.abs();
      }
    }
  }

  /// 计算两点间距离
  double _calculateDistance(TrackPointVO p1, TrackPointVO p2) {
    const R = 6371000.0; // 地球半径（米）
    final phi1 = p1.latitude * (pi / 180);
    final phi2 = p2.latitude * (pi / 180);
    final deltaPhi = (p2.latitude - p1.latitude) * (pi / 180);
    final deltaLambda = (p2.longitude - p1.longitude) * (pi / 180);

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// 处理点击事件
  void _handleTap(TapDownDetails details) {
    if (!widget.config.enableInteraction || widget.trackPoints.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    // 计算点击位置对应的索引
    final chartWidth = renderBox.size.width - 32; // 减去左右边距
    final relativeX = (localPosition.dx - 16) / chartWidth; // 减去左边距

    if (relativeX >= 0 && relativeX <= 1) {
      final index = (relativeX * (widget.trackPoints.length - 1)).round();
      if (index >= 0 && index < widget.trackPoints.length) {
        setState(() {
          _selectedIndex = index;
        });

        widget.events.onPointSelected?.call(index, widget.trackPoints[index]);
        widget.events.onProgressChanged?.call(relativeX);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trackPoints.isEmpty) {
      return SizedBox(
        height: widget.config.height,
        child: const Center(
          child: Text('暂无海拔数据'),
        ),
      );
    }

    return Container(
      height: widget.config.height + 60, // 额外空间用于标签
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题和统计信息
          if (widget.config.showLabels) _buildHeader(),

          // 图表主体
          Expanded(
            child: GestureDetector(
              onTapDown: _handleTap,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: EnhancedElevationChartPainter(
                    trackPoints: widget.trackPoints,
                    config: widget.config,
                    selectedIndex: _selectedIndex,
                    maxElevation: _maxElevation!,
                    minElevation: _minElevation!,
                  ),
                ),
              ),
            ),
          ),

          // 底部信息
          if (widget.config.showLabels) _buildFooter(),
        ],
      ),
    );
  }

  /// 构建标题
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '海拔图表',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_selectedIndex != null)
            Text(
              '海拔: ${widget.trackPoints[_selectedIndex!].elevation.toStringAsFixed(1)}m',
              style: TextStyle(
                fontSize: 14,
                color: widget.config.textColor,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建底部信息
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              '距离', '${(_totalDistance! / 1000).toStringAsFixed(1)}km'),
          _buildStatItem('最高', '${_maxElevation!.toStringAsFixed(0)}m'),
          _buildStatItem('最低', '${_minElevation!.toStringAsFixed(0)}m'),
          _buildStatItem('爬升', '${_elevationGain!.toStringAsFixed(0)}m'),
          _buildStatItem('下降', '${_elevationLoss!.toStringAsFixed(0)}m'),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: widget.config.textColor,
          ),
        ),
      ],
    );
  }
}

/// 增强的海拔图表绘制器
class EnhancedElevationChartPainter extends CustomPainter {
  final List<TrackPointVO> trackPoints;
  final ElevationChartConfig config;
  final int? selectedIndex;
  final double maxElevation;
  final double minElevation;

  const EnhancedElevationChartPainter({
    required this.trackPoints,
    required this.config,
    this.selectedIndex,
    required this.maxElevation,
    required this.minElevation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trackPoints.isEmpty) return;

    // 计算高度范围，确保有一定的边距
    final elevationRange =
        (maxElevation - minElevation).clamp(50.0, double.infinity);
    final paddedMinElevation = minElevation - elevationRange * 0.1;
    final paddedMaxElevation = maxElevation + elevationRange * 0.1;
    final paddedRange = paddedMaxElevation - paddedMinElevation;

    // 绘制网格
    if (config.showGrid) {
      _drawGrid(canvas, size);
    }

    // 绘制海拔曲线
    _drawElevationCurve(canvas, size, paddedMinElevation, paddedRange);

    // 绘制选中点
    if (selectedIndex != null && selectedIndex! < trackPoints.length) {
      _drawSelectedPoint(canvas, size, paddedMinElevation, paddedRange);
    }
  }

  /// 绘制网格
  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = config.gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 水平网格线
    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // 垂直网格线
    for (int i = 1; i <= 4; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  /// 绘制海拔曲线
  void _drawElevationCurve(
      Canvas canvas, Size size, double minElev, double range) {
    final linePaint = Paint()
      ..color = config.lineColor
      ..strokeWidth = config.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: config.fillColors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // 构建路径
    for (int i = 0; i < trackPoints.length; i++) {
      final x = size.width * i / (trackPoints.length - 1);
      final normalizedElevation = (trackPoints[i].elevation - minElev) / range;
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

    // 绘制填充和线条
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  /// 绘制选中点
  void _drawSelectedPoint(
      Canvas canvas, Size size, double minElev, double range) {
    final selectedPaint = Paint()
      ..color = config.selectedPointColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final x = size.width * selectedIndex! / (trackPoints.length - 1);
    final normalizedElevation =
        (trackPoints[selectedIndex!].elevation - minElev) / range;
    final y = size.height * (1 - normalizedElevation.clamp(0.0, 1.0));

    // 绘制选中点
    canvas.drawCircle(Offset(x, y), 6, selectedPaint);
    canvas.drawCircle(Offset(x, y), 6, borderPaint);

    // 绘制垂直指示线
    final linePaint = Paint()
      ..color = config.selectedPointColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant EnhancedElevationChartPainter oldDelegate) {
    return trackPoints != oldDelegate.trackPoints ||
        selectedIndex != oldDelegate.selectedIndex ||
        config != oldDelegate.config;
  }
}
