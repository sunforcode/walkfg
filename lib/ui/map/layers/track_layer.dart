import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/ui/map/core/map_enum.dart';

/// 轨迹渲染配置
class TrackRenderConfig {
  /// 渲染模式
  final TrackRenderMode renderMode;
  
  /// 线条宽度
  final double strokeWidth;
  
  /// 默认颜色
  final Color defaultColor;
  
  /// 是否显示方向箭头
  final bool showDirectionArrows;
  
  /// 箭头间距（米）
  final double arrowSpacing;
  
  /// 选中分段的线条宽度倍率
  final double selectedStrokeWidthMultiplier;
  
  /// 未选中分段的透明度
  final double unselectedOpacity;

  const TrackRenderConfig({
    this.renderMode = TrackRenderMode.normal,
    this.strokeWidth = 3.0,
    this.defaultColor = Colors.blue,
    this.showDirectionArrows = false,
    this.arrowSpacing = 1000.0,
    this.selectedStrokeWidthMultiplier = 1.5,
    this.unselectedOpacity = 0.5,
  });
}

/// 轨迹图层组件 - 专门负责轨迹线的显示
/// 
/// 职责：
/// 1. 渲染轨迹线
/// 2. 根据不同模式着色（速度、海拔、坡度）
/// 3. 显示方向箭头
/// 4. 处理轨迹点击事件
class TrackLayer extends StatelessWidget {
  /// 轨迹点数据
  final List<TrackPointVO> trackPoints;
  
  /// 渲染配置
  final TrackRenderConfig config;
  
  /// 分段数据
  final List<SegmentModel> segments;
  
  /// 当前选中的分段ID
  final String? selectedSegmentId;
  
  /// 轨迹点击回调
  final void Function(int index, TrackPointVO point)? onTrackPointTap;
  
  /// 分段点击回调
  final void Function(SegmentModel segment)? onSegmentTap;

  const TrackLayer({
    super.key,
    required this.trackPoints,
    this.config = const TrackRenderConfig(),
    this.segments = const <SegmentModel>[],
    this.selectedSegmentId,
    this.onTrackPointTap,
    this.onSegmentTap,
  });

  /// 计算两点之间的距离（米）
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // 地球半径（米）
    final phi1 = lat1 * (pi / 180);
    final phi2 = lat2 * (pi / 180);
    final deltaPhi = (lat2 - lat1) * (pi / 180);
    final deltaLambda = (lon2 - lon1) * (pi / 180);

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// 根据渲染模式获取颜色
  Color _getSegmentColor(TrackPointVO point, TrackPointVO? nextPoint) {
    switch (config.renderMode) {
      case TrackRenderMode.speed:
        return _getSpeedColor(point, nextPoint);
      case TrackRenderMode.elevation:
        return _getElevationColor(point);
      case TrackRenderMode.gradient:
        return _getGradientColor(point, nextPoint);
      case TrackRenderMode.normal:
      default:
        return config.defaultColor;
    }
  }

  /// 根据速度获取颜色
  Color _getSpeedColor(TrackPointVO point, TrackPointVO? nextPoint) {
    if (nextPoint == null ||
        point.timestamp == null ||
        nextPoint.timestamp == null) {
      return config.defaultColor;
    }

    final distance = _calculateDistance(
      point.latitude,
      point.longitude,
      nextPoint.latitude,
      nextPoint.longitude,
    );

    final duration = nextPoint.timestamp!.difference(point.timestamp!).inSeconds;
    if (duration <= 0) return config.defaultColor;

    final speed = distance / duration; // 米/秒

    // 速度范围：0-5 m/s
    if (speed < 1.0) return Colors.blue;
    if (speed < 2.0) return Colors.green;
    if (speed < 3.0) return Colors.yellow;
    if (speed < 4.0) return Colors.orange;
    return Colors.red;
  }

  /// 根据海拔获取颜色
  Color _getElevationColor(TrackPointVO point) {
    // 假设海拔范围：0-5000米
    final normalizedElevation = (point.elevation / 5000.0).clamp(0.0, 1.0);

    if (normalizedElevation < 0.2) return Colors.blue;
    if (normalizedElevation < 0.4) return Colors.green;
    if (normalizedElevation < 0.6) return Colors.yellow;
    if (normalizedElevation < 0.8) return Colors.orange;
    return Colors.red;
  }

  /// 根据坡度获取颜色
  Color _getGradientColor(TrackPointVO point, TrackPointVO? nextPoint) {
    if (nextPoint == null) return config.defaultColor;

    final distance = _calculateDistance(
      point.latitude,
      point.longitude,
      nextPoint.latitude,
      nextPoint.longitude,
    );

    if (distance <= 0) return config.defaultColor;

    final elevationDiff = nextPoint.elevation - point.elevation;
    final gradient = elevationDiff / distance * 100; // 坡度百分比

    // 坡度范围：-30% 到 30%
    if (gradient < -15) return Colors.red;
    if (gradient < -5) return Colors.orange;
    if (gradient < 5) return Colors.green;
    if (gradient < 15) return Colors.orange;
    return Colors.red;
  }

  /// 解析颜色字符串（如 #FF5722）
  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;
    try {
      final hexStr = colorStr.replaceAll('#', '');
      if (hexStr.length == 6) {
        return Color(int.parse('FF$hexStr', radix: 16));
      } else if (hexStr.length == 8) {
        return Color(int.parse(hexStr, radix: 16));
      }
    } catch (e) {
      print('TrackLayer: 解析颜色失败: $e');
    }
    return null;
  }

  /// 根据索引获取对应的分段
  SegmentModel? _getSegmentForIndex(int index) {
    for (final segment in segments) {
      final start = segment.trackStartIndex ?? 0;
      final end = segment.trackEndIndex ?? trackPoints.length - 1;
      if (index >= start && index <= end) {
        return segment;
      }
    }
    return null;
  }

  /// 构建轨迹线
  List<Polyline> _buildPolylines() {
    if (trackPoints.length < 2) return [];

    final polylines = <Polyline>[];

    // 如果有分段数据，按分段渲染
    if (segments.isNotEmpty && config.renderMode == TrackRenderMode.normal) {
      return _buildPolylinesWithSegments();
    }

    // 原有逻辑
    // 根据渲染模式决定是否分段
    if (config.renderMode == TrackRenderMode.normal) {
      // 普通模式：单条线
      polylines.add(
        Polyline(
          points: trackPoints
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
          strokeWidth: config.strokeWidth,
          color: config.defaultColor,
        ),
      );
    } else {
      // 其他模式：分段着色
      for (int i = 0; i < trackPoints.length - 1; i++) {
        final current = trackPoints[i];
        final next = trackPoints[i + 1];

        polylines.add(
          Polyline(
            points: [
              LatLng(current.latitude, current.longitude),
              LatLng(next.latitude, next.longitude),
            ],
            strokeWidth: config.strokeWidth,
            color: _getSegmentColor(current, next),
          ),
        );
      }
    }

    return polylines;
  }

  /// 按分段构建轨迹线
  List<Polyline> _buildPolylinesWithSegments() {
    final polylines = <Polyline>[];

    // 按顺序处理每个分段
    for (final segment in segments) {
      final start = segment.trackStartIndex ?? 0;
      final end = segment.trackEndIndex ?? trackPoints.length - 1;

      // 确保索引有效
      if (start < 0 || end >= trackPoints.length || start >= end) {
        print('TrackLayer: 分段 ${segment.name} 索引无效: $start-$end');
        continue;
      }

      // 获取分段的点（包含end）
      final segmentPoints = trackPoints.sublist(start, end + 1);

      // 判断是否选中
      final isSelected = selectedSegmentId == segment.id;

      // 获取颜色
      Color color = _parseColor(segment.color) ?? config.defaultColor;

      // 未选中的分段降低透明度
      if (!isSelected && selectedSegmentId != null) {
        color = color.withOpacity(config.unselectedOpacity);
      }

      // 选中的分段增加宽度
      final strokeWidth = isSelected
          ? config.strokeWidth * config.selectedStrokeWidthMultiplier
          : config.strokeWidth;

      // 创建折线
      polylines.add(
        Polyline(
          points: segmentPoints
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
          strokeWidth: strokeWidth,
          color: color,
        ),
      );
    }

    return polylines;
  }

  /// 构建方向箭头
  List<Marker> _buildDirectionArrows() {
    if (!config.showDirectionArrows || trackPoints.length < 2) {
      return [];
    }

    final arrows = <Marker>[];
    double accumulatedDistance = 0.0;
    double nextArrowDistance = config.arrowSpacing;

    for (int i = 1; i < trackPoints.length; i++) {
      final prev = trackPoints[i - 1];
      final current = trackPoints[i];

      final segmentDistance = _calculateDistance(
        prev.latitude,
        prev.longitude,
        current.latitude,
        current.longitude,
      );

      accumulatedDistance += segmentDistance;

      // 如果累计距离达到箭头间距，添加箭头
      if (accumulatedDistance >= nextArrowDistance) {
        // 计算方向角度
        final bearing = _calculateBearing(
          prev.latitude,
          prev.longitude,
          current.latitude,
          current.longitude,
        );

        arrows.add(
          Marker(
            point: LatLng(current.latitude, current.longitude),
            width: 20,
            height: 20,
            child: Transform.rotate(
              angle: bearing * pi / 180,
              child: Icon(
                Icons.arrow_upward,
                color: config.defaultColor,
                size: 16,
              ),
            ),
          ),
        );

        nextArrowDistance += config.arrowSpacing;
      }
    }

    return arrows;
  }

  /// 计算方位角
  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final phi1 = lat1 * (pi / 180);
    final phi2 = lat2 * (pi / 180);
    final deltaLon = (lon2 - lon1) * (pi / 180);

    final y = sin(deltaLon) * cos(phi2);
    final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLon);

    final bearing = atan2(y, x) * (180 / pi);
    return (bearing + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    if (trackPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // 轨迹线层
        PolylineLayer(
          polylines: _buildPolylines(),
        ),
        
        // 方向箭头层
        if (config.showDirectionArrows)
          MarkerLayer(
            markers: _buildDirectionArrows(),
          ),
      ],
    );
  }
}